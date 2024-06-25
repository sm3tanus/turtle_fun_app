import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class AntiMafiaGamePage extends StatefulWidget {
  String nameRoom;
  String nameUser;

  AntiMafiaGamePage(
      {super.key, required this.nameRoom, required this.nameUser});

  @override
  State<AntiMafiaGamePage> createState() => _AntiMafiaGamePageState();
}

int gameCount = 1;
void gameCountPlus() {
  gameCount++;
}

final List<Map<String, dynamic>> games = [
  {'membersCount': 3, 'result': null},
  {'membersCount': 2, 'result': null},
  {'membersCount': 3, 'result': null},
  {'membersCount': 2, 'result': null},
  {'membersCount': 3, 'result': null},
];

class _AntiMafiaGamePageState extends State<AntiMafiaGamePage> {
  List<String> roles = [];
  String? secondInformant;
  int firstInformantIndex = 0;
  int secondInformantIndex = 0;
  int leaderIndex = 0;
  List<int> robberyTeam = [];
  bool isRobberyStarted = false;
  bool isRobberyFinished = false;
  bool isRobberySuccess = true;
  int currentUserIndex = 0;
  List<Map<String, dynamic>> usersPlay = [];
  bool isUsersPlayLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchUsersPlay();
  }

  Future<void> _fetchUsersPlay() async {
    var roomSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: widget.nameRoom)
        .get();

    if (roomSnapshot.docs.isNotEmpty) {
      var roomDocRef = roomSnapshot.docs.first.reference;

      var usersPlaySnapshot = await roomDocRef.collection('usersPlay').get();

      usersPlay = usersPlaySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      isUsersPlayLoaded = true; // Устанавливаем флаг после загрузки
      _assignRoles();
      _findCurrentUserIndex();
    }
    setState(() {});
  }

  void _assignRoles() {
    if (isUsersPlayLoaded && usersPlay.isNotEmpty) {
      roles = List.generate(usersPlay.length, (index) => 'Грабитель');

      final random = Random();

      // Выбираем двух осведомителей (только при первом запуске)
      for (int i = 0; i < 1; i++) {
        final randomIndex = random.nextInt(usersPlay.length);
        final randomIndex2 = random.nextInt(usersPlay.length);
        if (roles[randomIndex] != 'Осведомитель' &&
            roles[randomIndex2] != 'Осведомитель' &&
            randomIndex2 != randomIndex &&
            usersPlay[randomIndex2]['name'] != widget.nameUser) {
          roles[randomIndex] = 'Осведомитель';
          firstInformantIndex = randomIndex;
          roles[randomIndex2] = 'Осведомитель';
          secondInformantIndex = randomIndex2;

          secondInformant = usersPlay[randomIndex2]['name'];
        } else {
          i--;
        }
      }

      _chooseLeader();
    }
  }

  void _chooseLeader() {
    final random = Random();
    leaderIndex = random.nextInt(usersPlay.length);
  }

  void _addToRobberyTeam(int index) {
    if (robberyTeam.contains(index)) {
      robberyTeam.remove(index);
    } else if (robberyTeam.length < games[gameCount - 1]['membersCount'] &&
        (gameCount == 1)) {
      robberyTeam.add(index);
    }

    setState(() {});
  }

  void _startRobbery() {
    setState(() {
      isRobberyStarted = true;
    });
  }

  void _onRobberyResult(bool success) {
    if (!isRobberyFinished) {
      if (usersPlay.every((user) =>
          (roles[usersPlay.indexOf(user)] == 'Осведомитель' && !success) ||
          (roles[usersPlay.indexOf(user)] != 'Осведомитель' && success))) {
        setState(() {
          isRobberyFinished = true;
          games[gameCount - 1]['result'] = success;
          if (gameCount < games.length) {
            gameCountPlus();
            isRobberyStarted = false;
            robberyTeam.clear();
            isRobberyFinished = false;
            isRobberySuccess = true;
            _chooseLeader();
          }
        });
      }
    }
  }

  void _findCurrentUserIndex() {
    currentUserIndex =
        usersPlay.indexWhere((user) => user['name'] == widget.nameUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(30, 85, 65, 1),
      body: SafeArea(
          child: Column(
        children: [
          Center(
            child: Text(
              textAlign: TextAlign.center,
              'ОГРАБЛЕНИЕ   ${gameCount} / 5',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: games
                  .map((game) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: game['result'] == true
                              ? Colors.green
                              : game['result'] == false
                                  ? Colors.red
                                  : null,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              '${game['membersCount']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  roles[currentUserIndex] == 'Осведомитель'
                      ? 'Твоя роль (${usersPlay[currentUserIndex]['name']}) - Осведомитель\nНапарник - $secondInformant'
                      : 'Твоя роль - ${roles[currentUserIndex]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Лидер: ${usersPlay[leaderIndex]['name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text('Команда для ограбления:'),
                    const SizedBox(height: 5),
                    Column(
                      children: robberyTeam
                          .map((index) => Text(usersPlay[index]['name']))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: currentUserIndex == leaderIndex
                ? Column(
                    children: [
                      if (!isRobberyStarted &&
                          robberyTeam.length ==
                              games[gameCount - 1]['membersCount'])
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: _startRobbery,
                            child: const Text('Начать ограбление'),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: usersPlay.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => _addToRobberyTeam(index),
                              child: ListTile(
                                title: Text(usersPlay[index]['name']),
                                trailing: Text(
                                  roles[index],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      'Ожидайте выбора лидера',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
          if (isRobberyStarted)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (roles[currentUserIndex] == 'Осведомитель' ||
                      robberyTeam.contains(currentUserIndex))
                    ElevatedButton(
                      onPressed: () => _onRobberyResult(true),
                      child: const Text('Успех'),
                    ),
                  if (roles[currentUserIndex] == 'Осведомитель')
                    ElevatedButton(
                      onPressed: () => _onRobberyResult(false),
                      child: const Text('Провал'),
                    ),
                ],
              ),
            ),
        ],
      )),
    );
  }
}
