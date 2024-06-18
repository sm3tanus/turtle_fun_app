import 'package:cloud_firestore/cloud_firestore.dart';

class Answer{
  Future<void> addAnswerToRoom(String name, String nameUser, String answer, int index) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: name)
        .get();

    var docId = filter.docs.first.id;

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(docId)
        .collection('answers')
        .doc()
        .set({
      'name': nameUser,
      'answer': answer,
      'index': index
    });
  }
}