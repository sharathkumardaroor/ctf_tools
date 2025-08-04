import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/file_analysis_provider.dart';
import '../models/file_analysis_result.dart';

class AnalysisResultsWidget extends StatelessWidget {
  const AnalysisResultsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FileAnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.analysisResults.isEmpty) {
          return Card(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No files analyzed yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upload files to start analysis',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Card(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Analysis Results',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.analysisResults.length,
                    itemBuilder: (context, index) {
                      final result = provider.analysisResults[index];
                      return _buildAnalysisCard(context, result, provider);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisCard(BuildContext context, FileAnalysisResult result, FileAnalysisProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(
          _getFileIcon(result.fileType),
          color: _getFileColor(result.fileType),
          size: 32,
        ),
        title: Text(
          result.fileName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${result.fileType} • ${_formatFileSize(result.fileSize)}'),
            if (result.securityFlags.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  children: result.securityFlags.take(3).map((flag) {
                    return Chip(
                      label: Text(
                        flag.type,
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: _getSecurityLevelColor(flag.level),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Export Report'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'details':
                _showDetailedAnalysis(context, result);
                break;
              case 'export':
                _exportReport(context, result);
                break;
              case 'delete':
                provider.removeAnalysis(result.filePath);
                break;
            }
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection('File Information', [
                  'Path: ${result.filePath}',
                  'Size: ${_formatFileSize(result.fileSize)}',
                  'Type: ${result.fileType}',
                  'MIME: ${result.mimeType}',
                  'Analyzed: ${_formatDateTime(result.analyzedAt)}',
                ]),
                const SizedBox(height: 16),
                _buildHashSection(result.hashes),
                const SizedBox(height: 16),
                if (result.securityFlags.isNotEmpty) ...[
                  _buildSecurityFlagsSection(result.securityFlags),
                  const SizedBox(height: 16),
                ],
                if (result.strings.isNotEmpty) ...[
                  _buildStringsSection(result.strings),
                  const SizedBox(height: 16),
                ],
                _buildCustomAnalysisSection(result.customAnalysis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(item, style: const TextStyle(fontSize: 14)),
        )),
      ],
    );
  }

  Widget _buildHashSection(Map<String, String> hashes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'File Hashes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...hashes.entries.map((entry) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  '${entry.key}:',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: SelectableText(
                  entry.value,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: entry.value));
                },
                tooltip: 'Copy hash',
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSecurityFlagsSection(List<SecurityFlag> flags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Security Analysis',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...flags.map((flag) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getSecurityLevelColor(flag.level).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getSecurityLevelColor(flag.level),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getSecurityLevelIcon(flag.level),
                    color: _getSecurityLevelColor(flag.level),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    flag.type,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      flag.level.name.toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: _getSecurityLevelColor(flag.level),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(flag.description),
              if (flag.recommendation != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Recommendation: ${flag.recommendation}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildStringsSection(List<String> strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Extracted Strings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: strings.length,
            itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                title: SelectableText(
                  strings[index],
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: strings[index]));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAnalysisSection(Map<String, dynamic> analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Advanced Analysis',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (analysis['entropy'] != null)
          Text('Entropy: ${analysis['entropy'].toStringAsFixed(2)}'),
        if (analysis['base64_strings'] != null && analysis['base64_strings'].isNotEmpty)
          Text('Base64 strings found: ${analysis['base64_strings'].length}'),
        if (analysis['urls'] != null && analysis['urls'].isNotEmpty)
          Text('URLs found: ${analysis['urls'].length}'),
        if (analysis['emails'] != null && analysis['emails'].isNotEmpty)
          Text('Email addresses found: ${analysis['emails'].length}'),
        if (analysis['hex_patterns'] != null && analysis['hex_patterns'].isNotEmpty)
          Text('Hex patterns found: ${analysis['hex_patterns'].length}'),
      ],
    );
  }

  IconData _getFileIcon(String fileType) {
    if (fileType.contains('Image')) return Icons.image;
    if (fileType.contains('PDF')) return Icons.picture_as_pdf;
    if (fileType.contains('Archive') || fileType.contains('ZIP')) return Icons.archive;
    if (fileType.contains('Executable')) return Icons.settings_applications;
    if (fileType.contains('Text')) return Icons.text_snippet;
    return Icons.insert_drive_file;
  }

  Color _getFileColor(String fileType) {
    if (fileType.contains('Image')) return Colors.green;
    if (fileType.contains('PDF')) return Colors.red;
    if (fileType.contains('Archive') || fileType.contains('ZIP')) return Colors.orange;
    if (fileType.contains('Executable')) return Colors.purple;
    if (fileType.contains('Text')) return Colors.blue;
    return Colors.grey;
  }

  Color _getSecurityLevelColor(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.info:
        return Colors.blue;
      case SecurityLevel.low:
        return Colors.green;
      case SecurityLevel.medium:
        return Colors.orange;
      case SecurityLevel.high:
        return Colors.red;
      case SecurityLevel.critical:
        return Colors.purple;
    }
  }

  IconData _getSecurityLevelIcon(SecurityLevel level) {
    switch (level) {
      case SecurityLevel.info:
        return Icons.info;
      case SecurityLevel.low:
        return Icons.check_circle;
      case SecurityLevel.medium:
        return Icons.warning;
      case SecurityLevel.high:
        return Icons.error;
      case SecurityLevel.critical:
        return Icons.dangerous;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDetailedAnalysis(BuildContext context, FileAnalysisResult result) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Detailed Analysis: ${result.fileName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection('File Information', [
                        'Path: ${result.filePath}',
                        'Size: ${_formatFileSize(result.fileSize)}',
                        'Type: ${result.fileType}',
                        'MIME: ${result.mimeType}',
                        'Analyzed: ${_formatDateTime(result.analyzedAt)}',
                      ]),
                      const SizedBox(height: 16),
                      _buildHashSection(result.hashes),
                      const SizedBox(height: 16),
                      if (result.securityFlags.isNotEmpty) ...[
                        _buildSecurityFlagsSection(result.securityFlags),
                        const SizedBox(height: 16),
                      ],
                      if (result.strings.isNotEmpty) ...[
                        _buildStringsSection(result.strings),
                        const SizedBox(height: 16),
                      ],
                      _buildCustomAnalysisSection(result.customAnalysis),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportReport(BuildContext context, FileAnalysisResult result) {
    // Placeholder for export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
      ),
    );
  }
}