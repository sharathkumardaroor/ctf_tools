import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({super.key});

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  List<TimelineEvent> _events = [];
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'File System', 'Network', 'Process', 'Registry', 'User Activity'];

  @override
  void initState() {
    super.initState();
    _loadSampleEvents();
  }

  void _loadSampleEvents() {
    _events = [
      TimelineEvent(
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'File System',
        description: 'File created: C:\\Users\\Admin\\Documents\\secret.txt',
        severity: EventSeverity.medium,
        source: 'NTFS',
        details: {
          'File Size': '2,048 bytes',
          'Permissions': 'Read/Write',
          'Hash': 'a1b2c3d4e5f6...',
        },
      ),
      TimelineEvent(
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        type: 'Network',
        description: 'Outbound connection to 192.168.1.100:443',
        severity: EventSeverity.high,
        source: 'TCP',
        details: {
          'Protocol': 'HTTPS',
          'Duration': '45 seconds',
          'Data Transferred': '1.2 MB',
        },
      ),
      TimelineEvent(
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: 'Process',
        description: 'Process started: malware.exe (PID: 1234)',
        severity: EventSeverity.critical,
        source: 'Windows',
        details: {
          'Parent Process': 'explorer.exe',
          'Command Line': 'malware.exe --stealth',
          'Working Directory': 'C:\\Temp',
        },
      ),
      TimelineEvent(
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        type: 'Registry',
        description: 'Registry key modified: HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run',
        severity: EventSeverity.medium,
        source: 'Registry',
        details: {
          'Key': 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run',
          'Value': 'Malware',
          'Data': 'C:\\Temp\\malware.exe',
        },
      ),
      TimelineEvent(
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        type: 'User Activity',
        description: 'User login: Administrator',
        severity: EventSeverity.low,
        source: 'Windows Security',
        details: {
          'Login Type': 'Interactive',
          'Source IP': '192.168.1.50',
          'Session ID': '12345',
        },
      ),
      TimelineEvent(
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        type: 'File System',
        description: 'File deleted: C:\\Users\\Admin\\Documents\\evidence.pdf',
        severity: EventSeverity.high,
        source: 'NTFS',
        details: {
          'Original Size': '5.2 MB',
          'Deleted By': 'Administrator',
          'Recoverable': 'Yes',
        },
      ),
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildControls(),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: Column(
              children: [
                _buildTimelineHeader(),
                Expanded(
                  child: _buildTimelineContent(),
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
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.timeline, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline Analysis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Chronological analysis of system events and activities',
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

  Widget _buildControls() {
    return Row(
      children: [
        const Text(
          'Filter by type:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: _selectedFilter,
          items: _filters.map((filter) {
            return DropdownMenuItem(
              value: filter,
              child: Text(filter),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedFilter = value!;
            });
          },
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _exportTimeline,
          icon: const Icon(Icons.download),
          label: const Text('Export'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _refreshTimeline,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  Widget _buildTimelineHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF21262D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Timeline Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            '${_getFilteredEvents().length} events',
            style: const TextStyle(
              color: Color(0xFF8B949E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineContent() {
    final filteredEvents = _getFilteredEvents();
    
    if (filteredEvents.isEmpty) {
      return const Center(
        child: Text(
          'No events match the selected filter',
          style: TextStyle(color: Color(0xFF8B949E)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        final isLast = index == filteredEvents.length - 1;
        
        return _buildTimelineItem(event, isLast);
      },
    );
  }

  Widget _buildTimelineItem(TimelineEvent event, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getSeverityColor(event.severity),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF30363D),
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFF30363D),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Event content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              event.type,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: _getTypeColor(event.type),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              event.severity.name.toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: _getSeverityColor(event.severity),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          const Spacer(),
                          Text(
                            _formatTimestamp(event.timestamp),
                            style: const TextStyle(
                              color: Color(0xFF8B949E),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Source: ${event.source}',
                        style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 12,
                        ),
                      ),
                      if (event.details.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ExpansionTile(
                          title: const Text(
                            'Details',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: const EdgeInsets.only(top: 8),
                          children: [
                            ...event.details.entries.map((entry) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        '${entry.key}:',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SelectableText(
                                        entry.value,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TimelineEvent> _getFilteredEvents() {
    if (_selectedFilter == 'All') {
      return _events;
    }
    return _events.where((event) => event.type == _selectedFilter).toList();
  }

  Color _getSeverityColor(EventSeverity severity) {
    switch (severity) {
      case EventSeverity.low:
        return Colors.green;
      case EventSeverity.medium:
        return Colors.orange;
      case EventSeverity.high:
        return Colors.red;
      case EventSeverity.critical:
        return Colors.purple;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'File System':
        return Colors.blue;
      case 'Network':
        return Colors.cyan;
      case 'Process':
        return Colors.orange;
      case 'Registry':
        return Colors.purple;
      case 'User Activity':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  void _exportTimeline() {
    final timelineData = StringBuffer();
    timelineData.writeln('Timeline Export - ${DateTime.now()}');
    timelineData.writeln('=' * 50);
    
    for (final event in _getFilteredEvents()) {
      timelineData.writeln();
      timelineData.writeln('Timestamp: ${event.timestamp}');
      timelineData.writeln('Type: ${event.type}');
      timelineData.writeln('Severity: ${event.severity.name}');
      timelineData.writeln('Source: ${event.source}');
      timelineData.writeln('Description: ${event.description}');
      
      if (event.details.isNotEmpty) {
        timelineData.writeln('Details:');
        for (final entry in event.details.entries) {
          timelineData.writeln('  ${entry.key}: ${entry.value}');
        }
      }
      timelineData.writeln('-' * 30);
    }

    Clipboard.setData(ClipboardData(text: timelineData.toString()));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timeline exported to clipboard'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _refreshTimeline() {
    _loadSampleEvents();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timeline refreshed'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }
}

class TimelineEvent {
  final DateTime timestamp;
  final String type;
  final String description;
  final EventSeverity severity;
  final String source;
  final Map<String, String> details;

  TimelineEvent({
    required this.timestamp,
    required this.type,
    required this.description,
    required this.severity,
    required this.source,
    required this.details,
  });
}

enum EventSeverity {
  low,
  medium,
  high,
  critical,
}