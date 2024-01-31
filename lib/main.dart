// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:try2/firebase_options.dart';
import 'package:try2/model/firebase_config.dart';
import 'package:try2/pages/dispaly_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dailylog(),
    ),
  );
}

class Dailylog extends StatefulWidget {
  const Dailylog({super.key});

  @override
  State<Dailylog> createState() => _DailylogState();
}

class _DailylogState extends State<Dailylog> {
  File? _pickedImage;
  TextEditingController topic = TextEditingController();
  TextEditingController descrip = TextEditingController();
  FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text(
          "Daily Log",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  controller: topic,
                  decoration: InputDecoration(
                      icon: const Icon(Icons.topic),
                      label: const Text("Enter the Topic"),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50))),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  minLines: 4,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: descrip,
                  decoration: InputDecoration(
                      icon: const Icon(Icons.description),
                      label: const Text("Topic Description"),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Attach the Image:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo, size: 25),
                      onPressed: () async {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          // Convert XFile to File
                          setState(() {
                            _pickedImage = File(pickedFile.path);
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 100,
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Check if the image is selected
                      if (_pickedImage == null) {
                        // Image is not selected, show Snackbar with a different message
                        snackbar(context,
                            "Data is saved successfully, but image is not selected");
                      } else {
                        await firebaseService.saveData(
                          topic.text,
                          descrip.text,
                          image: _pickedImage,
                        );
                        snackbar(context, "Data is saved successfully");
                      }

                      topic.clear();
                      descrip.clear();
                    } catch (e) {
                      print('Error saving data: $e');
                    }
                  },
                  child: const Text(
                    "Save Log",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisplayPage(
                                fetchData: firebaseService.fetchData)));
                  },
                  child: const Icon(Icons.arrow_forward),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> snackbar(BuildContext context, String message) async {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 4),
      backgroundColor: const Color.fromARGB(255, 254, 169, 0),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
  );
}
