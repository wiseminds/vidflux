import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class TouchNotifier with ChangeNotifier {
  final BehaviorSubject<bool> _touchSubject = BehaviorSubject.seeded(false);
  bool get value => _touchSubject.value;
  void toggleControl() {
    _touchSubject.add(!value);
    notifyListeners();
//   }
  }

  void setValue(bool value) {
    _touchSubject.add(value);
    notifyListeners();
  }
}