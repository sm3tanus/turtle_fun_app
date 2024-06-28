import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/pages/choise_game_page.dart';
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
  @override
  void initState() {
    super.initState();
    inRoom();
  }

  Future inRoom() async {
    if (await countUser() != 1) {
      Room room = Room();
      if (await room.checkLeaderInRoom(widget.nameRoom)) {
        if (await room.checkUserPlayInRoom(widget.nameRoom, widget.nameUser)) {
          room.addUsersToPlayRoom(widget.nameRoom, widget.nameUser);
          room.setUserNavigateTrue(widget.nameRoom, widget.nameUser);
          setState(() {
            visibilityWelcome = true;
          });
        }
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
    }
  }

  Future<int> countUser() async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: widget.nameRoom)
        .get();

    var roomId = filter.docs.first.id;
    var roomDoc = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('usersPlay')
        .get();
    return roomDoc.size;
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ElevatedButton(
                      onPressed: () async {
                        Room room = Room();

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
                          if (await countUser() != 1) {
                            if (await room.checkLeaderInRoom(widget.nameRoom)) {
                              room.addNameToRoom(
                                  widget.nameRoom, "НайдиИстину");
                              setState(() {
                                visibilityOne = false;
                              });
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
                                visibilityOne = false;
                                visibility = true;
                              });
                            }
                          } else {
                            setState(() {
                              visibilityOne = true;
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
