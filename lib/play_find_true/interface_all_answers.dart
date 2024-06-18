import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  var roomId;
  void initState() {
    _getRoomId();
  }

  Future<void> _getRoomId() async {
    var filter = await FirebaseFirestore.instance
        .collection('rooms')
        .where('name', isEqualTo: widget.nameRoom)
        .get();

    setState(() {
      roomId = filter.docs.first.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomId)
            .collection('answers')
            .get(),
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
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Обработка нажатия на кнопку
                      print('${answer['answer']} pressed');
                    },
                    child: Text(answer['answer'] ?? 'No text'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
