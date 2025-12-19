import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importe a tela nova

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desafio Instabuy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomeScreen(), // <--- Aponta para nossa tela nova
    );
  }
}