// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/pages/choise_game_page.dart';
import 'package:turtle_fun/pages/enter_name.dart';

// ignore: must_be_immutable
class ListRooms extends StatefulWidget {
  String nameRoom;
  String nameUser;
  ListRooms({super.key, required this.nameRoom, required this.nameUser});

  @override
  State<ListRooms> createState() => _ListRoomsState();
}

class _ListRoomsState extends State<ListRooms> {
  List rooms = [];
  List filter = [];
  TextEditingController search = TextEditingController();
  var selectedItem;
  var user;
  var stream = FirebaseFirestore.instance.collection('rooms').snapshots();

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }


  Future<void> _fetchRooms() async {
    var snapshot = await FirebaseFirestore.instance.collection('rooms').get();
    setState(() {
      rooms = snapshot.docs;
      filter = rooms.where((doc) => doc['name'].toLowerCase() != widget.nameRoom.toLowerCase()).toList();
      user = rooms.where((doc) => doc['name'].toLowerCase() == widget.nameRoom.toLowerCase()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
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
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Image.asset(
                            'assets/logo.png',
                          ),
                        ),
                        Text(
                          'Назад',
                          style: TextStyle(
                            color: Color(0xffA1C096),
                            fontSize: 25,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.09,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                ),
                child: TextField(
                  controller: search,
                  onChanged: ((value) {
                    if (value.isNotEmpty) {
                      filter = rooms
                          .where((i) => i['name'].contains(value.toLowerCase()))
                          .toList();
                    } else {
                      filter = rooms
                          .where((doc) => doc['name'] != widget.nameRoom)
                          .toList();
                    }
                  }),
                  cursorColor: Color(0xffA1FF80),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24),
                  decoration: InputDecoration(
                    hintText: 'Поиск',
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
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.03,
                      ),
                      child: Text(
                        'Комната',
                        style: TextStyle(
                            fontSize: 28,
                            color: Color(0xffA1FF80),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.03,
                      ),
                      child: Text(
                        'Лидер',
                        style: TextStyle(
                            fontSize: 28,
                            color: Color(0xffA1FF80),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<Object>(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filter.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () async {
                                Room room = Room();
                                setState(() {
                                  selectedItem = filter[index];
                                });
                                if (widget.nameUser.isNotEmpty) {
                                  await room.addUsersToRoom(
                                      selectedItem['name'], widget.nameUser);
                                  if (widget.nameRoom.isNotEmpty) {
                                    await room.deleteRoom(widget.nameRoom);
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChoiseGame(
                                          nameRoom: selectedItem['name'],
                                          nameUser: widget.nameUser),
                                    ),
                                  );
                                } else if (widget.nameUser.isEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EnterName(
                                        nameRoom: selectedItem['name'],
                                        nameUser: widget.nameUser,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Color(0xffA1C096),
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                          ),
                                          child: Text(
                                            filter[index]['name'],
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff1E5541),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                          ),
                                          child: Text(
                                            filter[index]['leader'],
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: Color(0xff1E5541),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
