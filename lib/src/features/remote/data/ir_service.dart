import 'package:flutter/services.dart';

class IrService {
  static const _channel = MethodChannel('com.raaghav.uniremote/ir');

  /// Returns true if the device has an IR blaster.
  static Future<bool> hasIrBlaster() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasIrBlaster');
      return result ?? false;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('IrService.hasIrBlaster error: ${e.message}');
      return false;
    }
  }

  /// Transmits the IR pattern at the given frequency.
  /// [freqHz] — carrier frequency in Hz (e.g. 38000 for NEC, 40000 for SIRC)
  /// [pattern] — on/off durations in microseconds
  /// Returns true on success.
  static Future<bool> transmit(int freqHz, List<int> pattern) async {
    try {
      final result = await _channel.invokeMethod<bool>('transmit', {
        'freqHz': freqHz,
        'pattern': pattern,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('IrService.transmit error: ${e.message}');
      return false;
    }
  }
}
