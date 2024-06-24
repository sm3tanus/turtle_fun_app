import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final bool isTraitor;

  User(this.name, this.isTraitor);
}

class GameQuestion {
  final String question;
  final List<String> answers;
  final int correctIndex;

  GameQuestion(this.question, this.answers, this.correctIndex);
}

class TraitorGamePage extends StatefulWidget {
  final List<User> users;
  final String gameRoomName;
  String nameRoom;
  String nameUser;

  TraitorGamePage(
      {required this.users,
      required this.gameRoomName,
      required this.nameRoom,
      required this.nameUser});

  @override
  _TraitorGamePageState createState() => _TraitorGamePageState();
}

class _TraitorGamePageState extends State<TraitorGamePage> {
  int traitorScore = 0;
  int innocentScore = 0;
  int questionIndex = 0;
  List<GameQuestion> gameQuestions = [
    GameQuestion(
      "Какого цвета небо?",
      ["Красное", "Синее", "Зеленое", "Желтое"],
      1,
    ),
    GameQuestion(
      "Какого цвета небо?",
      ["Красное", "Синее", "Зеленое", "Желтое"],
      1,
    ),
    GameQuestion(
      "Какого цвета небо?",
      ["Красное", "Синее", "Зеленое", "Желтое"],
      1,
    ),
    GameQuestion(
      "Какого цвета небо?",
      ["Красное", "Синее", "Зеленое", "Желтое"],
      1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Игра "Предатель"'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Ваша роль: ${widget.users.firstWhere((user) => user.isTraitor).name}',
            ),
            Text(
              gameQuestions[questionIndex].question,
            ),
            Column(
              children: List.generate(
                gameQuestions[questionIndex].answers.length,
                (index) => ElevatedButton(
                  onPressed: () {
                    if (widget.users
                        .firstWhere((user) => user.isTraitor)
                        .isTraitor) {
                      // Логика для предателя
                      if (index == gameQuestions[questionIndex].correctIndex) {
                        traitorScore++;
                      }
                    } else {
                      // Логика для невиновных игроков
                      if (index != gameQuestions[questionIndex].correctIndex) {
                        innocentScore++;
                      }
                    }
                    setState(() {
                      if (questionIndex < gameQuestions.length - 1) {
                        questionIndex++;
                      } else {
                        // Показать результаты
                        showResults(context);
                      }
                    });
                  },
                  child: Text(gameQuestions[questionIndex].answers[index]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void showResults(BuildContext context) {
    String resultText;
    if (traitorScore > innocentScore) {
      resultText = 'Предатель выиграл $traitorScore:$innocentScore';
    } else {
      resultText = 'Мирные выиграли $innocentScore:$traitorScore';
    }
    // Обновим результаты игры в базе данных
    updateGameResults(resultText);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Результаты'),
          content: Text(resultText),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void updateGameResults(String resultText) async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.gameRoomName)
        .update({'gameResults': resultText});
  }
}
