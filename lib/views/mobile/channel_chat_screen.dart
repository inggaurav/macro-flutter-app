import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/workspace_provider.dart';
import '../../theme/app_theme.dart';

class ChannelChatScreen extends StatefulWidget {
  final ChatChannel channel;
  final WorkspaceProvider provider;

  const ChannelChatScreen({
    super.key,
    required this.channel,
    required this.provider,
  });

  @override
  State<ChannelChatScreen> createState() => _ChannelChatScreenState();
}

class _ChannelChatScreenState extends State<ChannelChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    widget.provider.addChatMessage(
      _msgController.text,
      targetChannelId: widget.channel.id,
    );
    _msgController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final channelMessages = widget.provider.chatMessages
        .where((m) => m.channelId == widget.channel.id)
        .toList();

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
            const Icon(Icons.tag, color: AppTheme.primaryIndigo, size: 20),
            const SizedBox(width: 6),
            Text(
              widget.channel.name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline, color: AppTheme.textSecondary), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Chat Timeline
          Expanded(
            child: channelMessages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 40, color: AppTheme.textMuted.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text('No messages in #${widget.channel.name} yet', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        const SizedBox(height: 4),
                        const Text('Be the first to post a message or ask @AI', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: channelMessages.length,
                    itemBuilder: (context, index) {
                      final msg = channelMessages[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(msg.senderAvatar),
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
                                          color: msg.isAgent ? AppTheme.accentPurple : AppTheme.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (msg.isAgent) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentPurple.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'BOT',
                                            style: TextStyle(color: AppTheme.accentPurple, fontSize: 8, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 6),
                                      Text(
                                        DateFormat('h:mm a').format(msg.timestamp),
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    msg.text,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.4),
                                  ),
                                  if (msg.mentions.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 4,
                                      children: msg.mentions.map((m) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryIndigo.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            m,
                                            style: const TextStyle(color: AppTheme.primaryIndigo, fontSize: 10, fontWeight: FontWeight.bold),
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

          // Sticky Mobile Message Composer
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceDark,
                border: Border(top: BorderSide(color: AppTheme.borderDark)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.alternate_email, color: AppTheme.primaryIndigo, size: 20),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.bgDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: TextField(
                        controller: _msgController,
                        onSubmitted: (val) => _sendMessage(),
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Message... (type @)',
                          hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryIndigo,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 16),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
