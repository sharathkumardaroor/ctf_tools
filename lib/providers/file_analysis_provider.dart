import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/file_analysis_result.dart';
import '../services/file_analyzer_service.dart';

class FileAnalysisProvider extends ChangeNotifier {
  final FileAnalyzerService _analyzerService = FileAnalyzerService();
  
  final List<FileAnalysisResult> _analysisResults = [];
  bool _isAnalyzing = false;
  String? _currentFilePath;
  Uint8List? _currentFileBytes;
  
  List<FileAnalysisResult> get analysisResults => _analysisResults;
  bool get isAnalyzing => _isAnalyzing;
  String? get currentFilePath => _currentFilePath;
  Uint8List? get currentFileBytes => _currentFileBytes;
  
  Future<void> analyzeFile(String filePath) async {
    _isAnalyzing = true;
    _currentFilePath = filePath;
    notifyListeners();
    
    try {
      final file = File(filePath);
      _currentFileBytes = await file.readAsBytes();
      
      final result = await _analyzerService.analyzeFile(filePath, _currentFileBytes!);
      
      // Remove any existing analysis for this file
      _analysisResults.removeWhere((r) => r.filePath == filePath);
      
      // Add new analysis result
      _analysisResults.insert(0, result);
      
    } catch (e) {
      debugPrint('Error analyzing file: $e');
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }
  
  void removeAnalysis(String filePath) {
    _analysisResults.removeWhere((result) => result.filePath == filePath);
    notifyListeners();
  }
  
  void clearAllAnalyses() {
    _analysisResults.clear();
    _currentFilePath = null;
    _currentFileBytes = null;
    notifyListeners();
  }
  
  FileAnalysisResult? getAnalysisForFile(String filePath) {
    try {
      return _analysisResults.firstWhere((result) => result.filePath == filePath);
    } catch (e) {
      return null;
    }
  }
}