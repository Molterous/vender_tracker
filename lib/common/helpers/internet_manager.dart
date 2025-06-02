import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' as foundation;

class InternetManager {
  InternetManager._();

  static final _instance = InternetManager._();

  static InternetManager get instance => _instance;
  final _connectivity = Connectivity();

  final String streamKey = 'StatusResult';
  final String connectivityKey = 'ConnectivityResult';
  final String _tag = 'InternetManager';

  StreamController? _controller;

  // remember to call initialiseStream() before
  // using getStream() otherwise it will be null.
  Stream<dynamic>? getStream() {
    return _controller?.stream;
  }

  // Initialize stream, in case of continuous listening of network state
  // and remember to dispose stream when work is done.
  void initialiseStream() async {
    _controller = StreamController.broadcast();
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _checkStatus(result);

    _connectivity.onConnectivityChanged.listen((result) {
      _print(result, 'initialiseStream() listener');
      if (_controller != null) _checkStatus(result);
    });
  }

  // In case of only one time value, this function returns a future of bool
  Future<bool> getNetworkStatus() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _print(result, 'getNetworkStatus()');
    return await _checkStatus(result);
  }

  // This functions tried to ping demo server after checking the mobile state
  // to check if the network is actually working or not.
  // Simply to overcome 'Connected but No Internet' state in android.
  Future<bool> _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;

    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      try {
        final result = await InternetAddress.lookup('google.com');
        isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (e) {
        isOnline = false;
      } catch (_) {
        isOnline = false;
      }
    }

    _controller?.sink.add({streamKey: isOnline, connectivityKey: result});

    _print(isOnline, '_checkStatus()');
    return isOnline;
  }

  void disposeStream() {
    _controller?.close();
    _controller = null;
  }

  void _print(dynamic data, String funName) {
    try {
      if (!foundation.kReleaseMode) {
        print('$_tag $funName -> ${data.toString()}');
      }
    } catch (_) {}
  }
}
