///Ekeh Wisdom ekeh.wisdom@gmail.com
///c2019
///Sun Nov 24 2019
library vidflux;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';


import 'src/video_controls.dart';
import 'src/playpause_button.dart';
import 'src/screen_manager.dart';

const IS_DEBUG_MODE = kDebugMode;

/// ```
/// A widget that plays video given the video url, this is not suitable for youtube videos see
/// youtube_player_flutter for playing youtube videos
///```
class VidFlux extends StatefulWidget {
  final bool isFullscreen;
  final VideoPlayerController videoPlayerController;
  final TouchDetector _touchDetector;

  /// a widget to show when the video is in error state
  final Widget errorWidget;

  /// a widget to show when the video is in error state
  final Widget loadingIndicator;

/// number of times to re initialize the video when a playback error occurs
  final int retry;

/// if true the video automatically starts playing once initialized
  final bool autoPlay;


  final List<DeviceOrientation> fullScreenOrientations;

  VidFlux({
    Key key,
    @required this.videoPlayerController,
    this.isFullscreen = false,
    this.errorWidget,
    this.loadingIndicator,
    this.retry = 5, this.autoPlay = false, this.fullScreenOrientations,
  })  : _touchDetector =
            TouchDetector(videoPlayerController, isFullscreen ?? false),
        super(key: key);
  @override
  VidFluxState createState() => VidFluxState();
}

class VidFluxState extends State<VidFlux>{
  VideoPlayerController _videoPlayerController;
  bool isLoading = true;
  bool isInitializing = true;
  int retryInit;
  StateNotifier _stateNotifier;

  void _errorListener() {
    if (widget.videoPlayerController.value.hasError) {
      if (IS_DEBUG_MODE)
        print(
            'error listener. $retryInit   .${_videoPlayerController.value?.errorDescription}');

      if (retryInit > 0) {
        retryInit--;
        _videoPlayerController?.value?.copyWith();
        if (_videoPlayerController.value?.errorDescription?.contains('404') ??
            false) {
          _stateNotifier.setLoading(false);
          _stateNotifier.setHasError(
              true, _videoPlayerController.value?.errorDescription);
          retryInit = widget.retry;
          setState(() {});
        } else
          initController();
      } else {
        _stateNotifier.setLoading(false);
        _stateNotifier.setHasError(
            true, _videoPlayerController.value?.errorDescription);
        retryInit = widget.retry;
        setState(() {});
      }
    }
  }


  @override
  void initState() {
    retryInit = widget.retry;
    _videoPlayerController = widget.videoPlayerController;
    _stateNotifier = StateNotifier();
    if (!_videoPlayerController.value.initialized) initController();
    _videoPlayerController.addListener(_errorListener);
    if(widget.autoPlay || widget._touchDetector.isFullScreen) _videoPlayerController.play();
    super.initState();
  }


  void initController() {
    _stateNotifier.setLoading(true);
    _videoPlayerController?.value?.copyWith();
    _stateNotifier.setHasError(false);
    if (IS_DEBUG_MODE) print('init .........................$retryInit');
    _videoPlayerController
      ..initialize().then((_) {
        isInitializing = false;
        if (IS_DEBUG_MODE)
          print('success init .........................$retryInit');
        isLoading = false;
        _stateNotifier.setLoading(false);
        _videoPlayerController?.value?.copyWith();
        _stateNotifier.setHasError(false);
        retryInit = widget.retry;
        _videoPlayerController.play();
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_errorListener);
    ScreenManager().keepOn(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {print('touch gesture detected');
          // if (_videoPlayerController.value.isPlaying)
            widget._touchDetector
                .toggleControl();
          // else if (!widget._touchDetector._showControls)
          //   widget._touchDetector.toggleControl(true);
        },
        // onHorizontalDragStart: (details) {
        //   _stateNotifier.setTakeAction(false);
        // },
        // onHorizontalDragEnd: (details) {
        //   _stateNotifier.setTakeAction(true);
        // },
        // onHorizontalDragCancel: () {
        //   _stateNotifier.setTakeAction(true);
        // },
        // onHorizontalDragUpdate: (details) async {
        // WidgetsBinding.instance.addPostFrameCallback((d) async {
        //   if ( _videoPlayerController.value.initialized) {
        //      _videoPlayerController.seekTo(
        //         await  _videoPlayerController?.position +
        //             Duration(seconds: (details.delta.dx > 1 ? 10 : -10)));

        //      _videoPlayerController?.play();
        //   }
        // });
        // },
        child: Container(
            color: Colors.black,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => widget._touchDetector),
                ChangeNotifierProvider(create: (_) => _stateNotifier)
              ],
              child: AspectRatio(
                  aspectRatio: (widget.isFullscreen &&
                          MediaQuery.of(context).orientation ==
                              Orientation.landscape)
                      ? (MediaQuery.of(context).size.width /
                          MediaQuery.of(context).size.height)
                      : _videoPlayerController.value.initialized
                          ? _videoPlayerController.value.aspectRatio
                          : 16 / 9,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Builder(builder: (context)=> ScreenManagerWidget(_videoPlayerController)),
                      _videoPlayerController.value.initialized
                          ? VideoPlayer(_videoPlayerController)
                          : Container(
                              color: Colors.black,
                            ),
                      Center(child: LoadinIndicator(_videoPlayerController)),
                      if (_videoPlayerController.value.initialized)
                        PlayPauseButton(
                          controller: _videoPlayerController,
                        ),
                      if (_videoPlayerController.value.initialized)
                        Container(
                            margin: EdgeInsets.only(bottom: 10),
                            alignment: Alignment.bottomCenter,
                            child: VideoControls(_videoPlayerController,
                                playerKey: widget.key, fullScreenOrientations: widget.fullScreenOrientations,
                                isFullScreen: widget.isFullscreen)),
                     widget.errorWidget ?? ErrorWidget(initController: initController),
                      // VideoProgressIndicator(_videoPlayerController, allowScrubbing: true,)
                    ],
                  )),
            )));
    // Chewie(controller: _playerController);
  }
}

