import 'package:cloud_firestore/cloud_firestore.dart';

class Answer {
  Future<void> addAnswerToRoom(
      String name, String nameUser, String answer, int index) async {
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
        .set({'name': nameUser, 'answer': answer, 'index': index, 'like': 0});
  }

  addLikeAnswer(String nameUser, int index, String nameRoom) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();

    var docId = filter.docs.first.id;

    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(docId)
        .collection('answers')
        .where(
          'name',
          isEqualTo: nameUser,
        )
        .where('index', isEqualTo: index)
        .get();
    DocumentReference userDocRef = userSnapshot.docs.first.reference;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDocRef);
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        int newLikeCount = (data['like'] ?? 0) + 1;
        transaction.update(userDocRef, {'like': newLikeCount});
      }
    });
  }
}
