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
        .set({'name': leader, 'game': 1});

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(docId)
        .collection('usersPlay')
        .doc()
        .set({'name': leader, 'navigate': false, 'ready': false});
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
        .set({
      'name': nameUser,
    });
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
      await FirebaseFirestore.instance.collection('rooms').doc(doc.id).delete();
    }
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

  Future fetchRooms(String nameRoom) async {
    var snapshot = await FirebaseFirestore.instance.collection('rooms').get();

    var rooms = snapshot.docs;
    var filter = rooms.where((doc) => doc['name'] == nameRoom).toList();
    return filter;
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

  nameGame(String nameRoom) async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();
    for (var doc in filter.docs) {
      var data = doc.data();
      if (data.containsKey('namePlay')) {
        return data['namePlay'];
      }
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
}
