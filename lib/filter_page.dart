import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  final String command;
  final int maxBuffer;
  const FilterPage({super.key, required this.command, this.maxBuffer = 10000});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late StreamSubscription<List<int>> _sub;
  late Process _process;
  var _logs = <String>[];
  var _filteredLogs = <String>[];
  final _tc = TextEditingController();
  final _sc = ScrollController();

  String get _filterText => _tc.text;

  var _scrollToBottom = false;

  @override
  void initState() {
    super.initState();
    spawnProcess();
  }

  Future<void> spawnProcess() async {
    var args = widget.command.split(" ");
    _process = await Process.start(args[0], args.sublist(1),
        workingDirectory: Directory.current.path);
    _sub = _process.stdout
        .listen((e) => _addLog(utf8.decode(e, allowMalformed: true)));
  }

  void _addLog(String s) {
    setState(() {
      _logs.add(s);
      final text = _filterText.toLowerCase();
      if (_logs.length > widget.maxBuffer) {
        _logs = _logs.sublist(_logs.length - widget.maxBuffer);
      }
      if (_filterText.isEmpty) {
        _filteredLogs = _logs;
      } else {
        if (_filteredLogs == _logs) {
          _filteredLogs = _logs
              .where((e) => e.toLowerCase().contains(text))
              .toList(growable: true);
        } else if (s.toLowerCase().contains(text)) {
          _filteredLogs.add(s);
        }
      }

      _scrollToBottom = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tc.dispose();
    _sc.dispose();
    _sub.cancel();
    _process.kill();
  }

  @override
  Widget build(BuildContext context) {
    if (_scrollToBottom) {
      _scrollToBottom = false;
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _sc.jumpTo(_sc.position.maxScrollExtent));
    }

    final text = _filterText.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.command),
      ),
      body: Column(
        children: [
          TextField(controller: _tc),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  controller: _sc,
                  padding: EdgeInsets.zero,
                  itemCount: _filteredLogs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final log = _filteredLogs[index];
                    if (_filterText.isNotEmpty) {
                      var i = log.toLowerCase().indexOf(text);
                      if (i != -1) {
                        final prefix = log.substring(0, i);
                        final highlight = log.substring(i, i + text.length);
                        final suffix = log.substring(i + text.length);

                        return SelectableText.rich(TextSpan(children: [
                          if (prefix.isNotEmpty) TextSpan(text: prefix),
                          TextSpan(
                              text: highlight,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          if (suffix.isNotEmpty) TextSpan(text: suffix)
                        ]));
                      }
                    }
                    return SelectableText(log);
                  }),
            ),
          )
        ],
      ),
    );
  }
}
