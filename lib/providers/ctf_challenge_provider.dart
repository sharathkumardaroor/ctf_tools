import 'package:flutter/foundation.dart';
import '../models/ctf_challenge.dart';

class CTFChallengeProvider extends ChangeNotifier {
  final List<CTFChallenge> _challenges = [];
  CTFChallenge? _selectedChallenge;
  
  List<CTFChallenge> get challenges => _challenges;
  CTFChallenge? get selectedChallenge => _selectedChallenge;
  
  void addChallenge(CTFChallenge challenge) {
    _challenges.add(challenge);
    notifyListeners();
  }
  
  void removeChallenge(String id) {
    _challenges.removeWhere((challenge) => challenge.id == id);
    if (_selectedChallenge?.id == id) {
      _selectedChallenge = null;
    }
    notifyListeners();
  }
  
  void selectChallenge(CTFChallenge challenge) {
    _selectedChallenge = challenge;
    notifyListeners();
  }
  
  void updateChallenge(CTFChallenge updatedChallenge) {
    final index = _challenges.indexWhere((c) => c.id == updatedChallenge.id);
    if (index != -1) {
      _challenges[index] = updatedChallenge;
      if (_selectedChallenge?.id == updatedChallenge.id) {
        _selectedChallenge = updatedChallenge;
      }
      notifyListeners();
    }
  }
  
  void addNoteToChallenge(String challengeId, String note) {
    final challenge = _challenges.firstWhere((c) => c.id == challengeId);
    final updatedChallenge = challenge.copyWith(
      notes: [...challenge.notes, note],
    );
    updateChallenge(updatedChallenge);
  }
  
  void markChallengeAsSolved(String challengeId, String flag) {
    final challenge = _challenges.firstWhere((c) => c.id == challengeId);
    final updatedChallenge = challenge.copyWith(
      isSolved: true,
      flag: flag,
      solvedAt: DateTime.now(),
    );
    updateChallenge(updatedChallenge);
  }
}