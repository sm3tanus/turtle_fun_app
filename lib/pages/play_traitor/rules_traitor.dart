import 'package:flutter/material.dart';
import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/pages/choise_game_page.dart';
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
  bool visibilityPlay = false;
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
                                  users: [],
                                  gameRoomName: widget.nameRoom,
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
