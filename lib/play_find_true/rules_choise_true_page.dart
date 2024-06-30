import 'dart:async';

import 'package:flutter/material.dart';
import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/pages/choise_game_page.dart';
import 'package:turtle_fun/pages/play_anti_mafia/rules_anti_mafia.dart';
import 'package:turtle_fun/pages/play_traitor/rules_traitor.dart';
import 'package:turtle_fun/play_find_true/interface_answers.dart';

// ignore: must_be_immutable
class RulesChoiseTrue extends StatefulWidget {
  String nameRoom;
  String nameUser;
  RulesChoiseTrue({super.key, required this.nameRoom, required this.nameUser});

  @override
  State<RulesChoiseTrue> createState() => _RulesChoiseTrueState();
}

class _RulesChoiseTrueState extends State<RulesChoiseTrue> {
  bool visibility = false;
  bool visibilityWelcome = false;
  bool visibilityOne = false;
  bool visibleLeader = false;
  Room room = Room();
  @override
  void initState() {
    super.initState();
    check();
    mainTimer();
  }

  check() async {
    if (await room.checkIsLeader(widget.nameRoom, widget.nameUser)) {
      setState(() {
        visibleLeader = true;
      });
    }
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
        int roomStatus = await room.checkRoomsNamePlay(widget.nameRoom);
        int userCount = await room.countUser(widget.nameRoom);
        if (roomStatus == 1 && userCount != 1) {
          if (mounted) {
            _timer?.cancel();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FindTrue(
                  nameRoom: widget.nameRoom,
                  nameUser: widget.nameUser,
                ),
              ),
            );
          }
        } else if (roomStatus == 2 && userCount != 1) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RulesTraitor(
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        'Каждому игроку дается один и тот же вопрос, на который игрок должен ответить максимально честно и приближенно к верному ответу.',
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
                        'Цель игры - найти и выбрать правильное утверждение, которое соответствует действительности.',
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
                        'Игрок, за ответ которого проголосовало больше всего людей, побеждает.',
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
                  Visibility(
                    visible: visibleLeader,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (await room.checkUserPlayInRoom(
                              widget.nameRoom, widget.nameUser)) {
                            room.addUsersToPlayRoom(
                                widget.nameRoom, widget.nameUser);
                            room.setUserNavigateTrue(
                                widget.nameRoom, widget.nameUser);
                            setState(() {
                              visibilityWelcome = true;
                            });
                          } else {
                            setState(() {
                              visibilityWelcome = false;
                            });
                            room.setUserNavigateTrue(
                                widget.nameRoom, widget.nameUser);

                            if (await room.checkLeaderInRoom(widget.nameRoom)) {
                              room.addNameToRoom(
                                  widget.nameRoom, "НайдиИстину");
                              setState(() {
                                visibilityOne = false;
                              });
                              if (await room.countUser(widget.nameRoom) != 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FindTrue(
                                      nameRoom: widget.nameRoom,
                                      nameUser: widget.nameUser,
                                    ),
                                  ),
                                );
                              } else {
                                setState(() {
                                  visibilityOne = true;
                                });
                              }
                            } else {
                              setState(() {
                                visibilityOne = false;
                                visibility = true;
                              });
                            }
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
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Visibility(
                visible: visibilityOne,
                child: const Text(
                  'Одному играть не получится.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
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
  }
}
