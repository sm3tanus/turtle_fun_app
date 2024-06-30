// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/pages/choise_game_page.dart';

// ignore: must_be_immutable
class EnterName extends StatefulWidget {
  String nameRoom;
  String nameUser;
  EnterName({super.key, required this.nameRoom, required this.nameUser});

  @override
  State<EnterName> createState() => _EnterNameState();
}

class _EnterNameState extends State<EnterName> {
  final TextEditingController _name = TextEditingController();

  bool visibility = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Turtle Fun',
                          textAlign: TextAlign.right,
                          softWrap: true,
                          style: TextStyle(
                              color: Color.fromARGB(255, 181, 255, 179),
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Image.asset(
                        'assets/logo.png',
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.width * 0.4,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.3,
                ),
                Visibility(
                  visible: visibility,
                  child: Text(
                    'Вы забыли про имя :(',
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.03,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.09,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: TextField(
                    cursorColor: Color(0xffA1FF80),
                    textAlign: TextAlign.center,
                    controller: _name,
                    maxLength: 10,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                    decoration: InputDecoration(
                        hintText: 'Введите имя',
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 226, 226, 226),
                            fontSize: 24),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffA1FF80), width: 2),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffA1FF80), width: 2),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffA1FF80), width: 2),
                          borderRadius: BorderRadius.circular(60),
                        )),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.08,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_name.text.isNotEmpty) {
                        if (widget.nameRoom.isNotEmpty) {
                          Room room = Room();
                          room.addUsersToRoom(widget.nameRoom, _name.text);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChoiseGame(
                                  nameRoom: widget.nameRoom,
                                  nameUser: _name.text),
                            ),
                          );
                        }
                        else{
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChoiseGame(
                                  nameRoom: widget.nameRoom,
                                  nameUser: _name.text),
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
                      'ПРИСОЕДИНИТЬСЯ',
                      style: TextStyle(
                        color: Color(0xff1E5541),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      
    );
  }
}
