import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_analysis_provider.dart';
import '../widgets/file_upload_widget.dart';
import '../widgets/analysis_results_widget.dart';
import '../widgets/challenge_list_widget.dart';
import '../widgets/statistics_widget.dart';
import '../widgets/hex_viewer_widget.dart';
import '../widgets/tools_panel_widget.dart';
import '../widgets/network_analysis_widget.dart';
import '../widgets/forensics_widget.dart';
import '../widgets/timeline_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.security, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CTF Analyzer Pro',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Advanced Cybersecurity Analysis Platform',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B949E),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Consumer<FileAnalysisProvider>(
            builder: (context, provider, child) {
              return provider.isAnalyzing
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        provider.clearAllAnalyses();
                      },
                      tooltip: 'Clear All Analyses',
                    );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context);
            },
            tooltip: 'Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF00D4FF),
          indicatorWeight: 3,
          labelColor: const Color(0xFF00D4FF),
          unselectedLabelColor: const Color(0xFF8B949E),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
            Tab(icon: Icon(Icons.analytics_outlined), text: 'File Analysis'),
            Tab(icon: Icon(Icons.flag_outlined), text: 'Challenges'),
            Tab(icon: Icon(Icons.code_outlined), text: 'Hex Viewer'),
            Tab(icon: Icon(Icons.build_outlined), text: 'Tools'),
            Tab(icon: Icon(Icons.network_check_outlined), text: 'Network'),
            Tab(icon: Icon(Icons.memory_outlined), text: 'Forensics'),
            Tab(icon: Icon(Icons.timeline_outlined), text: 'Timeline'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildFileAnalysisTab(),
          _buildChallengesTab(),
          _buildHexViewerTab(),
          _buildToolsTab(),
          _buildNetworkTab(),
          _buildForensicsTab(),
          _buildTimelineTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CTF Analysis Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          StatisticsWidget(),
          SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: FileUploadWidget(),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: AnalysisResultsWidget(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileAnalysisTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          FileUploadWidget(),
          SizedBox(height: 16),
          Expanded(
            child: AnalysisResultsWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: ChallengeListWidget(),
    );
  }

  Widget _buildHexViewerTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: HexViewerWidget(),
    );
  }

  Widget _buildToolsTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: ToolsPanelWidget(),
    );
  }

  Widget _buildNetworkTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: NetworkAnalysisWidget(),
    );
  }

  Widget _buildForensicsTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: ForensicsWidget(),
    );
  }

  Widget _buildTimelineTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: TimelineWidget(),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.palette),
              title: Text('Theme'),
              subtitle: Text('Dark theme enabled'),
            ),
            ListTile(
              leading: Icon(Icons.memory),
              title: Text('Max file size'),
              subtitle: Text('100 MB'),
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Security scanning'),
              subtitle: Text('Enabled'),
            ),
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