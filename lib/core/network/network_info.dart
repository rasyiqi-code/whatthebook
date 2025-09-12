import 'package:flutter/foundation.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // For web platforms, we assume connection is available
    // since the app wouldn't load without internet
    if (kIsWeb) {
      return true;
    }

    // For other platforms, we can implement actual network checking
    // For now, return true as a fallback
    return true;
  }
}
