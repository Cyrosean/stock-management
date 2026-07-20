/// Central place for API configuration.
///
/// Your PC's local IP changes between sessions (e.g. when you reconnect to
/// WiFi). Instead of editing every screen file, just update [baseUrl] here.
///
/// To find your current IP on Windows: open Command Prompt and run
/// `ipconfig`, then look for "IPv4 Address" under your active adapter.
///
/// Tip: setting a static/reserved IP for your PC in your router settings
/// means you may never have to touch this again.
class ApiConfig {
  static const String baseUrl = "http://10.168.255.61/wholesale_api";
}
