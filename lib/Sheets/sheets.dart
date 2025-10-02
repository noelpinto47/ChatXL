import 'dart:io';
import 'package:chatdb/Sheets/sheetpage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart' as prefix;
import '../Chat/controller.dart';
import '../Database/databasehelper.dart';
import '../Elements/checkinternet.dart';

class SheetsFragment extends StatefulWidget {
  const SheetsFragment({super.key});

  @override
  SheetsFragmentState createState() => SheetsFragmentState();
}

class SheetsFragmentState extends State<SheetsFragment> {
  final Controller c = Get.put(Controller());
  final CheckInternet p = Get.put(CheckInternet());
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  void _initializeDatabase() async {
    // Initialize the database and create tables if necessary
    await dbHelper.database;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: 32.0, right: 28.0, left: 28.0, bottom: 8.0),
      child: Column(
        children: [
          Expanded(
              flex: 5,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.getContacts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    List<Map<String, dynamic>> contacts = snapshot.data!;

                    return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 60,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 3),
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: () {
                                    var filePath =
                                        contacts[index]['excelFilePath'];
                                    // print(filePath);
                                    Future.delayed(
                                        const Duration(milliseconds: 1500), () {
                                      Get.to(() => SheetPage(filePath));
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      alignment: Alignment.centerLeft,
                                      foregroundColor:
                                          Colors.white.withOpacity(0.5),
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0.0))),
                                  child: Text(
                                    contacts[index]['excelSheetName'],
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontFamily: 'Ubuntu',
                                      color: Color.fromARGB(230, 48, 68, 67),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: const Icon(Icons.remove),
                                  color: const Color.fromARGB(220, 48, 68, 67),
                                  onPressed: () {
                                    _deleteContact(contacts[index]['id']);
                                  },
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              )),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 3,
                  backgroundColor: Colors.white.withOpacity(0.55),
                  foregroundColor: Colors.white.withOpacity(0.55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              onPressed: () {
                pickFile(context);
              },
              child: const Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Text(
                      'Upload New Sheet',
                      style: TextStyle(
                          fontFamily: 'Ubuntu',
                          color: Color.fromARGB(230, 48, 68, 67)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.add,
                      color: Color.fromARGB(220, 48, 68, 67),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> readExcelData(String filePath) async {
    try {
      var file = File(filePath);
      var bytes = await file.readAsBytes();

      try {
        var excel = prefix.Excel.decodeBytes(bytes);
        // ignore: unused_local_variable
        var sheet = excel.tables.keys.first;
      } catch (e) {
        // If Excel parsing fails due to custom formats, that's okay
        // The file can still be uploaded to the API for processing
        print(
            "Excel preview not available for this file, but it can still be used.");
      }
    } catch (e) {
      print("Error reading Excel file: $e");
      rethrow;
    }
  }

  Future<void> pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      readExcelData(filePath);
      c.fileImported.value = true;
      c.filePath.value = result.files.single.name;
      ExcelSheets newContact = ExcelSheets(
          excelSheetName: result.files.single.name, excelFilePath: filePath);
      await dbHelper.insertContact(newContact);

      setState(() {}); // Refresh the UI after deletion
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No file selected"),
      ));
    }
  }

  void _deleteContact(int contactId) async {
    await dbHelper.deleteContact(contactId);
    setState(() {}); // Refresh the UI after deletion
  }
}
