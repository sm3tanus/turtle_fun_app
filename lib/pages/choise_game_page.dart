import 'package:flutter/material.dart';
import 'package:turtle_fun/pages/enter_name.dart';
import 'package:turtle_fun/pages/list_rooms.dart';
import 'package:turtle_fun/pages/main_page.dart';
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

  @override
  void initState() {
    if (widget.nameRoom.isNotEmpty) {
      setState(() {
        visibilityName = true;
      });
    }
    super.initState();
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
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.transparent,
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
                        SizedBox(width: 10),
                        Text(
                          'Поиск комнаты...',
                          style: TextStyle(
                            color: Color(0xffA1FF80),
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.15,
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.nameUser.isEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnterName(
                            nameRoom: widget.nameRoom,
                            nameUser: widget.nameUser,
                          ),
                        ),
                      );
                    } else if (widget.nameRoom.isEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListRooms(
                              nameRoom: widget.nameRoom,
                              nameUser: widget.nameUser),
                        ),
                      );
                    } 
                    
                    else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RulesChoiseTrue(
                              nameRoom: widget.nameRoom,
                              nameUser: widget.nameUser),
                        ),
                      );
                    }
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.15,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/rules');
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.15,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/rules');
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffA1C096),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MainPage(
                    nameRoom: widget.nameRoom, nameUser: widget.nameUser)),
          );
        },
        child: const Icon(
          Icons.add,
          color: Color(0xff1E5541),
        ),
      ),
    );
  }
}
