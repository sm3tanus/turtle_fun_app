import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameQuestion {
  final String question;
  final List<String> answers;
  final int correctIndex;

  GameQuestion(this.question, this.answers, this.correctIndex);
}

class TraitorGamePage extends StatefulWidget {
  String nameRoom;
  String nameUser;
  Map<String, dynamic> usersGameResult;
  List<Map<String, dynamic>> usersPlay;
  TraitorGamePage(
      {required this.nameRoom,
      required this.nameUser,
      required this.usersGameResult,
      required this.usersPlay});

  @override
  _TraitorGamePageState createState() => _TraitorGamePageState();
}

class _TraitorGamePageState extends State<TraitorGamePage> {
  int currentUserIndex = 0;
  String currentRole = '';
  int currentRoleIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _findCurrentUserIndex();
    _findRole();
  }

  void _findCurrentUserIndex() {
    currentUserIndex =
        widget.usersPlay.indexWhere((user) => user['name'] == widget.nameUser);
  }

  List<String> place = [
    'Больница',
    'Стройка',
  ];
  void _findRole() {
    for (String placeName in place) {
      if (widget.usersGameResult['place'] == placeName) {
        // Нашли место, теперь ищем роль
        currentRole = widget.usersGameResult[placeName]
            [widget.usersPlay[currentUserIndex]['role']];

        return; // Выходим из функции, роль найдена
      }
    }

    // Если ни одно место не совпало
    print('нет такого места');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(widget.usersPlay[currentUserIndex]['robbery'] == true
              ? 'Вы предатель. Не дайте себя обнаружить!!!'
              : 'Вы мирный житель. Найдите всех шпионов!!! \n Место где вы находитесь - ${widget.usersGameResult['place']} \n Ваша роль - $currentRole'),
          Column(
            children: List.generate(
              widget.usersPlay.length,
              (index) => ElevatedButton(
                onPressed: () {},
                child: Text(widget.usersPlay[index]['name']),
              ),
            ),
          )
        ],
      ),
    );
  }
}
