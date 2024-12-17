import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_vocabulary/viewModel/vocabulary_viewmodel.dart';
import '../model/vocabulary.dart';


class UpdateVocabularyScreen extends StatefulWidget {
  final Vocabulary vocab;

  UpdateVocabularyScreen({required this.vocab});

  @override
  _UpdateVocabularyScreenState createState() => _UpdateVocabularyScreenState();
}

class _UpdateVocabularyScreenState extends State<UpdateVocabularyScreen> {
  final TextEditingController wordController = TextEditingController();
  final TextEditingController translationController = TextEditingController();
  final TextEditingController synonymController = TextEditingController();
  final TextEditingController antonymController = TextEditingController();
  final TextEditingController exampleController = TextEditingController();

  final RxString selectedType = ''.obs; // Track selected type dynamically

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

  late RxList<String> examples; // Reactive list for examples

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the current vocabulary values
    wordController.text = widget.vocab.word;
    translationController.text = widget.vocab.translation;
    synonymController.text = widget.vocab.synonym;
    antonymController.text = widget.vocab.antonym;
    selectedType.value = widget.vocab.type;
    examples = RxList<String>.from(widget.vocab.examples);
  }

  @override
  Widget build(BuildContext context) {
    final VocabularyViewModel viewModel = Get.find<VocabularyViewModel>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Vocabulary'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Word', screenWidth),
              _buildTextField(wordController, 'Enter the word', 28, screenWidth),

              _buildSectionTitle('Translation', screenWidth),
              _buildTextField(translationController, 'Enter the translation', 28, screenWidth),

              _buildSectionTitle('Synonym', screenWidth),
              _buildTextField(synonymController, 'Enter a synonym', 28, screenWidth),

              _buildSectionTitle('Antonym', screenWidth),
              _buildTextField(antonymController, 'Enter an antonym', 28, screenWidth),

              _buildSectionTitle('Type', screenWidth),
              _buildDropdown(screenWidth),

              _buildSectionTitle('Examples', screenWidth),
              _buildExampleField(screenWidth),

              Obx(() {
                return examples.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.02),
                        child: Column(
                          children: examples.map((example) {
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                              elevation: 2,
                              child: ListTile(
                                title: Text(
                                  example,
                                  style: TextStyle(fontSize: screenWidth * 0.04),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showEditExampleDialog(example),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => examples.remove(example),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : SizedBox();
              }),

              SizedBox(height: screenHeight * 0.04),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.02,
                    ),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                  ),
                  icon: Icon(Icons.save, color: Colors.white),
                  label: Text(
                    'Update Vocabulary',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    if (_validateInput(context)) {
                      final updatedVocab = Vocabulary(
                        id: widget.vocab.id,
                        word: wordController.text.trim(),
                        translation: translationController.text.trim(),
                        type: selectedType.value.trim(),
                        examples: examples.toList(),
                        synonym: synonymController.text.trim(),
                        antonym: antonymController.text.trim(),
                        dateAdded: widget.vocab.dateAdded, // Retain original date
                      );

                      viewModel.updateVocabulary(updatedVocab);
                      Get.back(); // Navigate back to the list screen
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

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(top: screenWidth * 0.05, bottom: screenWidth * 0.02),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, int maxLength, double screenWidth) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '', // Hide maxLength counter text
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
      ),
    );
  }

  Widget _buildDropdown(double screenWidth) {
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: selectedType.value.isEmpty ? null : selectedType.value,
        hint: Text('Select a type'),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
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
    });
  }

  Widget _buildExampleField(double screenWidth) {
    return TextField(
      controller: exampleController,
      maxLength: 90,
      decoration: InputDecoration(
        hintText: 'Add an example sentence',
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.02),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.add_circle,
            color: Colors.blueAccent,
            size: screenWidth * 0.07,
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
    );
  }

  void _showEditExampleDialog(String example) {
    final TextEditingController editController = TextEditingController(text: example);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Example'),
          content: TextField(
            controller: editController,
            maxLength: 90,
            decoration: InputDecoration(
              hintText: 'Update example sentence',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  final index = examples.indexOf(example);
                  setState(() {
                    examples[index] = editController.text.trim();
                  });
                  Navigator.pop(context);
                } else {
                  Get.snackbar(
                    'Error',
                    'Example cannot be empty!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  bool _validateInput(BuildContext context) {
    if (wordController.text.isEmpty || translationController.text.isEmpty || selectedType.value.isEmpty) {
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