class StateNotifier with ChangeNotifier {
  bool _isLoading;
  bool _hasError;
  bool takeAction;
  String message;
  Duration position;
  StateNotifier()
      : _isLoading = true,
        _hasError = false,
        takeAction = true,
        position = Duration.zero;

  get isLoading => _isLoading;
  get hasError => _hasError;
  void setHasError(bool val, [String message]) {
    _hasError = val;
    this.message = _formatMessage(message);
    notifyListeners();
  }

  void setTakeAction(bool val) {
    takeAction = val;
    notifyListeners();
  }

  void setPosition(Duration val) {
    position = val;
    notifyListeners();
  }

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  String _formatMessage([String message]) {
    if (message == null) return null;
    if (message.contains('HttpDataSourceException'))
      return 'An Error occured playing video, please check your internet connection';
    if (message.contains('404'))
      return 'This Channel is not currently Streaming Please contact channel Admin';
    return 'An Error occured playing video';
  }
}

class LoadinIndicator extends StatefulWidget {
  final VideoPlayerController _controller;

  const LoadinIndicator(this._controller);
  @override
  _LoadinIndicatorState createState() => _LoadinIndicatorState();
}

class _LoadinIndicatorState extends State<LoadinIndicator> {
  bool isBuferring = true;
  Duration position = Duration.zero;
  @override
  void initState() {
    if (IS_DEBUG_MODE) print('init loader');
    widget._controller?.addListener(_buferingListener);
    // isBuferring = widget.isLoading;
    position = widget._controller?.value?.position ?? Duration.zero;
    super.initState();
  }

  @override
  void dispose() {
    widget._controller.removeListener(_buferingListener);
    super.dispose();
  }

  int _counter = 0;
  void _buferingListener() {
    // print('counter..........................$_counter');

    if (_counter > 10) {
      _counter = 0;
      if (Provider.of<StateNotifier>(context, listen: false).position ==
          widget._controller?.value?.position) {
        if (!Provider.of<StateNotifier>(context, listen: false).isLoading &&
            Provider.of<StateNotifier>(context, listen: false).takeAction)
          Provider.of<StateNotifier>(context, listen: false).setLoading(true);
        if (!(widget._controller?.value?.isPlaying ?? false))
          Provider.of<StateNotifier>(context, listen: false).setLoading(false);
      } else {
        if (Provider.of<StateNotifier>(context, listen: false).isLoading &&
            Provider.of<StateNotifier>(context, listen: false).takeAction)
          Provider.of<StateNotifier>(context, listen: false).setLoading(false);
        if (!(widget._controller?.value?.isPlaying ?? false))
          Provider.of<StateNotifier>(context, listen: false).setLoading(false);
      }
      if (Provider.of<StateNotifier>(context, listen: false).takeAction)
        Provider.of<StateNotifier>(context, listen: false)
            .setPosition(widget._controller?.value?.position);
    }
    //  if (_counter == 1)
    // Provider.of<StateNotifier>(context).setPosition(widget._controller?.value?.position);
    _counter++;
    if (widget._controller?.value?.isBuffering ?? true)
      Provider.of<StateNotifier>(context, listen: false).setLoading(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StateNotifier>(
        builder: (context, state, _) =>
            state._isLoading || (widget._controller?.value?.isBuffering ?? true)
                ? Container(
                    width: 70.0,
                    height: 70.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : SizedBox.shrink());
  }
}

class ErrorWidget extends StatefulWidget {
  final VoidCallback initController;

  const ErrorWidget({Key key, this.initController}) : super(key: key);
  @override
  _ErrorWidgetState createState() => _ErrorWidgetState();
}

class _ErrorWidgetState extends State<ErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StateNotifier>(
        builder: (context, state, _) => state._hasError
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Text(
                      state.message ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                          letterSpacing: 2),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: RaisedButton(
                          color: Colors.white,
                          child: Text(
                            'Reload',
                            style: Theme.of(context)
                                .textTheme
                                .body1
                                .copyWith(color: Colors.black),
                          ),
                          onPressed: widget.initController),
                    ),
                    // Spacer(),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox.shrink());
  }
}

class TouchDetector with ChangeNotifier {
  final VideoPlayerController _playerController;
  bool _showControls = true;
  bool _isFullScreen;

  TouchDetector(this._playerController, this._isFullScreen)
      : _showControls = !_isFullScreen;

  VideoPlayerController get playerController => _playerController;
  bool get showControls => _showControls;
  bool get isFullScreen => _isFullScreen;

  set fullScreen(bool value) => _isFullScreen = value;
  void toggleControl() {
      _showControls = !_showControls;
      notifyListeners();
  }
}
