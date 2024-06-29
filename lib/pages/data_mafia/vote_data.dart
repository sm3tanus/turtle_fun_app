class Player {
  final String name;

  Player(this.name);
}

class Room {
  final List<Player> players;

  Room(this.players);
}

class DatabaseService {
  List<Player> playersList = [];

  Future<void> getPlayersInRoom(String roomPath) async {
    // final snapshot = await FirebaseFirestore.instance.collection(roomPath).get();
    // playersList.clear();
    // snapshot.docs.forEach((doc) {
    //   playersList.add(Player(doc.data()['name']));
    // });
  }
}
