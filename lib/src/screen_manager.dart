///Ekeh Wisdom ekeh.wisdom@gmail.com
///c2019
///Sun Nov 24 2019
import 'package:screen/screen.dart';

class ScreenManager {
  Future<double> getBrightness() async => await Screen.brightness;

  Future<double> setBrightness(double brightness) async =>
      await Screen.setBrightness(brightness);

  Future<bool> isKeptOn() async => await Screen.isKeptOn;

  Future<bool> keepOn(bool on) async => await Screen.keepOn(on);
}
