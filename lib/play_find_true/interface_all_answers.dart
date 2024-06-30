import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:turtle_fun/db/answer_crud.dart';
import 'package:turtle_fun/play_find_true/game_process.dart';
import 'package:turtle_fun/play_find_true/table_points.dart';

// ignore: must_be_immutable
class AllAnswers extends StatefulWidget {
  String nameRoom;
  String nameUser;
  int currentIndex;

  AllAnswers(
      {Key? key,
      required this.nameRoom,
      required this.nameUser,
      required this.currentIndex})
      : super(key: key);

  @override
  State<AllAnswers> createState() => _AllAnswersState();
}

class _AllAnswersState extends State<AllAnswers> {
  ProcessFind processFind = ProcessFind();
  List<String>? facts;

  String? question;
  Future<QuerySnapshot>? answers;
  bool visibility = true;
  Timer? _timer;
  Timer? _timerPage;
  Timer? _countdownTimer;
  var trueAnswers;
  bool showCorrectAnswer = false;
  int? selectedAnswerIndex;
  int countdown = 20;
  bool onPress = false;

  @override
  void initState() {
    super.initState();
    trueAnswers = processFind.answers.toList();
    facts = processFind.facts_without_answers.toList();
    if (facts!.isNotEmpty) {
      question = facts![widget.currentIndex];
      findAnswers();
    }
    startTimer();
    startCountdown();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 10), () async {
      setState(() {
        showCorrectAnswer = true;
      });
      newPageTimer();
    });
  }

  void newPageTimer() {
    _timerPage?.cancel();
    _timerPage = Timer(Duration(seconds: 5), () async {
      if (widget.currentIndex != 7) {
        setState(() {
          widget.currentIndex = widget.currentIndex + 1;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AllAnswers(
              nameRoom: widget.nameRoom,
              nameUser: widget.nameUser,
              currentIndex: widget.currentIndex,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TablePoints(
              nameRoom: widget.nameRoom,
              nameUser: widget.nameUser,
            ),
          ),
        );
      }
    });
  }

  void startCountdown() {
    _countdownTimer?.cancel();
    countdown = 10;
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

  Future<void> findAnswers() async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: widget.nameRoom)
        .get();

    if (filter.docs.isNotEmpty) {
      var docId = filter.docs.first.id;
      var answersSnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(docId)
          .collection('answers')
          .where('index', isEqualTo: widget.currentIndex)
          .get();

      setState(() {
        answers = Future.value(answersSnapshot);
        showCorrectAnswer = false;
        selectedAnswerIndex = null;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerPage?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Text(
            question ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xffA1C096), fontSize: 24),
          ),
          Visibility(
            visible: visibility,
            child: Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: answers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No answers found'));
                  } else {
                    var answersSnapshot = snapshot.data!.docs;

                    List<Map<String, dynamic>> answersList =
                        answersSnapshot.map((doc) {
                      return doc.data() as Map<String, dynamic>;
                    }).toList();

                    answersList.add({
                      'answer': trueAnswers[widget.currentIndex].toString(),
                      'name': 'correctAnswer',
                    });

                    return ListView.builder(
                      itemCount: answersList.length,
                      itemBuilder: (context, index) {
                        var answer = answersList[index];
                        bool isCorrectAnswer =
                            answer['name'] == 'correctAnswer';
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 5, left: 30, right: 30),
                          child: Column(
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: showCorrectAnswer
                                      ? (isCorrectAnswer
                                          ? Colors.green
                                          : selectedAnswerIndex == index
                                              ? Colors.red
                                              : Colors.transparent)
                                      : Colors.transparent,
                                  side: const BorderSide(
                                      color: Color(0xffA1C096), width: 2),
                                ),
                                onPressed: () async {
                                  if (!onPress) {
                                    Answer answerClass = Answer();
                                    if (!showCorrectAnswer) {
                                      setState(() {
                                        selectedAnswerIndex = index;
                                      });
                                    }

                                    if (isCorrectAnswer) {
                                      await answerClass.addPointToUser(
                                          widget.nameUser, widget.nameRoom);
                                    }
                                    setState(() {
                                      onPress = true;
                                    });
                                  }
                                },
                                child: Text(
                                  answer['answer'] ?? 'No text',
                                  style: const TextStyle(
                                      color: Color(0xffA1FF80), fontSize: 20),
                                ),
                              ),
                              if (selectedAnswerIndex == index &&
                                  showCorrectAnswer &&
                                  !isCorrectAnswer)
                                const Text(
                                  'Ваш ответ',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          Visibility(
            visible: onPress,
            child: Text(
              'Ваш голос учтен.',
              style: const TextStyle(color: Color(0xffA1C096), fontSize: 20),
            ),
          ),
          Text(
            '$countdown секунд',
            style: const TextStyle(color: Color(0xffA1C096), fontSize: 20),
          ),
        ],
      ),
    );
  }
}
