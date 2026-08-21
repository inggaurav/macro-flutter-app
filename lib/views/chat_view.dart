import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../features/chat/controllers/chat_controller.dart';
import '../providers/workspace_provider.dart';
import '../repositories/auth_repository.dart';
import '../theme/app_theme.dart';
import 'mobile/channel_chat_screen.dart';

class ChatView extends StatefulWidget {
  final WorkspaceProvider provider;

  const ChatView({super.key, required this.provider});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();

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
    final isMobile = MediaQuery.of(context).size.width < 768;
    final chatController = Provider.of<ChatController>(context);
    final authRepo = Provider.of<AuthRepository>(context);

    final channels = chatController.channels;
    final activeChannel = chatController.activeChannel;
    final activeMessages = chatController.activeMessages;

    final channelsListWidget = Container(
      width: isMobile ? double.infinity : 260,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(right: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Channels & Chat',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chatController.realtimeState.name.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryIndigo,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: chatController.isLoadingChannels
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryIndigo,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    children: channels.map((channel) {
                      final isSelected =
                          !isMobile && activeChannel?.id == channel.id;
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          selected: isSelected,
                          selectedTileColor: AppTheme.primaryIndigo.withOpacity(
                            0.15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          dense: true,
                          leading: Icon(
                            channel.isPrivate ? Icons.lock : Icons.tag,
                            size: 18,
                            color: isSelected
                                ? AppTheme.primaryIndigo
                                : AppTheme.textMuted,
                          ),
                          title: Text(
                            channel.name,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: channel.unreadCount > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryIndigo,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${channel.unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            chatController.selectChannel(channel.id);
                            if (isMobile) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChannelChatScreen(channel: channel),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: channelsListWidget,
      );
    }

    // Desktop Widescreen Split Layout
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Row(
        children: [
          channelsListWidget,
          Expanded(
            child: activeChannel == null
                ? const Center(
                    child: Text(
                      'Select a channel to begin messaging',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : Column(
                    children: [
                      // Active Channel Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: AppTheme.surfaceDark,
                          border: Border(
                            bottom: BorderSide(color: AppTheme.borderDark),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  activeChannel.isPrivate
                                      ? Icons.lock
                                      : Icons.tag,
                                  color: AppTheme.primaryIndigo,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  activeChannel.name,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  activeChannel.description,
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Messages Feed
                      Expanded(
                        child: chatController.isLoadingMessages
                            ? const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryIndigo,
                                ),
                              )
                            : activeMessages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 40,
                                      color: AppTheme.textMuted.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No messages in #${activeChannel.name} yet',
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: activeMessages.length,
                                itemBuilder: (context, index) {
                                  final msg = activeMessages[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundImage: NetworkImage(
                                            msg.senderAvatar,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    msg.senderName,
                                                    style: TextStyle(
                                                      color: msg.isAgent
                                                          ? AppTheme
                                                                .accentPurple
                                                          : AppTheme
                                                                .textPrimary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  if (msg.isAgent) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 1,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme
                                                            .accentPurple
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        'AGENT',
                                                        style: TextStyle(
                                                          color: AppTheme
                                                              .accentPurple,
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    DateFormat(
                                                      'h:mm a',
                                                    ).format(msg.timestamp),
                                                    style: const TextStyle(
                                                      color: AppTheme.textMuted,
                                                      fontSize: 11,
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

                      // Input Bar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppTheme.surfaceDark,
                          border: Border(
                            top: BorderSide(color: AppTheme.borderDark),
                          ),
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
                                  hintText: 'Message #${activeChannel.name}...',
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
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onSubmitted: (_) =>
                                    _sendMessage(chatController, authRepo),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.primaryIndigo,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.send, size: 18),
                              onPressed: () =>
                                  _sendMessage(chatController, authRepo),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
