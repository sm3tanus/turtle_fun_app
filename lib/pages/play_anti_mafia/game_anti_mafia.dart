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

int roundCount = 1;
void roundCountPlus() {
  roundCount++;
}

final List<Map<String, dynamic>> games = [
  {'membersCount': 3},
  {'membersCount': 2},
  {'membersCount': 3},
  {'membersCount': 2},
  {'membersCount': 3},
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
  Map<String, dynamic> usersGameResult = {};
  bool isUsersPlayLoaded = false;
  bool isUsersGameResultLoaded = false;
  DocumentReference? gameResultsDocRef;
  @override
  void initState() {
    super.initState();
    _fetchUsersPlay();
    _createGameResults();
  }

  Future<void> _fetchUsersPlay() async {
    var roomSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: widget.nameRoom)
        .get();

    if (roomSnapshot.docs.isNotEmpty) {
      var roomDocRef = roomSnapshot.docs.first.reference;

      var usersPlaySnapshot = await roomDocRef.collection('users').get();

      usersPlay = usersPlaySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      isUsersPlayLoaded = true; // Устанавливаем флаг после загрузки
      _assignRoles();
      _findCurrentUserIndex();
      _chooseLeader();
    }
    setState(() {});
  }

  Future<void> _createGameResults() async {
    // Получаем документ комнаты
    var roomSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: widget.nameRoom)
        .get();

    if (roomSnapshot.docs.isNotEmpty) {
      var roomDocRef = roomSnapshot.docs.first.reference;

      // Создаем документ gameResults с начальными данными
      gameResultsDocRef = roomDocRef.collection('gameResults').doc();
      await gameResultsDocRef!.set({
        'firstRound': {'result': false, 'membersCount': 3},
        'secondRound': {'result': false, 'membersCount': 2},
        'thirdRound': {'result': false, 'membersCount': 3},
        'fourthRound': {'result': false, 'membersCount': 2},
        'fifthRound': {'result': false, 'membersCount': 3},
      });
      _fetchGameResults();
    }
  }

  Future<void> _fetchGameResults() async {
    if (gameResultsDocRef != null) {
      var gameResultsSnapshot = await gameResultsDocRef!.get();

      if (gameResultsSnapshot.exists) {
        usersGameResult = gameResultsSnapshot.data() as Map<String, dynamic>;
        isUsersGameResultLoaded = true; // Устанавливаем флаг после загрузки
      }
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
    }
  }

  void _chooseLeader() {
    final random = Random();
    leaderIndex = random.nextInt(usersPlay.length);
  }

  void _addToRobberyTeam(int index) {
    if (robberyTeam.contains(index)) {
      robberyTeam.remove(index);
    } else if (robberyTeam.length <
            usersGameResult['firstRound']['membersCount'] &&
        (roundCount == 1)) {
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
          usersGameResult['firstRound']['result'] = success;
          _updateGameResults();
          if (roundCount < usersGameResult.length) {
            roundCount++;
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

  void _updateGameResults() async {
    if (gameResultsDocRef != null) {
      await gameResultsDocRef!.update(usersGameResult);
    }
  }

  void _findCurrentUserIndex() {
    currentUserIndex =
        usersPlay.indexWhere((user) => user['name'] == widget.nameUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(30, 85, 65, 1),
        body: SafeArea(
          child: Column(
            children: [
              Center(
                child: Text(
                  textAlign: TextAlign.center,
                  'ОГРАБЛЕНИЕ   ${roundCount} / 5',
                  style: TextStyle(fontSize: 20, color: Colors.white),
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
                              color: usersGameResult['firstRound']['result'] ==
                                      true
                                  ? Colors.green
                                  : usersGameResult['firstRound']['result'] ==
                                          false
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
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Лидер: ${usersPlay[leaderIndex]['name']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text('Команда для ограбления:'),
                        SizedBox(height: 5),
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
              SizedBox(height: 20),
              Expanded(
                child: currentUserIndex == leaderIndex
                    // Если игрок лидер, то показываем всех игроков
                    ? Column(
                        children: [
                          // Кнопка "Начать ограбление"
                          if (!isRobberyStarted &&
                              robberyTeam.length ==
                                  usersGameResult['firstRound']['membersCount'])
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: _startRobbery,
                                child: const Text('Начать ограбление'),
                              ),
                            ),
                          // Список игроков
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
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    // Если игрок не лидер, то показываем сообщение
                    : Center(
                        child: Text(
                          'Ожидайте выбора лидера',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
              // Кнопки "Успех" и "Провал" для осведомителей и грабителей

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Кнопка "Успех" для осведомителей и грабителей

                  ElevatedButton(
                    onPressed: () {
                      _onRobberyResult(true);
                      print(usersGameResult['firstRound']['result']);
                    },
                    child: const Text('Успех'),
                  ),
                  // Кнопка "Провал" для осведомителей

                  ElevatedButton(
                    onPressed: () {
                      _onRobberyResult(false);
                      print(usersGameResult['firstRound']['result']);
                    },
                    child: const Text('Провал'),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
