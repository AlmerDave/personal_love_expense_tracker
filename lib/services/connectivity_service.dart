import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      return results.any((result) => 
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet
      );
    } catch (e) {
      return false;
    }
  }

  /// Stream connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }

  /// Get current connectivity status
  Future<String> getConnectionType() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    
    if (results.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else {
      return 'No Connection';
    }
  }
}
