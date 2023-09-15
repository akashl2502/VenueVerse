import 'package:VenueVerse/pages/Userdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/Colors.dart';

class Viewrequests extends StatefulWidget {
  const Viewrequests({super.key});

  @override
  State<Viewrequests> createState() => _ViewrequestsState();
}

class _ViewrequestsState extends State<Viewrequests> {
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
            child: SafeArea(
                child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: StreamBuilder(
                  stream: _firestore
                      .collection('request')
                      .where('did', isEqualTo: userdet['did'])
                      .where('isapproved', isEqualTo: 'pending')
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

                      Reqcard.add(Requestcard(
                          width: width, data: doc.data(), docid: doc.id));
                    }
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: Reqcard);
                  }),
            )),
          ),
        ),
      ),
    );
  }
}

class Requestcard extends StatefulWidget {
  const Requestcard(
      {super.key,
      required this.width,
      required this.data,
      required this.docid});

  final double width;
  final data;
  final docid;

  @override
  State<Requestcard> createState() => _RequestcardState();
}

class _RequestcardState extends State<Requestcard> {
  @override
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> Actorrej({action}) async {
    await _firestore
        .collection('request')
        .doc(widget.docid)
        .update({'isapproved': action});
  }

  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
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
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    // Wrap the Text widget with another Flexible
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        '${widget.data['name']}(${widget.data['roll']}) from ${widget.data['dept']} is requesting to takeover ${widget.data['RN']} from ${widget.data['FT']} to ${widget.data['ET']} at ${widget.data['dor']}',
                        style: GoogleFonts.ysabeau(
                          fontSize: 19,
                          height: 2,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,

                        textAlign: TextAlign.center, // Define a max line count
                        overflow:
                            TextOverflow.ellipsis, // Use ellipsis for overflow
                        softWrap: true, // Enable soft line wrap
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Approval Pending Container
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Actorrej(action: "Approved");
                  },
                  icon: Icon(Icons.check),
                  label: Text("Approve"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white // background color
                      ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Actorrej(action: "Denied");
                  },
                  icon: Icon(Icons.close),
                  label: Text("Reject"),
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.red, // text and icon color
                      side: BorderSide(color: Colors.red),
                      foregroundColor: Colors.white // border color
                      ),
                ),
              ],
            ), // Space between the row and the approval container
          ],
        ),
      ),
    );
  }
}
