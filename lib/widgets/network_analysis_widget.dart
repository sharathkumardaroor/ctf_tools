import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math' as math;

class NetworkAnalysisWidget extends StatefulWidget {
  const NetworkAnalysisWidget({super.key});

  @override
  State<NetworkAnalysisWidget> createState() => _NetworkAnalysisWidgetState();
}

class _NetworkAnalysisWidgetState extends State<NetworkAnalysisWidget> with TickerProviderStateMixin {
  late TabController _networkTabController;
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _packetDataController = TextEditingController();
  
  List<NetworkScanResult> _scanResults = [];
  List<PacketAnalysis> _packetAnalyses = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _networkTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _networkTabController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _urlController.dispose();
    _packetDataController.dispose();
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
                  controller: _networkTabController,
                  labelColor: const Color(0xFF00D4FF),
                  unselectedLabelColor: const Color(0xFF8B949E),
                  indicatorColor: const Color(0xFF00D4FF),
                  tabs: const [
                    Tab(text: 'Port Scanner'),
                    Tab(text: 'Packet Analysis'),
                    Tab(text: 'DNS Tools'),
                    Tab(text: 'Web Analysis'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _networkTabController,
                    children: [
                      _buildPortScannerTab(),
                      _buildPacketAnalysisTab(),
                      _buildDNSToolsTab(),
                      _buildWebAnalysisTab(),
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
              colors: [Color(0xFF00D4FF), Color(0xFF0EA5E9)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.network_check, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Network Analysis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Advanced network reconnaissance and analysis tools',
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

  Widget _buildPortScannerTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: 'Target IP/Domain',
                    hintText: '192.168.1.1 or example.com',
                    prefixIcon: Icon(Icons.computer),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'Port Range',
                    hintText: '1-1000',
                    prefixIcon: Icon(Icons.settings_ethernet),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _performPortScan,
                icon: _isScanning 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_isScanning ? 'Scanning...' : 'Scan'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan Results:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _scanResults.isEmpty
                ? const Center(
                    child: Text(
                      'No scan results yet. Enter a target and click Scan.',
                      style: TextStyle(color: Color(0xFF8B949E)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final result = _scanResults[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: result.isOpen ? Colors.green : Colors.red,
                            child: Icon(
                              result.isOpen ? Icons.lock_open : Icons.lock,
                              color: Colors.white,
                            ),
                          ),
                          title: Text('Port ${result.port}'),
                          subtitle: Text(
                            '${result.service} - ${result.isOpen ? "Open" : "Closed"}\n'
                            'Response time: ${result.responseTime}ms',
                          ),
                          trailing: result.banner.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.info),
                                  onPressed: () => _showBannerInfo(result.banner),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacketAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _packetDataController,
            decoration: const InputDecoration(
              labelText: 'Packet Data (Hex)',
              hintText: 'Enter packet data in hexadecimal format...',
              prefixIcon: Icon(Icons.data_usage),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _analyzePacket,
            icon: const Icon(Icons.analytics),
            label: const Text('Analyze Packet'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Packet Analysis Results:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _packetAnalyses.isEmpty
                ? const Center(
                    child: Text(
                      'No packet analyses yet. Enter packet data and click Analyze.',
                      style: TextStyle(color: Color(0xFF8B949E)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _packetAnalyses.length,
                    itemBuilder: (context, index) {
                      final analysis = _packetAnalyses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: Icon(
                            _getProtocolIcon(analysis.protocol),
                            color: const Color(0xFF00D4FF),
                          ),
                          title: Text('${analysis.protocol} Packet'),
                          subtitle: Text('${analysis.sourceIP} → ${analysis.destIP}'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('Protocol', analysis.protocol),
                                  _buildInfoRow('Source IP', analysis.sourceIP),
                                  _buildInfoRow('Destination IP', analysis.destIP),
                                  _buildInfoRow('Source Port', analysis.sourcePort.toString()),
                                  _buildInfoRow('Destination Port', analysis.destPort.toString()),
                                  _buildInfoRow('Packet Size', '${analysis.packetSize} bytes'),
                                  if (analysis.payload.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    const Text('Payload:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF21262D),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: SelectableText(
                                        analysis.payload,
                                        style: const TextStyle(fontFamily: 'monospace'),
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

  Widget _buildDNSToolsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Domain Name',
              hintText: 'example.com',
              prefixIcon: Icon(Icons.dns),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _performDNSLookup('A'),
                icon: const Icon(Icons.search),
                label: const Text('A Record'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performDNSLookup('AAAA'),
                icon: const Icon(Icons.search),
                label: const Text('AAAA Record'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performDNSLookup('MX'),
                icon: const Icon(Icons.email),
                label: const Text('MX Record'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performDNSLookup('TXT'),
                icon: const Icon(Icons.text_fields),
                label: const Text('TXT Record'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performDNSLookup('NS'),
                icon: const Icon(Icons.dns),
                label: const Text('NS Record'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'DNS Lookup Results:',
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
                  'DNS lookup results will appear here',
                  style: TextStyle(color: Color(0xFF8B949E)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'https://example.com',
              prefixIcon: Icon(Icons.web),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _analyzeWebHeaders,
                icon: const Icon(Icons.http),
                label: const Text('Analyze Headers'),
              ),
              ElevatedButton.icon(
                onPressed: _checkSSLCertificate,
                icon: const Icon(Icons.security),
                label: const Text('SSL Certificate'),
              ),
              ElevatedButton.icon(
                onPressed: _scanWebVulnerabilities,
                icon: const Icon(Icons.bug_report),
                label: const Text('Vulnerability Scan'),
              ),
              ElevatedButton.icon(
                onPressed: _analyzeWebTechnologies,
                icon: const Icon(Icons.code),
                label: const Text('Technology Stack'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Web Analysis Results:',
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
                  'Web analysis results will appear here',
                  style: TextStyle(color: Color(0xFF8B949E)),
                ),
              ),
            ),
          ),
        ],
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

  IconData _getProtocolIcon(String protocol) {
    switch (protocol.toUpperCase()) {
      case 'TCP':
        return Icons.swap_horiz;
      case 'UDP':
        return Icons.send;
      case 'HTTP':
        return Icons.http;
      case 'HTTPS':
        return Icons.https;
      case 'DNS':
        return Icons.dns;
      default:
        return Icons.device_hub;
    }
  }

  void _performPortScan() {
    if (_ipController.text.isEmpty) return;
    
    setState(() {
      _isScanning = true;
      _scanResults.clear();
    });

    // Simulate port scanning
    final target = _ipController.text;
    final portRange = _portController.text.isEmpty ? '1-100' : _portController.text;
    final ports = _parsePortRange(portRange);

    Future.delayed(const Duration(seconds: 2), () {
      final results = <NetworkScanResult>[];
      
      for (final port in ports.take(20)) { // Limit to 20 ports for demo
        final isOpen = math.Random().nextBool();
        results.add(NetworkScanResult(
          port: port,
          isOpen: isOpen,
          service: _getServiceName(port),
          responseTime: math.Random().nextInt(100) + 10,
          banner: isOpen && math.Random().nextBool() ? 'Service banner for port $port' : '',
        ));
      }

      setState(() {
        _scanResults = results;
        _isScanning = false;
      });
    });
  }

  List<int> _parsePortRange(String range) {
    if (range.contains('-')) {
      final parts = range.split('-');
      if (parts.length == 2) {
        final start = int.tryParse(parts[0]) ?? 1;
        final end = int.tryParse(parts[1]) ?? 100;
        return List.generate(end - start + 1, (i) => start + i);
      }
    }
    final port = int.tryParse(range);
    return port != null ? [port] : List.generate(100, (i) => i + 1);
  }

  String _getServiceName(int port) {
    const services = {
      21: 'FTP',
      22: 'SSH',
      23: 'Telnet',
      25: 'SMTP',
      53: 'DNS',
      80: 'HTTP',
      110: 'POP3',
      143: 'IMAP',
      443: 'HTTPS',
      993: 'IMAPS',
      995: 'POP3S',
    };
    return services[port] ?? 'Unknown';
  }

  void _analyzePacket() {
    final packetData = _packetDataController.text.trim();
    if (packetData.isEmpty) return;

    // Simulate packet analysis
    final analysis = PacketAnalysis(
      protocol: 'TCP',
      sourceIP: '192.168.1.100',
      destIP: '192.168.1.1',
      sourcePort: 12345,
      destPort: 80,
      packetSize: packetData.length ~/ 2,
      payload: 'GET / HTTP/1.1\r\nHost: example.com\r\n\r\n',
    );

    setState(() {
      _packetAnalyses.insert(0, analysis);
    });
  }

  void _performDNSLookup(String recordType) {
    // Placeholder for DNS lookup functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$recordType record lookup for ${_urlController.text}'),
        backgroundColor: const Color(0xFF00D4FF),
      ),
    );
  }

  void _analyzeWebHeaders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Web header analysis started'),
        backgroundColor: Color(0xFF00D4FF),
      ),
    );
  }

  void _checkSSLCertificate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SSL certificate check started'),
        backgroundColor: Color(0xFF00D4FF),
      ),
    );
  }

  void _scanWebVulnerabilities() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Web vulnerability scan started'),
        backgroundColor: Color(0xFF00D4FF),
      ),
    );
  }

  void _analyzeWebTechnologies() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Technology stack analysis started'),
        backgroundColor: Color(0xFF00D4FF),
      ),
    );
  }

  void _showBannerInfo(String banner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service Banner'),
        content: SelectableText(banner),
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

class NetworkScanResult {
  final int port;
  final bool isOpen;
  final String service;
  final int responseTime;
  final String banner;

  NetworkScanResult({
    required this.port,
    required this.isOpen,
    required this.service,
    required this.responseTime,
    required this.banner,
  });
}

class PacketAnalysis {
  final String protocol;
  final String sourceIP;
  final String destIP;
  final int sourcePort;
  final int destPort;
  final int packetSize;
  final String payload;

  PacketAnalysis({
    required this.protocol,
    required this.sourceIP,
    required this.destIP,
    required this.sourcePort,
    required this.destPort,
    required this.packetSize,
    required this.payload,
  });
}