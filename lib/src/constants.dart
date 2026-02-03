class Constants {
  static const String serverUrl = 'https://api.lab.amplitude.com';
  static const String flagsServerUrl = 'https://flag.lab.amplitude.com';
  static const ServerZone serverZone = ServerZone.us;
  static const int fetchTimeoutMillis = 10000;
}

enum ServerZone { us, eu }
