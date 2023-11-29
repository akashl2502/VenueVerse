import 'package:VenueVerse/components/Snackbar.dart';
import 'package:VenueVerse/pages/Userdetails.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../components/Colors.dart';
import '../components/Custompopup.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<String> uploadImage(File? image) async {
    if (image == null) {
      return ''; // Return empty string if no image is selected
    }

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageReference = storage.ref().child('images/${Uuid().v4()}');

    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => print('Image uploaded'));

    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }

  Future<void> ShowAlertbox() async {
    String hallName = '';
    String seatNumber = '';
    String notes = '';
    String selectedHall = 'Halls';
    bool projector = false;
    bool audioSystem = false;
    bool airCondition = false;
    File? selectedImage;
    bool storagePermissionGranted = false;

    var storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) {
      storagePermissionGranted = true;
    } else {
      var result = await Permission.storage.request();
      if (result.isGranted) {
        storagePermissionGranted = true;
      } else {
        Showsnackbar(
          context: context,
          contentType: ContentType.warning,
          title: "Storage Permission",
          message: "Must be granted permission",
        );
        // Future.delayed(Duration(seconds: 2), () {
        //   Navigator.pop(context);
        // });
      }
    }

    if (!storagePermissionGranted) {
      Showsnackbar(
        context: context,
        contentType: ContentType.warning,
        title: "Storage Permission",
        message: "Must be granted permission",
      );
      // Future.delayed(Duration(seconds: 2), () {
      //   Navigator.pop(context);
      // });
    }
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              "Confirmation",
              style: GoogleFonts.ysabeau(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker _picker = ImagePicker();
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            setState(() {
                              selectedImage = File(image.path);
                            });
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: selectedImage != null
                              ? Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    onChanged: (name) {
                      hallName = name;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  SizedBox(height: 10),
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
                  TextFormField(
                    onChanged: (number) {
                      seatNumber = number;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Seat Capacity',
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: projector,
                            onChanged: (value) {
                              setState(() {
                                projector = value!;
                              });
                            },
                          ),
                          Text('Projector'),
                        ],
                      ),
                      SizedBox(width: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: audioSystem,
                            onChanged: (value) {
                              setState(() {
                                audioSystem = value!;
                              });
                            },
                          ),
                          Text('Audio System'),
                        ],
                      ),
                      SizedBox(width: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: airCondition,
                            onChanged: (value) {
                              setState(() {
                                airCondition = value!;
                              });
                            },
                          ),
                          Text('Air Condition'),
                        ],
                      ),
                    ],
                  ),
                  TextFormField(
                    onChanged: (value) {
                      notes = value;
                    },
                    maxLines: 3, // Allows multiple lines
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () async {
                          var uuid = Uuid();
                          String Randomuuid = uuid.v4();
                          Map<String, dynamic> newMap = {
                            'dept': userdet['dept'],
                            "name": hallName,
                            'seatNumber': seatNumber,
                            'notes': notes,
                            'projector': projector,
                            'audio': audioSystem,
                            'ac': airCondition,
                            'uid': Randomuuid,
                          };
                          var checkimg = selectedImage != null
                              ? selectedImage!.existsSync()
                              : false;
                          if (hallName.isNotEmpty &&
                              notes.isNotEmpty &&
                              seatNumber.isNotEmpty &&
                              checkimg) {
                            setState(() {
                              _isloading = true;
                            });
                            try {
                              String imageUrl =
                                  await uploadImage(selectedImage);
                              newMap['imageurl'] = imageUrl;
                              print(newMap);
                              UpdateArray(newMap: newMap, hname: selectedHall);
                            } catch (e) {
                              Showsnackbar(
                                context: context,
                                contentType: ContentType.failure,
                                title: "Important",
                                message: e.toString(),
                              );
                              setState(() {
                                _isloading = false;
                              });
                            }
                            Navigator.of(context).pop();
                          } else {
                            Showsnackbar(
                              context: context,
                              contentType: ContentType.warning,
                              title: "Important",
                              message: "Name should not be empty",
                            );
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
            ),
          );
        });
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
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add') {
                  ShowAlertbox();
                } else if (value == 'edit') {
                  // Handle edit action
                  // ...
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'add',
                  child: ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add'),
                  ),
                ),
                // const PopupMenuItem<String>(
                //   value: 'edit',
                //   child: ListTile(
                //     leading: Icon(Icons.edit),
                //     title: Text('Edit'),
                //   ),
                // ),
              ],
            ),
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
