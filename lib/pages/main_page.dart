// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/pages/choise_game_page.dart';

// ignore: must_be_immutable
class MainPage extends StatefulWidget {
  String nameRoom;
  String nameUser;
  MainPage({super.key, required this.nameRoom, required this.nameUser});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _nameRoom = TextEditingController();
  bool visibility = false;
  bool visibility2 = false;

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
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Turtle Fun',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: Color.fromARGB(255, 181, 255, 179),
                              fontSize: 44,
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
                Visibility(
                  visible: visibility2,
                  child: Text(
                    'Имя комнаты уже занято :(',
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
                      ),
                    ),
                  ),
                ),
                Text(
                  'Если хотите создать комнату:',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 174, 0),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
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
                    controller: _nameRoom,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                    decoration: InputDecoration(
                        hintText: 'Название комнаты',
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
                  height: MediaQuery.of(context).size.height * 0.09,
                  child: ElevatedButton(
                    onPressed: () async {
                      Room room = Room();
                      if (_name.text.isNotEmpty &&
                          !await room
                              .checkInRoom(_nameRoom.text.toLowerCase()) &&
                          _nameRoom.text.isNotEmpty) {
                        room.createRoom(_name.text.toLowerCase(),
                            _nameRoom.text.toLowerCase());

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChoiseGame(
                              nameRoom: _nameRoom.text,
                              nameUser: _name.text,
                            ),
                          ),
                        );
                      } else if (await room
                          .checkInRoom(_nameRoom.text.toLowerCase())) {
                        setState(() {
                          visibility2 = true;
                        });
                      } else if (_name.text.isNotEmpty &&
                          _nameRoom.text.isEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChoiseGame(
                              nameRoom: '',
                              nameUser: _name.text,
                            ),
                          ),
                        );
                      } else {
                        setState(() {
                          visibility = true;
                        });
                      }
                    },
                    child: const Text(
                      'НАЧАТЬ ИГРУ',
                      style: TextStyle(
                        color: Color(0xff1E5541),
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffA1C096),
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
        child: Icon(
          Icons.navigate_next,
          color: Color(0xff1E5541),
        ),
      ),
    );
  }
}
