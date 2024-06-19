import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:turtle_fun/db/answer_crud.dart';
import 'package:turtle_fun/play_find_true/game_process.dart';

class AllAnswers extends StatefulWidget {
  final String nameRoom;
  final String nameUser;

  AllAnswers({Key? key, required this.nameRoom, required this.nameUser})
      : super(key: key);

  @override
  State<AllAnswers> createState() => _AllAnswersState();
}

class _AllAnswersState extends State<AllAnswers> {
  @override
  ProcessFind processFind = ProcessFind();
  List<String>? facts;
  int currentIndex = 0;
  String? question;
  var roomId;
  var answers;

  @override
  void initState() {
    super.initState();
    facts = processFind.facts_without_answers.toList();
    if (facts!.isNotEmpty) {
      question = facts![currentIndex];
    }
    _getRoomId();
  }

  void nextQuestion() {
    setState(() {
      currentIndex++;
      question = facts![currentIndex - 1];
    });
  }

  Future<void> _setUserReady() async {
    QuerySnapshot roomSnapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: widget.nameRoom)
        .get();

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

  Future<void> _getRoomId() async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: widget.nameRoom)
        .get();

    setState(() {
      roomId = filter.docs.first.id;
    });
    answers = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('answers')
        .where('index', isEqualTo: currentIndex)
        .get();
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
          Expanded(
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
                  var answers = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: answers.length,
                    itemBuilder: (context, index) {
                      var answer = answers[index];
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: 5, left: 30, right: 30),
                        child: ElevatedButton(
                          onPressed: () async {
                            Answer answer = Answer();
                            await answer.addLikeAnswer(widget.nameUser, currentIndex, widget.nameRoom);
                          },
                          child: Text(
                            answer['answer'] ?? 'No text',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllAnswers(
                      nameRoom: widget.nameRoom,
                      nameUser: widget.nameUser,
                    ),
                  ),
                );
              },
              child: Text('awdawd'))
        ],
      ),
    );
  }
}
