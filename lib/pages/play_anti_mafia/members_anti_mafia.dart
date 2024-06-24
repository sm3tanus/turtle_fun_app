// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:turtle_fun/db/room_crud.dart';
// import 'package:turtle_fun/pages/play_anti_mafia/rules_anti_mafia.dart';

// class AntiMafiaMembersPage extends StatefulWidget {
//   String nameRoom;
//   String nameUser;
//   AntiMafiaMembersPage(
//       {super.key, required this.nameRoom, required this.nameUser});

//   @override
//   State<AntiMafiaMembersPage> createState() => _AntiMafiaMembersPageState();
// }

// class _AntiMafiaMembersPageState extends State<AntiMafiaMembersPage> {
  

 
  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromRGBO(30, 85, 65, 1),
//       body: SafeArea(
//           child: Center(
//               child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Text(
//               'АНТИ МАФИЯ',
//               style: TextStyle(
//                   fontSize: 30,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700),
//             ),
//           ),
//           Expanded(
//             child: users.isEmpty
//                 ? Center(
//                     child:
//                         CircularProgressIndicator(), // Показывает индикатор загрузки, пока данные не получены
//                   )
//                 : Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Wrap(
//                       spacing: 100,
//                       runSpacing: 20,
//                       children: List.generate(users.length, (index) {
//                         return Column(
//                           children: [
//                             SizedBox(
//                               width: 100, // Ограничение ширины текста
//                               child: FittedBox(
//                                 fit: BoxFit
//                                     .scaleDown, // Подгонка текста к ширине
//                                 child: Text(
//                                   users[index]['name'],
//                                   style: TextStyle(
//                                       color: Colors.white, fontSize: 20),
//                                 ),
//                               ),
//                             )
//                           ],
//                         );
//                       }),
//                     ),
//                   ),
//           )
//         ],
//       ))),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: FloatingActionButton.extended(
//           onPressed: () {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => RulesAntiMafia(
                         
//                           nameRoom: widget.nameRoom,
//                           nameUser: widget.nameUser,
//                         )));
//           },
//           backgroundColor: Color.fromRGBO(161, 255, 128, 1),
//           label: Text(
//             'НАЧАТЬ ИГРУ',
//             style: TextStyle(color: Color.fromRGBO(30, 85, 65, 1)),
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
// }
