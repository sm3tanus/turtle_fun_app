import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/pages/choise_game_page.dart';

// ignore: must_be_immutable
class TablePoints extends StatefulWidget {
  String nameRoom;
  String nameUser;
  TablePoints({super.key, required this.nameRoom, required this.nameUser});

  @override
  State<TablePoints> createState() => _TablePointsState();
}

class _TablePointsState extends State<TablePoints> {
  Timer? _timer;
  Timer? _countdownTimer;

  int countdown = 15;

  @override
  void initState() {
    startTimer();
    startCountdown();
    super.initState();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 15), () async {
      Room room = Room();
      room.deleteRoom(widget.nameRoom);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChoiseGame(
            nameRoom: "",
            nameUser: "",
          ),
        ),
      );
    });
  }

  void startCountdown() {
    _countdownTimer?.cancel();
    countdown = 15;
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          _countdownTimer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getDataFromFirestore(widget.nameRoom),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Ошибка загрузки данных: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Нет данных для отображения.'));
          } else {
            List<Map<String, dynamic>> data = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Имя',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Color.fromARGB(255, 255, 174, 0)),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Очки',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Color.fromARGB(255, 255, 174, 0)),
                        ),
                      ),
                    ],
                    rows: List<DataRow>.generate(
                      data.length,
                      (index) => DataRow(
                        cells: <DataCell>[
                          DataCell(Text(
                            data[index]['name'].toString(),
                            style: TextStyle(
                                fontSize: 20, color: Color(0xffA1C096)),
                          )),
                          DataCell(Text(
                            (data[index]['points'] ?? 0).toString(),
                            style: TextStyle(
                                fontSize: 20, color: Color(0xffA1C096)),
                          )),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    '$countdown секунд',
                    style:
                        const TextStyle(color: Color(0xffA1C096), fontSize: 20),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getDataFromFirestore(
      String nameRoom) async {
    QuerySnapshot rooms = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: nameRoom)
        .get();
    var roomId = rooms.docs.first.id;

    var usersPlay = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('usersPlay')
        .get();
    List<Map<String, dynamic>> data = [];
    usersPlay.docs.forEach((doc) {
      Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
      data.add({
        'name': docData['name'],
        'points': docData['points'],
      });
    });

    return data;
  }
}
