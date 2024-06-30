import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turtle_fun/db/room_crud.dart';
import 'package:turtle_fun/routes/routes.dart';
import 'package:turtle_fun/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAQlecr8Yjwg-0pZU221MgQDTKlYPsZ0Oo",
      appId: "1:33460470729:android:269a51570f216d10e09e18",
      messagingSenderId: "33460470729",
      projectId: "turtle-fun-app",
      storageBucket: "turtle-fun-app.appspot.com",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Room room = Room();
  Future<void> _deleteCollection() async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('rooms');
    QuerySnapshot querySnapshot = await collectionRef.get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TurtleFun',
      theme: themeData,
      debugShowCheckedModeBanner: false,
      routes: routes,
      initialRoute: '/',
    );
  }


 
}
