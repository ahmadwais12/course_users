import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:course_users/models/chat_models.dart';

class ChatService {
  static final ChatService _instance = ChatService._();
  ChatService._();
  factory ChatService() => _instance;

  final _client = Supabase.instance.client;
  final _channels = <String, RealtimeChannel>{};

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    return DateTime.now();
  }

  ChatGroup _buildGroup(Map<String, dynamic> json, {ChatMessage? lastMessage}) {
    return ChatGroup(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Chat',
      type: json['type'] as String? ?? 'direct',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      description: json['description'] as String?,
      createdBy: json['created_by'] as String?,
      classId: json['class_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      lastMessage: lastMessage,
    );
  }

  ChatMessage _buildMessage(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      groupId: json['group_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      messageType: json['message_type'] as String? ?? 'text',
      content: json['content'] as String?,
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt(),
      createdAt: _parseDate(json['created_at']),
      senderName: json['sender_name'] as String?,
      senderAvatar: json['sender_avatar'] as String?,
      replyTo: json['reply_to'] as String?,
    );
  }

  Future<List<ChatGroup>> _fetchGroups(String userId) async {
    try {
      final memberships = await _client
          .from('chat_group_members')
          .select('group_id')
          .eq('user_id', userId);

      final groupIds = (memberships as List)
          .map((m) => (m as Map)['group_id'] as String)
          .toList();

      if (groupIds.isEmpty) return [];

      final groupsData = await _client
          .from('chat_groups')
          .select()
          .inFilter('id', groupIds)
          .order('updated_at', ascending: false);

      final groups = <ChatGroup>[];
      for (final g in (groupsData as List)) {
        final gMap = g as Map<String, dynamic>;

        final msgs = await _client
            .from('chat_messages')
            .select(
                'id, sender_id, content, message_type, file_url, file_name, file_size, created_at, sender_name')
            .eq('group_id', gMap['id'] as String)
            .order('created_at', ascending: false)
            .limit(1);

        ChatMessage? lastMsg;
        if ((msgs).isNotEmpty) {
          lastMsg = _buildMessage(msgs[0]);
        }

        groups.add(_buildGroup(gMap, lastMessage: lastMsg));
      }

      return groups;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<ChatGroup>> streamChatGroups(String userId) {
    final controller = StreamController<List<ChatGroup>>();

    _fetchGroups(userId).then((groups) {
      if (!controller.isClosed) controller.add(groups);
    }).catchError((e) {
      if (!controller.isClosed) controller.addError(e);
    });

    final channel = _client.channel('chat_groups:$userId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_group_members',
          callback: (_) async {
            final g = await _fetchGroups(userId);
            if (!controller.isClosed) controller.add(g);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (_) async {
            final g = await _fetchGroups(userId);
            if (!controller.isClosed) controller.add(g);
          },
        )
        .subscribe();
    _channels['chat_groups:$userId'] = channel;

    return controller.stream;
  }

  Stream<List<ChatMessage>> streamMessages(String groupId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('created_at', ascending: true)
        .map((data) => (data as List)
            .map((m) => _buildMessage(m as Map<String, dynamic>))
            .toList());
  }

  Future<String> sendTextMessage({
    required String groupId,
    required String content,
    String? replyTo,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final result = await _client.from('chat_messages').insert({
      'group_id': groupId,
      'sender_id': userId,
      'content': content,
      'message_type': 'text',
      if (replyTo != null) 'reply_to': replyTo,
    }).select('id').single();

    await _client.from('chat_groups').update({
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', groupId);

    return result['id'] as String;
  }

  Future<String> sendFileMessage({
    required String groupId,
    required String messageType,
    required String fileUrl,
    required String fileName,
    int? fileSize,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final result = await _client.from('chat_messages').insert({
      'group_id': groupId,
      'sender_id': userId,
      'message_type': messageType,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
    }).select('id').single();

    await _client.from('chat_groups').update({
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', groupId);

    return result['id'] as String;
  }

  Future<String> createGroup({
    required String name,
    required String type,
    String? description,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client.from('chat_groups').insert({
      'name': name,
      'type': type,
      'description': description,
      'created_by': userId,
    }).select('id').single();

    final groupId = response['id'] as String;

    await _client.from('chat_group_members').insert({
      'group_id': groupId,
      'user_id': userId,
      'role': 'admin',
    });

    return groupId;
  }

  Future<void> addGroupMembers(String groupId, List<String> userIds) async {
    final inserts = userIds.map((uid) => {
      'group_id': groupId,
      'user_id': uid,
    }).toList();
    if (inserts.isNotEmpty) {
      await _client.from('chat_group_members').insert(inserts);
    }
  }

  Future<void> leaveGroup(String groupId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    await _client
        .from('chat_group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', userId);
  }

  Future<String> uploadVoiceMessage({
    required String groupId,
    required File audioFile,
    required int durationSeconds,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final ext = p.extension(audioFile.path).isNotEmpty
        ? p.extension(audioFile.path)
        : '.m4a';
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}$ext';
    final storagePath = 'chat_uploads/$groupId/$fileName';

    await _client.storage.from('chat_uploads').upload(
          storagePath,
          audioFile,
          fileOptions: const FileOptions(contentType: 'audio/m4a'),
        );

    final fileUrl =
        _client.storage.from('chat_uploads').getPublicUrl(storagePath);

    return sendFileMessage(
      groupId: groupId,
      messageType: 'audio',
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: await audioFile.length(),
    );
  }

  Stream<Map<String, dynamic>> streamIncomingCalls(String userId) {
    final controller = StreamController<Map<String, dynamic>>();

    _fetchActiveCalls(userId).then((calls) {
      for (final c in calls) {
        if (!controller.isClosed) controller.add(c);
      }
    });

    final channel = _client.channel('incoming_calls:$userId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_calls',
          callback: (payload) async {
            final callId = payload.newRecord['id'] as String?;
            if (callId != null) {
              final call = await _fetchCall(callId);
              if (call != null && !controller.isClosed) controller.add(call);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chat_calls',
          callback: (payload) async {
            final callId = payload.newRecord['id'] as String?;
            if (callId != null) {
              final call = await _fetchCall(callId);
              if (call != null && !controller.isClosed) controller.add(call);
            }
          },
        )
        .subscribe();
    _channels['incoming_calls:$userId'] = channel;

    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> _fetchActiveCalls(String userId) async {
    final result = await _client
        .from('chat_calls')
        .select('*, caller:caller_id(id, full_name, avatar_url), callee:callee_id(id, full_name, avatar_url)')
        .or('caller_id.eq.$userId,callee_id.eq.$userId')
        .inFilter('status', ['ringing', 'answered']);
    return (result as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> _fetchCall(String callId) async {
    final result = await _client
        .from('chat_calls')
        .select('*, caller:caller_id(id, full_name, avatar_url), callee:callee_id(id, full_name, avatar_url)')
        .eq('id', callId)
        .maybeSingle();
    return result;
  }

  Future<Map<String, dynamic>> initiateCall({
    required String groupId,
    required String calleeId,
    required String callType,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final result = await _client.from('chat_calls').insert({
      'group_id': groupId,
      'caller_id': userId,
      'callee_id': calleeId,
      'call_type': callType,
      'status': 'ringing',
    }).select('*, caller:caller_id(id, full_name, avatar_url), callee:callee_id(id, full_name, avatar_url)').single();

    final channel = _client.channel('call_signaling:${result['id']}');
    _channels['call_signaling:${result['id']}'] = channel;
    channel.subscribe();

    return result;
  }

  Future<void> answerCall(String callId) async {
    await _client.from('chat_calls').update({
      'status': 'answered',
      'answered_at': DateTime.now().toIso8601String(),
    }).eq('id', callId);
  }

  Future<void> endCall(String callId, {int? durationSeconds}) async {
    await _client.from('chat_calls').update({
      'status': 'ended',
      'ended_at': DateTime.now().toIso8601String(),
      'duration_seconds': durationSeconds,
    }).eq('id', callId);

    final channel = _channels.remove('call_signaling:$callId');
    if (channel != null) {
      _client.removeChannel(channel);
    }
  }

  Future<void> declineCall(String callId) async {
    await _client.from('chat_calls').update({
      'status': 'declined',
      'ended_at': DateTime.now().toIso8601String(),
    }).eq('id', callId);
  }

  void dispose() {
    for (final channel in _channels.values) {
      _client.removeChannel(channel);
    }
    _channels.clear();
  }
}
