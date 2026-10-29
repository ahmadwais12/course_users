import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/services/chat_service.dart';

class CallScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> callData;
  final bool isIncoming;

  const CallScreen({
    super.key,
    required this.callData,
    required this.isIncoming,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final _chatService = ChatService();
  StreamSubscription<Map<String, dynamic>>? _callSubscription;
  String _status = 'ringing';
  int _elapsedSeconds = 0;
  Timer? _timer;

  String get _callId => widget.callData['id'] as String;
  String get _callType => widget.callData['call_type'] as String;
  Map<String, dynamic>? get _caller => widget.callData['caller'];
  Map<String, dynamic>? get _callee => widget.callData['callee'];
  String get _otherUserName =>
      _caller?['full_name'] as String? ??
      _callee?['full_name'] as String? ??
      'Unknown';
  String? get _otherAvatar =>
      _caller?['avatar_url'] as String? ??
      _callee?['avatar_url'] as String?;

  @override
  void initState() {
    super.initState();
    _status = widget.isIncoming ? 'ringing' : 'calling';
    _listenForUpdates();
  }

  void _listenForUpdates() {
    _callSubscription = _chatService
        .streamIncomingCalls('')
        .listen((call) {
      if (call['id'] != _callId) return;
      final status = call['status'] as String?;
      if (status == null) return;

      setState(() => _status = status);

      if (status == 'answered') {
        _startTimer();
      } else if (status == 'ended' || status == 'declined') {
        _timer?.cancel();
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop(call);
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  String get _formattedTime {
    final min = _elapsedSeconds ~/ 60;
    final sec = _elapsedSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Future<void> _answer() async {
    await _chatService.answerCall(_callId);
  }

  Future<void> _end() async {
    _timer?.cancel();
    await _chatService.endCall(_callId, durationSeconds: _elapsedSeconds);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _decline() async {
    await _chatService.declineCall(_callId);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            CircleAvatar(
              radius: 60,
              backgroundImage: _otherAvatar != null
                  ? NetworkImage(_otherAvatar!)
                  : null,
              child: _otherAvatar == null
                  ? Icon(Icons.person, size: 60, color: Colors.white70)
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              _otherUserName,
              style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _status == 'calling' ? 'Calling...' :
              _status == 'ringing' ? 'Incoming call...' :
              _status == 'answered' ? _formattedTime :
              _status == 'ended' ? 'Call ended' : _status,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Icon(
              _callType == 'video' ? Icons.videocam : Icons.phone,
              color: Colors.white54,
              size: 28,
            ),
            const Spacer(flex: 2),
            if (_status == 'ringing') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallActionButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    label: 'Decline',
                    onPressed: _decline,
                  ),
                  _CallActionButton(
                    icon: Icons.call,
                    color: Colors.black87,
                    label: 'Answer',
                    onPressed: _answer,
                  ),
                ],
              ),
            ] else if (_status == 'calling' || _status == 'answered') ...[
              _CallActionButton(
                icon: Icons.call_end,
                color: Colors.red,
                label: 'End Call',
                onPressed: _end,
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class IncomingCallListenerWidget extends ConsumerStatefulWidget {
  final Widget child;

  const IncomingCallListenerWidget({super.key, required this.child});

  @override
  ConsumerState<IncomingCallListenerWidget> createState() =>
      _IncomingCallListenerWidgetState();
}

class _IncomingCallListenerWidgetState
    extends ConsumerState<IncomingCallListenerWidget> {
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _listen());
  }

  void _listen() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _subscription =
        ChatService().streamIncomingCalls(userId).listen((call) {
      if (!mounted || call['status'] != 'ringing') return;
      final calleeId = call['callee_id'] as String?;
      if (calleeId != userId) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CallScreen(callData: call, isIncoming: true),
        ),
      );
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onPressed;

  const _CallActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: color,
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 28),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
