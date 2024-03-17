import 'package:com.srec.venueverse/components/Colors.dart';
import 'package:com.srec.venueverse/pages/Userdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Status"),
        centerTitle: true,
        backgroundColor: Appcolor.secondgreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
          child: SingleChildScrollView(
            child: StreamBuilder(
                stream: _firestore
                    .collection('request')
                    .where('uid', isEqualTo: userdet['uid'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: Appcolor.firstgreen,
                    ));
                  } else if (snapshot.hasError) {
                    return Column(
                      children: [
                        Center(child: Text('Error: ${snapshot.error}'))
                      ],
                    ); // If there's an error
                  }
                  // else if (!snapshot.hasData ||
                  //     snapshot.data!.docs.isEmpty) {
                  //   return Column(
                  //     children: [Center(child: Text('No data available.'))],
                  //   );
                  // }

                  final orderDocs = snapshot.data!.docs;
                  List<Widget> Reqcard = [];
                  for (var doc in orderDocs) {
                    print('Document ID: ${doc.id}');
                    print('Data: ${doc.data()}');

                    Reqcard.add(Viewrequestcard(
                      width: width,
                      data: doc.data(),
                      docid: doc.id,
                    ));
                  }
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: Reqcard);
                }),
          ),
        ),
      ),
    );
  }
}

class Viewrequestcard extends StatelessWidget {
  const Viewrequestcard(
      {super.key,
      required this.width,
      required this.data,
      required this.docid});

  final double width;
  final data;
  final docid;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set this for the Column
          children: [
            // Row for Name and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      data['RN'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ysabeau(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      data['dor'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ysabeau(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Approval Pending Container
            SizedBox(
                height: 20), // Space between the row and the approval container
            Container(
              width: width * 0.8,
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: data['isapproved'] == 'pending'
                    ? Colors.orangeAccent
                    : data['isapproved'] == 'Approved'
                        ? Colors.greenAccent
                        : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                data['isapproved'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
