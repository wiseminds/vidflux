import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';


class AutoOrientationBuilder extends StatefulWidget {
  final bool enabled;
  final List<DeviceOrientation> exitOrientations;
  final List<SystemUiOverlay> exitOverlays;
  const AutoOrientationBuilder({Key key, this.enabled = false, this.exitOverlays, this.exitOrientations}) : super(key: key);

  @override
  _AutoOrientationBuilderState createState() => _AutoOrientationBuilderState();
}

class _AutoOrientationBuilderState extends State<AutoOrientationBuilder> {
  
  @override
  Widget build(BuildContext context) {print('orientation');
    return  WillPopScope(
      onWillPop: () async {
    SystemChrome.setEnabledSystemUIOverlays( widget.exitOverlays ?? [SystemUiOverlay.bottom, SystemUiOverlay.top]);
     SystemChrome.setPreferredOrientations(widget.exitOrientations ?? [DeviceOrientation.portraitUp]);
    return true;
      },
          child: widget.enabled
          ? NativeDeviceOrientationReader(
              builder: (context) {
                NativeDeviceOrientation orientation =
                    NativeDeviceOrientationReader.orientation(context);
                // print("Received new orientation: $orientation");
                changeOrientation(orientation);
                return SizedBox();
              },
              useSensor: true,
            )
          : null,
    );
  }

  changeOrientation(NativeDeviceOrientation orientation) {
    List<DeviceOrientation> or = [];
    bool removeNavbar = false;
    switch (orientation) {
      case NativeDeviceOrientation.landscapeLeft:
        or = [DeviceOrientation.landscapeLeft];
        removeNavbar = true;
        break;
      case NativeDeviceOrientation.landscapeRight:
        or = [DeviceOrientation.landscapeRight];
        removeNavbar = true;
        break;
      case NativeDeviceOrientation.portraitDown:
        or = [DeviceOrientation.portraitDown];
        break;
      case NativeDeviceOrientation.portraitUp:
        or = [DeviceOrientation.portraitUp];
        break;
      default:
    }
    SystemChrome.setPreferredOrientations(or);
    if (removeNavbar)
      SystemChrome.setEnabledSystemUIOverlays([]);
    else
      SystemChrome.setEnabledSystemUIOverlays(
          [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  }
}
