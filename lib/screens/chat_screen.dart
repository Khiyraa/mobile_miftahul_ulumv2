import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/models/chat_message_model.dart';
import 'package:mobile_miftahul_ulumv2/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessageModel> _messages = [];
  bool _isLoading = true;
  bool _isConnected = false;

  // Sesi
  String _parentId   = '';
  String _parentName = '';
  String _authToken  = '';

  // WebSocket Reverb (protokol Pusher)
  WebSocketChannel? _ws;
  StreamSubscription? _wsSub;
  String? _socketId;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _disposed = false;

  String get _channelName => 'private-chat.$_parentId';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _parentId   = prefs.getString('parentId')   ?? '1';
    _parentName = prefs.getString('parentName') ?? 'Wali Santri';
    _authToken  = prefs.getString('authToken')  ?? 'dummy-token-$_parentId';

    await _loadMessages();
    _connectReverb();
  }

  // ─── Load riwayat chat ───────────────────────────────────────────────
  Future<void> _loadMessages() async {
    final msgs = await ApiService().getChatHistory(_parentId);
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(msgs);
      _isLoading = false;
    });
    _scrollToBottom();
  }

  // ─── WebSocket: connect, subscribe, listen ───────────────────────────
  void _connectReverb() {
    if (_disposed || _parentId.isEmpty) return;

    final scheme = kReverbUseTls ? 'wss' : 'ws';
    final url = Uri.parse(
      '$scheme://${getReverbHost()}:$kReverbWsPort/app/$kReverbAppKey'
      '?protocol=7&client=flutter&version=1.0.0&flash=false',
    );

    debugPrint('[Reverb] Connecting → $url');

    try {
      _ws = WebSocketChannel.connect(url);
    } catch (e) {
      debugPrint('[Reverb] Connect error: $e');
      _scheduleReconnect();
      return;
    }

    _wsSub = _ws!.stream.listen(
      _onMessage,
      onError: (err) {
        debugPrint('[Reverb] Stream error: $err');
        _onDisconnect();
      },
      onDone: () {
        debugPrint('[Reverb] Connection closed');
        _onDisconnect();
      },
      cancelOnError: true,
    );
  }

  void _onMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final event = msg['event'] as String? ?? '';
      final dataRaw = msg['data'];
      // Pusher membungkus 'data' sebagai string JSON
      final data = dataRaw is String && dataRaw.isNotEmpty
          ? jsonDecode(dataRaw) as Map<String, dynamic>
          : (dataRaw is Map<String, dynamic> ? dataRaw : <String, dynamic>{});

      switch (event) {
        case 'pusher:connection_established':
          _socketId = data['socket_id'] as String?;
          debugPrint('[Reverb] Connected, socket_id=$_socketId');
          if (mounted) setState(() => _isConnected = true);
          _subscribeChannel();
          _startPing();
          break;

        case 'pusher_internal:subscription_succeeded':
          debugPrint('[Reverb] Subscribed to ${msg['channel']}');
          break;

        case 'pusher:ping':
          _send({'event': 'pusher:pong', 'data': {}});
          break;

        case 'pusher:pong':
          break;

        case 'pusher:error':
          debugPrint('[Reverb] Pusher error: $data');
          break;

        case 'MessageSent':
          _handleNewMessage(data);
          break;

        default:
          if (event.startsWith('pusher')) {
            debugPrint('[Reverb] Internal: $event');
          }
      }
    } catch (e) {
      debugPrint('[Reverb] Parse error: $e | raw=$raw');
    }
  }

  /// Subscribe ke private channel — perlu auth signature dari endpoint backend
  Future<void> _subscribeChannel() async {
    if (_socketId == null) return;
    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/broadcasting/auth'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'channel_name': _channelName,
          'socket_id': _socketId!,
        },
      );

      if (response.statusCode != 200) {
        debugPrint('[Reverb Auth] Gagal: ${response.statusCode} ${response.body}');
        return;
      }

      final auth = (jsonDecode(response.body) as Map<String, dynamic>)['auth'] as String?;
      if (auth == null) return;

      _send({
        'event': 'pusher:subscribe',
        'data': {
          'channel': _channelName,
          'auth': auth,
        },
      });
    } catch (e) {
      debugPrint('[Reverb Auth] Error: $e');
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    final isFromAdmin = data['is_from_admin'] as bool? ?? true;
    // Mobile hanya menambahkan pesan dari admin via WebSocket
    // (pesan wali sudah ditambah optimistis saat kirim)
    if (!isFromAdmin) return;

    final msg = ChatMessageModel(
      id:        (data['id'] ?? '').toString(),
      sender:    'Admin Pesantren',
      text:      data['pesan'] as String? ?? '',
      timestamp: DateTime.now(),
      isMe:      false,
    );
    if (!mounted) return;
    setState(() => _messages.add(msg));
    _scrollToBottom();
  }

  void _send(Map<String, dynamic> payload) {
    try {
      _ws?.sink.add(jsonEncode(payload));
    } catch (e) {
      debugPrint('[Reverb] Send error: $e');
    }
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _send({'event': 'pusher:ping', 'data': {}});
    });
  }

  void _onDisconnect() {
    _pingTimer?.cancel();
    if (mounted) setState(() => _isConnected = false);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_disposed) _connectReverb();
    });
  }

  // ─── Kirim pesan ─────────────────────────────────────────────────────
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _parentId.isEmpty) return;

    _messageController.clear();

    final optimistic = ChatMessageModel(
      id:        'temp_${DateTime.now().millisecondsSinceEpoch}',
      sender:    _parentName,
      text:      text,
      timestamp: DateTime.now(),
      isMe:      true,
    );
    setState(() => _messages.add(optimistic));
    _scrollToBottom();

    final success = await ApiService().sendMessage(_parentId, text);

    if (!success && mounted) {
      setState(() => _messages.remove(optimistic));
      _messageController.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim pesan. Periksa koneksi internet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Utilities ────────────────────────────────────────────────────────
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  void dispose() {
    _disposed = true;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _wsSub?.cancel();
    _ws?.sink.close(ws_status.normalClosure);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ═════════════════════════════ BUILD ═════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          color: AppTheme.surface.withValues(alpha: 0.95),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Admin Pesantren',
                          style: AppTheme.headline.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: 7, height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isConnected ? const Color(0xFF22c55e) : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isConnected ? 'Online · Real-time' : 'Menghubungkan…',
                              style: AppTheme.label.copyWith(
                                fontSize: 11,
                                color: _isConnected
                                    ? const Color(0xFF16a34a)
                                    : AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary, size: 20),
                    onPressed: _isLoading ? null : _loadMessages,
                    tooltip: 'Muat ulang',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_messages.isEmpty) return _buildEmptyState();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildDateChip(
            _messages.isNotEmpty
                ? _formatDate(_messages.first.timestamp)
                : _formatDate(DateTime.now()),
          );
        }
        return _buildBubble(_messages[index - 1]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.chat_bubble_outline, color: AppTheme.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Belum ada pesan',
                style: AppTheme.headline.copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Mulai percakapan dengan admin pesantren',
              textAlign: TextAlign.center,
              style: AppTheme.body.copyWith(fontSize: 13, color: AppTheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(String label) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTheme.label.copyWith(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceVariant, letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(ChatMessageModel msg) {
    final isMine = msg.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
          child: Column(
            crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 2, right: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: isMine
                      ? [
                          Text(_formatTime(msg.timestamp),
                              style: AppTheme.label.copyWith(fontSize: 10, color: AppTheme.onSurfaceVariant)),
                          const SizedBox(width: 5),
                          Text(_parentName.isNotEmpty ? _parentName : 'Saya',
                              style: AppTheme.label.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.onSurface)),
                        ]
                      : [
                          Text(msg.sender,
                              style: AppTheme.label.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                          const SizedBox(width: 5),
                          Text(_formatTime(msg.timestamp),
                              style: AppTheme.label.copyWith(fontSize: 10, color: AppTheme.onSurfaceVariant)),
                        ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMine ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft:     const Radius.circular(18),
                    topRight:    const Radius.circular(18),
                    bottomLeft:  Radius.circular(isMine ? 18 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: AppTheme.body.copyWith(
                    color: isMine ? Colors.white : AppTheme.onSurface,
                    fontSize: 14, height: 1.5,
                  ),
                ),
              ),
              if (isMine) ...[
                const SizedBox(height: 2),
                const Icon(Icons.done_all_rounded, size: 13, color: AppTheme.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 12, right: 12, top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.25))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12, offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan…',
                  hintStyle: AppTheme.body.copyWith(color: AppTheme.onSurfaceVariant, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: InputBorder.none,
                ),
                style: AppTheme.body.copyWith(fontSize: 14),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8, offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
