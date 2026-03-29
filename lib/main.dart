import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(const ResiflowApp());
}

class ResiflowApp extends StatelessWidget {
  const ResiflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResiFlow',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String result = "Chargement...";

  @override
  void initState() {
    super.initState();
    callApi();
  }

  void callApi() async {
    try {
      final response = await ApiService.getHealth();
      setState(() {
        result = response;
      });
    } catch (e) {
      setState(() {
        result = "Erreur: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ResiFlow"),
      ),
      body: Center(
        child: Text(
          result,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}