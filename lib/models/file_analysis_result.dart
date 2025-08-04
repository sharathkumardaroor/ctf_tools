import 'dart:typed_data';

class FileAnalysisResult {
  final String filePath;
  final String fileName;
  final int fileSize;
  final String fileType;
  final String mimeType;
  final DateTime analyzedAt;
  final Map<String, String> hashes;
  final FileMetadata metadata;
  final List<String> strings;
  final List<SecurityFlag> securityFlags;
  final Map<String, dynamic> customAnalysis;
  final Uint8List? thumbnail;

  FileAnalysisResult({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.mimeType,
    required this.analyzedAt,
    required this.hashes,
    required this.metadata,
    required this.strings,
    required this.securityFlags,
    required this.customAnalysis,
    this.thumbnail,
  });
}

class FileMetadata {
  final String? encoding;
  final bool isExecutable;
  final bool isArchive;
  final bool isImage;
  final bool isText;
  final Map<String, dynamic> exifData;
  final List<String> embeddedFiles;

  FileMetadata({
    this.encoding,
    required this.isExecutable,
    required this.isArchive,
    required this.isImage,
    required this.isText,
    required this.exifData,
    required this.embeddedFiles,
  });
}

class SecurityFlag {
  final String type;
  final String description;
  final SecurityLevel level;
  final String? recommendation;

  SecurityFlag({
    required this.type,
    required this.description,
    required this.level,
    this.recommendation,
  });
}

enum SecurityLevel {
  info,
  low,
  medium,
  high,
  critical,
}