import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:my_vocabulary/viewModel/vocabulary_viewmodel.dart';
import 'add_vocabulary_screen.dart';

class VocabularyListScreen extends StatefulWidget {
  @override
  _VocabularyListScreenState createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  final VocabularyViewModel _vocabularyViewModel = Get.put(VocabularyViewModel());
  final TextEditingController _searchController = TextEditingController();
  final RxString _filterType = ''.obs;
  final RxBool _isAscending = true.obs;
  final RxBool _filterByDate = false.obs;

  bool isGridView = false;

  final LiveOptions options = LiveOptions(
    delay: Duration(milliseconds: 100),
    showItemInterval: Duration(milliseconds: 100),
    showItemDuration: Duration(milliseconds: 300),
    reAnimateOnVisibility: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 35, 114, 184),
        title: Text('Vocabulary List',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              setState(() {
                _vocabularyViewModel.vocabularyList.isNotEmpty?
                _vocabularyViewModel.shareVocabularyAsPdf():
                null;
              });
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, // Start of the gradient
            end: Alignment.bottomCenter, // End of the gradient
            colors: [
              Color.fromARGB(255, 35, 114, 184),
              Color.fromARGB(255, 107, 174, 237),
              Color.fromARGB(255, 231, 224, 240), // Start with white // End with a near-purple color
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Get.width * 0.04,
                vertical: Get.height * 0.02,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 165, 144, 144), width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
            ),
                      enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
            ),
                        hintText: 'Search words...',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2.0),
                          borderRadius: BorderRadius.circular(Get.width * 0.02),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        _vocabularyViewModel.filterVocabulary(
                          searchQuery: value,
                          type: _filterType.value,
                          isAscending: _isAscending.value,
                          sortByDate: _filterByDate.value,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: Get.width * 0.02),
                  IconButton(
                    icon: Icon(Icons.filter_alt),
                    onPressed: () {
                      _showFilterDialog(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_vocabularyViewModel.filteredVocabularyList.isEmpty) {
                  return Center(
                    child: Text(
                      'No vocabulary found.',
                      style: TextStyle(fontSize: Get.height * 0.02),
                    ),
                  );
                }
        
                return isGridView ? _buildAnimatedGrid() : _buildAnimatedList();
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddVocabularyScreen());
        },
        child: Icon(Icons.add, size: Get.height * 0.03),
      ),
    );
  }

  Widget _buildAnimatedList() {
    return LiveList.options(
      options: options,
      itemBuilder: (context, index, animation) {
        final vocab = _vocabularyViewModel.filteredVocabularyList[index];
        return _buildListItem(context, vocab, animation);
      },
      itemCount: _vocabularyViewModel.filteredVocabularyList.length,
    );
  }

  Widget _buildAnimatedGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(Get.width * 0.02),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 cards per row
        crossAxisSpacing: Get.width * 0.02,
        mainAxisSpacing: Get.height * 0.02,
      ),
      itemCount: _vocabularyViewModel.filteredVocabularyList.length,
      itemBuilder: (context, index) {
        final vocab = _vocabularyViewModel.filteredVocabularyList[index];
        return _buildDismissibleCard(vocab);
      },
    );
  }

