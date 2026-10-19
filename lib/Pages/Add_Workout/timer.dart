import 'dart:async';

import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget { // todo add initial seconds
  final Function(int seconds)? updateVariable;

  const TimerScreen({super.key, this.updateVariable});

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null) return;
    setState(() { isRunning = true; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() { _seconds++; });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() { isRunning = false; });
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      isRunning = false;
      _seconds = 0;
    });
  }

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = (seconds % 3600 ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (isRunning) {
                _stopTimer();
              } else {
                _seconds == 0 ? _startTimer() : _resetTimer();
              }
              widget.updateVariable?.call(_seconds);
            },
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.blue,
              child: Icon(
                isRunning
                    ? Icons.pause
                    : _seconds == 0
                        ? Icons.play_arrow
                        : Icons.restart_alt_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatTime(_seconds),
            style: const TextStyle(color: Colors.white, fontSize: 25),
          ),
        ],
      ),
    );
  }
}