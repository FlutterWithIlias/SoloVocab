import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import '../model/vocabulary.dart';
import '../viewModel/vocabulary_viewmodel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class AddVocabularyScreen extends StatefulWidget {
  @override
  _AddVocabularyScreenState createState() => _AddVocabularyScreenState();
}

class _AddVocabularyScreenState extends State<AddVocabularyScreen> {
  final TextEditingController wordController = TextEditingController();
  final TextEditingController translationController = TextEditingController();
  final TextEditingController synonymController = TextEditingController();
  final TextEditingController antonymController = TextEditingController();
  final TextEditingController exampleController = TextEditingController();

  final RxList<String> examples = <String>[].obs;
  final RxString selectedType = ''.obs;

  final List<String> types = [
    'noun',
    'verb',
    'adjective',
    'adverb',
    'pronoun',
    'determiner',
    'preposition',
    'conjunction',
  ];

  @override
  Widget build(BuildContext context) {
    final VocabularyViewModel viewModel = Get.find<VocabularyViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vocabulary'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Get.width * 0.04,
          vertical: Get.height * 0.02,
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Word', wordController, 'Enter the word', 28, _onWordChanged),
              _buildTextField('Translation', translationController, 'Enter the translation', 28),
              _buildTextField('Synonym', synonymController, 'Enter a synonym', 28),
              _buildTextField('Antonym', antonymController, 'Enter an antonym', 28),
              _buildAnimatedDropdown(),
              _buildExampleSection(),
              Obx(() {
                return examples.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(top: Get.height * 0.02),
                        child: Column(
                          children: examples.map((example) {
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: Get.height * 0.01),
                              elevation: 2,
                              child: ListTile(
                                title: Text(
                                  example,
                                  style: TextStyle(fontSize: Get.height * 0.02),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => examples.remove(example),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : SizedBox();
              }),
              SizedBox(height: Get.height * 0.04),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: Get.width * 0.1,
                      vertical: Get.height * 0.02,
                    ),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Get.width * 0.03),
                    ),
                  ),
                  icon: Icon(
                    Icons.save,
                    color: Colors.white,
                    size: Get.height * 0.03,
                  ),
                  label: Text(
                    'Save Vocabulary',
                    style: TextStyle(
                      fontSize: Get.height * 0.025,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    if (_validateInput(context)) {
                      final newVocab = Vocabulary(
                        word: wordController.text.trim(),
                        translation: translationController.text.trim(),
                        type: selectedType.value.trim(),
                        examples: examples.toList(),
                        synonym: synonymController.text.trim(),
                        antonym: antonymController.text.trim(),
                        dateAdded: DateTime.now(),
                      );

                      viewModel.addVocabulary(newVocab);
                      Get.back();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This is the text field widget used for word, translation, synonym, antonym, etc.
  Widget _buildTextField(String title, TextEditingController controller, String hint, int maxLength, [Function? onChanged]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: Get.height * 0.02,
            bottom: Get.height * 0.01,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: Get.height * 0.025,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextField(
          controller: controller,
          maxLength: maxLength,
          onChanged: (text) {
            if (onChanged != null) onChanged(text);  // Trigger fetch on word change
          },
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Get.width * 0.03),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Get.width * 0.04,
              vertical: Get.height * 0.02,
            ),
              
              suffixIcon: title=="Word"?IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.blueAccent,
                size: Get.height * 0.03,
              ),
              onPressed: () {
                  wordController.clear();
                  synonymController.clear();
                  antonymController.clear();
                  translationController.clear();
                  exampleController.clear();
                  selectedType.value = '';
              },
            ):null,
          ),
        ),
      ],
    );
  }

  // Dropdown for selecting word type
  Widget _buildAnimatedDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: Get.height * 0.02,
            bottom: Get.height * 0.01,
          ),
          child: Text(
            'Type',
            style: TextStyle(
              fontSize: Get.height * 0.025,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Obx(() {
          return DropdownButtonFormField<String>(
            value: selectedType.value.isEmpty ? null : selectedType.value,
            hint: Text('Select a type'),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Get.width * 0.03),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: Get.width * 0.04,
                vertical: Get.height * 0.02,
              ),
            ),
            items: types.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                selectedType.value = value;
              }
            },
          );
        }),
      ],
    );
  }

  // Add example section
  Widget _buildExampleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: Get.height * 0.02,
            bottom: Get.height * 0.01,
          ),
          child: Text(
            'Examples',
            style: TextStyle(
              fontSize: Get.height * 0.025,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextField(
          controller: exampleController,
          maxLength: 90,
          decoration: InputDecoration(
            hintText: 'Add an example sentence',
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Get.width * 0.03),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Get.width * 0.04,
              vertical: Get.height * 0.02,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.add_circle,
                color: Colors.blueAccent,
                size: Get.height * 0.03,
              ),
              onPressed: () {
                if (exampleController.text.trim().isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Example cannot be empty!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } else if (examples.length < 5) {
                  setState(() {
                    examples.add(exampleController.text.trim());
                    exampleController.clear();
                  });
                } else {
                  Get.snackbar(
                    'Limit Reached',
                    'You can only add up to 5 examples.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // On Word Changed, fetch synonyms and antonyms
  void _onWordChanged(String word) {
    if (word.isEmpty) {
      // Clear synonym and antonym fields if the word is deleted

      synonymController.clear();
      antonymController.clear();
      translationController.clear();
      exampleController.clear();
      selectedType.value = '';


    } else {
      fetchSynonymsAntonyms(word);
    }
  }

  // Fetch Synonyms and Antonyms
Future<void> fetchSynonymsAntonyms(String word) async {
  try {
    final url = 'https://translate.google.com/m?hl=fr&q=$word&sl=en';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the HTML response body
      dom.Document document = parser.parse(response.body);

      // Find the element that contains the translation
      var translationElement = document.querySelector('div.result-container');

      if (translationElement != null) {
        translationController.text = translationElement.text.trim();  // Extracts the translated text
      } else {
        throw Exception('Translation not found');
      }
    } else {
      throw Exception('Failed to fetch the translation');
    }

    // Fetching from Merriam-Webster for synonyms and antonyms
    String url1 = 'https://www.merriam-webster.com/thesaurus/$word';
    var response1 = await http.get(Uri.parse(url1));

    if (response1.statusCode == 200) {
      var document = parse(response1.body);

      // Extract synonyms and antonyms
      List<dom.Element> listItems = document.querySelectorAll('div.sense-content.w-100');
      List<String> wordsList = listItems.map((element) => element.text.trim()).toList();

      var type = document.querySelectorAll('a.important-blue-link');
      var example = document.querySelectorAll('span.t.has-aq');

      if (wordsList.isNotEmpty) {
        String cleanedString = wordsList[0].replaceAll(RegExp(r'\s+'), ' ').trim();
        List<String> wordsList1 = cleanedString.split(' ');

        List<String> getWordsAfterSkipping(List<String> list, String targetWord) {
          int targetIndex = list.indexOf(targetWord);
          if (targetIndex != -1) {
            if (targetWord == "Synonyms") {
              int startIndex = targetIndex + 5;
              int endIndex = startIndex + 3;
              return list.sublist(startIndex, endIndex);
            } else {
              int startIndex = targetIndex + 4;
              int endIndex = startIndex + 3;
              return list.sublist(startIndex, endIndex);
            }
          }
          return [];
        }

        List<String> synonymsWords = getWordsAfterSkipping(wordsList1, 'Synonyms');
        List<String> antonymsWords = getWordsAfterSkipping(wordsList1, 'Antonyms');

        // Set synonyms, antonyms and example
        synonymController.text = synonymsWords.join(', ').trim();
        antonymController.text = antonymsWords.join(', ').trim();

        if (example.isNotEmpty) {
          exampleController.text = example[0].text;
        }

        // Set type (if valid)
        if (type.isNotEmpty && types.contains(type[0].text)) {
          selectedType.value = type[0].text;  // This will update the dropdown value correctly
        } else {
          selectedType.value = types[0];  // Fallback to the first type if not valid
        }
      }
    } else {
      print('Failed to load page');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}


  bool _validateInput(BuildContext context) {
    if (wordController.text.isEmpty ||
        translationController.text.isEmpty ||
        selectedType.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all required fields!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }
}
