import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: library_prefixes, implementation_imports
import 'package:flutter/src/painting/box_border.dart' as OuterBorder;

// ignore: must_be_immutable
class SheetPage extends StatefulWidget {
  var filePath = "";

  SheetPage(this.filePath, {super.key});

  @override
  // ignore: no_logic_in_create_state
  SheetPageState createState() => SheetPageState(filePath);
}

class SheetPageState extends State<SheetPage> {
  var filePath = "";
  SheetPageState(this.filePath);
  List<List<String>> excelData = [];
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExcelData();
  }

  Future<void> _loadExcelData() async {
    try {
      List<List<String>> data = await readExcel();
      setState(() {
        excelData = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff405C5A),
      appBar: AppBar(
        backgroundColor: const Color(0xff405C5A),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xffFFCFA3),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff034B40),
                            foregroundColor: const Color(0xffFFCFA3),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    decoration: BoxDecoration(
                      border: OuterBorder.Border.all(
                        color: Colors.white, // Set the border color
                        width: 1.0, // Set the border width
                      ),
                      color: const Color(0xff405C5A),
                    ),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Center(
                        child: excelData.isNotEmpty && excelData.length > 1
                            ? DataTable(
                                columns: List<DataColumn>.generate(
                                  excelData[0]
                                      .length, // Use header count as the column count
                                  (index) => DataColumn(
                                    label: Text(
                                      index < excelData[0].length
                                          ? excelData[0][index]
                                          : '', // Use empty string for extra headers
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ),
                                ),
                                rows: excelData
                                    .sublist(1)
                                    .map<DataRow>((List<String> rowData) {
                                  assert(rowData.length <= excelData[0].length,
                                      'Number of cells in data row must not exceed the number of columns.');

                                  // If there are fewer cells than columns, pad with empty strings
                                  final paddedRowData = List<String>.filled(
                                    excelData[0].length,
                                    '',
                                    growable: false,
                                  );
                                  for (var i = 0; i < rowData.length; i++) {
                                    paddedRowData[i] = rowData[i];
                                  }

                                  return DataRow(
                                    cells: paddedRowData
                                        .map<DataCell>((String cellData) {
                                      return DataCell(Text(
                                        cellData,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        overflow: TextOverflow.visible,
                                      ));
                                    }).toList(),
                                  );
                                }).toList(),
                              )
                            : const Text(
                                'No data available',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Future<List<List<String>>> readExcel() async {
    try {
      final File file = File(filePath); // Use the picked file path directly

      if (!await file.exists()) {
        throw Exception("File does not exist.");
      }

      final Uint8List bytes = await file.readAsBytes();

      // Try to decode with error handling for custom formats
      Excel excel;
      try {
        excel = Excel.decodeBytes(bytes);
      } catch (e) {
        // If there's an issue with custom number formats, return empty data
        // but don't throw - the file can still be used with the API
        throw Exception(
            "Preview not available for this Excel file.\n\nThis file uses custom formatting that cannot be displayed, but don't worry - you can still use it in the chat! The file has been saved and the API will process it correctly.");
      }

      String firstSheet = excel.tables.keys.first;

      final sheet = excel.tables[firstSheet];

      List<List<String>> excelData = [];

      for (var row in sheet!.rows) {
        List<String> rowData = [];
        for (var cell in row) {
          if (cell != null) {
            rowData.add(cell.value.toString());
          }
        }
        excelData.add(rowData);
      }
      return excelData;
    } catch (e) {
      // Return a friendly error message but allow the file to be used
      rethrow;
    }
  }
}
