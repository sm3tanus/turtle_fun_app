import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  List<Map<String, dynamic>> usersPlay = [];

  Future<void> fetchUsersPlay(String roomName) async {
    try {
      var roomSnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .where('name', isEqualTo: roomName)
          .limit(1)
          .get();

      if (roomSnapshot.docs.isNotEmpty) {
        var roomId = roomSnapshot.docs.first.id;
        var usersPlaySnapshot = await FirebaseFirestore.instance
            .collection('rooms/$roomId/users')
            .get();

        usersPlay = usersPlaySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      // Обработка ошибок при работе с базой данных, например, вывод ошибки
      print('Ошибка при получении данных: $e');
    }
  }
}
