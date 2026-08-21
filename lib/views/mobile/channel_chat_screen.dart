import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../features/chat/controllers/chat_controller.dart';
import '../../features/chat/domain/chat_channel.dart';
import '../../repositories/auth_repository.dart';
import '../../theme/app_theme.dart';

class ChannelChatScreen extends StatefulWidget {
  final ChatChannel channel;

  const ChannelChatScreen({super.key, required this.channel});

  @override
  State<ChannelChatScreen> createState() => _ChannelChatScreenState();
}

class _ChannelChatScreenState extends State<ChannelChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<ChatController>(context, listen: false);
      controller.selectChannel(widget.channel.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatController chatController, AuthRepository authRepo) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = authRepo.currentUser;
    chatController.sendMessage(
      text: text,
      senderName: user?.name ?? 'Alex Rivera',
      senderAvatar:
          user?.avatarUrl ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
    );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);
    final authRepo = Provider.of<AuthRepository>(context);

    final messages = chatController.activeMessages;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(
              widget.channel.isPrivate ? Icons.lock : Icons.tag,
              color: AppTheme.primaryIndigo,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              widget.channel.name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatController.isLoadingMessages
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryIndigo,
                    ),
                  )
                : messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages in #${widget.channel.name} yet',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final avatarUrl = msg.senderAvatar.trim();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl.isEmpty
                                  ? Text(
                                      msg.senderName.isNotEmpty
                                          ? msg.senderName[0].toUpperCase()
                                          : 'M',
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        msg.senderName,
                                        style: TextStyle(
                                          color: msg.isAgent
                                              ? AppTheme.accentPurple
                                              : AppTheme.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        DateFormat(
                                          'h:mm a',
                                        ).format(msg.timestamp),
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    msg.text,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceDark,
              border: Border(top: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Message #${widget.channel.name}...',
                      hintStyle: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: AppTheme.bgDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.borderDark,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(chatController, authRepo),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send, size: 18),
                  onPressed: () => _sendMessage(chatController, authRepo),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
