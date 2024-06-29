import 'package:flutter/material.dart';
import 'package:turtle_fun/pages/data_mafia/vote_data.dart';

class VoteAntiMafia extends StatefulWidget {
  final String nameRoom;
  final String nameUser;

  const VoteAntiMafia(
      {Key? key, required this.nameRoom, required this.nameUser})
      : super(key: key);

  @override
  _VoteAntiMafiaState createState() => _VoteAntiMafiaState();
}

class _VoteAntiMafiaState extends State<VoteAntiMafia> {
  DatabaseService databaseService =
      DatabaseService(); // Предположим, что у вас есть класс DatabaseService

  List<Map<String, dynamic>> usersPlay = []; // Список пользователей

  @override
  void initState() {
    super.initState();
    DatabaseService(); // Remove this line
    // Replace it with:
    _loadUserPlayData(); // Call the new function that contains awaited operation
  }

  Future<void> _loadUserPlayData() async {
    await DatabaseService(); // Wait for the completion of the asynchronous operation
  }

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
                    'У вас столько-то голосований',
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
                    children: [
                      for (var userPlay
                          in usersPlay) // Заменяем databaseService.usersPlay на usersPlay
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: Text(
                              userPlay['username'],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    elevation: 5,
                    iconColor: const Color(0xffA1FF80),
                  ),
                  child: Padding(
                    // Добавляем Padding для текста кнопки
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Голосовать',
                      style: TextStyle(
                        color: Colors.white,
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
