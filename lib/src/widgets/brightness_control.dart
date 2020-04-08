import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screen/screen.dart';

import 'vertical_progress_indicator.dart';

class BrightnessController extends StatefulWidget {
  final Color backgrouncColor;
  final Size size;
  BrightnessController({Key key, this.backgrouncColor, this.size})
      : super(key: key);

  @override
  BrightnessControllerState createState() => BrightnessControllerState();
}

class BrightnessControllerState extends State<BrightnessController>
    with SingleTickerProviderStateMixin {
  final BehaviorSubject<double> _brigtnessSubject =
      BehaviorSubject.seeded(null);
  double _maxBrightness = 1.0;
  bool _showBrightness = false;
  AnimationController _controller;
  Animation<double> _animation;
  Timer _timer;
  @override
  void initState() {
    _initialize();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 100),
        upperBound: 1,
        lowerBound: 0,
        value: 0);
    _animation = CurvedAnimation(
        parent: _controller, curve: Curves.fastLinearToSlowEaseIn);
    super.initState();
  }

  Future<void> _initialize() async {
    double initBrightness = await Screen.brightness;
    _brigtnessSubject.add(initBrightness);
  }


  _show([bool state = false]) async {
    state
        ? await _controller.animateTo(1.0, duration: Duration.zero)
        : await _controller.reverse();
    setState(() {
      _showBrightness = state;
    });
  }

  void _resetTimer() => _timer = Timer(Duration(seconds: 1), _show);

  void changeBrightness(double vol, [bool useValue = false]) {
    if (vol == null) return;
    double value = useValue
        ? vol
        : max(
            0.0,
            min(
                (vol +
                        (_brigtnessSubject.value ?? 0.0) /
                            (_maxBrightness ?? 0.0)) *
                    (_maxBrightness ?? 0.0),
                (_maxBrightness ?? 0.0)));
    _brigtnessSubject.add(value);
    Screen.setBrightness(_brigtnessSubject.value);
    if (!_showBrightness) {
      _show(true);
    }
    if (_timer?.isActive ?? false) _timer?.cancel();
    _resetTimer();
  }

  @override
  void dispose() {
    _brigtnessSubject?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _animation.value,
      duration: Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(4),
        color: widget.backgrouncColor ?? Colors.black45,
        height: widget.size?.height ?? 90,
        width: widget.size?.width ?? 200,
        child: Stack(
          children: <Widget>[
            StreamBuilder(
                stream: _brigtnessSubject,
                initialData: 0.0,
                builder: (context, snapshot) {
                  double val = (snapshot.data ?? 0.0) / (_maxBrightness ?? 0.0);
                  return Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          VerticalProgressIndicator(value: val),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Brightness',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4
                                      .copyWith(color: Colors.white),
                                ),
                                Text('${(val * 100).round()}%',
                                    style:
                                        Theme.of(context).textTheme.headline5),
                              ],
                            ),
                          )
                        ],
                      ));
                }),
          ],
        ),
      ),
    );
  }
}
