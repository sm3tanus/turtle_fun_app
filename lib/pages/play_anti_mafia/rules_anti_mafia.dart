import 'package:flutter/material.dart';
import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/pages/choise_game_page.dart';
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
                        'Грабители должны провести 5 ограблений, выбрав участников после обсуждения.',
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
                        'Полицейские осведомители должны мешать ограблениям и не выдать себя раньше времени.',
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
                        'Участники голосуют после всех ограблений, пытаясь вычислить осведомителей.',
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
                          if (await room.checkLeaderInRoom(widget.nameRoom)) {
                            if (await room.navigate(widget.nameRoom) &&
                                widget.nameRoom.isNotEmpty &&
                                widget.nameUser.isNotEmpty) {
                              room.addNameToRoom(
                                  widget.nameRoom, "НайдиИстину");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AntiMafiaGamePage(
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
