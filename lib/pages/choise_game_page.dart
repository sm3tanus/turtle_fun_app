import 'dart:async';

import 'package:flutter/material.dart';
import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/pages/list_rooms.dart';
import 'package:turtle_fun/pages/main_page.dart';
import 'package:turtle_fun/pages/play_anti_mafia/game_anti_mafia.dart';
import 'package:turtle_fun/pages/play_anti_mafia/rules_anti_mafia.dart';
import 'package:turtle_fun/pages/play_anti_mafia/vote_anti_mafia.dart';
import 'package:turtle_fun/pages/play_traitor/rules_traitor.dart';
import 'package:turtle_fun/play_find_true/interface_answers.dart';
import 'package:turtle_fun/play_find_true/rules_choise_true_page.dart';

// ignore: must_be_immutable
class ChoiseGame extends StatefulWidget {
  String nameRoom;
  String nameUser;
  ChoiseGame({super.key, required this.nameRoom, required this.nameUser});

  @override
  State<ChoiseGame> createState() => _ChoiseGameState();
}

class _ChoiseGameState extends State<ChoiseGame> {
  bool visibilityName = false;
  bool inRoom = false;

  @override
  void initState() {
    if (widget.nameRoom.isNotEmpty) {
      setState(() {
        visibilityName = true;
      });
    }
    if (widget.nameRoom.isNotEmpty && widget.nameUser.isNotEmpty) {
      setState(() {
        inRoom = true;
      });
    }
    mainTimer();
    super.initState();
  }

  Timer? _timer;
  void mainTimer() {
    _timer = Timer.periodic(
      Duration(seconds: 2),
      (Timer t) => checkInRoom(),
    );
  }

  Future<void> checkInRoom() async {
    Room room = Room();
    if (widget.nameRoom.isNotEmpty && widget.nameUser.isNotEmpty) {
      if (await room.inRoom(widget.nameRoom, widget.nameUser)) {
        if (await room.checkRoomsNamePlay(widget.nameRoom) == 1) {
          if (await room.countUser(widget.nameRoom) != 1) {
            _timer?.cancel();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FindTrue(
                  nameRoom: widget.nameRoom,
                  nameUser: widget.nameUser,
                ),
              ),
            );
          }
        } else if (await room.checkRoomsNamePlay(widget.nameRoom) == 2) {
          if (await room.countUser(widget.nameRoom) != 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RulesAntiMafia(
                  nameRoom: widget.nameRoom,
                  nameUser: widget.nameUser,
                ),
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: inRoom,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () async {
                          Room room = Room();
                          await room.deleteUserInRoom(
                              widget.nameRoom, widget.nameUser);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChoiseGame(
                                nameRoom: "",
                                nameUser: "",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 35,
                          color: Color.fromARGB(255, 255, 174, 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: visibilityName,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Имя вашей комнаты: ',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          Text(
                            widget.nameRoom,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 30,
                              color: Color.fromARGB(255, 255, 174, 0),
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Color(0xffA1C096),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListRooms(
                              nameRoom: widget.nameRoom,
                              nameUser: widget.nameUser,
                            ),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Поиск комнаты',
                              style: TextStyle(
                                color: Color(0xff1E5541),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Visibility(
                    visible: !inRoom,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Color(0xffA1C096),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainPage(
                                nameRoom: widget.nameRoom,
                                nameUser: widget.nameUser,
                              ),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Создать комнату',
                                style: TextStyle(
                                  color: Color(0xff1E5541),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !inRoom,
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02),
                  ),
                  Visibility(
                    visible: inRoom,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RulesChoiseTrue(
                                  nameRoom: widget.nameRoom,
                                  nameUser: widget.nameUser),
                            ),
                          );
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => TablePoints(
                          //       nameRoom: widget.nameRoom,
                          //       nameUser: widget.nameUser,
                          //     ),
                          //   ),
                          // );
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/choiseTrue.png',
                              width: MediaQuery.of(context).size.width * 0.2,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            const Text(
                              'УЗНАЙ ИСТИНУ',
                              style: TextStyle(
                                color: Color(0xff1E5541),
                                fontSize: 27,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Visibility(
                    visible: inRoom,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RulesAntiMafia(
                                nameRoom: widget.nameRoom,
                                nameUser: widget.nameUser,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/antimafia.png',
                              width: MediaQuery.of(context).size.width * 0.2,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            const Text(
                              'АНТИМАФИЯ',
                              style: TextStyle(
                                color: Color(0xff1E5541),
                                fontSize: 27,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  // Visibility(
                  //   visible: !inRoom,
                  //   child: Container(
                  //     width: MediaQuery.of(context).size.width * 0.9,
                  //     height: 70,
                  //     decoration: BoxDecoration(
                  //       color: Color(0xffA1C096),
                  //       borderRadius: BorderRadius.circular(25.0),
                  //     ),
                  //     child: InkWell(
                  //       onTap: () {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => MainPage(
                  //               nameRoom: widget.nameRoom,
                  //               nameUser: widget.nameUser,
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //       // child: const Padding(
                  //       //   padding: EdgeInsets.symmetric(horizontal: 16.0),
                  //       //   child: Row(
                  //       //     mainAxisAlignment: MainAxisAlignment.center,
                  //       //     children: [
                  //       //       SizedBox(
                  //       //         width: 10,
                  //       //       ),
                  //       //       Text(
                  //       //         'Создать комнату',
                  //       //         style: TextStyle(
                  //       //           color: Color(0xff1E5541),
                  //       //           fontSize: 20,
                  //       //           fontWeight: FontWeight.w600,
                  //       //         ),
                  //       //         softWrap: true,
                  //       //       ),
                  //       //     ],
                  //       //   ),
                  //       // ),
                  //     ),
                  //   ),
                  // ),

                  Visibility(
                    visible: !inRoom,
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02),
                  ),
                  Visibility(
                    visible: inRoom,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => RulesChoiseTrue(
                          //         nameRoom: widget.nameRoom,
                          //         nameUser: widget.nameUser),
                          //   ),
                          // );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoteAntiMafia(
                                nameRoom: widget.nameRoom,
                                nameUser: widget.nameUser,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/nlo.png',
                              width: MediaQuery.of(context).size.width * 0.2,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            const Text(
                              'ПРИШЕЛЕЦ',
                              style: TextStyle(
                                color: Color(0xff1E5541),
                                fontSize: 27,
                              ),
                            ),
                          ],
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
