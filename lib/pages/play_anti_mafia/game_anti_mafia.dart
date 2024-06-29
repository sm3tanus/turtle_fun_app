import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:turtle_fun/pages/play_anti_mafia/anti_mafia_crud.dart';

class AntiMafiaGamePage extends StatefulWidget {
  String nameRoom;
  String nameUser;
  Map<String, dynamic> usersGameResult;
  int randomIDForGameResult;
  AntiMafiaGamePage(
      {super.key,
      required this.nameRoom,
      required this.nameUser,
      required this.usersGameResult,
      required this.randomIDForGameResult});

  @override
  State<AntiMafiaGamePage> createState() => _AntiMafiaGamePageState();
}

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
  bool isUsersPlayLoaded = false;
  bool isUsersGameResultLoaded = false;
  DocumentReference? gameResultsDocRef;
  AntiMafiaCrud amf = new AntiMafiaCrud();
  int roundCount = 1;
  int membersCount = 3;
  int membersCount2 = 2;
  bool result = true;
  @override
  void initState() {
    super.initState();
    _fetchUsersPlay();
  }

  void roundCountPlus() {
    roundCount++;
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
      _chooseLeader();
      isUsersPlayLoaded = true; // Устанавливаем флаг после загрузки
    } else {
      print('иди нахуй');
    }
  }

  //кароч тк у нас лидер пустой в первом раунде этот метод в каждом раунде будет срабатывать ток однажды.
  // мы будем делать его нулом только после завершения раунда
  void _chooseLeader() {
    final random = Random();
    if (leaderInRound == null) {
      leaderInRoundIndex = random.nextInt(usersPlay.length);

      leaderInRound = usersPlay[leaderInRoundIndex]['name'];
      widget.usersGameResult['$roundCount']['leaderName'] = leaderInRound;
      if (roundCount == 1 || roundCount == 3 || roundCount == 5) {
        widget.usersGameResult['$roundCount']['membersCount'] = membersCount;
        amf.updateLeaderInRound(
            widget.nameRoom,
            roundCount,
            widget.randomIDForGameResult,
            widget.nameUser,
            membersCount,
            result);
      } else {
        widget.usersGameResult['$roundCount']['membersCount'] = membersCount2;
        amf.updateLeaderInRound(
            widget.nameRoom,
            roundCount,
            widget.randomIDForGameResult,
            widget.nameUser,
            membersCount,
            result);
      }
      widget.usersGameResult['$roundCount']['result'] = result;
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

  void _addToRobberyTeam(int index) {
    if (robberyTeam.contains(index)) {
      robberyTeam.remove(index);
    } else if (robberyTeam.length <
            widget.usersGameResult['$roundCount']['membersCount'] &&
        (roundCount == 1)) {
      robberyTeam.add(index);
    }
    if (robberyTeam.length ==
        widget.usersGameResult['$roundCount']['membersCount']) {
      setState(() {});
    }
  }

  void _startRobbery() {
    setState(() {
      isRobberyStarted = true;
    });
  }

  // void _onRobberyResult(bool success) {
  //   if (!isRobberyFinished) {
  //     if (usersPlay.every((user) =>
  //         (usersPlay.every['role'] == 'Осведомитель' && !success) ||
  //         (usersPlay[usersPlay.indexOf(user)] != 'Осведомитель' && success))) {
  //       setState(() {
  //         isRobberyFinished = true;
  //         widget.usersGameResult['firstRound']['result'] = success;

  //         if (roundCount < widget.usersGameResult.length) {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _fetchUsersPlay(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки данных'));
          } else if (isUsersPlayLoaded) {
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
                          children: widget.usersGameResult.entries.map((entry) {
                            final roundKey = entry.key;
                            final roundData =
                                entry.value as Map<String, dynamic>;

                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: roundData['result'] == true
                                    ? Colors.green
                                    : roundData['result'] == false
                                        ? Colors.red
                                        : null,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    '${roundData['membersCount']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
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
                                          widget.usersGameResult['$roundCount']
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
                                            title:
                                                Text(usersPlay[index]['name']),
                                            trailing: Text(
                                              '${usersPlay[index]['role']}',
                                              style: TextStyle(
                                                  color: Colors.white),
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
                                    result = true;
                                    roundCountPlus();
                                    print(widget.usersGameResult['$roundCount']
                                        ['result']);
                                    setState(() {});
                                  },
                                  child: const Text('Успех'),
                                ),
                              // Кнопка "Провал" для осведомителей
                              if (usersPlay[currentUserIndex]['role'] == 1)
                                ElevatedButton(
                                  onPressed: () {
                                    result = false;
                                    roundCountPlus();
                                    setState(() {});
                                  },
                                  child: const Text('Провал'),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                )); // Ваш виджет
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
