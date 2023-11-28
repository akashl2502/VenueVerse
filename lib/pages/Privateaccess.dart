import 'package:VenueVerse/components/Snackbar.dart';
import 'package:VenueVerse/pages/Userdetails.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:uuid/uuid.dart';
import '../components/Colors.dart';
import '../components/Custompopup.dart';

class Private extends StatefulWidget {
  @override
  State<Private> createState() => _PrivateState();
}

class _PrivateState extends State<Private> {
  @override
  void initState() {
    super.initState();
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isloading = false;
  List<Map<String, String>> data = [
    {'email': 'akash.2011003@srec.ac.in', 'department': 'AI&DS'},
    {'email': 'prasath.2011031@srec.ac.in', 'department': 'IT'},
  ];
  void UpdateArray({required Map<String, dynamic> newMap, required hname}) {
    print(hname);
    setState(() {
      _isloading = true;
    });
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String documentID = 'OS4SmHTi9m3awkhAZrb8';
    DocumentReference documentRef =
        firestore.collection('Rooms').doc(documentID);
    firestore.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(documentRef);
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          List<dynamic> halles = data[hname] ?? [];
          halles.add(newMap);
          transaction.update(documentRef, {hname: halles});
        }
      }
    }).then((_) {
      setState(() {
        _isloading = false;
      });
      Showsnackbar(
          context: context,
          contentType: ContentType.success,
          title: "Updated",
          message: "New data has been updated");
    }).catchError((error) {
      print(error);
      setState(() {
        _isloading = false;
      });
      Showsnackbar(
          context: context,
          contentType: ContentType.failure,
          title: "Failed",
          message: "Failed to update data");
    });
  }

  Future<void> ShowAlertbox() async {
    String hallName = '';
    String selectedHall = 'Halls';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirmation",
            style: GoogleFonts.ysabeau(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                onChanged: (name) {
                  hallName = name;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedHall,
                items: ['Halls', 'Labs'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedHall = newValue.toString();
                },
                decoration: InputDecoration(),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      var uuid = Uuid();
                      String Randomuuid = uuid.v4();
                      Map<String, dynamic> newMap = {
                        'dept': userdet['dept'],
                        "name": hallName,
                        'uid': Randomuuid
                      };
                      if (hallName.isNotEmpty) {
                        UpdateArray(newMap: newMap, hname: selectedHall);
                        Navigator.of(context).pop();
                      } else {
                        Showsnackbar(
                            context: context,
                            contentType: ContentType.warning,
                            title: "Important",
                            message: "Name should not be empty");
                      }
                    },
                    child: Text(
                      "Add",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Private Access"),
          centerTitle: true,
          backgroundColor: Appcolor.secondgreen,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () {
                  ShowAlertbox();
                },
                icon: Icon(Icons.add))
          ],
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
            title: Text(
              "Update Email",
              style: GoogleFonts.ysabeau(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
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
