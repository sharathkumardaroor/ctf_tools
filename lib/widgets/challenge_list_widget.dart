import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ctf_challenge_provider.dart';
import '../models/ctf_challenge.dart';

class ChallengeListWidget extends StatefulWidget {
  const ChallengeListWidget({super.key});

  @override
  State<ChallengeListWidget> createState() => _ChallengeListWidgetState();
}

class _ChallengeListWidgetState extends State<ChallengeListWidget> {
  ChallengeCategory? _selectedCategory;
  bool _showSolvedOnly = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flag, color: Colors.orange),
            const SizedBox(width: 8),
            const Text(
              'CTF Challenges',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _showAddChallengeDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Challenge'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFilters(),
        const SizedBox(height: 16),
        Expanded(
          child: _buildChallengeList(),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        DropdownButton<ChallengeCategory?>(
          value: _selectedCategory,
          hint: const Text('All Categories'),
          items: [
            const DropdownMenuItem<ChallengeCategory?>(
              value: null,
              child: Text('All Categories'),
            ),
            ...ChallengeCategory.values.map((category) {
              return DropdownMenuItem<ChallengeCategory>(
                value: category,
                child: Text(_getCategoryDisplayName(category)),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
        const SizedBox(width: 16),
        FilterChip(
          label: const Text('Solved Only'),
          selected: _showSolvedOnly,
          onSelected: (selected) {
            setState(() {
              _showSolvedOnly = selected;
            });
          },
        ),
      ],
    );
  }

  Widget _buildChallengeList() {
    return Consumer<CTFChallengeProvider>(
      builder: (context, provider, child) {
        var challenges = provider.challenges;

        // Apply filters
        if (_selectedCategory != null) {
          challenges = challenges.where((c) => c.category == _selectedCategory).toList();
        }
        if (_showSolvedOnly) {
          challenges = challenges.where((c) => c.isSolved).toList();
        }

        if (challenges.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.flag_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  challenges.isEmpty ? 'No challenges yet' : 'No challenges match your filters',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add your first CTF challenge to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            return _buildChallengeCard(challenge, provider);
          },
        );
      },
    );
  }

  Widget _buildChallengeCard(CTFChallenge challenge, CTFChallengeProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(challenge.category),
          child: Icon(
            _getCategoryIcon(challenge.category),
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                challenge.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: challenge.isSolved ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (challenge.isSolved)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_getCategoryDisplayName(challenge.category)} • ${challenge.points} pts'),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    _getDifficultyDisplayName(challenge.difficulty),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getDifficultyColor(challenge.difficulty),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                ...challenge.tags.take(2).map((tag) => Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.grey.withValues(alpha: 0.3),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: challenge.isSolved ? 'unsolved' : 'solved',
              child: Row(
                children: [
                  Icon(challenge.isSolved ? Icons.undo : Icons.check),
                  const SizedBox(width: 8),
                  Text(challenge.isSolved ? 'Mark Unsolved' : 'Mark Solved'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditChallengeDialog(challenge);
                break;
              case 'solved':
                _showSolvedDialog(challenge);
                break;
              case 'unsolved':
                provider.updateChallenge(challenge.copyWith(
                  isSolved: false,
                  flag: null,
                  solvedAt: null,
                ));
                break;
              case 'delete':
                provider.removeChallenge(challenge.id);
                break;
            }
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (challenge.description.isNotEmpty) ...[
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(challenge.description),
                  const SizedBox(height: 16),
                ],
                if (challenge.url != null) ...[
                  const Text(
                    'URL:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(challenge.url!),
                  const SizedBox(height: 16),
                ],
                if (challenge.files.isNotEmpty) ...[
                  const Text(
                    'Files:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...challenge.files.map((file) => Text('• $file')),
                  const SizedBox(height: 16),
                ],
                if (challenge.flag != null) ...[
                  const Text(
                    'Flag:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    challenge.flag!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      backgroundColor: Colors.green,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (challenge.notes.isNotEmpty) ...[
                  const Text(
                    'Notes:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...challenge.notes.map((note) => Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(note),
                  )),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddNoteDialog(challenge),
                      icon: const Icon(Icons.note_add),
                      label: const Text('Add Note'),
                    ),
                    const SizedBox(width: 8),
                    if (!challenge.isSolved)
                      ElevatedButton.icon(
                        onPressed: () => _showSolvedDialog(challenge),
                        icon: const Icon(Icons.flag),
                        label: const Text('Submit Flag'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddChallengeDialog() {
    _showChallengeDialog();
  }

  void _showEditChallengeDialog(CTFChallenge challenge) {
    _showChallengeDialog(challenge: challenge);
  }

  void _showChallengeDialog({CTFChallenge? challenge}) {
    final nameController = TextEditingController(text: challenge?.name ?? '');
    final descriptionController = TextEditingController(text: challenge?.description ?? '');
    final pointsController = TextEditingController(text: challenge?.points.toString() ?? '100');
    final urlController = TextEditingController(text: challenge?.url ?? '');
    final tagsController = TextEditingController(text: challenge?.tags.join(', ') ?? '');
    
    ChallengeCategory selectedCategory = challenge?.category ?? ChallengeCategory.misc;
    ChallengeDifficulty selectedDifficulty = challenge?.difficulty ?? ChallengeDifficulty.medium;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(challenge == null ? 'Add Challenge' : 'Edit Challenge'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Challenge Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ChallengeCategory>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: ChallengeCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_getCategoryDisplayName(category)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<ChallengeDifficulty>(
                        value: selectedDifficulty,
                        decoration: const InputDecoration(
                          labelText: 'Difficulty',
                          border: OutlineInputBorder(),
                        ),
                        items: ChallengeDifficulty.values.map((difficulty) {
                          return DropdownMenuItem(
                            value: difficulty,
                            child: Text(_getDifficultyDisplayName(difficulty)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDifficulty = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pointsController,
                  decoration: const InputDecoration(
                    labelText: 'Points',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final provider = Provider.of<CTFChallengeProvider>(context, listen: false);
                
                final newChallenge = CTFChallenge(
                  id: challenge?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descriptionController.text,
                  category: selectedCategory,
                  difficulty: selectedDifficulty,
                  points: int.tryParse(pointsController.text) ?? 100,
                  tags: tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                  files: challenge?.files ?? [],
                  notes: challenge?.notes ?? [],
                  isSolved: challenge?.isSolved ?? false,
                  flag: challenge?.flag,
                  createdAt: challenge?.createdAt ?? DateTime.now(),
                  solvedAt: challenge?.solvedAt,
                  url: urlController.text.isEmpty ? null : urlController.text,
                );

                if (challenge == null) {
                  provider.addChallenge(newChallenge);
                } else {
                  provider.updateChallenge(newChallenge);
                }

                Navigator.of(context).pop();
              },
              child: Text(challenge == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSolvedDialog(CTFChallenge challenge) {
    final flagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Flag'),
        content: TextField(
          controller: flagController,
          decoration: const InputDecoration(
            labelText: 'Flag',
            border: OutlineInputBorder(),
            hintText: 'flag{...} or CTF{...}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<CTFChallengeProvider>(context, listen: false);
              provider.markChallengeAsSolved(challenge.id, flagController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(CTFChallenge challenge) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Note',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<CTFChallengeProvider>(context, listen: false);
              provider.addNoteToChallenge(challenge.id, noteController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.web:
        return 'Web';
      case ChallengeCategory.crypto:
        return 'Cryptography';
      case ChallengeCategory.forensics:
        return 'Forensics';
      case ChallengeCategory.reversing:
        return 'Reverse Engineering';
      case ChallengeCategory.pwn:
        return 'Pwn/Binary Exploitation';
      case ChallengeCategory.misc:
        return 'Miscellaneous';
      case ChallengeCategory.osint:
        return 'OSINT';
      case ChallengeCategory.steganography:
        return 'Steganography';
    }
  }

  String _getDifficultyDisplayName(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Easy';
      case ChallengeDifficulty.medium:
        return 'Medium';
      case ChallengeDifficulty.hard:
        return 'Hard';
      case ChallengeDifficulty.insane:
        return 'Insane';
    }
  }

  Color _getCategoryColor(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.web:
        return Colors.blue;
      case ChallengeCategory.crypto:
        return Colors.purple;
      case ChallengeCategory.forensics:
        return Colors.green;
      case ChallengeCategory.reversing:
        return Colors.red;
      case ChallengeCategory.pwn:
        return Colors.orange;
      case ChallengeCategory.misc:
        return Colors.grey;
      case ChallengeCategory.osint:
        return Colors.teal;
      case ChallengeCategory.steganography:
        return Colors.pink;
    }
  }

  IconData _getCategoryIcon(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.web:
        return Icons.web;
      case ChallengeCategory.crypto:
        return Icons.lock;
      case ChallengeCategory.forensics:
        return Icons.search;
      case ChallengeCategory.reversing:
        return Icons.settings_backup_restore;
      case ChallengeCategory.pwn:
        return Icons.bug_report;
      case ChallengeCategory.misc:
        return Icons.help;
      case ChallengeCategory.osint:
        return Icons.visibility;
      case ChallengeCategory.steganography:
        return Icons.hide_image;
    }
  }

  Color _getDifficultyColor(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return Colors.green;
      case ChallengeDifficulty.medium:
        return Colors.orange;
      case ChallengeDifficulty.hard:
        return Colors.red;
      case ChallengeDifficulty.insane:
        return Colors.purple;
    }
  }
}