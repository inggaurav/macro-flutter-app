import 'package:flutter/material.dart';
import '../providers/workspace_provider.dart';
import '../theme/app_theme.dart';

class CallRoomView extends StatelessWidget {
  final WorkspaceProvider provider;

  const CallRoomView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final activeCall = provider.callSessions.first;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Row(
        children: [
          // Left Video Call Stage
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Meeting Title Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderDark),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRose,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.fiber_manual_record,
                              size: 10,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        activeCall.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '00:${activeCall.durationMinutes}:18',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Video Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                          ),
                      itemCount: activeCall.participantAvatars.length,
                      itemBuilder: (context, index) {
                        final avatar = activeCall.participantAvatars[index];
                        final names = [
                          'Alex Rivera',
                          'Jordan Vance',
                          'David Chen',
                        ];

                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: index == 0
                                  ? AppTheme.accentEmerald
                                  : AppTheme.borderDark,
                              width: index == 0 ? 2 : 1,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(avatar),
                              fit: BoxFit.cover,
                              opacity: 0.85,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        index == 0 ? Icons.mic : Icons.mic_off,
                                        size: 14,
                                        color: index == 0
                                            ? AppTheme.accentEmerald
                                            : AppTheme.accentRose,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        names[index % names.length],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Control Bar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceDark,
                    border: Border(top: BorderSide(color: AppTheme.borderDark)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surfaceLightDark,
                        ),
                        icon: const Icon(Icons.mic, color: Colors.white),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surfaceLightDark,
                        ),
                        icon: const Icon(Icons.videocam, color: Colors.white),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryIndigo,
                        ),
                        icon: const Icon(
                          Icons.screen_share,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.accentRose,
                        ),
                        icon: const Icon(Icons.call_end, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Live AI Transcript Panel
          Container(
            width: 320,
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderDark),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.description,
                        color: AppTheme.accentEmerald,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Live AI Transcription',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Text(
                        activeCall.liveTranscript,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),

                // AI Realtime Meeting Notes Card
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppTheme.accentPurple,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'AI Call Summary Notes',
                            style: TextStyle(
                              color: AppTheme.accentPurple,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        activeCall.aiSummary,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          height: 1.4,
                        ),
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
