import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  Future<void> createRoom(String leader, String name) async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc()
        .set({'leader': leader, 'name': name});

    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: name)
        .get();

    var docId = filter.docs.first.id;

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(docId)
        .collection('users')
        .doc()
        .set({'name': leader, 'game': 1, 'role': 0, 'robbery': false});

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(docId)
        .collection('gameResults')
        .doc()
        .set({
      '1': {'result': false, 'membersCount': 3, 'leaderName': ''},
      '2': {'result': false, 'membersCount': 2, 'leaderName': ''},
      '3': {'result': false, 'membersCount': 3, 'leaderName': ''},
      '4': {'result': false, 'membersCount': 2, 'leaderName': ''},
      '5': {'result': false, 'membersCount': 3, 'leaderName': ''},
      'id': 0
    });
  }

  Future<void> addUsersToRoom(String name, String nameUser) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: name)
        .get();

    var docId = filter.docs.first.id;

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(docId)
        .collection('users')
        .doc()
        .set({'name': nameUser, 'role': 0, 'robbery': false});
  }

  Future<void> addUsersToPlayRoom(String name, String nameUser) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: name)
        .get();

    var docId = filter.docs.first.id;

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(docId)
        .collection('usersPlay')
        .doc()
        .set({'name': nameUser, 'navigate': false, 'ready': false});
  }

  checkInRoom(String name) async {
    var rooms = await FirebaseFirestore.instance.collection('rooms').get();
    bool inRoom = rooms.docs.any((doc) => doc['name'] == name);
    if (inRoom) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> deleteRoom(String name) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: name)
        .get();

    for (var doc in querySnapshot.docs) {
      await deleteDocumentAndSubcollections(doc.reference);
    }
  }

  Future<void> deleteDocumentAndSubcollections(DocumentReference docRef) async {
    var usersPlayCollections = await docRef.collection('usersPlay').get();
    for (var subDoc in usersPlayCollections.docs) {
      await deleteDocumentAndSubcollections(subDoc.reference);
    }
    var usersCollections = await docRef.collection('users').get();
    for (var subDoc in usersCollections.docs) {
      await deleteDocumentAndSubcollections(subDoc.reference);
    }
    var answersCollections = await docRef.collection('answers').get();
    for (var subDoc in answersCollections.docs) {
      await deleteDocumentAndSubcollections(subDoc.reference);
    }
    await docRef.delete();
  }

  Future<void> deleteUserInRoom(String nameRoom, String nameUser) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();
    var docId = querySnapshot.docs.first.id;

    var user = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(docId)
        .collection('users')
        .where('name', isEqualTo: nameUser)
        .get();
    var userPlay = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(docId)
        .collection('usersPlay')
        .where('name', isEqualTo: nameUser)
        .get();
    for (var doc in userPlay.docs) {
      await doc.reference.delete();
    }
    for (var doc in user.docs) {
      await doc.reference.delete();
    }
  }

  navigate(String nameRoom) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();

    var docId = filter.docs.first.id;
    var snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(docId)
        .collection('usersPlay')
        .get();

    for (var doc in snapshot.docs) {
      if (doc.data()['navigate'] != true) {
        return false;
      }
    }
    return true;
  }

  Future<void> setUserNavigateTrue(String nameRoom, String nameUser) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();

    var roomId = filter.docs.first.id;

    var usersPlay = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('usersPlay')
        .where('name', isEqualTo: nameUser)
        .get();

    var userId = usersPlay.docs.first.id;
    var userDocRef = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('usersPlay')
        .doc(userId);

    await userDocRef.update({'navigate': true});
  }

  Future<void> addNameToRoom(String nameRoom, String namePlay) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();

    var roomId = filter.docs.first.id;

    var roomDocRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);

    await roomDocRef.set({
      'namePlay': namePlay,
    }, SetOptions(merge: true));
  }

  checkLeaderInRoom(String nameRoom) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();

    var roomId = filter.docs.first.id;
    DocumentSnapshot roomDoc =
        await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();

    if (roomDoc.exists) {
      String leader = roomDoc['leader'];
      CollectionReference usersPlayRef =
          roomDoc.reference.collection('usersPlay');

      QuerySnapshot usersPlaySnapshot = await usersPlayRef
          .where('name', isEqualTo: leader)
          .where('navigate', isEqualTo: true)
          .get();

      if (usersPlaySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  checkUserPlayInRoom(String nameRoom, String nameUser) async {
    QuerySnapshot roomSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();

    DocumentReference roomRef = roomSnapshot.docs.first.reference;

    QuerySnapshot userSnapshot = await roomRef
        .collection('usersPlay')
        .where('name', isEqualTo: nameUser)
        .get();
    return userSnapshot.docs.isEmpty;
  }

  Future<int> countUser(String nameRoom) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();

    var roomId = filter.docs.first.id;
    var roomDoc = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('usersPlay')
        .get();
    return roomDoc.size;
  }

  Future<bool> inRoom(String nameRoom, String nameUser) async {
    Room room = Room();
    if (await room.checkLeaderInRoom(nameRoom)) {
      if (await room.checkUserPlayInRoom(nameRoom, nameUser)) {
        room.addUsersToPlayRoom(nameRoom, nameUser);
        room.setUserNavigateTrue(nameRoom, nameUser);
      }
      return true;
    }

    return false;
  }

  Future<int> checkRoomsNamePlay(String nameRoom) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String namePlay = data['namePlay'];
      if (namePlay.startsWith('НайдиИстину')) {
        return 1;
      } else if (namePlay.startsWith('Предатель')) {
        return 2;
      }
    }
    return 3;
  }

  checkIsLeader(String nameRoom, String nameUser) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .where('leader', isEqualTo: nameUser)
        .get();
    if (filter.size != 0) {
      return true;
    }
    return false;
  }
}
