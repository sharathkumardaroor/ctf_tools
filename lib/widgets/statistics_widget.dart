import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_analysis_provider.dart';
import '../providers/ctf_challenge_provider.dart';

class StatisticsWidget extends StatelessWidget {
  const StatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FileAnalysisProvider, CTFChallengeProvider>(
      builder: (context, fileProvider, challengeProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                'Files Analyzed',
                fileProvider.analysisResults.length.toString(),
                Icons.file_present,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                'Challenges',
                challengeProvider.challenges.length.toString(),
                Icons.flag,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                'Solved',
                challengeProvider.challenges.where((c) => c.isSolved).length.toString(),
                Icons.check_circle,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                'Security Flags',
                fileProvider.analysisResults
                    .fold<int>(0, (sum, result) => sum + result.securityFlags.length)
                    .toString(),
                Icons.security,
                Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}