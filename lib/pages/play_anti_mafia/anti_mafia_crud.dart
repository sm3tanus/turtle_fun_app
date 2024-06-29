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

  Future<void> updateLeaderInRound(String nameRoom, int roundCount, int id,
      String nameUser, int membersCount, bool result) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();

    var roomId = filter.docs.first.id;

    // Получаем ссылку на документ gameResults
    var filter2 = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('gameResults')
        .where('id', isEqualTo: id)
        .get();
    var gameId = filter2.docs.first.id;
    var gameResultsDocRef = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('gameResults')
        .doc(gameId); // Замените "gameResultsDocId" на фактическое ID документа

    // Обновляем имя лидера в нужной части документа
    await gameResultsDocRef.update({
      '$roundCount': {
        'leaderName': nameUser,
        'membersCount': membersCount,
        'result': result
        // ... другие поля, если нужно
      }
    });
  }
}
