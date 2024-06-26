import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/pages/choise_game_page.dart';
import 'package:turtle_fun/pages/play_anti_mafia/anti_mafia_crud.dart';
import 'package:turtle_fun/pages/play_traitor/answers_traitor.dart';

// ignore: must_be_immutable
class RulesTraitor extends StatefulWidget {
  String nameRoom;
  String nameUser;
  RulesTraitor({super.key, required this.nameRoom, required this.nameUser});

  @override
  State<RulesTraitor> createState() => _RulesTraitorState();
}

class _RulesTraitorState extends State<RulesTraitor> {
  bool visibility = false;
  bool visibilityWelcome = false;
  String? leaderName;
  String? secondInformant;
  int leaderIndex = 0;
  int currentUserIndex = 0;
  List<Map<String, dynamic>> usersPlay = [];
  Map<String, dynamic> usersGameResult = {};
  bool isUsersPlayLoaded = false;
  bool isUsersGameResultLoaded = false;
  bool isRolesCorrect = false;
  bool result = false;
  bool isPlaceCorrect = false;
  AntiMafiaCrud amf = new AntiMafiaCrud();
  int placeIndex = 0;
  List<String> place = [
    'Больница',
    'Стройка',
  ];
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
    Random random = new Random();

    if (isPlaceCorrect == false) {
      placeIndex = random.nextInt(place.length);
      String placeName = place[placeIndex];
      print('$placeName');

      amf.updateGameResults(
          widget.nameRoom, widget.nameUser, result, placeName);

      isPlaceCorrect == true;
    }
    if (roomSnapshot.docs.isNotEmpty) {
      var roomDocRef = roomSnapshot.docs.first.reference;
      var roomId = roomSnapshot.docs.first.id;
      var usersPlaySnapshot = await roomDocRef.collection('users').get();

      usersPlay = usersPlaySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .collection('gameResults')
          .snapshots()
          .listen((snapshot) {
        // Проверяем, есть ли данные в коллекции gameResults
        if (snapshot.docs.isNotEmpty) {
          // Получаем данные из первого документа
          DocumentSnapshot doc = snapshot.docs.first;

          // Обновляем usersGameResult
          setState(() {
            usersGameResult = doc.data() as Map<String, dynamic>;
            isUsersGameResultLoaded = true;
          });
        }
      });
    }

    // Устанавливаем флаг после загрузки

    setState(() {});
    _assignRoles();
    isUsersPlayLoaded = true;
  }

  void _assignRoles() {
    if (usersPlay.every((user) => user['robbery'] == false)) {
      if (usersPlay.isNotEmpty && isRolesCorrect == false) {
        if (usersPlay.any((user) => user['robbery'] != false)) {
          return print('роли уже выбраны');
        } else {
          final random = Random();

          // Присваиваем 'robbery' случайным пользователям (меньше половины)
          int robberyCount = (usersPlay.length / 2).floor(); // Округляем вниз
          for (int i = 0; i < robberyCount; i++) {
            int randomIndex = random.nextInt(usersPlay.length);
            if (usersPlay[randomIndex]['robbery'] == false) {
              // Проверяем, уже ли присвоено
              usersPlay[randomIndex]['robbery'] = true;
              String randomIndexName = usersPlay[randomIndex]['name'];
              amf.updateRobberyOnTrue(widget.nameRoom, randomIndexName);
            } else {
              i--; // Если уже присвоено, пропустить итерацию
            }
          } // Присваиваем роли всем пользователям
          for (int i = 0; i < usersPlay.length; i++) {
            int randomIndex2 = random.nextInt(10);
            usersPlay[i]['role'] = randomIndex2;
            // Используем имя пользователя из цикла
            amf.updateRole(widget.nameRoom, usersPlay[i]['name'], randomIndex2);
          }

          // Проверка на корректность ролей
          if (usersPlay.every((user) => user['roles'] != 0) ||
              usersPlay.any((user) => user['roles'] == 1) &&
                  usersPlay.any((user) => user['roles'] != 0)) {
            isRolesCorrect = true;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isUsersPlayLoaded && !isPlaceCorrect && !isRolesCorrect) {
      return Center(child: CircularProgressIndicator());
    } else {
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
                          height: MediaQuery.of(context).size.height * 0.15,
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
                          'В начале игры игрокам раздается роль "Предатель" или "Мирный".',
                          style: TextStyle(fontSize: 20, color: Colors.white),
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
                          'Цель предателя не выдать себя и вводить в заблуждение мирных игроков, наталкивая их на неправильный ответ.',
                          style: TextStyle(fontSize: 20, color: Colors.white),
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
                          'За каждый неправильный ответ команды, предателю начисляется балл или наоборот.',
                          style: TextStyle(fontSize: 20, color: Colors.white),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TraitorGamePage(
                                  nameRoom: widget.nameRoom,
                                  nameUser: widget.nameUser,
                                  usersGameResult: usersGameResult,
                                  usersPlay: usersPlay),
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
              ],
            ),
          ),
        ),
      );
    }
  }
}
