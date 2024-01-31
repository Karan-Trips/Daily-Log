// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:try2/model/firebase_config.dart';
import 'package:try2/pages/view_page.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage({Key? key, required this.fetchData}) : super(key: key);

  final Future<List<Map<String, dynamic>>> Function() fetchData;

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  late Future<List<Map<String, dynamic>>> _logs;
  FirebaseService firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _logs = widget.fetchData();
  }

  Future<void> refreshData() async {
    setState(() {
      _logs = widget.fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _logs,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No log found.'));
                  } else {
                    return ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailPage(log: snapshot.data![index]),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            color: Colors.amberAccent,
                            child: ListTile(
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _showDeleteDialog(
                                      context, snapshot.data![index]);
                                },
                              ),
                              leading: Text(
                                '${snapshot.data![index]['date']}',
                                textDirection: TextDirection.ltr,
                              ),
                              title: Text(
                                '${snapshot.data![index]['topic']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Column(
                                children: [
                                  Text(
                                    '${snapshot.data![index]['description']}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, Map<String, dynamic> log) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await firebaseService.deleteData(log['id']);
                Navigator.of(context).pop();
                refreshData();
              },
            ),
          ],
        );
      },
    );
  }
}
