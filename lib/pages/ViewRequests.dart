import 'dart:async';

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
  bool loading = false;
  Completer<void> _completer = Completer<void>();

  @override
  void dispose() {
    // Cancel the Completer when the widget is disposed
    _completer.completeError('disposed');
    super.dispose();
  }

  Future<void> Actorrej({action}) async {
    setState(() {
      loading = true;
    });

    await _firestore
        .collection('request')
        .doc(widget.docid)
        .update({'isapproved': action}).then((value) async {
      if (action == "Approved") {
        try {
          CollectionReference _cat = _firestore.collection("Userdetails");
          Query query = _cat.where("uid", isEqualTo: widget.data['uid']);
          QuerySnapshot querySnapshot = await query.get();

          final temp = querySnapshot.docs.map((doc) => doc.data()).toList();
          if (temp.isNotEmpty) {
            var fcm = (temp[0] as Map<String, dynamic>)['fcm'];
            var dept = (temp[0] as Map<String, dynamic>)['dept'];

            CollectionReference _cat = _firestore.collection("Admin");
            Query query = _cat.where("dept", isEqualTo: dept);
            QuerySnapshot querySnapshot = await query.get();

            final admin_temp =
                querySnapshot.docs.map((doc) => doc.data()).toList();
            print(dept);
            print(admin_temp);
            if (admin_temp.isNotEmpty) {
              var email_id =
                  (admin_temp[0] as Map<String, dynamic>)['LA'] ?? [];
              List FCM_token = [fcm];
              List gmail_id = [widget.data['email']];
              for (var i = 0; i < email_id.length; i++) {
                gmail_id.add(email_id[i]['email']);
                CollectionReference _fcm_finder =
                    _firestore.collection("Userdetails");
                Query _fcm_q =
                    _fcm_finder.where("email", isEqualTo: email_id[i]['email']);
                QuerySnapshot querySnapshot = await _fcm_q.get();
                final temp =
                    querySnapshot.docs.map((doc) => doc.data()).toList();
                print(temp);
                if (temp.isNotEmpty) {
                  var fcm_token_peeple =
                      (temp[0] as Map<String, dynamic>)['fcm'] ?? null;
                  if (fcm_token_peeple != null) {
                    FCM_token.add(fcm_token_peeple);
                  }
                }
              }

              print(gmail_id);
              print(FCM_token);
              try {
                sendPushNotification(
                    email: gmail_id,
                    state: 1,
                    registration_token: FCM_token,
                    title: "Request Status",
                    body:
                        "Your Request for ${widget.data['RN']} has been ${action} by department on ${widget.data['dor']} between ${widget.data['FT']} on ${widget.data['ET']}",
                    reason: '');
                updateBooking();
              } catch (e) {
                print(e);
                print("Api error");
              }
            }
          }
        } catch (e) {
          print(e);
        }
      } else {
        Showsnackbar(
            context: context,
            contentType: ContentType.failure,
            title: "Rejected",
            message: "${widget.data['name']} request haas been updated");
      }
    });
  }

  Future<void> updateBooking() async {
    try {
      var uuid = Uuid();
      String Randomuuid = uuid.v4();
      DocumentReference<Map<String, dynamic>> docRef =
          _firestore.collection("Booking").doc(widget.data['dor']);

      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await docRef.get();

      if (querySnapshot.exists) {
        Map<String, dynamic> _docData = querySnapshot.data()!;
        if (_docData.keys.contains(widget.data['rid'])) {
          Map<String, dynamic> newData = {
            widget.data['rid']: {
              ..._docData[widget.data['rid']],
              Randomuuid: [
                widget.data['FT'],
                widget.data['ET'],
                widget.data['name'],
                widget.data['roll'],
                widget.data['reason'],
                widget.data['dept']
              ],
            }
          };
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
                widget.data['reason'],
                widget.data['dept']
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
              widget.data['reason'],
              widget.data['dept']
            ]
          },
        }, SetOptions(merge: true));
      }

      Showsnackbar(
          context: context,
          contentType: ContentType.success,
          title: "Accept",
          message: "${widget.data['name']} request haas been updated");

      if (mounted) {}
    } catch (e) {
      if (mounted) {}
      print('Error fetching data: $e');
    }
  }

  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: CircularProgressIndicator(
              color: Appcolor.firstgreen,
            ),
          )
        : Container(
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
                              '${widget.data['name']}(${widget.data['roll']}) from ${widget.data['dept']} is requesting to takeover ${widget.data['RN']} from ${widget.data['FT']} to ${widget.data['ET']} on ${widget.data['dor']} for ${widget.data['reason']}',
                              style: GoogleFonts.ysabeau(
                                fontSize: 19,
                                height: 2,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 10,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow
                                  .ellipsis, // Use ellipsis for overflow
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
                        onPressed: () async {
                          await showDialog(
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
                                        "Are you sure to Accept this request",
                                        style: GoogleFonts.ysabeau(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            await Actorrej(action: "Approved");
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Yes",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 15),
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
                                                color: Colors.red,
                                                fontSize: 15),
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
                        onPressed: () async {
                          var user_bool = false;
                          await showDialog(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Actorrej(action: "denied");
                                            user_bool = false;
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Yes",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 15),
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
                                                color: Colors.red,
                                                fontSize: 15),
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
