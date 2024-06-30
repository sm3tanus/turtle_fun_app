import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:turtle_fun/db/answer_crud.dart';
import 'package:turtle_fun/play_find_true/game_process.dart';
import 'package:turtle_fun/play_find_true/interface_all_answers.dart';

class FindTrue extends StatefulWidget {
  final String nameRoom;
  final String nameUser;

  const FindTrue({super.key, required this.nameRoom, required this.nameUser});

  @override
  State<FindTrue> createState() => _FindTrueState();
}

class _FindTrueState extends State<FindTrue> {
  ProcessFind processFind = ProcessFind();
  List<String>? facts;
  int currentIndex = 0;
  String? question;
  TextEditingController _answer = TextEditingController();
  bool visibility = false;
  bool allUsersReady = false;
  bool enterAnswer = true;
  bool visibilityWait = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    facts = processFind.facts_without_answers.toList();
    if (facts!.isNotEmpty) {
      question = facts![currentIndex];
    }
  }

  void startPeriodicTask() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await areAllUsersReady();
      if (allUsersReady && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AllAnswers(
              nameRoom: widget.nameRoom,
              nameUser: widget.nameUser,
              currentIndex: 0,
            ),
          ),
        );
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answer.dispose();
    super.dispose();
  }

  Future<void> _setUserReady() async {
    QuerySnapshot roomSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: widget.nameRoom)
        .get();

    if (roomSnapshot.docs.isNotEmpty) {
      DocumentReference roomRef = roomSnapshot.docs.first.reference;

      QuerySnapshot querySnapshot = await roomRef
          .collection('usersPlay')
          .where('name', isEqualTo: widget.nameUser)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String userDocId = querySnapshot.docs.first.id;

        await roomRef
            .collection('usersPlay')
            .doc(userDocId)
            .update({'ready': true});
      }
    }
  }

  Future<void> areAllUsersReady() async {
    QuerySnapshot roomSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: widget.nameRoom)
        .get();

    if (roomSnapshot.docs.isNotEmpty) {
      DocumentReference roomRef = roomSnapshot.docs.first.reference;

      QuerySnapshot querySnapshot = await roomRef
          .collection('usersPlay')
          .where('ready', isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty && mounted) {
        setState(() {
          allUsersReady = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: enterAnswer,
                child: Text(
                  question ?? '',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Color(0xffA1C096), fontSize: 24),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Visibility(
                visible: enterAnswer,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.09,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: TextField(
                    cursorColor: const Color(0xffA1FF80),
                    textAlign: TextAlign.center,
                    controller: _answer,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                    decoration: InputDecoration(
                      hintText: 'Введите ответ',
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 226, 226, 226),
                          fontSize: 24),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xffA1FF80), width: 2),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xffA1FF80), width: 2),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xffA1FF80), width: 2),
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: enterAnswer,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.08,
                  child: ElevatedButton(
                    onPressed: () async {
                      Answer answer = Answer();
                      if (_answer.text.isNotEmpty) {
                        await answer.addAnswerToRoom(widget.nameRoom,
                            widget.nameUser, _answer.text, currentIndex);
                        _answer.clear();
                        setState(() {
                          currentIndex++;
                          if (currentIndex < facts!.length) {
                            question = facts![currentIndex];
                          } else {
                            enterAnswer = false;
                          }
                          visibility = false;
                        });
                      } else {
                        setState(() {
                          visibility = true;
                        });
                      }
                    },
                    child: const Text(
                      'ОТПРАВИТЬ',
                      style: TextStyle(
                        color: Color(0xff1E5541),
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !enterAnswer,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.08,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _setUserReady();
                      startPeriodicTask();
                      setState(() {
                        visibilityWait = true;
                      });
                    },
                    child: const Text(
                      'ДАЛЕЕ',
                      style: TextStyle(
                        color: Color(0xff1E5541),
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.03,
              ),
              Visibility(
                visible: visibility,
                child: const Text(
                  'Введите ответ!',
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.03,
              ),
              Visibility(
                visible: visibilityWait,
                child: const Text(
                  'Дождитесь остальных!',
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
