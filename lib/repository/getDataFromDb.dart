import 'package:sqflite/sqflite.dart';

import '../service/db_service.dart';
import '../model/vocabulary.dart';

class VocabularyRepository {
  final DBService _dbService = DBService();

Future<List<Vocabulary>> getAllVocabulary() async {
  String sql = "SELECT * FROM vocabulary";
  List<Map<String, dynamic>> result =
      (await _dbService.readData(sql)).cast<Map<String, dynamic>>();

  return result.map((map) => Vocabulary.fromMap(map)).toList();
}



  String escapeSingleQuotes(String text) {
  return text.replaceAll("'", "''"); // Replace single quote with double single quotes
}

Future<int> addVocabulary(Vocabulary vocab) async {
  String escapedWord = escapeSingleQuotes(vocab.word);
  String escapedTranslation = escapeSingleQuotes(vocab.translation);
  String escapedType = escapeSingleQuotes(vocab.type);
  String escapedExamples = vocab.examples.map(escapeSingleQuotes).join('|');
  String escapedSynonym = escapeSingleQuotes(vocab.synonym);
  String escapedAntonym = escapeSingleQuotes(vocab.antonym);

  String sql = '''
    INSERT INTO vocabulary (word, translation, type, examples, synonym, antonym, dateAdded)
    VALUES ('$escapedWord', '$escapedTranslation', '$escapedType', '$escapedExamples',
            '$escapedSynonym', '$escapedAntonym', '${vocab.dateAdded.toIso8601String()}')
  ''';

  return await _dbService.insertData(sql);
}


Future<int> updateVocabulary(Vocabulary vocab) async {
  String escapedWord = escapeSingleQuotes(vocab.word);
  String escapedTranslation = escapeSingleQuotes(vocab.translation);
  String escapedType = escapeSingleQuotes(vocab.type);
  String escapedExamples = vocab.examples.map(escapeSingleQuotes).join('|');
  String escapedSynonym = escapeSingleQuotes(vocab.synonym);
  String escapedAntonym = escapeSingleQuotes(vocab.antonym);

  String sql = '''
    UPDATE vocabulary
    SET word = '$escapedWord',
        translation = '$escapedTranslation',
        type = '$escapedType',
        examples = '$escapedExamples',
        synonym = '$escapedSynonym',
        antonym = '$escapedAntonym',
        dateAdded = '${vocab.dateAdded.toIso8601String()}'
    WHERE id = ${vocab.id}
  ''';

  return await _dbService.updateData(sql);
}


  Future<int> deleteVocabulary(int id) async {
    String sql = "DELETE FROM vocabulary WHERE id = $id";
    return await _dbService.deleteData(sql);
  }

  Future<Map<String, int>> fetchCounts() async {
    final Database db = await _dbService.database;
    final Map<String, int> counts = {};

    final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT 
          type, 
          COUNT(*) as count 
        FROM vocabulary 
        WHERE type IN ('noun', 'verb', 'adjective', 'adverb') 
        GROUP BY type
        ''');

    // Initialize all types with a default count of 0
    counts['noun'] = 0;
    counts['verb'] = 0;
    counts['adjective'] = 0;
    counts['adverb'] = 0;

    // Populate counts from query result
    for (var row in result) {
      counts[row['type']] = row['count'] as int;
    }

    return counts;
  }

  Future<bool> hasVocabulary() async {
  final Database db = await _dbService.database;
  final result = await db.rawQuery('SELECT EXISTS (SELECT 1 FROM vocabulary LIMIT 1)');
  return result.isNotEmpty && result.first.values.first == 1;
}
}
