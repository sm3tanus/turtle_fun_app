import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:turtle_fun/db/answer_crud.dart';
import 'package:turtle_fun/play_find_true/game_process.dart';
import 'package:turtle_fun/play_find_true/interface_all_answers.dart';

// ignore: must_be_immutable
class FindTrue extends StatefulWidget {
  String nameRoom;
  String nameUser;
  FindTrue({super.key, required this.nameRoom, required this.nameUser});

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

  @override
  void initState() {
    super.initState();
    facts = processFind.facts_without_answers.toList();
    if (facts!.isNotEmpty) {
      question = facts![currentIndex];
    }
  }

  void nextQuestion() {
    setState(() {
      if (currentIndex < facts!.length - 1) {
        currentIndex++;
      } else {

        void _setUserReady() {
          FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.nameRoom)
              .collection('usersPlay')
              .doc(widget.nameUser)
              .update({'ready': true});
        }
      }
      question = facts![currentIndex];
    });
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                question ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xffA1C096), fontSize: 24),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Container(
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
                      borderSide:
                          const BorderSide(color: Color(0xffA1FF80), width: 2),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xffA1FF80), width: 2),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xffA1FF80), width: 2),
                      borderRadius: BorderRadius.circular(60),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.08,
                child: ElevatedButton(
                  onPressed: () {
                    Answer answer = Answer();
                    if (_answer.text.isNotEmpty) {
                      answer.addAnswerToRoom(widget.nameRoom, widget.nameUser,
                          _answer.text, currentIndex);
                      nextQuestion();
                      _answer.clear();
               
                      if (allUsersReady) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllAnswers(
                              nameRoom: widget.nameRoom,
                              nameUser: widget.nameUser,
                            ),
                          ),
                        );
                      }
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
            ],
          ),
        ),
      ),
    );
  }
}
