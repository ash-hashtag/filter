import 'package:filter/filter_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _tc = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _tc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Filter"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _tc,
              onSubmitted: onSubmit,
            ),
            ElevatedButton(
              onPressed: () => onSubmit(_tc.text),
              child: const Text("Run"),
            )
          ],
        ),
      ),
    );
  }

  void onSubmit(String s) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => FilterPage(command: s)));
  }
}
