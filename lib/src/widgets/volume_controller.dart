import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:volume_watcher/volume_watcher.dart';

import 'vertical_progress_indicator.dart';

class VolumeController extends StatefulWidget {
  final Color backgrouncColor;
  final Size size;
  VolumeController({Key key, this.backgrouncColor, this.size})
      : super(key: key);

  @override
  VolumeControllerState createState() => VolumeControllerState();
}

class VolumeControllerState extends State<VolumeController>
    with SingleTickerProviderStateMixin {
  final BehaviorSubject<double> _volumeSubject = BehaviorSubject.seeded(null);
  double _maxVolume = 0.0;
  bool _showVolume = false;
  bool _hasInitialized = false;
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
    num max = await VolumeWatcher.getMaxVolume;
    _maxVolume = max.toDouble();
    num initVolume = await VolumeWatcher.getCurrentVolume;
    _volumeSubject.add(initVolume.toDouble());
    _hasInitialized = true;
  }

  _onEvent(num vol) {
    _volumeSubject.add(vol.toDouble());
    if (_hasInitialized) changeVolume(vol.toDouble(), true);
  }

  _show([bool state = false]) async {
    state
        ? await _controller.animateTo(1.0, duration: Duration.zero)
        : await _controller.reverse();
    setState(() {
      _showVolume = state;
    });
  }

  void _resetTimer() => _timer = Timer(Duration(seconds: 1), _show);

  void changeVolume(double vol, [bool useValue = false]) {
    if (vol == null) return;
    double value = useValue
        ? vol
        : max(
            0.0,
            min(
                (vol + (_volumeSubject.value ?? 0.0) / (_maxVolume ?? 0.0)) *
                    (_maxVolume ?? 0.0),
                (_maxVolume ?? 0.0)));
    _volumeSubject.add(value);
    VolumeWatcher.setVolume(_volumeSubject.value);
    if (!_showVolume) {
      _show(true);
    }
    if (_timer?.isActive ?? false) _timer?.cancel();
    _resetTimer();
  }

  @override
  void dispose() {
    _volumeSubject?.close();
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
        width: widget.size?.width ?? 150,
        child: Stack(
          children: <Widget>[
            VolumeWatcher(onVolumeChangeListener: _onEvent),
            StreamBuilder(
                stream: _volumeSubject,
                initialData: 0.0,
                builder: (context, snapshot) {
                  double val = (snapshot.data ?? 0.0) / (_maxVolume ?? 0.0);
                  if (val.isNaN) val = 0.0;
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
                                  'Volume',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline
                                      .copyWith(color: Colors.white),
                                ),
                                Text('${((val) * 100).round()}%',
                                    style:
                                        Theme.of(context).textTheme.headline
                                        .copyWith(color: Colors.white)),
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
