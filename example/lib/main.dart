import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:vidflux/vidflux.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
VideoPlayerControlerProvider _controller; 
final GlobalKey<VidFluxState> _key = GlobalKey(debugLabel: 'vidflux');
final String url = 'https://bitmovin-a.akamaihd.net/content/playhouse-vr/mpds/105560.mpd';
final String url2 = 'https://bitmovin-a.akamaihd.net/content/playhouse-vr/mpds/105560.mpd';

 @override
  void initState() {
   
    super.initState();
    _controller = VideoPlayerControlerProvider(VideoPlayerController.network(url));
     _video =  VidFlux(key: _key,
             videoPlayerController: _controller.value, autoPlay: true, ) ;
  }
Widget _video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
          children: <Widget>[
            _video
          //  VidFlux(key: _controller.key,
          //    videoPlayerController: _controller.value, autoPlay: true, )
          ],
        ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        setState(() {
          _controller.value = VideoPlayerController.network(url2);
            _video =  VidFlux(key: _controller.key,
             videoPlayerController: _controller.value, autoPlay: true);
        });
        // _key.currentState.initState();
        // _key.currentState.setController(VideoPlayerController.network(url));
      },),
     );
  }
   
}

class VideoPlayerControlerProvider  {
VideoPlayerControlerProvider(VideoPlayerController _controller) : 
_controllers = [_controller], key = UniqueKey();
List<VideoPlayerController> _controllers;
Key key;
VideoPlayerController get value => _controllers[0];

 set value(VideoPlayerController newValue) {
   VideoPlayerController old = _controllers[0];
    if (old == newValue)
      return;
      _controllers = [newValue];
      key = UniqueKey();
      old.dispose();
  }


  

} 