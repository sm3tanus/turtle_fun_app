import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turtle_fun/pages/choise_game_page.dart';
import 'package:turtle_fun/pages/play_anti_mafia/anti_mafia_crud.dart';

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
  bool showPlaceList = false; // Флаг для показа/скрытия списка мест
  String? selectedPlace; // Сохраняет выбранное место
  AntiMafiaCrud amf = new AntiMafiaCrud();
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
    //widget.usersGameResult['place'] = widget.placeName;
    if (widget.usersGameResult['place'] != '') {
      for (String placeName2 in place) {
        if (widget.usersGameResult['place'] == placeName2) {
          // Нашли место, теперь ищем роль
          currentRole = widget.usersGameResult[placeName2]
              [widget.usersPlay[currentUserIndex]['role']];

          return; // Выходим из функции, роль найдена
        }
      }
    } else {
      print('нет такого места');
    }

    // Если ни одно место не совпало
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
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Color(0xffA1C096),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    showPlaceList = !showPlaceList; // Переключаем флаг
                  });
                },
                child: Text('Выбрать место'),
              ),
              // Показываем список мест, если флаг установлен
              if (showPlaceList)
                Column(
                  children: [
                    SizedBox(height: 20), // Отступ
                    for (String placeName in place)
                      ElevatedButton(
                        onPressed: () {
                          // Логика при нажатии на место
                          // Например, можно обновить состояние игры
                          // и закрыть список мест
                          print('Выбрано место: $placeName');
                          setState(() {
                            showPlaceList = false;
                            selectedPlace =
                                placeName; // Сохраняем выбранное место
                          });
                        },
                        child: Text(placeName),
                      ),
                    SizedBox(height: 20), // Отступ
                  ],
                ),
              // Кнопка "Подтвердить"
              if (selectedPlace != null)
                ElevatedButton(
                  onPressed: () {
                    print(widget.usersPlay[currentUserIndex]['robbery']);
                    print(widget.usersGameResult['place']);
                    // Проверяем, совпадает ли выбранное место с местом из игры
                    if (selectedPlace == widget.usersGameResult['place'] &&
                        widget.usersPlay[currentUserIndex]['robbery'] == true) {
                      // Пришельцы победили
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Результат'),
                          content: Text('Пришельцы победили!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  amf.updateResultInGameResults(
                                      widget.nameRoom);

                                  if (widget.usersGameResult['result'] ==
                                      true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChoiseGame(
                                          nameRoom: widget.nameRoom,
                                          nameUser: widget.nameUser,
                                        ),
                                      ),
                                    );
                                  }
                                });
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else if (selectedPlace ==
                            widget.usersGameResult['place'] &&
                        widget.usersPlay[currentUserIndex]['robbery'] == true) {
                      // Пришельцы проиграли
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Результат'),
                          content: Text('Пришельцы проиграли!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                amf.updateResultInGameResults(widget.nameRoom);
                                setState(() {
                                  if (widget.usersGameResult['result'] ==
                                      true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChoiseGame(
                                          nameRoom: widget.nameRoom,
                                          nameUser: widget.nameUser,
                                        ),
                                      ),
                                    );
                                  }
                                });
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Text('Подтвердить'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
