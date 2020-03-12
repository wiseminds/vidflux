import 'package:flutter/material.dart';
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
VideoPlayerController _controller; 
final String url = 'https://cdn.videvo.net/videvo_files/video/free/2019-04/originalContent/190408_01_Alaska_Landscapes1_09.mp4';

 @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
           VidFlux(videoPlayerController: _controller)
          ],
        ),
      
     );
  }
}
