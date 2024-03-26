import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:com.srec.venueverse/components/Colors.dart';
import 'package:com.srec.venueverse/components/Snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class hall_assistant extends StatefulWidget {
  const hall_assistant(
      {super.key,
      required this.list,
      required this.email,
      required this.docid});
  final List list;
  final String email;
  final docid;
  @override
  State<hall_assistant> createState() => _hall_assistantState();
}

class _hall_assistantState extends State<hall_assistant> {
  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    super.initState();
  }

  List HA_DATA = [];
  bool loading = true;

  void deleteItemFromOtherDocuments(
      String docId, Map<String, dynamic> itemToRemove) async {
    try {
      setState(() {
        loading = true;
      });
      final collection = FirebaseFirestore.instance.collection('Admin');

      final DocumentSnapshot? document = await collection.doc(docId).get();
      if (document != null && document.exists) {
        final Map<String, dynamic>? data =
            document.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('LA')) {
          final List<dynamic> LA = List.from(data['LA']);

          // Remove the item from the LA array if it exists
          LA.removeWhere((element) =>
              element['name'] == itemToRemove['name'] &&
              element['email'] == itemToRemove['email']);

          // Update the document with the modified LA array
          await collection.doc(docId).update({'LA': LA});
          Showsnackbar(
              context: context,
              contentType: ContentType.success,
              title: "User Removeed",
              message: "User removed from this user list");
          fetchData();
          print('Item removed from other documents successfully');
        } else {
          print('LA array not found in the document');
        }

        setState(() {
          loading = false;
        });
      } else {
        print('Document not found or LA array not found in the document');
      }
      print('Document not found or LA array not found in the document');
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('Error removing item from other documents: $e');
    }
  }

  void fetchData() async {
    setState(() {
      loading = true;
    });
    try {
      final document = await FirebaseFirestore.instance
          .collection('Admin')
          .doc(widget.docid)
          .get();

      if (document.exists) {
        final data = document.data();
        if (data != null && data.containsKey('LA')) {
          final LA = data['LA'];
          if (LA != null && LA.isNotEmpty) {
            print(LA);

            setState(() {
              HA_DATA = LA;
              loading = false;
            });
          } else {
            setState(() {
              HA_DATA = [];
              loading = false;
            });
          }
        } else {
          setState(() {
            HA_DATA = [];
            loading = false;
          });
        }
      } else {
        print("noooooooooooo");
        setState(() {
          HA_DATA = [];
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        HA_DATA = [];
        loading = false;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hall People Notifier"),
        centerTitle: true,
        backgroundColor: Appcolor.secondgreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AddPersonAlert(
                        docid: widget.docid,
                        rerenderdata: () {
                          fetchData();
                        });
                  },
                );
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: Appcolor.secondgreen,
              ),
            )
          : HA_DATA.length == 0
              ? Center(
                  child: Text(
                  "No Hall Assistant Found",
                  style: GoogleFonts.ysabeau(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ))
              : SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: HA_DATA
                        .map((data) => PersonCard(
                            name: data['name'],
                            email: data['email'],
                            onDeletePressed: () {
                              deleteItemFromOtherDocuments(widget.docid, {
                                'name': data['name'],
                                'email': data['email']
                              });
                            }))
                        .toList(),
                  ),
                ),
    );
  }
}

class PersonCard extends StatelessWidget {
  const PersonCard({
    Key? key,
    required this.name,
    required this.email,
    required this.onDeletePressed,
  }) : super(key: key);

  final String name;
  final String email;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.ysabeau(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    email,
                    style: GoogleFonts.ysabeau(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirm Deletion"),
                      content: Text("Are you sure you want to delete $name?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            onDeletePressed();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddPersonAlert extends StatefulWidget {
  final docid;
  final VoidCallback rerenderdata;

  const AddPersonAlert({
    Key? key,
    required this.docid,
    required this.rerenderdata,
  }) : super(key: key);

  @override
  _AddPersonAlertState createState() => _AddPersonAlertState();
}

class _AddPersonAlertState extends State<AddPersonAlert> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void addOrUpdateData(String collectionName, String docId,
      Map<String, dynamic> dataToAdd) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(collectionName);

    try {
      DocumentSnapshot documentSnapshot =
          await collectionReference.doc(docId).get();

      if (documentSnapshot.exists) {
        await collectionReference.doc(docId).update({
          'LA': FieldValue.arrayUnion([dataToAdd])
        });
      } else {
        await collectionReference.doc(docId).set({
          'LA': [dataToAdd]
        });
      }
      widget.rerenderdata();
      Showsnackbar(
          context: context,
          contentType: ContentType.success,
          title: "Successfully Updated",
          message: "Successfully Hall Assistant Added");
      Navigator.of(context).pop();
    } catch (e) {
      Showsnackbar(
          context: context,
          contentType: ContentType.failure,
          title: "Invalid Email",
          message: e);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Hall Assistant'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('No'),
        ),
        TextButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final email = _emailController.text.trim();
            if (name.isNotEmpty && email.isNotEmpty) {
              addOrUpdateData('Admin', widget.docid, {
                // Your map data here
                'name': name,
                'email': email,
              });
            }
          },
          child: Text('Yes'),
        ),
      ],
    );
  }
}
