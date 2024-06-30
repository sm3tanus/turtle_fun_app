import 'package:cloud_firestore/cloud_firestore.dart';

class AntiMafiaCrud {
  Future<void> updateRole(String nameRoom, String nameUser, int role) async {
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

    await userDocRef.update({'role': role});
  }

  Future<void> updateRobberyOnTrue(
      String nameRoom, String nameUser, int role) async {
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

    await userDocRef.update({'robbery': true, 'role': role});
  }

  Future<void> updateRobberyOnFalse(String nameRoom, String nameUser) async {
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

    await userDocRef.update({'robbery': false});
  }

  Future<void> updateIDinGameResults(String nameRoom, int id) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();

    var roomId = filter.docs.first.id;
    var filter2 = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('gameResults')
        .where('id', isNotEqualTo: 10000)
        .get();
    var gameId = filter2.docs.first.id;
    var filter3 = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('gameResults')
        .doc(gameId)
        .update({'id': id});
  }

  Future<void> updateGameResults(
      String nameRoom, String nameUser, bool result, String place) async {
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
        .where('name', isEqualTo: nameRoom)
        .get();
    var gameId = filter2.docs.first.id;
    var gameResultsDocRef = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('gameResults')
        .doc(gameId); // Замените "gameResultsDocId" на фактическое ID документа

    // Обновляем имя лидера в нужной части документа
    await gameResultsDocRef.set({
      'name': nameRoom,
      'leaderName': nameUser,
      'result': result,
      'place': place,
      'Больница': [
        'Врач',
        'Медсестра',
        'Хирург',
        'Стоматолог',
        'Санитар',
        'Физиотерапевт',
        'Администратор',
        'Охранник',
        'Диетолог',
        'Акушер-гинеколог',
        // ... другие профессии
      ],
      'Стройка': [
        'Строитель',
        'Маляр',
        'Электрик',
        'Архитектор',
        'Инженер',
        'Прораб',
        'Охранник',
        'Каменщик',
        'Бетонщик',
        'Сантехник',
        // ... другие профессии
      ]

      // ... аналогично для остальных мест
    });
  }

  Future<void> updatePlaceInGameResults(
      String nameRoom, String nameUser, bool result, String place) async {
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
        .where('name', isEqualTo: nameRoom)
        .get();
    var gameId = filter2.docs.first.id;
    var gameResultsDocRef = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('gameResults')
        .doc(gameId); // Замените "gameResultsDocId" на фактическое ID документа

    // Обновляем имя лидера в нужной части документа
    await gameResultsDocRef.update({
      'place': place,
    });
  }
}
