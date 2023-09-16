import 'package:VenueVerse/components/Snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../components/Colors.dart';
import '../components/Custompopup.dart';

class Private extends StatefulWidget {
  @override
  State<Private> createState() => _PrivateState();
}

class _PrivateState extends State<Private> {
  @override
  void initState() {
    // getdata();
    super.initState();
  }

  // List Admindata = [];
  // Future<void> getdata() async {
  //   try {
  //     QuerySnapshot a = await _firestore.collection("Admin").get();
  //     final data = a.docs.map((doc) => [doc.data(), doc.id]).toList();
  //     setState(() {
  //       Admindata = data;
  //       _isloading = false;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isloading = false;
  List<Map<String, String>> data = [
    {'email': 'akash.2011003@srec.ac.in', 'department': 'AI&DS'},
    {'email': 'prasath.2011031@srec.ac.in', 'department': 'IT'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Private Access"),
          centerTitle: true,
          backgroundColor: Appcolor.secondgreen,
          foregroundColor: Colors.white,
          // actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
        ),
        body: _isloading
            ? Center(
                child: CircularProgressIndicator(color: Appcolor.secondgreen),
              )
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: StreamBuilder(
                    stream: _firestore.collection("Admin").snapshots(),
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
                        Reqcard.add(Admincard(data: doc.data(), docid: doc.id));
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: Reqcard,
                      );
                    })));
  }
}

class Admincard extends StatelessWidget {
  const Admincard({super.key, required this.data, required this.docid});
  final data;
  final docid;

  void showCustomDialog({context, email, docid}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          docid: docid,
          email: email,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    data['email'],
                    style: GoogleFonts.ysabeau(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    data['dept'],
                    style: GoogleFonts.ysabeau(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
                color: Appcolor.firstgreen,
                icon: Icon(Icons.edit),
                onPressed: () {
                  showCustomDialog(
                      context: context, docid: docid, email: data['email']);
                }),
          ],
        ),
      ),
    );
  }
}

class CustomAlertDialog extends StatefulWidget {
  CustomAlertDialog({required this.docid, required this.email});
  final email;
  final docid;

  @override
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  final TextEditingController _emailController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isloading = false;
  @override
  Widget build(BuildContext context) {
    return _isloading
        ? Center(
            child: CircularProgressIndicator(
              color: Appcolor.firstgreen,
            ),
          )
        : AlertDialog(
            title: Text('Update Email'),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_isEmailValid(_emailController.text)) {
                    Preprocessddata(context);
                  } else {
                    Showsnackbar(
                        context: context,
                        contentType: ContentType.failure,
                        title: "Invalid Email",
                        message: "Please verify your email ....");
                  }
                },
                child: Text('Update'),
              ),
            ],
          );
  }

  bool _isEmailValid(String email) {
    String emailPattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    RegExp regex = new RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  Future<void> Preprocessddata(context) async {
    setState(() {
      _isloading = true;
    });
    try {
      CollectionReference b = await _firestore.collection("Userdetails");
      Query search = b.where("email", isEqualTo: _emailController.text);
      QuerySnapshot que = await search.get();
      var pre = que.docs.map((doc) => doc.id).toList();
      if (pre.isNotEmpty) {
        await _firestore
            .collection("Userdetails")
            .doc(pre[0])
            .update({"isadmin": true}).then((value) async {
          CollectionReference a = await _firestore.collection("Userdetails");
          Query _cat = a.where("email", isEqualTo: widget.email);
          QuerySnapshot querySnapshot = await _cat.get();
          var predata =
              querySnapshot.docs.map((doc) => [doc.data(), doc.id]).toList();
          if (predata.isNotEmpty) {
            String id = predata[0][1].toString();
            await _firestore
                .collection("Userdetails")
                .doc(id)
                .update({"isadmin": FieldValue.delete()});
          } else {
            Showsnackbar(
                context: context,
                contentType: ContentType.failure,
                title: "Invalid User",
                message: "Cannot find the old user...");
          }
          await _firestore
              .collection("Admin")
              .doc(widget.docid)
              .update({"email": _emailController.text}).then((value) {
            Showsnackbar(
                context: context,
                contentType: ContentType.success,
                title: "Updated",
                message: "New admin successfully updated");
          });
        });
      } else {
        Showsnackbar(
            context: context,
            contentType: ContentType.failure,
            title: "Invalid Email",
            message:
                "User should be exists before given them admin privileges");
      }
      Navigator.pop(context);
    } catch (e) {
      print(e);
      setState(() {
        _isloading = false;
      });
    }
    setState(() {
      _isloading = false;
    });
  }
}
