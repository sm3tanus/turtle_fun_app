import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChoiseGame(
                                nameRoom: widget.nameRoom,
                                nameUser: widget.nameUser),
                          ),
                        );
                      },
                      child: const Text(
                        'ВЫЙТИ',
                        style: TextStyle(
                          color: Color(0xff1E5541),
                          fontSize: 30,
                        ),
                      ),
                    ),
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
