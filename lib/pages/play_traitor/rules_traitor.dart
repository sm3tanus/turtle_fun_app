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
    'Супермаркет',
    'Автосалон',
    'Военная база',
    'Школа',
    'Университет',
    'Корабль',
    'Военкомат',
    'Пожарная часть',
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
            .where('name',
                isNotEqualTo: '') // Ограничиваем выборку одним документом
            .get();

        if (gameResultsSnapshot.docs.isNotEmpty) {
          // Извлекаем данные из первого документа
          DocumentSnapshot doc = gameResultsSnapshot.docs.first;

          // Записываем данные в usersGameResult
          usersGameResult = doc.data() as Map<String, dynamic>;

          isUsersGameResultLoaded = true; // Устанавливаем флаг после загрузки
        }
      }

      // Устанавливаем флаг после загрузки
    }
    setState(() {});
    _findCurrentUserIndex();
    Random random = new Random();

    if (usersGameResult['place'] == '' && isPlaceCorrect == false) {
      placeIndex = random.nextInt(place.length);
      String placeName = place[placeIndex];
      print('$placeName');
      do {
        amf.updateGameResults(
            widget.nameRoom, widget.nameUser, result, placeName);
      } while (usersGameResult['place'] != '');

      isPlaceCorrect == true;
    }

    _assignRoles();
    isUsersPlayLoaded = true;
  }

  void _findCurrentUserIndex() {
    currentUserIndex =
        usersPlay.indexWhere((user) => user['name'] == widget.nameUser);
  }

  void _assignRoles() {
    if (isUsersPlayLoaded && usersPlay.isNotEmpty && isRolesCorrect == false) {
      if (usersPlay.every((user) => user['role'] == 0)) {
        if (usersPlay.any((user) => user['role'] != 0)) {
          return print('роли уже выбраны');
        } else {
          final random = Random();

          for (int i = 0; i < 1; i++) {
            // в рандоме надо usersPlay.length поменять на длину листа профессий.
            // также надо изначально сделать выборку места
            // которая будет запоминаться и отображаться у всех одинаково.
            final randomIndex = random.nextInt(usersPlay.length);
            if (usersPlay[currentUserIndex]['role'] == 0) {
              usersPlay[currentUserIndex]['role'] = randomIndex;
              amf.updateRole(
                  widget.nameRoom, usersPlay[randomIndex]['name'], randomIndex);
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
    if (!isUsersPlayLoaded && !isPlaceCorrect) {
      return CircularProgressIndicator.adaptive();
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
                        onPressed: () async {
                          Room room = Room();
                          room.addUsersToPlayRoom(
                              widget.nameRoom, widget.nameUser);
                          room.setUserNavigateTrue(
                              widget.nameRoom, widget.nameUser);
                          if (await room.checkLeaderInRoom(widget.nameRoom)) {
                            if (await room.navigate(widget.nameRoom) &&
                                widget.nameRoom.isNotEmpty &&
                                widget.nameUser.isNotEmpty) {
                              room.addNameToRoom(widget.nameRoom, "Предатель");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TraitorGamePage(
                                    nameRoom: widget.nameRoom,
                                    nameUser: widget.nameUser,
                                  ),
                                ),
                              );
                            }
                          } else {
                            setState(() {
                              visibility = true;
                            });
                          }
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
                  visible: visibility,
                  child: const Text(
                    'Дождитесь лидера комнаты!',
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
