import 'dart:typed_data';
import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import '../models/file_analysis_result.dart';

class FileAnalyzerService {
  
  Future<FileAnalysisResult> analyzeFile(String filePath, Uint8List bytes) async {
    final fileName = path.basename(filePath);
    final fileSize = bytes.length;
    final fileExtension = path.extension(filePath).toLowerCase();
    
    // Generate hashes
    final hashes = _generateHashes(bytes);
    
    // Determine file type and MIME type
    final fileType = _determineFileType(bytes, fileExtension);
    final mimeType = _determineMimeType(fileType, fileExtension);
    
    // Extract strings
    final strings = _extractStrings(bytes);
    
    // Analyze metadata
    final metadata = _analyzeMetadata(bytes, fileType);
    
    // Check for security flags
    final securityFlags = _checkSecurityFlags(bytes, strings, fileType);
    
    // Perform custom analysis based on file type
    final customAnalysis = _performCustomAnalysis(bytes, fileType, strings);
    
    // Generate thumbnail if it's an image
    final thumbnail = _generateThumbnail(bytes, fileType);
    
    return FileAnalysisResult(
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
      mimeType: mimeType,
      analyzedAt: DateTime.now(),
      hashes: hashes,
      metadata: metadata,
      strings: strings,
      securityFlags: securityFlags,
      customAnalysis: customAnalysis,
      thumbnail: thumbnail,
    );
  }
  
  Map<String, String> _generateHashes(Uint8List bytes) {
    return {
      'MD5': md5.convert(bytes).toString(),
      'SHA1': sha1.convert(bytes).toString(),
      'SHA256': sha256.convert(bytes).toString(),
    };
  }
  
  String _determineFileType(Uint8List bytes, String extension) {
    if (bytes.isEmpty) return 'Empty';
    
    // Check magic bytes
    final header = bytes.take(16).toList();
    
    // Common file signatures
    if (header.length >= 4) {
      // PNG
      if (header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47) {
        return 'PNG Image';
      }
      // JPEG
      if (header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF) {
        return 'JPEG Image';
      }
      // PDF
      if (header[0] == 0x25 && header[1] == 0x50 && header[2] == 0x44 && header[3] == 0x46) {
        return 'PDF Document';
      }
      // ZIP
      if (header[0] == 0x50 && header[1] == 0x4B) {
        return 'ZIP Archive';
      }
      // ELF
      if (header[0] == 0x7F && header[1] == 0x45 && header[2] == 0x4C && header[3] == 0x46) {
        return 'ELF Executable';
      }
      // PE
      if (header[0] == 0x4D && header[1] == 0x5A) {
        return 'PE Executable';
      }
    }
    
    // Check if it's text
    if (_isTextFile(bytes)) {
      return 'Text File';
    }
    
    // Fall back to extension
    switch (extension) {
      case '.txt': return 'Text File';
      case '.py': return 'Python Script';
      case '.js': return 'JavaScript File';
      case '.html': return 'HTML Document';
      case '.css': return 'CSS Stylesheet';
      case '.json': return 'JSON Data';
      case '.xml': return 'XML Document';
      case '.sql': return 'SQL Script';
      case '.sh': return 'Shell Script';
      case '.bat': return 'Batch File';
      case '.c': return 'C Source Code';
      case '.cpp': return 'C++ Source Code';
      case '.java': return 'Java Source Code';
      case '.php': return 'PHP Script';
      default: return 'Binary File';
    }
  }
  
  String _determineMimeType(String fileType, String extension) {
    switch (fileType) {
      case 'PNG Image': return 'image/png';
      case 'JPEG Image': return 'image/jpeg';
      case 'PDF Document': return 'application/pdf';
      case 'ZIP Archive': return 'application/zip';
      case 'Text File': return 'text/plain';
      case 'HTML Document': return 'text/html';
      case 'CSS Stylesheet': return 'text/css';
      case 'JavaScript File': return 'application/javascript';
      case 'JSON Data': return 'application/json';
      case 'XML Document': return 'application/xml';
      default: return 'application/octet-stream';
    }
  }
  
  bool _isTextFile(Uint8List bytes) {
    if (bytes.isEmpty) return false;
    
    // Check for null bytes (common in binary files)
    for (int i = 0; i < bytes.length && i < 1024; i++) {
      if (bytes[i] == 0) return false;
    }
    
    // Check if most bytes are printable ASCII
    int printableCount = 0;
    int sampleSize = bytes.length < 1024 ? bytes.length : 1024;
    
    for (int i = 0; i < sampleSize; i++) {
      int byte = bytes[i];
      if ((byte >= 32 && byte <= 126) || byte == 9 || byte == 10 || byte == 13) {
        printableCount++;
      }
    }
    
    return printableCount / sampleSize > 0.7;
  }
  
