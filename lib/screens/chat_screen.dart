import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/models/chat_message_model.dart';
import 'package:mobile_miftahul_ulumv2/services/api_service.dart';
import 'package:mobile_miftahul_ulumv2/services/reverb_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessageModel> _messages = [];
  bool _isLoading = true;
  bool _isConnected = false;

  String _parentId = '';
  String _parentName = '';

  StreamSubscription<ReverbEvent>? _reverbSub;
  Timer? _pollingTimer;
  Timer? _statusTimer;
  String? _lastMessageId;

  String get _channelName => 'private-chat.$_parentId';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Muat ulang pesan saat app kembali aktif dari background
      _loadMessages();
    }
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _parentId = prefs.getString('parentId') ?? '1';
    _parentName = prefs.getString('parentName') ?? 'Wali Santri';

    // Subscribe dulu sebelum load pesan
    _setupReverbListener();

    // Baru load pesan
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    final msgs = await ApiService().getChatHistory(_parentId);
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(msgs);
      _isLoading = false;
      if (msgs.isNotEmpty) _lastMessageId = msgs.last.id;
    });
    _scrollToBottom();
  }

  void _setupReverbListener() {
    ReverbService().subscribe(_channelName);
    _isConnected = ReverbService().isConnected;

    _reverbSub = ReverbService().events.listen((evt) {
      if (!mounted) return;

      if (evt.channel == _channelName && evt.event == 'MessageSent') {
        // is_from_admin bisa datang sebagai bool true/false atau int 1/0 dari PHP
        final raw = evt.data['is_from_admin'];
        final isFromAdmin = raw == true || raw == 1;
        if (!isFromAdmin) return; // Pesan sendiri sudah ditambah optimistis

        final newId = evt.data['id']?.toString() ?? '';
        if (_messages.any((m) => m.id == newId)) return; // Hindari duplikat

        final msg = ChatMessageModel(
          id: newId,
          sender: 'Pengurus Pesantren',
          text: evt.data['pesan'] as String? ?? '',
          timestamp:
              DateTime.tryParse(
                evt.data['created_at'] as String? ?? '',
              )?.toLocal() ??
              DateTime.now(),
          isMe: false,
        );
        setState(() {
          _messages.add(msg);
          _lastMessageId = newId;
        });
        _scrollToBottom();
      }
    });

    // Cek status koneksi setiap 2 detik dan re-subscribe jika baru konek
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      final connected = ReverbService().isConnected;
      if (connected != _isConnected) {
        setState(() => _isConnected = connected);
        if (connected) ReverbService().subscribe(_channelName);
      }
    });
  }

  // Polling ringan setiap 30 detik sebagai safety net jika WebSocket terputus
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted) return;

      final msgs = await ApiService().getChatHistory(_parentId);
      if (!mounted || msgs.isEmpty) return;

      final latestId = msgs.last.id;
      if (latestId == _lastMessageId) return; // Tidak ada pesan baru

      // Append-only: tambahkan pesan yang belum ada (hindari hapus pesan optimistis)
      final existingIds = _messages.map((m) => m.id).toSet();
      final incoming = msgs.where((m) => !existingIds.contains(m.id)).toList();

      if (incoming.isNotEmpty) {
        setState(() {
          _messages.addAll(incoming);
        });
        _scrollToBottom();
      }
      _lastMessageId = latestId;
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _parentId.isEmpty) return;

    _messageController.clear();

    final optimistic = ChatMessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      sender: _parentName,
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
    );
    setState(() => _messages.add(optimistic));
    _scrollToBottom();

    final success = await ApiService().sendMessage(_parentId, text);

    if (!mounted) return;
    if (success) {
      // Ganti optimistic message (temp ID) dengan data asli dari server
      await _loadMessages();
    } else {
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

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reverbSub?.cancel();
    _pollingTimer?.cancel();
    _statusTimer?.cancel();
    ReverbService().unsubscribe(_channelName);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pengurus Pesantren',
                          style: AppTheme.headline.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isConnected
                                    ? const Color(0xFF22c55e)
                                    : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isConnected
                                  ? 'Terhubung · Waktu Nyata'
                                  : 'Mode Biasa · Periksa setiap 10 detik',
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
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesan',
              style: AppTheme.headline.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Mulai percakapan dengan pengurus pesantren',
              textAlign: TextAlign.center,
              style: AppTheme.body.copyWith(
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
              ),
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
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceVariant,
            letterSpacing: 0.4,
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
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.76,
          ),
          child: Column(
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 2, right: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: isMine
                      ? [
                          Text(
                            _formatTime(msg.timestamp),
                            style: AppTheme.label.copyWith(
                              fontSize: 10,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _parentName.isNotEmpty ? _parentName : 'Saya',
                            style: AppTheme.label.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ]
                      : [
                          Text(
                            msg.sender,
                            style: AppTheme.label.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatTime(msg.timestamp),
                            style: AppTheme.label.copyWith(
                              fontSize: 10,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMine ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMine ? 18 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: AppTheme.body.copyWith(
                    color: isMine ? Colors.white : AppTheme.onSurface,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              if (isMine) ...[
                const SizedBox(height: 2),
                const Icon(
                  Icons.done_all_rounded,
                  size: 13,
                  color: AppTheme.primary,
                ),
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
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
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
                border: Border.all(
                  color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan…',
                  hintStyle: AppTheme.body.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
