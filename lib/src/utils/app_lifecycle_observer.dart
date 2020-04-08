///Ekeh Wisdom ekeh.wisdom@gmail.com
///c2019
///Sun Nov 24 2019
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class AppLifeCycleObserver with WidgetsBindingObserver {
  /// list of callbacks to be called when the  application is
  /// not currently visible to the user, not responding to user
  /// input, and running in the background.
  List<CallbackItem> _onPaused = [];

  /// list of callbacks to be called when the  application is
  ///The application is in an inactive state and is not receiving user input.
  ///On iOS, this state corresponds to an app or the Flutter host view running
  ///in the foreground inactive state. Apps transition to this state when in a
  /// phone call, responding to a TouchID request, when entering the app switcher
  /// or the control center, or when the UIViewController hosting the Flutter app
  /// is transitioning.
  ///On Android, this corresponds to an app or the Flutter host view running in the
  ///foreground inactive state. Apps transition to this state when another activity
  ///is focused, such as a split-screen app, a phone call, a picture-in-picture app,
  ///a system dialog, or another window.
  List<CallbackItem> _onInactive = [];

  /// list of callbacks to be called when the  application is
  ///Still hosted on a flutter engine but is detached from any host views.
  ///When the application is in this state, the engine is running without a view.
  ///It can either be in the progress of attaching a view when engine was first initializes,
  ///or after the view being destroyed due to a Navigator pop.
  List<CallbackItem> _onDetached = [];

  /// list of callbacks to be called when the  application comes
  /// back to the foreground and is responding to user
  List<CallbackItem> _onResumed = [];

  void initialize() {
    if (kDebugMode)
      print('App lifecycle state initializing');
    isInitialized = true;
    WidgetsBinding.instance.addObserver(this);
  }
  bool isInitialized = false;
  AppLifecycleState _currentState;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode)
      print('App lifecycle state changed from $_currentState to $state  pause: ${_onPaused.length},  resume:${_onResumed.length},  inactive:${_onInactive.length},  detach:${_onDetached.length}');
    _currentState = state;
    switch (state) {
      case AppLifecycleState.paused:
        for (var item in _onPaused) _runFun(item.fun);
        break;
      case AppLifecycleState.resumed:
        for (var item in _onResumed) _runFun(item.fun);
        break;
      case AppLifecycleState.inactive:
        for (var item in _onInactive) _runFun(item.fun);
        break;
      case AppLifecycleState.detached:
        for (var item in _onDetached) _runFun(item.fun);
        break;
      default:
    }
  }

  void removeCallbacks(int tag) {
    dispose();
     if (kDebugMode)
      print('App lifecycle state removing callbacks $tag');
    _onPaused.removeWhere((callback) => callback.tag == tag);
    _onResumed.removeWhere((callback) => callback.tag == tag);
    _onDetached.removeWhere((callback) => callback.tag == tag);
    _onInactive.removeWhere((callback) => callback.tag == tag);
    initialize();
  }

  void addCallbacks(List<CallbackItem> callbacks) {
    dispose();
   
    // if(!isInitialized) initialize();
    for (var callback in callbacks) {
       if (kDebugMode)
      print('App lifecycle state adding callbacks ${callback.tag} ');
      switch (callback.state) {
        case AppLifecycleState.paused:
          _onPaused.add(callback);
          break;
        case AppLifecycleState.resumed:
          _onResumed.add(callback);
          break;
        case AppLifecycleState.inactive:
          _onInactive.add(callback);
          break;
        case AppLifecycleState.detached:
          _onDetached.add(callback);
          break;
        default:
      }
    }
    initialize();
  }

  void _runFun(VoidCallback fun) {
    try {
      fun();
    } catch (err) {
      if (kDebugMode)
        print('an error occured in running lifecycle callback $err');
    }
  }

  void dispose() {
    if (kDebugMode)
      print('App lifecycle state disposing');
    WidgetsBinding.instance.removeObserver(this);
  }
}

class CallbackItem {
  final VoidCallback fun;
  final int tag;
  final AppLifecycleState state;
  CallbackItem(this.fun, this.tag, this.state);
}
