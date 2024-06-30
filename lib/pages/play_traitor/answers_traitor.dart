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
  bool _showPlaceList = false;
  String? _selectedPlace; // Храним выбранное место

  @override
  void initState() {
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

  void _updatePlaceAndCheckWin() {
    // Проверяем, выбрал ли пришелец правильное место
    if (_selectedPlace == widget.usersGameResult['place']) {
      // Обновляем базу данных
      // ... ваш код обновления базы данных
      // Например, amf.updateGameResult(widget.nameRoom, {'winner': 'Пришельцы'});

      // Покажем сообщение о победе
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Победа!'),
            content: Text('Пришельцы победили!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрыть диалоговое окно
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Если выбрано неправильное место, показываем сообщение
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Неверно!'),
            content: Text('Вы выбрали неправильное место.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрыть диалоговое окно
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.usersPlay[currentUserIndex]['robbery'] == true
                    ? 'assets/nlo.png'
                    : 'assets/human.png',
                height: 200, // Высота изображения
                width: 200,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.usersPlay[currentUserIndex]['robbery'] == true
                        ? 'Вы пришелец.\n Не дайте себя обнаружить!!!'
                        : 'Вы мирный житель.\n Найдите всех пришельцев!!! \n Место где вы находитесь - ${widget.usersGameResult['place']} \n Ваша роль - $currentRole',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              // Кнопка для выбора места
              if (widget.usersPlay[currentUserIndex]['robbery'] == true)
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Color(0xffA1C096),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _showPlaceList = !_showPlaceList;
                    });
                  },
                  child: Text('Выбрать место'),
                ),

              // Виджет с отображением списка мест (если _showPlaceList == true)
              if (_showPlaceList)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Список мест:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ... ваш контент
                              if (_showPlaceList)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Список мест:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      // Используйте Flexible вместо Expanded в ListView.builder
                                      Flexible(
                                        child: ListView.builder(
                                          itemCount: place.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title: Text(
                                                place[index],
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _selectedPlace = place[index];
                                                  _showPlaceList = false;
                                                });
                                                _updatePlaceAndCheckWin();
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        )
                      ]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
