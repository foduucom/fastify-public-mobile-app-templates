import 'dart:async';
import 'package:flutter/material.dart';

class OtpTimer extends StatefulWidget {
  const OtpTimer({Key? key, required this.onEnd, required this.timeDuration})
      : super(key: key);

  final VoidCallback onEnd;
  final int timeDuration;

  @override
  // ignore: library_private_types_in_public_api
  _OtpTimerState createState() => _OtpTimerState();
}

class _OtpTimerState extends State<OtpTimer> {
  final interval = const Duration(seconds: 1);
  late Timer _timer;
  // final int widget.timeDuration = 60;

  int currentSeconds = 0;

  String get timerText =>
      '${((widget.timeDuration - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((widget.timeDuration - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout([int? milliseconds]) {
    var duration = interval;
    _timer = Timer.periodic(duration, (timer) {
      setState(() {
        currentSeconds = timer.tick;
        if (timer.tick >= widget.timeDuration) {
          timer.cancel();
          widget.onEnd();
        }
      });
    });
  }

  @override
  void initState() {
    startTimeout();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.timer),
        const SizedBox(
          width: 5,
        ),
        Text(timerText, style: const TextStyle(color: Color(0xFFeb323a)))
      ],
    );
  }
}
