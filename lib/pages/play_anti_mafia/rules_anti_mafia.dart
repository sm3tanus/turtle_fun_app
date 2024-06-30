import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/pages/choise_game_page.dart';
import 'package:turtle_fun/pages/play_anti_mafia/anti_mafia_crud.dart';
import 'package:turtle_fun/pages/play_anti_mafia/game_anti_mafia.dart';
import 'package:turtle_fun/play_find_true/interface_answers.dart';

// ignore: must_be_immutable
class RulesAntiMafia extends StatefulWidget {
  String nameRoom;
  String nameUser;

  RulesAntiMafia({
    super.key,
    required this.nameRoom,
    required this.nameUser,
  });

  @override
  State<RulesAntiMafia> createState() => _RulesAntiMafiaState();
}

class _RulesAntiMafiaState extends State<RulesAntiMafia> {
  bool visibility = false;
  bool visibilityWelcome = false;
  String? leaderName;
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
  bool isRolesCorrect = false;
  DocumentReference? gameResultsDocRef;
  int? liderInRound;
  int randomIDForGameResult = 0;
  AntiMafiaCrud amf = new AntiMafiaCrud();
  @override
  void initState() {
    super.initState();
    _randomIDForGameResult();
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
      var roomId = roomSnapshot.docs.first.id;
      var roomDoc = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .get();
      leaderName = roomDoc['leader'];
      print(leaderName);
      // Устанавливаем флаг после загрузки
    }
    setState(() {});

    _assignRoles();
    isUsersPlayLoaded = true;
  }

  void _assignRoles() {
    if (isUsersPlayLoaded && usersPlay.isNotEmpty && isRolesCorrect == false) {
      if (usersPlay.every((user) => user['role'] == 0)) {
        if (usersPlay.any((user) => user['role'] == 1)) {
          return print('осведомители уже выбраны');
        } else {
          roles = List.generate(usersPlay.length, (index) => 'Грабитель');

          final random = Random();

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

              if (roles[randomIndex] == 'Осведомитель') {
                amf.updateRole(widget.nameRoom, usersPlay[randomIndex]['name'],
                    randomIndex);
              }
              if (roles[randomIndex2] == 'Осведомитель') {
                amf.updateRole(widget.nameRoom, usersPlay[randomIndex2]['name'],
                    randomIndex2);
              }
            } else {
              i--;
            }
          }
          isRolesCorrect = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _fetchUsersPlay(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки данных'));
          } else if (isUsersPlayLoaded == true) {
            return Scaffold(
              body: SafeArea(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.23,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(500),
                                bottomRight: Radius.circular(500),
                              ),
                              color: Color(0xffA1C096),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                              ),
                              const Text(
                                'ПРАВИЛА',
                                style: TextStyle(
                                    color: Color(0xff1E5541),
                                    fontSize: 54,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: const Row(
                          children: [
                            Text(
                              '1. ',
                              style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffA1C096)),
                            ),
                            Flexible(
                              child: Text(
                                'Грабители должны провести 5 ограблений, выбрав участников после обсуждения.',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: const Row(
                          children: [
                            Text(
                              '2. ',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffA1C096),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Полицейские осведомители должны мешать ограблениям и не выдать себя раньше времени.',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: const Row(
                          children: [
                            Text(
                              '3. ',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffA1C096),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Участники голосуют после всех ограблений, пытаясь вычислить осведомителей.',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.height * 0.07,
                            child: ElevatedButton(
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Color(0xffA1C096),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChoiseGame(
                                      nameRoom: widget.nameRoom,
                                      nameUser: widget.nameUser,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'НАЗАД',
                                style: TextStyle(
                                  color: Color(0xff1E5541),
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.height * 0.07,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AntiMafiaGamePage(
                                        nameRoom: widget.nameRoom,
                                        nameUser: widget.nameUser,
                                        randomIDForGameResult:
                                            randomIDForGameResult),
                                  ),
                                );
                              },
                              child: const Text(
                                'ИГРАТЬ',
                                style: TextStyle(
                                  color: Color(0xff1E5541),
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Visibility(
                        visible: visibilityWelcome,
                        child: const Text(
                          'Добро пожаловать!\nНажмите играть еще раз.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Visibility(
                        visible: visibility,
                        child: const Text(
                          textAlign: TextAlign.center,
                          'Дождитесь лидера комнаты!',
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
