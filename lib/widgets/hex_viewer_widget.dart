import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/file_analysis_provider.dart';

class HexViewerWidget extends StatefulWidget {
  const HexViewerWidget({super.key});

  @override
  State<HexViewerWidget> createState() => _HexViewerWidgetState();
}

class _HexViewerWidgetState extends State<HexViewerWidget> {
  final ScrollController _scrollController = ScrollController();
  int _bytesPerRow = 16;
  final int _currentOffset = 0;
  final int _maxDisplayBytes = 1024 * 16; // Display max 16KB at once
  String _searchQuery = '';
  final List<int> _searchResults = [];
  int _currentSearchIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FileAnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.currentFileBytes == null) {
          return Card(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.code,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No file loaded',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upload a file to view its hex representation',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(provider),
            const SizedBox(height: 16),
            _buildControls(provider),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    _buildHexHeader(),
                    Expanded(
                      child: _buildHexContent(provider.currentFileBytes!),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(FileAnalysisProvider provider) {
    final fileName = provider.currentFilePath?.split('/').last ?? 'Unknown';
    final fileSize = provider.currentFileBytes?.length ?? 0;

    return Row(
      children: [
        const Icon(Icons.code, color: Colors.blue),
        const SizedBox(width: 8),
        const Text(
          'Hex Viewer',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          '$fileName (${_formatFileSize(fileSize)})',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildControls(FileAnalysisProvider provider) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search (hex or text)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _performSearch(provider.currentFileBytes!);
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        if (_searchResults.isNotEmpty) ...[
          Text('${_currentSearchIndex + 1}/${_searchResults.length}'),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: _currentSearchIndex > 0 ? _previousSearchResult : null,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: _currentSearchIndex < _searchResults.length - 1 ? _nextSearchResult : null,
          ),
          const SizedBox(width: 16),
        ],
        DropdownButton<int>(
          value: _bytesPerRow,
          items: [8, 16, 32].map((bytes) {
            return DropdownMenuItem(
              value: bytes,
              child: Text('$bytes bytes/row'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _bytesPerRow = value!;
            });
          },
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _exportHex(provider.currentFileBytes!),
          icon: const Icon(Icons.download),
          label: const Text('Export'),
        ),
      ],
    );
  }

  Widget _buildHexHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              'Offset',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              List.generate(_bytesPerRow, (i) => i.toRadixString(16).padLeft(2, '0')).join(' '),
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Text(
              'ASCII',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHexContent(List<int> bytes) {
    final displayBytes = bytes.length > _maxDisplayBytes 
        ? bytes.sublist(_currentOffset, (_currentOffset + _maxDisplayBytes).clamp(0, bytes.length))
        : bytes;

    return Scrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: (displayBytes.length / _bytesPerRow).ceil(),
        itemBuilder: (context, index) {
          final rowOffset = _currentOffset + (index * _bytesPerRow);
          final rowBytes = displayBytes.skip(index * _bytesPerRow).take(_bytesPerRow).toList();
          
          return _buildHexRow(rowOffset, rowBytes);
        },
      ),
    );
  }

  Widget _buildHexRow(int offset, List<int> rowBytes) {
    final hexString = rowBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    final asciiString = rowBytes.map((b) => (b >= 32 && b <= 126) ? String.fromCharCode(b) : '.').join('');

    // Check if this row contains search results
    final hasSearchResult = _searchResults.any((resultOffset) => 
        resultOffset >= offset && resultOffset < offset + rowBytes.length);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      color: hasSearchResult ? Colors.yellow.withValues(alpha: 0.2) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: SelectableText(
              offset.toRadixString(16).padLeft(8, '0').toUpperCase(),
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.blue,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: SelectableText(
              hexString.padRight(_bytesPerRow * 3 - 1),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: SelectableText(
              asciiString,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch(List<int> bytes) {
    _searchResults.clear();
    _currentSearchIndex = -1;

    if (_searchQuery.isEmpty) {
      setState(() {});
      return;
    }

    // Try hex search first
    if (_searchQuery.replaceAll(' ', '').length % 2 == 0) {
      try {
        final hexBytes = _parseHexString(_searchQuery);
        if (hexBytes.isNotEmpty) {
          _searchResults.addAll(_findBytePattern(bytes, hexBytes));
        }
      } catch (e) {
        // Not valid hex, try text search
      }
    }

    // Text search
    if (_searchResults.isEmpty) {
      final textBytes = _searchQuery.codeUnits;
      _searchResults.addAll(_findBytePattern(bytes, textBytes));
    }

    if (_searchResults.isNotEmpty) {
      _currentSearchIndex = 0;
    }

    setState(() {});
  }

  List<int> _parseHexString(String hex) {
    final cleanHex = hex.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    final bytes = <int>[];
    
    for (int i = 0; i < cleanHex.length; i += 2) {
      if (i + 1 < cleanHex.length) {
        bytes.add(int.parse(cleanHex.substring(i, i + 2), radix: 16));
      }
    }
    
    return bytes;
  }

  List<int> _findBytePattern(List<int> haystack, List<int> needle) {
    final results = <int>[];
    
    for (int i = 0; i <= haystack.length - needle.length; i++) {
      bool match = true;
      for (int j = 0; j < needle.length; j++) {
        if (haystack[i + j] != needle[j]) {
          match = false;
          break;
        }
      }
      if (match) {
        results.add(i);
      }
    }
    
    return results;
  }

  void _previousSearchResult() {
    if (_currentSearchIndex > 0) {
      setState(() {
        _currentSearchIndex--;
      });
      _scrollToSearchResult();
    }
  }

  void _nextSearchResult() {
    if (_currentSearchIndex < _searchResults.length - 1) {
      setState(() {
        _currentSearchIndex++;
      });
      _scrollToSearchResult();
    }
  }

  void _scrollToSearchResult() {
    if (_currentSearchIndex >= 0 && _currentSearchIndex < _searchResults.length) {
      final offset = _searchResults[_currentSearchIndex];
      final rowIndex = offset ~/ _bytesPerRow;
      
      _scrollController.animateTo(
        rowIndex * 24.0, // Approximate row height
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _exportHex(List<int> bytes) {
    final hexString = StringBuffer();
    
    for (int i = 0; i < bytes.length; i += _bytesPerRow) {
      final rowBytes = bytes.skip(i).take(_bytesPerRow).toList();
      final offset = i.toRadixString(16).padLeft(8, '0').toUpperCase();
      final hex = rowBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      final ascii = rowBytes.map((b) => (b >= 32 && b <= 126) ? String.fromCharCode(b) : '.').join('');
      
      hexString.writeln('$offset  ${hex.padRight(_bytesPerRow * 3 - 1)}  $ascii');
    }

    Clipboard.setData(ClipboardData(text: hexString.toString()));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hex dump copied to clipboard'),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}