  List<String> _extractStrings(Uint8List bytes, {int minLength = 4}) {
    final strings = <String>[];
    final currentString = StringBuffer();
    
    for (int byte in bytes) {
      if (byte >= 32 && byte <= 126) {
        currentString.writeCharCode(byte);
      } else {
        if (currentString.length >= minLength) {
          strings.add(currentString.toString());
        }
        currentString.clear();
      }
    }
    
    if (currentString.length >= minLength) {
      strings.add(currentString.toString());
    }
    
    // Remove duplicates and sort by length (longest first)
    final uniqueStrings = strings.toSet().toList();
    uniqueStrings.sort((a, b) => b.length.compareTo(a.length));
    
    // Return top 100 strings
    return uniqueStrings.take(100).toList();
  }
  
  FileMetadata _analyzeMetadata(Uint8List bytes, String fileType) {
    return FileMetadata(
      encoding: _detectEncoding(bytes),
      isExecutable: _isExecutable(fileType),
      isArchive: _isArchive(fileType),
      isImage: _isImage(fileType),
      isText: _isTextFile(bytes),
      exifData: _extractExifData(bytes, fileType),
      embeddedFiles: _findEmbeddedFiles(bytes),
    );
  }
  
  String? _detectEncoding(Uint8List bytes) {
    if (bytes.isEmpty) return null;
    
    // Check for BOM
    if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
      return 'UTF-8 with BOM';
    }
    
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
      return 'UTF-16 LE';
    }
    
    if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
      return 'UTF-16 BE';
    }
    
    // Simple heuristic for UTF-8
    try {
      utf8.decode(bytes);
      return 'UTF-8';
    } catch (e) {
      return 'ASCII/Binary';
    }
  }
  
  bool _isExecutable(String fileType) {
    return fileType.contains('Executable') || fileType.contains('ELF') || fileType.contains('PE');
  }
  
  bool _isArchive(String fileType) {
    return fileType.contains('Archive') || fileType.contains('ZIP');
  }
  
  bool _isImage(String fileType) {
    return fileType.contains('Image');
  }
  
  Map<String, dynamic> _extractExifData(Uint8List bytes, String fileType) {
    // Simplified EXIF extraction for images
    if (!_isImage(fileType)) return {};
    
    // This is a placeholder - in a real implementation, you'd use a proper EXIF library
    return {
      'width': 'Unknown',
      'height': 'Unknown',
      'format': fileType,
    };
  }
  
  List<String> _findEmbeddedFiles(Uint8List bytes) {
    final embeddedFiles = <String>[];
    
    // Look for common file signatures within the file
    final signatures = {
      'PNG': [0x89, 0x50, 0x4E, 0x47],
      'JPEG': [0xFF, 0xD8, 0xFF],
      'PDF': [0x25, 0x50, 0x44, 0x46],
      'ZIP': [0x50, 0x4B],
    };
    
    for (final entry in signatures.entries) {
      final signature = entry.value;
      final name = entry.key;
      
      for (int i = 0; i <= bytes.length - signature.length; i++) {
        bool match = true;
        for (int j = 0; j < signature.length; j++) {
          if (bytes[i + j] != signature[j]) {
            match = false;
            break;
          }
        }
        if (match) {
          embeddedFiles.add('$name at offset $i');
        }
      }
    }
    
    return embeddedFiles;
  }
  
  List<SecurityFlag> _checkSecurityFlags(Uint8List bytes, List<String> strings, String fileType) {
    final flags = <SecurityFlag>[];
    
    // Check for suspicious strings
    final suspiciousPatterns = [
      'password',
      'secret',
      'key',
      'token',
      'api_key',
      'private',
      'confidential',
      'admin',
      'root',
      'flag{',
      'CTF{',
      'eval(',
      'exec(',
      'system(',
      'shell_exec',
      'base64_decode',
      'http://',
      'https://',
      'ftp://',
    ];
    
    for (final pattern in suspiciousPatterns) {
      for (final string in strings) {
        if (string.toLowerCase().contains(pattern.toLowerCase())) {
          flags.add(SecurityFlag(
            type: 'Suspicious String',
            description: 'Found potentially sensitive string: "$pattern"',
            level: _getSeverityLevel(pattern),
            recommendation: 'Review the context of this string',
          ));
          break;
        }
      }
    }
    
    // Check for executable files
    if (_isExecutable(fileType)) {
      flags.add(SecurityFlag(
        type: 'Executable File',
        description: 'This file is executable and may contain code',
        level: SecurityLevel.medium,
        recommendation: 'Analyze in a sandboxed environment',
      ));
    }
    
    // Check file size
    if (bytes.length > 10 * 1024 * 1024) { // 10MB
      flags.add(SecurityFlag(
        type: 'Large File',
        description: 'File is unusually large (${(bytes.length / 1024 / 1024).toStringAsFixed(1)} MB)',
        level: SecurityLevel.info,
        recommendation: 'Large files may hide embedded content',
      ));
    }
    
    return flags;
  }
  
  SecurityLevel _getSeverityLevel(String pattern) {
    switch (pattern.toLowerCase()) {
      case 'flag{':
      case 'ctf{':
        return SecurityLevel.high;
      case 'password':
      case 'secret':
      case 'private':
        return SecurityLevel.medium;
      case 'eval(':
      case 'exec(':
      case 'system(':
        return SecurityLevel.high;
      default:
        return SecurityLevel.low;
    }
  }
  
  Map<String, dynamic> _performCustomAnalysis(Uint8List bytes, String fileType, List<String> strings) {
    final analysis = <String, dynamic>{};
    
    // Entropy analysis
    analysis['entropy'] = _calculateEntropy(bytes);
    
    // Character frequency analysis
    analysis['char_frequency'] = _analyzeCharacterFrequency(bytes);
    
    // Base64 detection
    analysis['base64_strings'] = _findBase64Strings(strings);
    
    // URL extraction
    analysis['urls'] = _extractUrls(strings);
    
    // Email extraction
    analysis['emails'] = _extractEmails(strings);
    
    // Hex patterns
    analysis['hex_patterns'] = _findHexPatterns(strings);
    
    return analysis;
  }
  
  double _calculateEntropy(Uint8List bytes) {
    if (bytes.isEmpty) return 0.0;
    
    final frequency = List<int>.filled(256, 0);
    for (final byte in bytes) {
      frequency[byte]++;
    }
    
    double entropy = 0.0;
    final length = bytes.length;
    
    for (final count in frequency) {
      if (count > 0) {
        final probability = count / length;
        entropy -= probability * (math.log(probability) / math.ln2); // log base 2
      }
    }
    
    return entropy;
  }
  
  Map<String, int> _analyzeCharacterFrequency(Uint8List bytes) {
    final frequency = <String, int>{};
    
    for (final byte in bytes) {
      if (byte >= 32 && byte <= 126) {
        final char = String.fromCharCode(byte);
        frequency[char] = (frequency[char] ?? 0) + 1;
      }
    }
    
    // Return top 10 most frequent characters
    final sorted = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted.take(10));
  }
  
  List<String> _findBase64Strings(List<String> strings) {
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]{4,}={0,2}$');
    return strings.where((s) => s.length >= 8 && base64Pattern.hasMatch(s)).toList();
  }
  
  List<String> _extractUrls(List<String> strings) {
    final urlPattern = RegExp(r'https?://[^\s]+');
    final urls = <String>[];
    
    for (final string in strings) {
      final matches = urlPattern.allMatches(string);
      for (final match in matches) {
        urls.add(match.group(0)!);
      }
    }
    
    return urls.toSet().toList();
  }
  
  List<String> _extractEmails(List<String> strings) {
    final emailPattern = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
    final emails = <String>[];
    
    for (final string in strings) {
      final matches = emailPattern.allMatches(string);
      for (final match in matches) {
        emails.add(match.group(0)!);
      }
    }
    
    return emails.toSet().toList();
  }
  
  List<String> _findHexPatterns(List<String> strings) {
    final hexPattern = RegExp(r'^[0-9A-Fa-f]{8,}$');
    return strings.where((s) => hexPattern.hasMatch(s)).toList();
  }
  
  Uint8List? _generateThumbnail(Uint8List bytes, String fileType) {
    // Placeholder for thumbnail generation
    // In a real implementation, you'd use the image package to generate thumbnails
    if (_isImage(fileType)) {
      // Return the original bytes for now - in practice, you'd resize the image
      return bytes.length > 1024 ? bytes.sublist(0, 1024) : bytes;
    }
    return null;
  }
}