Widget _buildListItem(BuildContext context, var vocab, Animation<double> animation) {
  return FadeTransition(
    opacity: Tween<double>(begin: 0, end: 1).animate(animation),
    child: SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(animation),
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart, // Swipe to the left
        onDismissed: (direction) {
          _vocabularyViewModel.deleteVocabulary(vocab.id!);
          Get.snackbar(
            'Deleted',
            '${vocab.word} has been deleted.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight, // Align delete icon to the right
          padding: EdgeInsets.only(right: Get.width * 0.04),
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: Get.height * 0.04,
          ),
        ),
        child: GestureDetector(
          onTap: () => _showVocabularyDetails(vocab),
          child: Card(
            margin: EdgeInsets.symmetric(
              horizontal: Get.width * 0.04,
              vertical: Get.height * 0.01,
            ),
            child: ListTile(
              title: Text(
                vocab.word,
                style: TextStyle(
                  fontSize: Get.height * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: GestureDetector(
                onTap: () {
                  Get.toNamed('/updateVocabulary', arguments: vocab);
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.blue,
                  size: Get.height * 0.03,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildDismissibleCard(var vocab) {
  return Dismissible(
    key: UniqueKey(),
    direction: DismissDirection.down, // Drag down to delete
    onDismissed: (direction) {
      _vocabularyViewModel.deleteVocabulary(vocab.id!);
      Get.snackbar(
        'Deleted',
        '${vocab.word} has been deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
    },
    background: Container(
      color: Colors.red,
      alignment: Alignment.center,
      child: Icon(
        Icons.delete,
        color: Colors.white,
        size: Get.height * 0.04,
      ),
    ),
    child: GestureDetector(
      onTap: () => _showVocabularyDetails(vocab),
      child: Card(
        margin: EdgeInsets.all(Get.width * 0.01),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  vocab.word,
                  textAlign: TextAlign.center,
                  maxLines: 1, // Limit to one line
                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                  style: TextStyle(
                    fontSize: Get.height * 0.023,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: Get.height*0.01),
              child: GestureDetector(
              onTap: () {
                Get.toNamed('/updateVocabulary', arguments: vocab);
              },
              child: Icon(
                Icons.edit,
                size: Get.height * 0.018,
                color: Colors.blue,
              ),
            ),
            ),
          ],
        ),
      ),
    ),
  );
}


  void _showFilterDialog(BuildContext context) {
    final List<String> types = [
      'All',
      'Noun',
      'Verb',
      'Adjective',
      'Adverb',
      'Pronoun',
      'Determiner',
      'Preposition',
      'Conjunction'
    ];
    final RxString selectedType = _filterType.value.obs;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Vocabulary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                return DropdownButtonFormField<String>(
                  value: selectedType.value.isEmpty ? 'All' : selectedType.value,
                  decoration: InputDecoration(labelText: 'Type'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sort by Date:'),
                  Obx(() {
                    return Switch(
                      value: _filterByDate.value,
                      onChanged: (value) {
                        _filterByDate.value = value;
                      },
                    );
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order:'),
                  Obx(() {
                    return DropdownButton<bool>(
                      value: _isAscending.value,
                      items: [
                        DropdownMenuItem(
                          value: true,
                          child: Text('Ascending'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Descending'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _isAscending.value = value;
                        }
                      },
                    );
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _vocabularyViewModel.filterVocabulary(
                  searchQuery: '',
                  type: selectedType.value,
                  isAscending: _isAscending.value,
                  sortByDate: _filterByDate.value,
                );
                Get.back();
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

void _showVocabularyDetails(var vocab) {
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(text);
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                vocab.word,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.volume_up, color: Colors.blue),
              onPressed: () {
                _speak(vocab.word);
              },
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: Colors.grey[300]),
              SizedBox(height: 8),
              // Type
              RichText(
                text: TextSpan(
                  text: 'Type: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: vocab.type,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
                            SizedBox(height: 8),
              // Translation
              RichText(
                text: TextSpan(
                  text: 'Translation: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: vocab.translation,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Synonym
              Text(
                'Synonym:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 ,),
              ),
              Text(
                vocab.synonym.isNotEmpty ? vocab.synonym : 'No synonym available',
                style: TextStyle(fontSize: 14, color: Color.fromARGB(135, 8, 107, 10)),
              ),
              SizedBox(height: 10),
              // Antonym
              Text(
                'Antonym:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                vocab.antonym.isNotEmpty ? vocab.antonym : 'No antonym available',
                style: TextStyle(fontSize: 14, color: Color.fromARGB(136, 177, 13, 13)),
              ),
              SizedBox(height: 16),
              // Examples
              Text(
                'Examples:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              ...vocab.examples.map(
                (example) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          example,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Close',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}
}
