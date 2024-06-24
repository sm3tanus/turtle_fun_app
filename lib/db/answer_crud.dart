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
    try {
      var filter = await FirebaseFirestore.instance
          .collection('rooms')
          .where('name', isEqualTo: nameRoom)
          .get();

      var docId = filter.docs.first.id;

      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(docId)
          .collection('answers')
          .where('name', isEqualTo: nameUser)
          .where('index', isEqualTo: index)
          .get();

      DocumentReference userDocRef = userSnapshot.docs.first.reference;

      DocumentSnapshot snapshot = await userDocRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int currentLikeCount = data['like'] ?? 0;

        await userDocRef.update({'like': currentLikeCount + 1});
        print('Лайк успешно добавлен.');
      } else {
        print('Документ не существует.');
      }
    } catch (e) {
      print('Произошла ошибка: $e');
    }
  }

  addPointToUser(String nameUser, String nameRoom) async {
    try {
      var filter = await FirebaseFirestore.instance
          .collection('rooms')
          .where('name', isEqualTo: nameRoom)
          .get();

      var docId = filter.docs.first.id;

      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(docId)
          .collection('usersPlay')
          .where('name', isEqualTo: nameUser)
          .get();

      DocumentReference userDocRef = userSnapshot.docs.first.reference;

      DocumentSnapshot snapshot = await userDocRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int currentPointCount = data['points'] ?? 0;

        await userDocRef.update({'points': currentPointCount + 1});
        print('Очко успешно добавлено.');
      } else {
        print('Документ не существует.');
      }
    } catch (e) {
      print('Произошла ошибка: $e');
    }
  }

  // Future<void> decideMostLikes(String nameRoom, int index) async {
  //   var filter = await FirebaseFirestore.instance
  //       .collection('rooms')
  //       .where('name', isEqualTo: nameRoom)
  //       .get();

  //   var docId = filter.docs.first.id;

  //   QuerySnapshot answer = await FirebaseFirestore.instance
  //       .collection('rooms')
  //       .doc(docId)
  //       .collection('answers')
  //       .where('index', isEqualTo: index)
  //       .get();
  //   int maxLikes = 0;
  //   for (var doc in answer.docs) {
  //     int likes = doc['like'];
  //     if (likes > maxLikes) {
  //       maxLikes = likes;
  //     }
  //   }
  //   print("Maximum likes: $maxLikes");
  // }
}
