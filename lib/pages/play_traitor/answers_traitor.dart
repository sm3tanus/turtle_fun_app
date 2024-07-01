import 'dart:math';

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

  List<String> questions = [
    'С кем ты обычно здесь бываешь?',
    'С кем ты здесь общаешься?',
    'Кого ты чаще всего встречаешь в этом месте?',
    'Как ты взаимодействуешь с людьми в этом месте?',
    'На тебя могут здесь насать, за кривой базар?', //  Вопрос, который может быть некорректным и неуместным в некоторых контекстах.
    'Чем ты обычно занимаешься, когда бываешь здесь?',
    'Что тебя больше всего привлекает в этом месте?',
    'Какое впечатление ты получаешь, когда здесь бываешь?',
    'Какие эмоции ты испытываешь, когда здесь бываешь?',
    'Что тебя заставляет возвращаться сюда снова и снова?',
    'Что тебя окружает в этом месте?',
    'Какие звуки ты слышишь, когда здесь бываешь?',
    'Какой запах ты чувствуешь, когда здесь бываешь?',
    'Как выглядит это место, когда ты здесь бываешь?',
    'Есть ли у тебя любимые места в этом месте?',
    'Когда ты обычно бываешь здесь?',
    'Как часто ты здесь бываешь?',
    'Есть ли у тебя любимое время суток для посещения этого места?',
    'В какое время дня здесь больше всего людей?',
    'Как долго ты обычно здесь проводишь время?',
    'В какой одежде ты ходишь в этом месте?',
    'Что ты обычно носишь, когда бываешь здесь?',
    'Есть ли у тебя специальная одежда, которую ты надеваешь, когда здесь?',
    'Что ты обычно надеваешь, чтобы чувствовать себя здесь комфортно?',
    'Какая одежда тебе больше всего нравится для этого места?'
  ];
  void _findCurrentUserIndex() {
    currentUserIndex =
        widget.usersPlay.indexWhere((user) => user['name'] == widget.nameUser);
  }

  String getRandomQuestion() {
    final random = Random();
    final randomIndex = random.nextInt(questions.length);
    return questions[randomIndex];
  }

  List<String> place = [
    'Больница',
    'Стройка',
    'Супермаркет',
    'Автосалон',
    'Военная база',
    'Школа',
    'Университет',
    'Пляж',
    'Корабль',
    'Военкомат'
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
      body: SingleChildScrollView(
        child: Row(
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
                  onPressed: () {
                    String randomQuestion = getRandomQuestion();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Random Question'),
                          content: Text(randomQuestion),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Подсказка'),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                if (widget.usersPlay[currentUserIndex]['robbery'] == true)
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
                          widget.usersPlay[currentUserIndex]['robbery'] ==
                              true) {
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
                          widget.usersPlay[currentUserIndex]['robbery'] ==
                              true) {
                        // Пришельцы проиграли
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Результат'),
                            content: Text('Пришельцы проиграли!'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  amf.updateResultInGameResults(
                                      widget.nameRoom);
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
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FloatingActionButton.extended(
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
          backgroundColor: Color.fromRGBO(161, 255, 128, 1),
          label: Text(
            'ВЫХОД',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
