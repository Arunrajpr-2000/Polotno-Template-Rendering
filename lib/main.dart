import 'package:flutter/material.dart';
import 'package:polotno_template_editor/polotno_rendering_screen.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Polotno Template Editor',
      home: PolotnoRender(),
    );
  }
}
