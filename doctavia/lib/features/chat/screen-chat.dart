import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:doctavia/core/providers/provider-chat.dart';
import 'package:doctavia/core/services/service-chat.dart';
import 'package:doctavia/core/theme/theme.dart';
import 'package:doctavia/core/providers/provider-content.dart';

class ScreenChat extends StatefulWidget {
  const ScreenChat({super.key});

  @override
  State<ScreenChat> createState() => _ScreenChatState();
}

class _ScreenChatState extends State<ScreenChat> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  File? _selectedFile;
  String? _selectedFileName;
  String? _selectedFileBase64;
  String? _selectedFileType;

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedFile == null) return;
    
    // Send the message natively with the attached file if present
    context.read<ChatProvider>().sendMessage(
      text.isEmpty ? 'Analyze this document.' : text, 
      fileBase64: _selectedFileBase64,
      fileType: _selectedFileType,
    );
    
    // Clear input
    _textController.clear();
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
      _selectedFileBase64 = null;
      _selectedFileType = null;
    });
    
    _scrollToBottom();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'txt', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final ext = result.files.single.extension?.toLowerCase();
        
        // Map extensions to MIME types for OpenRouter
        String mimeType = 'application/octet-stream';
        if (['jpg', 'jpeg'].contains(ext)) {
          mimeType = 'image/jpeg';
        } else if (ext == 'png') {
          mimeType = 'image/png';
        } else if (ext == 'pdf') {
          mimeType = 'application/pdf';
        } else if (ext == 'txt') {
          mimeType = 'text/plain';
        } else if (['doc', 'docx'].contains(ext)) {
          mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        }

        final bytes = await file.readAsBytes();
        
        setState(() {
          _selectedFile = file;
          _selectedFileName = result.files.single.name;
          _selectedFileBase64 = base64Encode(bytes);
          _selectedFileType = mimeType;
        });
      }
    } catch (e) {
      // Handle error or cancellation
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppContent.get('chat.title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  chatProvider.isLoading ? AppContent.get('chat.status.analyzing') : AppContent.get('chat.status.online'),
                  style: TextStyle(
                    fontSize: 12,
                    color: chatProvider.isLoading ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppContent.get('chat.actions.clearChat'),
            onPressed: () {
              chatProvider.clearChat();
            },
          ),
        ],
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.messages.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatProvider.messages.length) {
                         return const _LoadingIndicator().animate().fadeIn(duration: 300.ms);
                      }
                      
                      final msg = chatProvider.messages[index];
                      return _ChatMessageBubble(message: msg)
                          .animate()
                          .slideY(begin: 0.5, end: 0, duration: 300.ms, curve: Curves.easeOut)
                          .fadeIn();
                    },
                  ),
          ),
          if (_selectedFile != null)
             _buildAttachmentPreview(theme),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Row(
        children: [
          Icon(
            _selectedFileBase64 != null ? Icons.image : Icons.insert_drive_file,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              _selectedFileName ?? AppContent.get('chat.labels.attachment'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                _selectedFile = null;
                _selectedFileName = null;
                _selectedFileBase64 = null;
                _selectedFileType = null;
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.health_and_safety_outlined, size: 64, color: theme.colorScheme.primary),
          ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: AppSpacing.xl),
          Text(AppContent.get('chat.emptyState.title'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              AppContent.get('chat.emptyState.subtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file, color: theme.colorScheme.primary),
              onPressed: _pickFile,
              tooltip: AppContent.get('chat.actions.attach'),
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: AppContent.get('chat.input.placeholder'),
                  hintStyle: const TextStyle(color: AppColors.mutedForeground),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 16),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                  bottomLeft: !isUser ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: isUser 
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (message.fileBase64 != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 250,
                                maxHeight: 300,
                                minWidth: 100,
                              ),
                              child: message.fileType?.startsWith('image/') == true
                                ? Image.memory(
                                    base64Decode(message.fileBase64!),
                                    fit: BoxFit.contain,
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.insert_drive_file, color: Colors.white, size: 16),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            message.fileType?.split('/').last.toUpperCase() ?? 'FILE',
                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      Text(
                        message.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  )
                : MarkdownBody(
                    data: message.content,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, height: 1.4),
                      strong: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                      listBullet: TextStyle(color: theme.colorScheme.primary),
                      h1: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                      h2: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
           Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 16),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: Radius.zero),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, theme.colorScheme.primary),
                const SizedBox(width: 4),
                _buildDot(1, theme.colorScheme.primary),
                const SizedBox(width: 4),
                _buildDot(2, theme.colorScheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    )
    .animate(onPlay: (controller) => controller.repeat())
    .fadeIn(duration: 300.ms, delay: (index * 150).ms)
    .then(delay: 300.ms)
    .fadeOut(duration: 300.ms);
  }
}
