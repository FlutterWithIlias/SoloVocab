class VocabularyCounts {
  final int nouns;
  final int verbs;
  final int adjectives;
  final int adverbs;

  VocabularyCounts({
    required this.nouns,
    required this.verbs,
    required this.adjectives,
    required this.adverbs,
  });
int get total => nouns + verbs + adjectives + adverbs;
  factory VocabularyCounts.fromMap(Map<String, int> map) {
    return VocabularyCounts(
      nouns: map['noun'] ?? 0,
      verbs: map['verb'] ?? 0,
      adjectives: map['adjective'] ?? 0,
      adverbs: map['adverb'] ?? 0,
    );
  }
}
