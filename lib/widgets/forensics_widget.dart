import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math' as math;

class ForensicsWidget extends StatefulWidget {
  const ForensicsWidget({super.key});

  @override
  State<ForensicsWidget> createState() => _ForensicsWidgetState();
}

class _ForensicsWidgetState extends State<ForensicsWidget> with TickerProviderStateMixin {
  late TabController _forensicsTabController;
  final TextEditingController _imagePathController = TextEditingController();
  final TextEditingController _searchTermController = TextEditingController();
  final TextEditingController _memoryDumpController = TextEditingController();
  
  List<ForensicArtifact> _artifacts = [];
  List<MemoryAnalysis> _memoryAnalyses = [];
  List<FileSystemEntry> _fileSystemEntries = [];
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _forensicsTabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _forensicsTabController.dispose();
    _imagePathController.dispose();
    _searchTermController.dispose();
    _memoryDumpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: Column(
              children: [
                TabBar(
                  controller: _forensicsTabController,
                  isScrollable: true,
                  labelColor: const Color(0xFF00D4FF),
                  unselectedLabelColor: const Color(0xFF8B949E),
                  indicatorColor: const Color(0xFF00D4FF),
                  tabs: const [
                    Tab(text: 'Disk Analysis'),
                    Tab(text: 'Memory Forensics'),
                    Tab(text: 'File Recovery'),
                    Tab(text: 'Metadata Extraction'),
                    Tab(text: 'Timeline Analysis'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _forensicsTabController,
                    children: [
                      _buildDiskAnalysisTab(),
                      _buildMemoryForensicsTab(),
                      _buildFileRecoveryTab(),
                      _buildMetadataExtractionTab(),
                      _buildTimelineAnalysisTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.memory, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Digital Forensics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Advanced digital investigation and evidence analysis',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8B949E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiskAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _imagePathController,
                  decoration: const InputDecoration(
                    labelText: 'Disk Image Path',
                    hintText: '/path/to/disk.img or C:\\disk.dd',
                    prefixIcon: Icon(Icons.storage),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeDiskImage,
                icon: _isAnalyzing 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard('File System', 'NTFS', Icons.folder),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard('Total Size', '500 GB', Icons.storage),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard('Free Space', '150 GB', Icons.pie_chart),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard('Partitions', '3', Icons.view_module),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'File System Structure:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _fileSystemEntries.isEmpty
                ? const Center(
                    child: Text(
                      'No disk image loaded. Enter a path and click Analyze.',
                      style: TextStyle(color: Color(0xFF8B949E)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _fileSystemEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _fileSystemEntries[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          leading: Icon(
                            entry.isDirectory ? Icons.folder : Icons.insert_drive_file,
                            color: entry.isDirectory ? Colors.blue : Colors.grey,
                          ),
                          title: Text(entry.name),
                          subtitle: Text(
                            '${entry.isDirectory ? "Directory" : "File"} • '
                            '${entry.size} bytes • '
                            'Modified: ${entry.lastModified}',
                          ),
                          trailing: entry.isDeleted
                              ? const Chip(
                                  label: Text('DELETED', style: TextStyle(fontSize: 10)),
                                  backgroundColor: Colors.red,
                                )
                              : null,
                          onTap: () => _showFileDetails(entry),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryForensicsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _memoryDumpController,
            decoration: const InputDecoration(
              labelText: 'Memory Dump Path',
              hintText: '/path/to/memory.dmp',
              prefixIcon: Icon(Icons.memory),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _analyzeProcesses,
                icon: const Icon(Icons.list),
                label: const Text('Process List'),
              ),
              ElevatedButton.icon(
                onPressed: _analyzeNetworkConnections,
                icon: const Icon(Icons.network_check),
                label: const Text('Network Connections'),
              ),
              ElevatedButton.icon(
                onPressed: _extractPasswords,
                icon: const Icon(Icons.key),
                label: const Text('Extract Passwords'),
              ),
              ElevatedButton.icon(
                onPressed: _analyzeRegistry,
                icon: const Icon(Icons.settings),
                label: const Text('Registry Analysis'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Memory Analysis Results:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _memoryAnalyses.isEmpty
                ? const Center(
                    child: Text(
                      'No memory analysis performed yet.',
                      style: TextStyle(color: Color(0xFF8B949E)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _memoryAnalyses.length,
                    itemBuilder: (context, index) {
                      final analysis = _memoryAnalyses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: Icon(
                            _getAnalysisIcon(analysis.type),
                            color: const Color(0xFF7C3AED),
                          ),
                          title: Text(analysis.title),
                          subtitle: Text(analysis.description),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...analysis.details.entries.map((entry) =>
                                    _buildInfoRow(entry.key, entry.value),
                                  ),
                                  if (analysis.data.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    const Text('Raw Data:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF21262D),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: SelectableText(
                                        analysis.data,
                                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                      ),
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
        ],
      ),
    );
  }

  Widget _buildFileRecoveryTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchTermController,
                  decoration: const InputDecoration(
                    labelText: 'File Signature or Extension',
                    hintText: 'jpg, pdf, docx, or hex signature',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _recoverFiles,
                icon: const Icon(Icons.restore),
                label: const Text('Recover Files'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard('Recoverable', '1,247', Icons.restore),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard('Corrupted', '89', Icons.error),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard('Recovered', '1,158', Icons.check_circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard('Success Rate', '93%', Icons.trending_up),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'File Recovery Results:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: const Center(
                child: Text(
                  'File recovery results will appear here',
                  style: TextStyle(color: Color(0xFF8B949E)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataExtractionTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metadata Extraction Tools',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _extractEXIFData,
                icon: const Icon(Icons.image),
                label: const Text('EXIF Data'),
              ),
              ElevatedButton.icon(
                onPressed: _extractDocumentMetadata,
                icon: const Icon(Icons.description),
                label: const Text('Document Metadata'),
              ),
              ElevatedButton.icon(
                onPressed: _extractVideoMetadata,
                icon: const Icon(Icons.video_file),
                label: const Text('Video Metadata'),
              ),
              ElevatedButton.icon(
                onPressed: _extractAudioMetadata,
                icon: const Icon(Icons.audio_file),
                label: const Text('Audio Metadata'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Extracted Metadata:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: const Center(
                child: Text(
                  'Metadata extraction results will appear here',
                  style: TextStyle(color: Color(0xFF8B949E)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline Analysis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generateTimeline,
                  icon: const Icon(Icons.timeline),
                  label: const Text('Generate Timeline'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exportTimeline,
                  icon: const Icon(Icons.download),
                  label: const Text('Export Timeline'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Timeline Events:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: const Center(
                child: Text(
                  'Timeline analysis results will appear here',
                  style: TextStyle(color: Color(0xFF8B949E)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF7C3AED), size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00D4FF),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8B949E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  IconData _getAnalysisIcon(String type) {
    switch (type.toLowerCase()) {
      case 'process':
        return Icons.list;
      case 'network':
        return Icons.network_check;
      case 'password':
        return Icons.key;
      case 'registry':
        return Icons.settings;
      default:
        return Icons.memory;
    }
  }

  void _analyzeDiskImage() {
    if (_imagePathController.text.isEmpty) return;
    
    setState(() {
      _isAnalyzing = true;
      _fileSystemEntries.clear();
    });

    // Simulate disk analysis
    Future.delayed(const Duration(seconds: 3), () {
      final entries = <FileSystemEntry>[
        FileSystemEntry(
          name: 'Windows',
          isDirectory: true,
          size: 0,
          lastModified: '2024-01-15 10:30:00',
          isDeleted: false,
        ),
        FileSystemEntry(
          name: 'Users',
          isDirectory: true,
          size: 0,
          lastModified: '2024-01-15 10:30:00',
          isDeleted: false,
        ),
        FileSystemEntry(
          name: 'secret_document.pdf',
          isDirectory: false,
          size: 1024576,
          lastModified: '2024-01-10 14:22:33',
          isDeleted: true,
        ),
        FileSystemEntry(
          name: 'passwords.txt',
          isDirectory: false,
          size: 2048,
          lastModified: '2024-01-08 09:15:22',
          isDeleted: true,
        ),
      ];

      setState(() {
        _fileSystemEntries = entries;
        _isAnalyzing = false;
      });
    });
  }

  void _analyzeProcesses() {
    final analysis = MemoryAnalysis(
      type: 'process',
      title: 'Running Processes',
      description: 'Analysis of active processes in memory dump',
      details: {
        'Total Processes': '127',
        'Suspicious Processes': '3',
        'Hidden Processes': '1',
      },
      data: 'PID: 1234, Name: malware.exe, Parent: explorer.exe\n'
            'PID: 5678, Name: keylogger.dll, Parent: svchost.exe',
    );

    setState(() {
      _memoryAnalyses.insert(0, analysis);
    });
  }

  void _analyzeNetworkConnections() {
    final analysis = MemoryAnalysis(
      type: 'network',
      title: 'Network Connections',
      description: 'Active network connections from memory',
      details: {
        'Active Connections': '23',
        'Listening Ports': '8',
        'Suspicious Connections': '2',
      },
      data: 'TCP 192.168.1.100:1234 -> 10.0.0.1:443 ESTABLISHED\n'
            'TCP 192.168.1.100:5678 -> 192.168.1.1:80 TIME_WAIT',
    );

    setState(() {
      _memoryAnalyses.insert(0, analysis);
    });
  }

  void _extractPasswords() {
    final analysis = MemoryAnalysis(
      type: 'password',
      title: 'Password Extraction',
      description: 'Extracted passwords and credentials',
      details: {
        'Passwords Found': '12',
        'Hash Types': 'NTLM, SHA256',
        'Cleartext Passwords': '4',
      },
      data: 'Username: admin, Password: [REDACTED]\n'
            'Hash: 5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8',
    );

    setState(() {
      _memoryAnalyses.insert(0, analysis);
    });
  }

  void _analyzeRegistry() {
    final analysis = MemoryAnalysis(
      type: 'registry',
      title: 'Registry Analysis',
      description: 'Windows registry analysis from memory',
      details: {
        'Registry Keys': '1,247',
        'Startup Entries': '23',
        'Suspicious Keys': '5',
      },
      data: 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run\n'
            'HKCU\\Software\\Classes\\exefile\\shell\\open\\command',
    );

    setState(() {
      _memoryAnalyses.insert(0, analysis);
    });
  }

  void _recoverFiles() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File recovery started'),
        backgroundColor: Color(0xFF7C3AED),
      ),
    );
  }

  void _extractEXIFData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('EXIF data extraction started'),
        backgroundColor: Color(0xFF7C3AED),
      ),
    );
  }

  void _extractDocumentMetadata() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document metadata extraction started'),
        backgroundColor: Color(0xFF7C3AED),
      ),
    );
  }

  void _extractVideoMetadata() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video metadata extraction started'),
        backgroundColor: Color(0xFF7C3AED),
      ),
    );
  }

  void _extractAudioMetadata() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio metadata extraction started'),
        backgroundColor: Color(0xFF7C3AED),
      ),
    );
  }

  void _generateTimeline() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timeline generation started'),
        backgroundColor: Color(0xFF7C3AED),
      ),
    );
  }

  void _exportTimeline() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timeline export started'),
        backgroundColor: Color(0xFF7C3AED),
      ),
    );
  }

  void _showFileDetails(FileSystemEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${entry.isDirectory ? "Directory" : "File"}'),
            Text('Size: ${entry.size} bytes'),
            Text('Last Modified: ${entry.lastModified}'),
            Text('Status: ${entry.isDeleted ? "DELETED" : "Active"}'),
          ],
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

class ForensicArtifact {
  final String name;
  final String type;
  final String location;
  final DateTime timestamp;
  final Map<String, String> metadata;

  ForensicArtifact({
    required this.name,
    required this.type,
    required this.location,
    required this.timestamp,
    required this.metadata,
  });
}

class MemoryAnalysis {
  final String type;
  final String title;
  final String description;
  final Map<String, String> details;
  final String data;

  MemoryAnalysis({
    required this.type,
    required this.title,
    required this.description,
    required this.details,
    required this.data,
  });
}

class FileSystemEntry {
  final String name;
  final bool isDirectory;
  final int size;
  final String lastModified;
  final bool isDeleted;

  FileSystemEntry({
    required this.name,
    required this.isDirectory,
    required this.size,
    required this.lastModified,
    required this.isDeleted,
  });
}