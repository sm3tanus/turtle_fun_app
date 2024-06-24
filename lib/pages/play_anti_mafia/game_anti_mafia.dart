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
  int currentUserIndex = -1;
  List<Map<String, dynamic>> usersPlay = [];

  @override
  void initState() {
    super.initState();
    _assignRoles();
  }

  Future<void> _fetchUsersPlay() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.nameRoom)
        .collection('usersPlay')
        .get();
    usersPlay = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    setState(() {});
  }

  void _assignRoles() {
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
    // Выбираем лидера (только при первом запуске)
    _chooseLeader();
  }

  void _chooseLeader() {
    final random = Random();
    leaderIndex = random.nextInt(usersPlay.length);
  }

  void _addToRobberyTeam(int index) {
    if (robberyTeam.contains(index)) {
      // Если игрок уже в команде, удаляем его
      robberyTeam.remove(index);
    } else if (robberyTeam.length < games[gameCount - 1]['membersCount'] &&
        (gameCount == 1)) {
      // Если игрок не в команде, добавляем его
      robberyTeam.add(index);
    }
    // Вызываем setState только после изменения gameCount
    setState(() {});
  }

  void _startRobbery() {
    setState(() {
      isRobberyStarted = true;
    });
  }

  void _onRobberyResult(bool success) {
    if (!isRobberyFinished) {
      // Проверяем, все ли игроки проголосовали
      if (usersPlay.every((user) =>
          (roles[usersPlay.indexOf(user)] == 'Осведомитель' &&
              !success) || // Осведомитель проваливает ограбление
          (roles[usersPlay.indexOf(user)] != 'Осведомитель' && success))) {
        // Грабитель голосует за успех
        // Ограбление завершено
        setState(() {
          isRobberyFinished = true;
          games[gameCount - 1]['result'] =
              success; // Сохраняем результат ограбления
          if (gameCount < games.length) {
            gameCountPlus();
            isRobberyStarted = false;
            robberyTeam.clear();
            isRobberyFinished = false;
            isRobberySuccess =
                true; // Сбрасываем флаг результата для следующего раунда
            _chooseLeader(); // Выбираем нового лидера перед началом следующего раунда
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
      backgroundColor: Color.fromRGBO(30, 85, 65, 1),
      body: SafeArea(
          child: Column(
        children: [
          Center(
            child: Text(
              textAlign: TextAlign.center,
              'ОГРАБЛЕНИЕ   ${gameCount} / 5',
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
          // Информация о лидере и команде
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
          // Список игроков
          Expanded(
            child: currentUserIndex == leaderIndex
                // Если игрок лидер, то показываем всех игроков
                ? Column(
                    children: [
                      // Кнопка "Начать ограбление"
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
          if (isRobberyStarted)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Кнопка "Успех" для осведомителей и грабителей
                  if (roles[currentUserIndex] == 'Осведомитель' ||
                      robberyTeam.contains(currentUserIndex))
                    ElevatedButton(
                      onPressed: () => _onRobberyResult(true),
                      child: const Text('Успех'),
                    ),
                  // Кнопка "Провал" для осведомителей
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
