import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/file_analysis_provider.dart';

class FileUploadWidget extends StatefulWidget {
  const FileUploadWidget({super.key});

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.upload_file, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'File Upload & Analysis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropZone(),
            const SizedBox(height: 16),
            _buildUploadButton(),
            const SizedBox(height: 16),
            _buildRecentFiles(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZone() {
    return Consumer<FileAnalysisProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: _isDragOver ? Colors.blue : Colors.grey,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _isDragOver 
                ? Colors.blue.withValues(alpha: 0.1) 
                : Colors.grey.withValues(alpha: 0.05),
          ),
          child: provider.isAnalyzing
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Analyzing file...'),
                    ],
                  ),
                )
              : InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 48,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Drop files here or click to browse',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Supports all file types for CTF analysis',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _pickFile,
        icon: const Icon(Icons.file_upload),
        label: const Text('Select Files'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFiles() {
    return Consumer<FileAnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.analysisResults.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Analyses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...provider.analysisResults.take(3).map((result) {
              return ListTile(
                dense: true,
                leading: Icon(
                  _getFileIcon(result.fileType),
                  color: Colors.blue,
                ),
                title: Text(
                  result.fileName,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${result.fileType} • ${_formatFileSize(result.fileSize)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: () {
                    provider.removeAnalysis(result.filePath);
                  },
                ),
                onTap: () {
                  // Navigate to detailed analysis view
                  _showAnalysisDetails(context, result);
                },
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final provider = Provider.of<FileAnalysisProvider>(context, listen: false);
        
        for (final file in result.files) {
          if (file.path != null) {
            await provider.analyzeFile(file.path!);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getFileIcon(String fileType) {
    if (fileType.contains('Image')) return Icons.image;
    if (fileType.contains('PDF')) return Icons.picture_as_pdf;
    if (fileType.contains('Archive') || fileType.contains('ZIP')) return Icons.archive;
    if (fileType.contains('Executable')) return Icons.settings_applications;
    if (fileType.contains('Text')) return Icons.text_snippet;
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showAnalysisDetails(BuildContext context, dynamic result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.fileName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: ${result.fileType}'),
              Text('Size: ${_formatFileSize(result.fileSize)}'),
              Text('MD5: ${result.hashes['MD5']}'),
              Text('SHA256: ${result.hashes['SHA256']}'),
              if (result.securityFlags.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Security Flags:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...result.securityFlags.map((flag) => Text('• ${flag.description}')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}