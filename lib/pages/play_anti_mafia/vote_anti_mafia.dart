import 'package:flutter/material.dart';

class VoteAntiMafia extends StatefulWidget {
  String nameRoom;
  String nameUser;
  VoteAntiMafia({super.key, required this.nameRoom, required this.nameUser});

  @override
  State<VoteAntiMafia> createState() => _VoteAntiMafiaState();
}

class _VoteAntiMafiaState extends State<VoteAntiMafia> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(30, 85, 65, 1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.transparent,
                  ),
                  //child: ТУТ НАПОЛНЕНИЕ КОНТЕЙНЕРА
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xffA1FF80),
                    ),
                    color: Colors.transparent,
                  ),
                  child: const Text(
                    'У вас столько то голосований',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: ListView(
                    children: const <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Text(
                          'Элемент 1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Text(
                          'Элемент 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    elevation: 5,
                    backgroundColor: const Color(0xffA1FF80),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Text(
                      'Голосовать',
                      style: TextStyle(
                        color: Color.fromRGBO(30, 85, 65, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
