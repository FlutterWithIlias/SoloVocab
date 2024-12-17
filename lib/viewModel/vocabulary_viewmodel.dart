import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import '../model/vocabulary.dart';
import '../repository/getDataFromDb.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class VocabularyViewModel extends GetxController {
  final VocabularyRepository _repository = VocabularyRepository();

  RxList<Vocabulary> vocabularyList = <Vocabulary>[].obs;
  RxList<Vocabulary> filteredVocabularyList = <Vocabulary>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadVocabulary();
  }

  Future<void> loadVocabulary() async {
    try {
      List<Vocabulary> vocabularies = await _repository.getAllVocabulary();
      vocabularyList.assignAll(vocabularies);
      filteredVocabularyList.assignAll(vocabularies); // Initially show all
    } catch (e) {
      print("Error loading vocabulary: $e");
    }
  }

  Future<void> addVocabulary(Vocabulary vocab) async {
    try {
      await _repository.addVocabulary(vocab);
      loadVocabulary(); // Reload after adding
    } catch (e) {
      print("Error adding vocabulary: $e");
    }
  }

  Future<void> updateVocabulary(Vocabulary vocab) async {
    try {
      await _repository.updateVocabulary(vocab);
      loadVocabulary(); // Reload after updating
    } catch (e) {
      print("Error updating vocabulary: $e");
    }
  }

  Future<void> deleteVocabulary(int id) async {
    try {
      await _repository.deleteVocabulary(id);
      loadVocabulary(); // Reload after deleting
    } catch (e) {
      print("Error deleting vocabulary: $e");
    }
  }

  void filterVocabulary({
    String searchQuery = '',
    String type = 'All',
    bool isAscending = true,
    bool sortByDate = false,
  }) {
    List<Vocabulary> filtered = vocabularyList;

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((vocab) {
        return vocab.word.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by type
    if (type != 'All' && type.isNotEmpty) {
      filtered = filtered.where((vocab) {
        return vocab.type.toLowerCase() == type.toLowerCase();
      }).toList();
    }

    // Sort by date or alphabetical order
    if (sortByDate) {
      filtered.sort((a, b) => isAscending
          ? a.dateAdded.compareTo(b.dateAdded)
          : b.dateAdded.compareTo(a.dateAdded));
    } else {
      // Default: Sort alphabetically
      filtered.sort((a, b) => isAscending
          ? a.word.toLowerCase().compareTo(b.word.toLowerCase())
          : b.word.toLowerCase().compareTo(a.word.toLowerCase()));
    }

    filteredVocabularyList.assignAll(filtered);
  }
 
 Future<void> shareVocabularyAsPdf() async {
  try {
    // Créer une instance de Document PDF
    final pdf = pw.Document();

    // Ajouter une page au PDF avec format paysage pour plus d'espace horizontal
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4, // Changer en paysage
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Titre du document
              pw.Text(
                'Vocabulary List',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Tableau contenant les données de vocabulaire
              pw.Table.fromTextArray(
                headers: ['Word', 'Translation', 'Synonym', 'Antonym', 'Type', 'Added on'],
                data: filteredVocabularyList.map((vocab) {
                  return [
                    vocab.word,
                    vocab.translation,
                    vocab.synonym,
                    vocab.antonym,
                    vocab.type,
                    // Formater la date selon vos préférences
                    "${vocab.dateAdded.day}/${vocab.dateAdded.month}/${vocab.dateAdded.year}",
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                cellStyle: pw.TextStyle(
                  fontSize: 10,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellHeight: 30, // Augmenter la hauteur des cellules
                columnWidths: {
                  0: pw.FlexColumnWidth(2), // Word
                  1: pw.FlexColumnWidth(3), // Translation
                  2: pw.FlexColumnWidth(3), // Synonym
                  3: pw.FlexColumnWidth(3), // Antonym
                  4: pw.FlexColumnWidth(2), // Type
                  5: pw.FlexColumnWidth(2), // Added on
                },
                cellAlignments: {
                  0: pw.Alignment.centerLeft, // Word
                  1: pw.Alignment.centerLeft, // Translation
                  2: pw.Alignment.centerLeft, // Synonym
                  3: pw.Alignment.centerLeft, // Antonym
                  4: pw.Alignment.center,     // Type
                  5: pw.Alignment.center,     // Added on
                },
                // Optionnel : ajuster les marges des cellules pour éviter les coupures
              ),
            ],
          );
        },
      ),
    );

    // Obtenir le répertoire temporaire
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/vocabulary.pdf");

    // Écrire le PDF dans le fichier
    await file.writeAsBytes(await pdf.save());

    // Créer une instance XFile à partir du fichier
    final xfile = XFile(file.path);

    // Partager le fichier PDF en utilisant shareXFiles
    await Share.shareXFiles(
      [xfile],
      text: 'This is my vocabulary list!',
    );

    // Optionnel : Supprimer le fichier temporaire après partage
    // await file.delete();
  } catch (e) {
    print("Erreur lors du partage du PDF: $e");
    // Afficher une notification ou un message d'erreur à l'utilisateur
    Get.snackbar('Erreur', 'Échec du partage du PDF.');
  }
}





}
