import 'package:VenueVerse/pages/Userdetails.dart';
import 'package:flutter/material.dart';
import 'package:VenueVerse/components/Colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedHall = 'Halls';
  DateTime? startDate;
  DateTime? endDate;
  bool _isloading = true;
  List Reportdata = [];
  List<String> Department = ['Halls', 'Labs'];
  @override
  void initState() {
    getDeptNames();
    super.initState();
  }

  Future<void> _exportToPDF() async {
    final pdfLib.Document pdf = pdfLib.Document();

    pdf.addPage(
      pdfLib.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          if (Reportdata.isNotEmpty)
            pdfLib.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['Date', 'From Time', 'To Time', 'Name', 'Department'],
                for (var data in Reportdata)
                  <String>[
                    data['dor'],
                    data['FT'],
                    data['ET'],
                    data['name'],
                    data['dept']
                  ],
              ],
            ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/report.pdf');
    await file.writeAsBytes(await pdf.save());
    print('PDF saved to ${file.path}');
    OpenFile.open(file.path);
  }

  void getDeptNames() async {
    List<String> deptNames = [];
    print("hai");
    try {
      // Replace 'rooms' with your actual collection name
      // Replace 'OS4SmHTi9m3awkhAZrb8' with your actual document ID
      DocumentSnapshot<Map<String, dynamic>> roomDoc = await FirebaseFirestore
          .instance
          .collection('Rooms')
          .doc('OS4SmHTi9m3awkhAZrb8')
          .get();

      if (roomDoc.exists) {
        List<dynamic> hallsArray = roomDoc.data()?['Halls'] ?? [];
        List<dynamic> labsArray = roomDoc.data()?['Labs'] ?? [];

        for (var hall in hallsArray) {
          if (hall is Map<String, dynamic> && hall.containsKey('dept')) {
            if (userdet['dept'] == hall['dept']) {
              deptNames.add(hall['name']);
            }
          }
        }
        for (var lab in labsArray) {
          if (lab is Map<String, dynamic> && lab.containsKey('dept')) {
            if (userdet['dept'] == lab['dept']) {
              deptNames.add(lab['name']);
            }
          }
        }
      }
    } catch (error) {
      setState(() {
        _isloading = false;
      });
      print("Error fetching data: $error");
    }
    setState(() {
      if (deptNames.length!=0){
    Department = deptNames;
      selectedHall = deptNames[0];
      }else{
        Department = ['Halls', 'Labs'];
        selectedHall='Halls';
      } 
  
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Report"),
        centerTitle: true,
        backgroundColor: Appcolor.secondgreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _isloading
            ? CircularProgressIndicator(color: Appcolor.secondgreen)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Hall:",
                    style: GoogleFonts.ysabeau(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedHall,
                    items: Department.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedHall = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Select Date Range:",
                    style: GoogleFonts.ysabeau(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );

                            if (pickedDate != null && pickedDate != startDate) {
                              setState(() {
                                startDate = pickedDate;
                              });
                            }
                          },
                          child: Text("Start Date"),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );

                            if (pickedDate != null && pickedDate != endDate) {
                              setState(() {
                                endDate = pickedDate;
                              });
                            }
                          },
                          child: Text("End Date"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Display selected dates
                  SizedBox(height: 20),
                  if (startDate != null && endDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Selected Start Date:",
                              style: GoogleFonts.ysabeau(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${DateFormat('yyyy-MM-dd').format(startDate!)}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              "Selected End Date:",
                              style: GoogleFonts.ysabeau(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${DateFormat('yyyy-MM-dd').format(endDate!)}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),

                  SizedBox(height: 20),
                  if (startDate != null &&
                      endDate != null &&
                      Reportdata.length != 0)
                    Text(
                      "Report Data:",
                      style: GoogleFonts.ysabeau(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  SizedBox(height: 10),
                  if (startDate != null &&
                      endDate != null &&
                      Reportdata.length != 0)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('From Time')),
                          DataColumn(label: Text('To Time')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Faculty Id')),
                          DataColumn(label: Text('Department')),
                        ],
                        rows: Reportdata.map((data) {
                          return DataRow(
                            cells: [
                              DataCell(Text(data['dor'])),
                              DataCell(Text(data['FT'])),
                              DataCell(Text(data['ET'])),
                              DataCell(Text(data['name'])),
                              DataCell(Text(data['roll'])),
                              DataCell(Text(data['dept'])),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  if (startDate != null && endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (selectedHall != 'Halls' &&
                                  startDate != null &&
                                  endDate != null) {
                                int startTimestamp =
                                    startDate!.millisecondsSinceEpoch;
                                int endTimestamp =
                                    endDate!.millisecondsSinceEpoch;

                                _searchInFirebase(
                                    selectedHall, startTimestamp, endTimestamp);
                              } else {
                                // Handle error, show a snackbar or any other UI indication
                              }
                            },
                            child: Text("Generate Report"),
                          ),
                        ],
                      ),
                    )
                ],
              ),
      ),
    );
  }

  void _searchInFirebase(String hall, int startTimestamp, int endTimestamp) {
    setState(() {
      _isloading = true;
    });
    _firestore
        .collection('request')
        .where('RN', isEqualTo: hall)
        .where('isapproved', isEqualTo: "Approved")
        .where('datemill', isGreaterThanOrEqualTo: startTimestamp)
        .where('datemill', isLessThanOrEqualTo: endTimestamp)
        .get()
        .then((QuerySnapshot<Object?> querySnapshot) {
      List Rdata = [];
      for (QueryDocumentSnapshot<Object?> document in querySnapshot.docs) {
        if (document.data() != null) {
          Rdata.add(document.data()!);
        }
      }
      setState(() {
        Reportdata = Rdata;
        _isloading = false;
      });
    }).catchError((error) {
      setState(() {
        _isloading = false;
      });
      print("Error searching in Firebase: $error");
    });
  }
}

class UserData {
  final String name;
  final String department;

  UserData({
    required this.name,
    required this.department,
  });
}
