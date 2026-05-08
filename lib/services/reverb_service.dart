import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_miftahul_ulumv2/services/api_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

/// Event yang diterima dari WebSocket Reverb
class ReverbEvent {
  final String channel;
  final String event;
  final Map<String, dynamic> data;

  const ReverbEvent({
    required this.channel,
    required this.event,
    required this.data,
  });
}

/// Service WebSocket terpusat (singleton).
/// Satu koneksi WebSocket, multi-channel (public & private).
/// Setiap screen subscribe lewat [events] stream + panggil [subscribe].
class ReverbService {
  static final ReverbService _instance = ReverbService._internal();
  factory ReverbService() => _instance;
  ReverbService._internal();

  WebSocketChannel? _ws;
  StreamSubscription? _wsSub;
  String? _socketId;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _disposed = false;
  bool _connected = false;
  String _authToken = '';

  // Channel yang sudah subscribed
  final Set<String> _subscribedChannels = {};
  // Channel yang ingin di-subscribe begitu connection ready
  final Set<String> _pendingChannels = {};

  // Stream untuk semua event aplikasi (custom, non-internal)
  final StreamController<ReverbEvent> _eventController =
      StreamController<ReverbEvent>.broadcast();

  /// Stream semua event masuk
  Stream<ReverbEvent> get events => _eventController.stream;

  /// Status koneksi
  bool get isConnected => _connected;
  String? get socketId => _socketId;

  /// Mulai koneksi. Aman dipanggil berulang — kalau sudah konek, no-op.
  void connect({required String authToken}) {
    if (_ws != null && !_disposed) return; // sudah konek/connecting
    _authToken = authToken;
    _disposed = false;
    _connectInternal();
  }

  void _connectInternal() {
    if (_disposed) return;

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
      final channel = msg['channel'] as String? ?? '';
      final dataRaw = msg['data'];
      final data = dataRaw is String && dataRaw.isNotEmpty
          ? jsonDecode(dataRaw) as Map<String, dynamic>
          : (dataRaw is Map<String, dynamic> ? dataRaw : <String, dynamic>{});

      switch (event) {
        case 'pusher:connection_established':
          _socketId = data['socket_id'] as String?;
          _connected = true;
          debugPrint('[Reverb] Connected, socket_id=$_socketId');
          _startPing();
          // Subscribe semua channel yang pending
          final toSubscribe = List<String>.from(_pendingChannels);
          _pendingChannels.clear();
          for (final ch in toSubscribe) {
            subscribe(ch);
          }
          break;

        case 'pusher_internal:subscription_succeeded':
          _subscribedChannels.add(channel);
          debugPrint('[Reverb] ✓ Subscribed: $channel');
          break;

        case 'pusher:ping':
          _send({'event': 'pusher:pong', 'data': {}});
          break;

        case 'pusher:pong':
          break;

        case 'pusher:error':
          debugPrint('[Reverb] Pusher error: $data');
          break;

        default:
          if (event.startsWith('pusher')) {
            // Internal event, abaikan
            break;
          }
          // Forward custom event ke listener aplikasi
          _eventController.add(ReverbEvent(
            channel: channel,
            event: event,
            data: data,
          ));
      }
    } catch (e) {
      debugPrint('[Reverb] Parse error: $e | raw=$raw');
    }
  }

  /// Subscribe ke channel.
  /// - `pengumuman` → public channel
  /// - `private-chat.{parentId}`, `private-santri.{id}` → private (auth otomatis)
  Future<void> subscribe(String channelName) async {
    if (_subscribedChannels.contains(channelName)) return;

    if (!_connected || _socketId == null) {
      // Tunggu sampai connected
      _pendingChannels.add(channelName);
      return;
    }

    if (channelName.startsWith('private-')) {
      final auth = await _getChannelAuth(channelName);
      if (auth == null) {
        debugPrint('[Reverb] Auth gagal untuk $channelName');
        return;
      }
      _send({
        'event': 'pusher:subscribe',
        'data': {'channel': channelName, 'auth': auth},
      });
    } else {
      // Public channel
      _send({
        'event': 'pusher:subscribe',
        'data': {'channel': channelName},
      });
    }
  }

  /// Unsubscribe dari channel
  void unsubscribe(String channelName) {
    _pendingChannels.remove(channelName);
    if (!_subscribedChannels.contains(channelName)) return;
    _send({
      'event': 'pusher:unsubscribe',
      'data': {'channel': channelName},
    });
    _subscribedChannels.remove(channelName);
    debugPrint('[Reverb] Unsubscribed: $channelName');
  }

  Future<String?> _getChannelAuth(String channelName) async {
    if (_socketId == null) return null;
    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/broadcasting/auth'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'channel_name': channelName,
          'socket_id': _socketId!,
        },
      );

      if (response.statusCode != 200) {
        debugPrint('[Reverb Auth] $channelName Failed ${response.statusCode}: ${response.body}');
        return null;
      }
      return (jsonDecode(response.body) as Map<String, dynamic>)['auth'] as String?;
    } catch (e) {
      debugPrint('[Reverb Auth] Exception: $e');
      return null;
    }
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
    _connected = false;
    _socketId = null;
    _pingTimer?.cancel();
    // Pindahkan subscriptions ke pending agar di-resubscribe setelah reconnect
    _pendingChannels.addAll(_subscribedChannels);
    _subscribedChannels.clear();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_disposed) _connectInternal();
    });
  }

  /// Tutup koneksi & bersihkan resource. Panggil saat logout.
  void disconnect() {
    _disposed = true;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _wsSub?.cancel();
    _ws?.sink.close(ws_status.normalClosure);
    _ws = null;
    _connected = false;
    _socketId = null;
    _subscribedChannels.clear();
    _pendingChannels.clear();
  }
}
