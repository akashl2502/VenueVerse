import 'package:com.srec.venueverse/components/Snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<dynamic> Getrooms({required context, room}) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    CollectionReference _cat = _firestore.collection("Rooms");
    QuerySnapshot querySnapshot = await _cat.get();

    final _docData = querySnapshot.docs.map((doc) => doc.data()).toList();
    return _docData[0];
  } catch (e) {
    Showsnackbar(
        context: context,
        contentType: ContentType.failure,
        title: "Error",
        message: "Someting has occured please contant admin");
    print(e);
    return [];
  }
}
