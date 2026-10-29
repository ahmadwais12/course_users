import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:course_users/models/chat_models.dart';
import 'package:course_users/providers/chat_providers.dart';

const _maxFileSize = 5 * 1024 * 1024;
const _maxFileSizeWarning = 'File size exceeds 5 MB limit';

class ChatConversationScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatConversationScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState
    extends ConsumerState<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  ChatMessage? _replyingTo;
  bool _isRecording = false;
  String? _recordingPath;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          if (_replyingTo != null) _buildReplyBanner(theme),
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients &&
                      _scrollController.position.pixels >=
                          _scrollController.position.maxScrollExtent - 100) {
                    _scrollToBottom();
                  }
                });
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text('No messages yet',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Send a message to start the conversation.'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;
                    return _buildMessageBubble(
                        context, theme, message, isMe);
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          _buildMessageInput(context, theme),
        ],
      ),
    );
  }

  Widget _buildReplyBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          Container(width: 4, height: 40, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Replying to ${_replyingTo!.senderName ?? 'Unknown'}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 12)),
                Text(_replyingTo!.content ?? 'File',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _replyingTo = null)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      BuildContext context, ThemeData theme, ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                message.senderName?.substring(0, 1).toUpperCase() ?? 'U',
                style:
                    TextStyle(color: theme.colorScheme.onPrimary, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context, message),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft: isMe
                        ? const Radius.circular(16)
                        : const Radius.circular(4),
                    bottomRight: isMe
                        ? const Radius.circular(4)
                        : const Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Text(
                        message.senderName ?? 'Unknown',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: theme.colorScheme.primary),
                      ),
                    if (message.replyTo != null)
                      _buildReplyIndicator(theme, message),
                    _buildMessageContent(theme, message, isMe),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe
                                ? theme.colorScheme.onPrimary
                                    .withValues(alpha: 0.7)
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildReplyIndicator(ThemeData theme, ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 3),
        ),
      ),
      child: const Text('Replied message',
          style: TextStyle(fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildMessageContent(
      ThemeData theme, ChatMessage message, bool isMe) {
    switch (message.messageType) {
      case 'text':
        return Text(message.content ?? '',
            style: TextStyle(
                color: isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface));
      case 'file':
        return _buildFileMessage(theme, message, isMe);
      case 'image':
        return _buildImageMessage(theme, message);
      case 'video':
        return _buildVideoMessage(theme, message);
      case 'audio':
        return _buildAudioMessage(theme, message, isMe);
      default:
        return Text('Unsupported message type',
            style: TextStyle(
                color: isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontStyle: FontStyle.italic));
    }
  }

  Widget _buildFileMessage(ThemeData theme, ChatMessage message, bool isMe) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (isMe ? theme.colorScheme.onPrimary : theme.colorScheme.primary)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file,
              color: isMe
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.fileName ?? 'File',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isMe
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface)),
                if (message.fileSize != null)
                  Text(_formatFileSize(message.fileSize!),
                      style: TextStyle(
                          fontSize: 12,
                          color: isMe
                              ? theme.colorScheme.onPrimary
                                  .withValues(alpha: 0.7)
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(ThemeData theme, ChatMessage message) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(message.fileUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                color: theme.colorScheme.surface,
                child: const Icon(Icons.broken_image))),
      ),
    );
  }

  Widget _buildVideoMessage(ThemeData theme, ChatMessage message) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
      decoration:
          BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(8)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.video_library, size: 50),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(ThemeData theme, ChatMessage message, bool isMe) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow,
              color: isMe
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: (isMe
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary)
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: _isRecording ? _buildRecordingBar(theme) : _buildInputRow(theme),
    );
  }

  Widget _buildRecordingBar(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.mic, color: Colors.red, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text('Recording... Tap to stop',
              style: TextStyle(color: theme.colorScheme.onSurface)),
        ),
        IconButton(
          icon: const Icon(Icons.stop, color: Colors.red),
          onPressed: _stopRecording,
        ),
      ],
    );
  }

  Widget _buildInputRow(ThemeData theme) {
    return Row(
      children: [
        IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () => _showAttachmentOptions(context)),
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            maxLines: null,
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          onPressed: _sendMessage,
          child: const Icon(Icons.send),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final replyToId = _replyingTo?.id;
    setState(() => _replyingTo = null);

    try {
      final service = ref.read(chatServiceProvider);
      await service.sendTextMessage(
        groupId: widget.chatId,
        content: text,
        replyTo: replyToId,
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Send failed: $e')));
      }
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: const Text('File'),
            onTap: () {
              Navigator.pop(ctx);
              _pickFile();
            },
          ),
          ListTile(
            leading: Icon(_isRecording ? Icons.stop : Icons.mic,
                color: _isRecording ? Colors.red : null),
            title: Text(_isRecording ? 'Stop Recording' : 'Voice Message'),
            onTap: () {
              Navigator.pop(ctx);
              if (_isRecording) {
                _stopRecording();
              } else {
                _startRecording();
              }
            },
          ),
        ],
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(source: source);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (bytes.length > _maxFileSize) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(_maxFileSizeWarning)));
      }
      return;
    }

    try {
      final userId = _currentUserId;
      final ext = image.path.split('.').last;
      final filePath = 'chat/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await Supabase.instance.client.storage.from('chat_uploads').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$ext'),
          );

      final fileUrl =
          Supabase.instance.client.storage.from('chat_uploads').getPublicUrl(filePath);

      final service = ref.read(chatServiceProvider);
      await service.sendFileMessage(
        groupId: widget.chatId,
        messageType: 'image',
        fileUrl: fileUrl,
        fileName: image.name,
        fileSize: bytes.length,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  void _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final file = result.files.first;

    if (file.size > _maxFileSize) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(_maxFileSizeWarning)));
      }
      return;
    }

    try {
      final userId = _currentUserId;
      final bytes = await file.xFile.readAsBytes();
      final filePath = 'chat/$userId/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      await Supabase.instance.client.storage.from('chat_uploads').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: 'application/octet-stream'),
          );

      final fileUrl =
          Supabase.instance.client.storage.from('chat_uploads').getPublicUrl(filePath);

      final service = ref.read(chatServiceProvider);
      await service.sendFileMessage(
        groupId: widget.chatId,
        messageType: 'file',
        fileUrl: fileUrl,
        fileName: file.name,
        fileSize: file.size,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(const RecordConfig(), path: path);
    setState(() {
      _isRecording = true;
      _recordingPath = path;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _recordingPath == null) return;

    setState(() => _isRecording = false);
    final path = _recordingPath!;
    _recordingPath = null;

    try {
      await _audioRecorder.stop();
      final audioFile = File(path);
      if (!await audioFile.exists()) return;

      final service = ref.read(chatServiceProvider);
      await service.uploadVoiceMessage(
        groupId: widget.chatId,
        audioFile: audioFile,
        durationSeconds: 0,
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Recording failed: $e')));
      }
    }
  }

  void _showMessageOptions(BuildContext context, ChatMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () {
              Navigator.pop(ctx);
              setState(() => _replyingTo = message);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy'),
            onTap: () {
              Navigator.pop(ctx);
              if (message.content != null) {
                Clipboard.setData(ClipboardData(text: message.content!));
              }
            },
          ),
          if (message.senderId == _currentUserId) ...[
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
          ],
        ],
      ),
    );
  }

}
