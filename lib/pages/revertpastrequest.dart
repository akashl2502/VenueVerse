import 'package:com.srec.venueverse/Api/Cloudpush.dart';
import 'package:com.srec.venueverse/components/Snackbar.dart';
import 'package:com.srec.venueverse/components/booking_finder.dart';
import 'package:com.srec.venueverse/pages/Peekinside.dart';
import 'package:com.srec.venueverse/pages/Userdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';
import '../components/Colors.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class Reverpastviewrequest extends StatefulWidget {
  Reverpastviewrequest(this.docid, this.date, this.rid, this.toggle);
  final date;
  final rid;
  final docid;
  final toggle;
  @override
  State<Reverpastviewrequest> createState() => _ReverpastviewrequestState();
}

class _ReverpastviewrequestState extends State<Reverpastviewrequest> {
  @override
  bool loading = true;
  Map pastdata = {};
  List widgets = [];

  @override
  void initState() {
    getBookingData(widget.date, widget.rid);
    super.initState();
  }

  void deleteHello(rid) async {
    setState(() {
      loading = true;
    });
    print(widget.docid);
    _firestore.collection('request').doc(widget.docid).update({
      'isapproved': "denied",
    });
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference docRef = firestore.collection('Booking').doc(widget.date);
    DocumentSnapshot docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      print('Document does not exist');
      return;
    }
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    data[widget.rid].remove(rid);
    await docRef.update(data);
    await getBookingData(widget.date, widget.rid);
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Widget littlecard(ft, tt, name, roll, reason, rid, dept) {
    return Stack(
      children: [
        Card(
          elevation: 5,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${name} - ${dept}",
                        style: GoogleFonts.ysabeau(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Start Time - ${ft}",
                            style: GoogleFonts.ysabeau(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "End Time - ${tt}",
                            style: GoogleFonts.ysabeau(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                reason ?? 'No Reason',
                                style: GoogleFonts.ysabeau(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 10,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        widget.toggle
            ? Container()
            : Positioned(
                top: 20,
                right: 30,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Revert?",
                              style: GoogleFonts.ysabeau(
                                fontSize: 20,
                                color: Colors.black,
                              )),
                          content: Text("Are you sure you want to delete?",
                              style: GoogleFonts.ysabeau(
                                fontSize: 16,
                                color: Colors.grey[600],
                              )),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("No",
                                  style: GoogleFonts.ysabeau(
                                    fontSize: 16,
                                    color: Colors.green,
                                  )),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteHello(rid);
                                Navigator.pop(context);
                              },
                              child: Text("Yes",
                                  style: GoogleFonts.ysabeau(
                                    fontSize: 16,
                                    color: Colors.red,
                                  )),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Icon(Icons.delete, color: Colors.red),
                ),
              ),
      ],
    );
  }

  Future getBookingData(String docId, String Columnheader) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot docSnapshot =
          await firestore.collection('Booking').doc(docId).get();

      if (docSnapshot.exists) {
        Map<dynamic, dynamic> data =
            docSnapshot.data() as Map<dynamic, dynamic>;
        Map columndata = data[Columnheader];
        print(columndata);
        setState(() {
          loading = false;
          pastdata = columndata;
          widgets = columndata.keys.toList();
        });

        print(data);
      }
    } catch (e) {
      print('Error retrieving document: $e');
      return null;
    }
  }

  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.toggle ? "Booking Details" : "Revert Booking Status"),
        centerTitle: true,
        backgroundColor: Appcolor.secondgreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SafeArea(
              child: loading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: Appcolor.secondgreen))
                  : widgets.length == 0
                      ? Center(
                          child: Text(
                            "No Request Found",
                            style: GoogleFonts.ysabeau(
                              fontSize: 25,
                              color: Appcolor.firstgreen,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              for (var i = 0; i < widgets.length; i++)
                                if (pastdata[widgets[i]].length != 5)
                                  littlecard(
                                    pastdata[widgets[i]][0],
                                    pastdata[widgets[i]][1],
                                    pastdata[widgets[i]][2],
                                    pastdata[widgets[i]][3],
                                    pastdata[widgets[i]][4],
                                    widgets[i],
                                    pastdata[widgets[i]][5],
                                  )
                                else
                                  littlecard(
                                      pastdata[widgets[i]][0],
                                      pastdata[widgets[i]][1],
                                      pastdata[widgets[i]][2],
                                      pastdata[widgets[i]][3],
                                      pastdata[widgets[i]][4],
                                      widgets[i],
                                      "NA")
                            ],
                          ))),
        ),
      ),
    );
  }
}
