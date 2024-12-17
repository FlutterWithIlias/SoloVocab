class Vocabulary {
  final int? id;
  final String word;
  final String translation;
  final String type;
  final List<String> examples;
  final String synonym; // Single synonym
  final String antonym; // Single antonym
  final DateTime dateAdded; // Date when the word was added

  Vocabulary({
    this.id,
    required this.word,
    required this.translation,
    required this.type,
    required this.examples,
    required this.synonym,
    required this.antonym,
    required this.dateAdded,
  });

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    return Vocabulary(
      id: map['id'],
      word: map['word'],
      translation: map['translation'],
      type: map['type'],
      examples: (map['examples'] as String).split('|'),
      synonym: map['synonym'] ?? '',
      antonym: map['antonym'] ?? '',
      dateAdded: DateTime.parse(map['dateAdded']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'type': type,
      'examples': examples.join('|'),
      'synonym': synonym,
      'antonym': antonym,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }
}
