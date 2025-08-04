enum ChallengeCategory {
  web,
  crypto,
  forensics,
  reversing,
  pwn,
  misc,
  osint,
  steganography,
}

enum ChallengeDifficulty {
  easy,
  medium,
  hard,
  insane,
}

class CTFChallenge {
  final String id;
  final String name;
  final String description;
  final ChallengeCategory category;
  final ChallengeDifficulty difficulty;
  final int points;
  final List<String> tags;
  final List<String> files;
  final List<String> notes;
  final bool isSolved;
  final String? flag;
  final DateTime createdAt;
  final DateTime? solvedAt;
  final String? url;

  CTFChallenge({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.points,
    required this.tags,
    required this.files,
    required this.notes,
    required this.isSolved,
    this.flag,
    required this.createdAt,
    this.solvedAt,
    this.url,
  });

  CTFChallenge copyWith({
    String? id,
    String? name,
    String? description,
    ChallengeCategory? category,
    ChallengeDifficulty? difficulty,
    int? points,
    List<String>? tags,
    List<String>? files,
    List<String>? notes,
    bool? isSolved,
    String? flag,
    DateTime? createdAt,
    DateTime? solvedAt,
    String? url,
  }) {
    return CTFChallenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      points: points ?? this.points,
      tags: tags ?? this.tags,
      files: files ?? this.files,
      notes: notes ?? this.notes,
      isSolved: isSolved ?? this.isSolved,
      flag: flag ?? this.flag,
      createdAt: createdAt ?? this.createdAt,
      solvedAt: solvedAt ?? this.solvedAt,
      url: url ?? this.url,
    );
  }
}