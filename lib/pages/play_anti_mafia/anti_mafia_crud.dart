import 'package:cloud_firestore/cloud_firestore.dart';

class AntiMafiaCrud {
  Future<void> updateRole(String nameRoom, String nameUser) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();

    var roomId = filter.docs.first.id;

    var usersPlay = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('users')
        .where('name', isEqualTo: nameUser)
        .get();

    var userId = usersPlay.docs.first.id;
    var userDocRef = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('users')
        .doc(userId);

    await userDocRef.update({'role': 1});
  }

  Future<void> updateLeaderInRound(
      String nameRoom, int roundCount, String nameUser) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();

    var roomId = filter.docs.first.id;

    var usersPlay = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('gameResults')
        .where('leaderName', isEqualTo: '')
        .get();

    var userId = usersPlay.docs.first.id;
    var userDocRef = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('gameResults')
        .doc(userId);

    await userDocRef.update({
      '${roundCount}': {'leaderName': nameUser}
    });
  }
}
