import 'package:flutter/material.dart';
import 'pages/home_page.dart';


void main() {
WidgetsFlutterBinding.ensureInitialized();
runApp(const MyApp());
}


class MyApp extends StatelessWidget {
const MyApp({super.key});


@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'My VPN (Windows)',
theme: ThemeData(
primarySwatch: Colors.blue,
),
home: const HomePage(),
);
}
}