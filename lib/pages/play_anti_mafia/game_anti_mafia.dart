import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:turtle_fun/pages/play_anti_mafia/anti_mafia_crud.dart';

class AntiMafiaGamePage extends StatefulWidget {
  String nameRoom;
  String nameUser;

  int randomIDForGameResult;
  AntiMafiaGamePage(
      {super.key,
      required this.nameRoom,
      required this.nameUser,
      required this.randomIDForGameResult});

  @override
  State<AntiMafiaGamePage> createState() => _AntiMafiaGamePageState();
}

class _AntiMafiaGamePageState extends State<AntiMafiaGamePage> {
  int firstInformantIndex = 0;
  int secondInformantIndex = 0;
  int leaderInRoundIndex = 0;
  String leaderInRound = '';
  List<int> robberyTeam = [];
  bool isRobberyStarted = false;
  bool isRobberyFinished = false;
  bool isRobberySuccess = true;
  int currentUserIndex = 0;
  Map<String, dynamic> usersGameResult = {};
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
      var roomId = roomSnapshot.docs.first.id;
      var usersPlaySnapshot = await roomDocRef.collection('users').get();

      usersPlay = usersPlaySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      if (!isUsersGameResultLoaded) {
        // Получаем список документов gameResults
        QuerySnapshot gameResultsSnapshot = await FirebaseFirestore.instance
            .collection('rooms') // Обращаемся к коллекции 'rooms'
            .doc(roomId) // Указываем ID комнаты
            .collection('gameResults') // Указываем имя подколлекции
            .where('id',
                isEqualTo: widget
                    .randomIDForGameResult) // Ограничиваем выборку одним документом
            .get();

        if (gameResultsSnapshot.docs.isNotEmpty) {
          // Извлекаем данные из первого документа
          DocumentSnapshot doc = gameResultsSnapshot.docs.first;

          // Записываем данные в usersGameResult
          usersGameResult = doc.data() as Map<String, dynamic>;

          isUsersGameResultLoaded = true; // Устанавливаем флаг после загрузки
        }
      }
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
    amf.updateLeaderInRound(widget.nameRoom, roundCount,
        widget.randomIDForGameResult, widget.nameUser, membersCount, result);
    if (leaderInRound == null &&
        usersGameResult['$roundCount']['leaderName'] == '') {
      leaderInRoundIndex = random.nextInt(usersPlay.length);

      leaderInRound = usersPlay[leaderInRoundIndex]['name'];
      usersGameResult['$roundCount']['leaderName'] = leaderInRound;
      print('лидер в раунде: $leaderInRound');
      if (roundCount == 1 || roundCount == 3 || roundCount == 5) {
        usersGameResult['$roundCount']['membersCount'] = membersCount;
        amf.updateLeaderInRound(widget.nameRoom, roundCount,
            widget.randomIDForGameResult, leaderInRound, membersCount, result);
      } else {
        usersGameResult['$roundCount']['membersCount'] = membersCount2;
        amf.updateLeaderInRound(widget.nameRoom, roundCount,
            widget.randomIDForGameResult, leaderInRound, membersCount2, result);
      }
      usersGameResult['$roundCount']['result'] = result;
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
            usersGameResult['$roundCount']['membersCount'] &&
        (roundCount == 1)) {
      robberyTeam.add(index);
    }
    if (robberyTeam.length == usersGameResult['$roundCount']['membersCount']) {
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
  //         usersGameResult['firstRound']['result'] = success;

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _fetchUsersPlay(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (isUsersPlayLoaded && isUsersGameResultLoaded) {
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
                          children: usersGameResult.keys.map((roundKey) {
                            final roundData = usersGameResult[roundKey];

                            // Проверяем, является ли roundData Map
                            if (roundData is Map<String, dynamic>) {
                              // Пример отображения результата раунда с использованием Container:
                              return Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: roundData['result'] == true
                                      ? Colors.green
                                      : roundData['result'] == false
                                          ? Colors.red
                                          : null, // Можно добавить другое значение для цвета, если 'result' не true или false
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
                            } else {
                              // Обработка случая, когда roundData не является Map
                              // Например, вы можете вывести сообщение о том, что данные некорректны
                              return Text('');
                            }
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              usersPlay[currentUserIndex]['role'] == 1
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
                                  usersGameResult['$roundCount']
                                              ['leaderName'] ==
                                          leaderInRound
                                      ? 'Лидер: ${usersGameResult['$roundCount']['leaderName']}'
                                      : '',
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
                        child: usersPlay[currentUserIndex]['robbery'] == false
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
                                        onPressed: () {
                                          _startRobbery;
                                          amf.updateRobberyOnTrue(
                                              widget.nameRoom, widget.nameUser);
                                        },
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

                                    print(usersGameResult['$roundCount']
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
