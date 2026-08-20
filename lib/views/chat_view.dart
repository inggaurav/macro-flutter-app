import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/workspace_provider.dart';
import '../theme/app_theme.dart';

class ChatView extends StatefulWidget {
  final WorkspaceProvider provider;

  const ChatView({super.key, required this.provider});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _msgController = TextEditingController();

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    widget.provider.addChatMessage(_msgController.text);
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final activeChannel = widget.provider.channels.firstWhere(
      (c) => c.id == widget.provider.selectedChannelId,
      orElse: () => widget.provider.channels.first,
    );

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Row(
        children: [
          // Channels & Direct Messages Left Sidebar
          Container(
            width: 260,
            decoration: const BoxDecoration(
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
                        'Channels & DMs',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20, color: AppTheme.primaryIndigo),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Channels Section
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  child: Text(
                    'CHANNELS',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: widget.provider.channels.map((channel) {
                      final isSelected = channel.id == activeChannel.id;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppTheme.primaryIndigo.withOpacity(0.15),
                        dense: true,
                        leading: Icon(
                          channel.isPrivate ? Icons.lock : Icons.tag,
                          size: 18,
                          color: isSelected ? AppTheme.primaryIndigo : AppTheme.textMuted,
                        ),
                        title: Text(
                          channel.name,
                          style: TextStyle(
                            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: channel.unreadCount > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryIndigo,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${channel.unreadCount}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              )
                            : null,
                        onTap: () => widget.provider.selectChannel(channel.id),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Main Active Chat Area
          Expanded(
            child: Column(
              children: [
                // Active Channel Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tag, color: AppTheme.primaryIndigo, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        activeChannel.name,
                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        activeChannel.description,
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.people_outline, size: 20), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.pin_drop_outlined, size: 20), onPressed: () {}),
                    ],
                  ),
                ),

                // Chat Messages Feed
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: widget.provider.chatMessages.length,
                    itemBuilder: (context, index) {
                      final msg = widget.provider.chatMessages[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(msg.senderAvatar),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        msg.senderName,
                                        style: TextStyle(
                                          color: msg.isAgent ? AppTheme.accentPurple : AppTheme.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (msg.isAgent) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentPurple.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'AGENT',
                                            style: TextStyle(color: AppTheme.accentPurple, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat('h:mm a').format(msg.timestamp),
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    msg.text,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.4),
                                  ),

                                  // Mention Chips
                                  if (msg.mentions.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      children: msg.mentions.map((m) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryIndigo.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppTheme.primaryIndigo.withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            m,
                                            style: const TextStyle(
                                              color: AppTheme.primaryIndigo,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Message Input Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppTheme.borderDark)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _msgController,
                          onSubmitted: (val) => _sendMessage(),
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Message #${activeChannel.name} (type @ to link Doc, Task, or Deal)...',
                            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.alternate_email, size: 18, color: AppTheme.primaryIndigo), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.attach_file, size: 18, color: AppTheme.textMuted), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.sentiment_satisfied_alt, size: 18, color: AppTheme.textMuted), onPressed: () {}),
                            const Spacer(),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryIndigo,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _sendMessage,
                              child: const Text('Send'),
                            ),
                          ],
                        ),
                      ],
                    ),
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
