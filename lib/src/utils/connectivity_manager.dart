import 'package:connectivity/connectivity.dart';

class ConnectivityManager {
  static Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi)
      return true;
    else
      return false;
  }

  static bool checkResult(ConnectivityResult result) =>
      (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi);

  static Stream<ConnectivityResult> get connectionStream =>
      Connectivity().onConnectivityChanged;
}
