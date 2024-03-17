import 'package:com.srec.venueverse/Api/Cloudpush.dart';
import 'package:com.srec.venueverse/components/Snackbar.dart';
import 'package:com.srec.venueverse/pages/Pastreviewrequest.dart';
import 'package:com.srec.venueverse/pages/Userdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';
import '../components/Colors.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Pastviewrequests()));
            },
            icon: Icon(Icons.history),
          )
        ],
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
                      .where('dept', isEqualTo: userdet['dept'])
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
    if (!mounted) {
      return null;
    }
    await _firestore
        .collection('request')
        .doc(widget.docid)
        .update({'isapproved': action}).then((value) async {
      if (action == "Approved") {
        updateBooking();
      } else {
        // Showsnackbar(
        //     context: context,
        //     contentType: ContentType.failure,
        //     title: "Rejected",
        //     message: "${widget.data['name']} request haas been updated");
      }
      try {
        print(widget.data);
        CollectionReference _cat = _firestore.collection("Userdetails");
        Query query = _cat.where("uid", isEqualTo: widget.data['uid']);
        QuerySnapshot querySnapshot = await query.get();
        final _docData = querySnapshot.docs.map((doc) => doc.data()).toList();

        final temp = querySnapshot.docs.map((doc) => doc.data()).toList();
        if (temp.isNotEmpty) {
          var fcm = (temp[0] as Map<String, dynamic>)['fcm'];
          print(fcm);
          try {
            sendPushNotification(
                email: widget.data['email'],
                state: 1,
                registration_token: fcm,
                title: "Request Status",
                body:
                    "Your Request for ${widget.data['RN']} has been ${action} by department on ${widget.data['dor']} between ${widget.data['FT']} on ${widget.data['ET']}",
                reason: '');
          } catch (e) {
            print(e);
            print("Api error");
          }
        }
      } catch (e) {
        print(e);
      }
    });
  }

  Future<void> updateBooking() async {
    try {
      var uuid = Uuid();
      String Randomuuid = uuid.v4();
      print(Randomuuid);
      DocumentReference<Map<String, dynamic>> docRef =
          _firestore.collection("Booking").doc(widget.data['dor']);

      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await docRef.get();

      if (querySnapshot.exists) {
        Map<String, dynamic> _docData = querySnapshot.data()!;
        if (_docData.keys.contains(widget.data['rid'])) {
          print(_docData[widget.data['rid']]);
          Map<String, dynamic> newData = {
            widget.data['rid']: {
              ..._docData[widget.data['rid']],
              Randomuuid: [
                widget.data['FT'],
                widget.data['ET'],
                widget.data['name'],
                widget.data['roll'],
                widget.data['reason']
              ],
            }
          };
          print(newData);
          await docRef.update(newData);
          print('Document updated successfully');
        } else {
          await _firestore.collection("Booking").doc(widget.data['dor']).set({
            widget.data['rid']: {
              Randomuuid: [
                widget.data['FT'],
                widget.data['ET'],
                widget.data['name'],
                widget.data['roll'],
                widget.data['reason']
              ]
            },
          }, SetOptions(merge: true));
        }
      } else {
        await _firestore.collection("Booking").doc(widget.data['dor']).set({
          widget.data['rid']: {
            Randomuuid: [
              widget.data['FT'],
              widget.data['ET'],
              widget.data['name'],
              widget.data['roll'],
              widget.data['reason']
            ]
          },
        }, SetOptions(merge: true));
      }

      Showsnackbar(
          context: context,
          contentType: ContentType.success,
          title: "Accpect",
          message: "${widget.data['name']} request haas been updated");
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Widget build(BuildContext context) {
    print(widget.data);

    return Container(
      margin: EdgeInsets.only(bottom: 20),
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
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        '${widget.data['name']}(${widget.data['roll']}) from ${widget.data['dept']} is requesting to takeover ${widget.data['RN']} from ${widget.data['FT']} to ${widget.data['ET']} at ${widget.data['dor']} because ${widget.data['reason']}',
                        style: GoogleFonts.ysabeau(
                          fontSize: 19,
                          height: 2,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 10,
                        textAlign: TextAlign.center,
                        overflow:
                            TextOverflow.ellipsis, // Use ellipsis for overflow
                        // Remove or set softWrap to false
                        // softWrap: true,
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Alert!",
                            style: GoogleFonts.ysabeau(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 20),
                              SingleChildScrollView(
                                child: Text(
                                  "Are you sure to Accpect this request",
                                  style: GoogleFonts.ysabeau(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Actorrej(action: "Approved");

                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(
                                          color: Colors.green, fontSize: 15),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "No",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            "Alert",
                            style: GoogleFonts.ysabeau(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 20),
                              SingleChildScrollView(
                                child: Text(
                                  "Are you sure to reject this request",
                                  style: GoogleFonts.ysabeau(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Actorrej(action: "denied");

                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(
                                          color: Colors.green, fontSize: 15),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "No",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
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
