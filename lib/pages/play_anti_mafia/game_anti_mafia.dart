import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/pages/play_anti_mafia/anti_mafia_crud.dart';

class AntiMafiaGamePage extends StatefulWidget {
  String nameRoom;
  String nameUser;

  AntiMafiaGamePage(
      {super.key, required this.nameRoom, required this.nameUser});

  @override
  State<AntiMafiaGamePage> createState() => _AntiMafiaGamePageState();
}

final List<Map<String, dynamic>> games = [
  {'membersCount': 3},
  {'membersCount': 2},
  {'membersCount': 3},
  {'membersCount': 2},
  {'membersCount': 3},
];

class _AntiMafiaGamePageState extends State<AntiMafiaGamePage> {
  int firstInformantIndex = 0;
  int secondInformantIndex = 0;
  int leaderInRoundIndex = 0;
  String? leaderInRound;
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
  AntiMafiaCrud amf = new AntiMafiaCrud();
  int roundCount = 1;
  int randomIDForGameResult = 0;
  void roundCountPlus() {
    roundCount++;
  }

  @override
  void initState() {
    super.initState();

    _fetchUsersPlay();
  }

  void _randomIDForGameResult() {
    Random random = new Random();
    randomIDForGameResult = random.nextInt(1000);
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

      _findCurrentUserIndex();
      _findSecondInformant();
      await _createGameResults();
      _fetchGameResults();
      isUsersPlayLoaded = true; // Устанавливаем флаг после загрузки
    } else {
      print('иди нахуй');
    }
  }

  Future<void> _createGameResults() async {
    _randomIDForGameResult();
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
        '1': {'result': false, 'membersCount': 3, 'leaderName': ''},
        '2': {'result': false, 'membersCount': 2, 'leaderName': ''},
        '3': {'result': false, 'membersCount': 3, 'leaderName': ''},
        '4': {'result': false, 'membersCount': 2, 'leaderName': ''},
        '5': {'result': false, 'membersCount': 3, 'leaderName': ''},
        'id': randomIDForGameResult
      });
    }
  }

  Future<void> _fetchGameResults() async {
    if (gameResultsDocRef != null) {
      var gameResultsSnapshot = await gameResultsDocRef!.get();

      if (gameResultsSnapshot.exists) {
        // Извлекаем данные как Map<String, dynamic>
        Map<String, dynamic> gameResultsData = gameResultsSnapshot.data()!
            as Map<String, dynamic>; // Преобразуем Object в Map

        // Создаем новый Map для хранения результатов игры
        usersGameResult = {};

        // Перебираем данные по раундам
        gameResultsData.forEach((roundKey, roundData) {
          // Извлекаем данные для текущего раунда
          if (roundData is Map<String, dynamic>) {
            usersGameResult[roundKey] = roundData;
          }
        });

        isUsersGameResultLoaded = true; // Устанавливаем флаг после загрузки
      }
    }
    _chooseLeader();
    setState(() {});
  }

  void _chooseLeader() {
    final random = Random();
    leaderInRoundIndex = random.nextInt(usersPlay.length);
    amf.updateLeaderInRound(widget.nameRoom, roundCount, randomIDForGameResult,
        usersPlay[leaderInRoundIndex]['name']);
    leaderInRound = usersPlay[leaderInRoundIndex]['name'];
    usersGameResult['$roundCount']['leaderName'] = leaderInRound;
  }

  void _addToRobberyTeam(int index) {
    if (robberyTeam.contains(index)) {
      robberyTeam.remove(index);
    } else if (robberyTeam.length <
            usersGameResult['$roundCount']['membersCount'] &&
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

  // void _onRobberyResult(bool success) {
  //   if (!isRobberyFinished) {
  //     if (usersPlay.every((user) =>
  //         (roles[usersPlay.indexOf(user)] == 'Осведомитель' && !success) ||
  //         (roles[usersPlay.indexOf(user)] != 'Осведомитель' && success))) {
  //       setState(() {
  //         isRobberyFinished = true;
  //         usersGameResult['firstRound']['result'] = success;
  //         _updateGameResults();
  //         if (roundCount < usersGameResult.length) {
  //           roundCount++;
  //           isRobberyStarted = false;
  //           robberyTeam.clear();
  //           isRobberyFinished = false;
  //           isRobberySuccess = true;
  //           _chooseLeader();
  //         }
  //       });
  //     }
  //   }
  // }

  void _updateGameResults() async {
    if (gameResultsDocRef != null) {
      await gameResultsDocRef!.update(usersGameResult);
    }
  }

  void _findCurrentUserIndex() {
    currentUserIndex =
        usersPlay.indexWhere((user) => user['name'] == widget.nameUser);
  }

  void _findSecondInformant() {
    if (usersPlay.isNotEmpty) {
      // Находим первого осведомителя
      int firstInformantIndex =
          usersPlay.indexWhere((user) => user['role'] == 1);

      // Если первый осведомитель найден
      if (firstInformantIndex != -1) {
        // Находим второго осведомителя, не равного текущему пользователю
        int secondInformantIndex;
        do {
          secondInformantIndex = Random().nextInt(usersPlay.length);
        } while (secondInformantIndex == firstInformantIndex ||
            usersPlay[secondInformantIndex]['name'] ==
                widget
                    .nameUser); // Изменил условие для проверки имени пользователя

        // Если второй осведомитель найден
        if (secondInformantIndex != -1) {
          // Делаем что-то с информацией о втором осведомителе
          print(
              "Второй осведомитель: ${usersPlay[secondInformantIndex]['name']}");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchUsersPlay(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Scaffold(
              backgroundColor: Color.fromRGBO(30, 85, 65, 1),
              body: SafeArea(
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        'ОГРАБЛЕНИЕ   $roundCount / 5',
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
                                        '${usersGameResult['$roundCount']['membersCount']}',
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
                            usersPlay[currentUserIndex]['role'] == '1'
                                ? 'Твоя роль (${usersPlay[currentUserIndex]['name']}) - Осведомитель\nНапарник - ${usersPlay[secondInformantIndex]['name']}'
                                : 'Твоя роль - (${usersPlay[currentUserIndex]['name']})Грабитель',
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
                                'Лидер: ${usersPlay[leaderInRoundIndex]['name']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text('Команда для ограбления:'),
                              SizedBox(height: 5),
                              Column(
                                children: robberyTeam
                                    .map((index) =>
                                        Text(usersPlay[index]['name']))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: currentUserIndex == leaderInRoundIndex
                          // Если игрок лидер, то показываем всех игроков
                          ? Column(
                              children: [
                                // Кнопка "Начать ограбление"
                                if (!isRobberyStarted &&
                                    robberyTeam.length ==
                                        usersGameResult['$roundCount']
                                            ['membersCount'])
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
                                            '${usersPlay[index]['role']}',
                                            style:
                                                TextStyle(color: Colors.white),
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
                    if (isRobberyStarted)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Кнопка "Успех" для осведомителей и грабителей
                            if (usersPlay[currentUserIndex]['role'] == 1 ||
                                robberyTeam.contains(currentUserIndex))
                              ElevatedButton(
                                onPressed: () {
                                  print(
                                      usersGameResult['$roundCount']['result']);
                                },
                                child: const Text('Успех'),
                              ),
                            // Кнопка "Провал" для осведомителей
                            if (usersPlay[currentUserIndex]['role'] == 1)
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Провал'),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              )); // Ваш виджет
        }
      },
    );
  }
}
