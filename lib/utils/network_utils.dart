import 'dart:io';

class NetworkUtils {
  static Future<String> getIpAddress() async {
    String ip = "Could not determine IP";
    try {
      for (var interface in await NetworkInterface.list(includeLoopback: false, type: InternetAddressType.IPv4)) {
        if (interface.addresses.isNotEmpty) {
          ip = interface.addresses.first.address;
          // Basic heuristic: prefer non-loopback, non-common private ranges if multiple are found.
          // This part might need more sophisticated logic for complex network setups.
          // For typical local Wi-Fi, the first non-loopback IPv4 is usually correct.
          if (!ip.startsWith("127.")) { // Found a non-loopback
             break; // Take the first non-loopback IPv4
          }
        }
      }
      // Fallback if only loopback or no preferred IP was found initially
      if (ip == "Could not determine IP" || ip.startsWith("127.")) {
        for (var interface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
            if (interface.addresses.isNotEmpty && interface.addresses.first.address != "127.0.0.1") {
                ip = interface.addresses.first.address;
                break;
            }
        }
      }
       // If still no IP, try any IPv4
      if (ip == "Could not determine IP") {
        for (var interface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
            if (interface.addresses.isNotEmpty) {
                ip = interface.addresses.first.address;
                break;
            }
        }
      }

    } catch (e) {
      // Return error message or rethrow, depending on desired error handling
      return "Error getting IP: $e";
    }
    return ip;
  }
}
