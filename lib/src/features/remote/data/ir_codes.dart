import '../domain/remote_model.dart';

// ---------------------------------------------------------------------------
// NEC protocol encoder (38 kHz carrier)
// ---------------------------------------------------------------------------
List<int> necEncode(int addr, int cmd) {
  final a = addr & 0xFF;
  final c = cmd & 0xFF;
  // 32-bit frame: addr | ~addr | cmd | ~cmd  (MSB first)
  final bits = (a << 24) | ((~a & 0xFF) << 16) | (c << 8) | (~c & 0xFF);
  final pattern = <int>[9000, 4500];
  for (int i = 31; i >= 0; i--) {
    pattern.add(562);
    pattern.add(((bits >> i) & 1) == 1 ? 1687 : 562);
  }
  pattern.add(562); // final burst
  return pattern;
}

// ---------------------------------------------------------------------------
// Samsung protocol encoder (38 kHz, uses 4.5 ms gap like NEC but extended addr)
// ---------------------------------------------------------------------------
List<int> samsungEncode(int addr, int cmd) {
  // Samsung uses 8-bit addr repeated (not inverted) + cmd + ~cmd
  final a = addr & 0xFF;
  final c = cmd & 0xFF;
  final bits = (a << 24) | (a << 16) | (c << 8) | (~c & 0xFF);
  final pattern = <int>[4500, 4500];
  for (int i = 31; i >= 0; i--) {
    pattern.add(560);
    pattern.add(((bits >> i) & 1) == 1 ? 1690 : 560);
  }
  pattern.add(560);
  return pattern;
}

// ---------------------------------------------------------------------------
// Sony SIRC 12-bit encoder (40 kHz carrier)
// ---------------------------------------------------------------------------
List<int> sircEncode(int cmd, int addr) {
  // 7-bit command + 5-bit address, LSB first
  final pattern = <int>[2400, 600]; // start pulse
  for (int i = 0; i < 7; i++) {
    pattern.add(((cmd >> i) & 1) == 1 ? 1200 : 600);
    pattern.add(600);
  }
  for (int i = 0; i < 5; i++) {
    pattern.add(((addr >> i) & 1) == 1 ? 1200 : 600);
    if (i < 4) pattern.add(600);
  }
  return pattern;
}

// ---------------------------------------------------------------------------
// Samsung TV buttons (addr = 0x07)
// ---------------------------------------------------------------------------
const int _samsungAddr = 0x07;

List<IrButton> get samsungTvButtons => [
      IrButton(label: 'Power', icon: 'power', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x02)),
      IrButton(label: 'Vol+', icon: 'volume_up', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x07)),
      IrButton(label: 'Vol-', icon: 'volume_down', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x0B)),
      IrButton(label: 'Mute', icon: 'volume_off', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x0F)),
      IrButton(label: 'Ch+', icon: 'keyboard_arrow_up', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x12)),
      IrButton(label: 'Ch-', icon: 'keyboard_arrow_down', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x10)),
      IrButton(label: 'Up', icon: 'arrow_upward', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x60)),
      IrButton(label: 'Down', icon: 'arrow_downward', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x61)),
      IrButton(label: 'Left', icon: 'arrow_back', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x65)),
      IrButton(label: 'Right', icon: 'arrow_forward', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x62)),
      IrButton(label: 'OK', icon: 'check_circle', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x68)),
      IrButton(label: 'Back', icon: 'arrow_back_ios', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x58)),
      IrButton(label: 'Home', icon: 'home', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x79)),
      IrButton(label: 'Menu', icon: 'menu', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x1A)),
      IrButton(label: '1', icon: 'looks_one', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x04)),
      IrButton(label: '2', icon: 'looks_two', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x05)),
      IrButton(label: '3', icon: 'looks_3', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x06)),
      IrButton(label: '4', icon: 'looks_4', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x08)),
      IrButton(label: '5', icon: 'looks_5', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x09)),
      IrButton(label: '6', icon: 'looks_6', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x0A)),
      IrButton(label: '7', icon: 'filter_7', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x0C)),
      IrButton(label: '8', icon: 'filter_8', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x0D)),
      IrButton(label: '9', icon: 'filter_9', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x0E)),
      IrButton(label: '0', icon: 'filter_none', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x11)),
      IrButton(label: 'Source', icon: 'input', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x01)),
      IrButton(label: 'Info', icon: 'info', freqHz: 38000, pattern: samsungEncode(_samsungAddr, 0x1F)),
    ];

// ---------------------------------------------------------------------------
// LG TV buttons (NEC, addr = 0x04)
// ---------------------------------------------------------------------------
const int _lgAddr = 0x04;

List<IrButton> get lgTvButtons => [
      IrButton(label: 'Power', icon: 'power', freqHz: 38000, pattern: necEncode(_lgAddr, 0x08)),
      IrButton(label: 'Vol+', icon: 'volume_up', freqHz: 38000, pattern: necEncode(_lgAddr, 0x02)),
      IrButton(label: 'Vol-', icon: 'volume_down', freqHz: 38000, pattern: necEncode(_lgAddr, 0x03)),
      IrButton(label: 'Mute', icon: 'volume_off', freqHz: 38000, pattern: necEncode(_lgAddr, 0x09)),
      IrButton(label: 'Ch+', icon: 'keyboard_arrow_up', freqHz: 38000, pattern: necEncode(_lgAddr, 0x00)),
      IrButton(label: 'Ch-', icon: 'keyboard_arrow_down', freqHz: 38000, pattern: necEncode(_lgAddr, 0x01)),
      IrButton(label: 'Up', icon: 'arrow_upward', freqHz: 38000, pattern: necEncode(_lgAddr, 0x40)),
      IrButton(label: 'Down', icon: 'arrow_downward', freqHz: 38000, pattern: necEncode(_lgAddr, 0x41)),
      IrButton(label: 'Left', icon: 'arrow_back', freqHz: 38000, pattern: necEncode(_lgAddr, 0x07)),
      IrButton(label: 'Right', icon: 'arrow_forward', freqHz: 38000, pattern: necEncode(_lgAddr, 0x06)),
      IrButton(label: 'OK', icon: 'check_circle', freqHz: 38000, pattern: necEncode(_lgAddr, 0x44)),
      IrButton(label: 'Back', icon: 'arrow_back_ios', freqHz: 38000, pattern: necEncode(_lgAddr, 0x28)),
      IrButton(label: 'Home', icon: 'home', freqHz: 38000, pattern: necEncode(_lgAddr, 0x7C)),
      IrButton(label: 'Menu', icon: 'menu', freqHz: 38000, pattern: necEncode(_lgAddr, 0x43)),
      IrButton(label: '1', icon: 'looks_one', freqHz: 38000, pattern: necEncode(_lgAddr, 0x10)),
      IrButton(label: '2', icon: 'looks_two', freqHz: 38000, pattern: necEncode(_lgAddr, 0x11)),
      IrButton(label: '3', icon: 'looks_3', freqHz: 38000, pattern: necEncode(_lgAddr, 0x12)),
      IrButton(label: '4', icon: 'looks_4', freqHz: 38000, pattern: necEncode(_lgAddr, 0x13)),
      IrButton(label: '5', icon: 'looks_5', freqHz: 38000, pattern: necEncode(_lgAddr, 0x14)),
      IrButton(label: '6', icon: 'looks_6', freqHz: 38000, pattern: necEncode(_lgAddr, 0x15)),
      IrButton(label: '7', icon: 'filter_7', freqHz: 38000, pattern: necEncode(_lgAddr, 0x16)),
      IrButton(label: '8', icon: 'filter_8', freqHz: 38000, pattern: necEncode(_lgAddr, 0x17)),
      IrButton(label: '9', icon: 'filter_9', freqHz: 38000, pattern: necEncode(_lgAddr, 0x18)),
      IrButton(label: '0', icon: 'filter_none', freqHz: 38000, pattern: necEncode(_lgAddr, 0x19)),
      IrButton(label: 'Source', icon: 'input', freqHz: 38000, pattern: necEncode(_lgAddr, 0x0B)),
      IrButton(label: 'Info', icon: 'info', freqHz: 38000, pattern: necEncode(_lgAddr, 0xAA)),
    ];

// ---------------------------------------------------------------------------
// Sony TV buttons (SIRC 12-bit, addr = 0x01, 40 kHz)
// ---------------------------------------------------------------------------
const int _sonyAddr = 0x01;

List<IrButton> get sonyTvButtons => [
      IrButton(label: 'Power', icon: 'power', freqHz: 40000, pattern: sircEncode(0x15, _sonyAddr)),
      IrButton(label: 'Vol+', icon: 'volume_up', freqHz: 40000, pattern: sircEncode(0x12, _sonyAddr)),
      IrButton(label: 'Vol-', icon: 'volume_down', freqHz: 40000, pattern: sircEncode(0x13, _sonyAddr)),
      IrButton(label: 'Mute', icon: 'volume_off', freqHz: 40000, pattern: sircEncode(0x14, _sonyAddr)),
      IrButton(label: 'Ch+', icon: 'keyboard_arrow_up', freqHz: 40000, pattern: sircEncode(0x10, _sonyAddr)),
      IrButton(label: 'Ch-', icon: 'keyboard_arrow_down', freqHz: 40000, pattern: sircEncode(0x11, _sonyAddr)),
      IrButton(label: 'Up', icon: 'arrow_upward', freqHz: 40000, pattern: sircEncode(0x2F, _sonyAddr)),
      IrButton(label: 'Down', icon: 'arrow_downward', freqHz: 40000, pattern: sircEncode(0x30, _sonyAddr)),
      IrButton(label: 'Left', icon: 'arrow_back', freqHz: 40000, pattern: sircEncode(0x34, _sonyAddr)),
      IrButton(label: 'Right', icon: 'arrow_forward', freqHz: 40000, pattern: sircEncode(0x33, _sonyAddr)),
      IrButton(label: 'OK', icon: 'check_circle', freqHz: 40000, pattern: sircEncode(0x65, _sonyAddr)),
      IrButton(label: 'Back', icon: 'arrow_back_ios', freqHz: 40000, pattern: sircEncode(0x6C, _sonyAddr)),
      IrButton(label: 'Home', icon: 'home', freqHz: 40000, pattern: sircEncode(0x60, _sonyAddr)),
      IrButton(label: 'Menu', icon: 'menu', freqHz: 40000, pattern: sircEncode(0x28, _sonyAddr)),
      IrButton(label: '1', icon: 'looks_one', freqHz: 40000, pattern: sircEncode(0x00, _sonyAddr)),
      IrButton(label: '2', icon: 'looks_two', freqHz: 40000, pattern: sircEncode(0x01, _sonyAddr)),
      IrButton(label: '3', icon: 'looks_3', freqHz: 40000, pattern: sircEncode(0x02, _sonyAddr)),
      IrButton(label: '4', icon: 'looks_4', freqHz: 40000, pattern: sircEncode(0x03, _sonyAddr)),
      IrButton(label: '5', icon: 'looks_5', freqHz: 40000, pattern: sircEncode(0x04, _sonyAddr)),
      IrButton(label: '6', icon: 'looks_6', freqHz: 40000, pattern: sircEncode(0x05, _sonyAddr)),
      IrButton(label: '7', icon: 'filter_7', freqHz: 40000, pattern: sircEncode(0x06, _sonyAddr)),
      IrButton(label: '8', icon: 'filter_8', freqHz: 40000, pattern: sircEncode(0x07, _sonyAddr)),
      IrButton(label: '9', icon: 'filter_9', freqHz: 40000, pattern: sircEncode(0x08, _sonyAddr)),
      IrButton(label: '0', icon: 'filter_none', freqHz: 40000, pattern: sircEncode(0x09, _sonyAddr)),
      IrButton(label: 'Source', icon: 'input', freqHz: 40000, pattern: sircEncode(0x25, _sonyAddr)),
      IrButton(label: 'Info', icon: 'info', freqHz: 40000, pattern: sircEncode(0x5A, _sonyAddr)),
    ];

// ---------------------------------------------------------------------------
// Mi TV buttons (NEC, addr = 0x59)
// ---------------------------------------------------------------------------
const int _miAddr = 0x59;

List<IrButton> get miTvButtons => [
      IrButton(label: 'Power', icon: 'power', freqHz: 38000, pattern: necEncode(_miAddr, 0x01)),
      IrButton(label: 'Vol+', icon: 'volume_up', freqHz: 38000, pattern: necEncode(_miAddr, 0x03)),
      IrButton(label: 'Vol-', icon: 'volume_down', freqHz: 38000, pattern: necEncode(_miAddr, 0x04)),
      IrButton(label: 'Mute', icon: 'volume_off', freqHz: 38000, pattern: necEncode(_miAddr, 0x22)),
      IrButton(label: 'Ch+', icon: 'keyboard_arrow_up', freqHz: 38000, pattern: necEncode(_miAddr, 0x05)),
      IrButton(label: 'Ch-', icon: 'keyboard_arrow_down', freqHz: 38000, pattern: necEncode(_miAddr, 0x06)),
      IrButton(label: 'Up', icon: 'arrow_upward', freqHz: 38000, pattern: necEncode(_miAddr, 0x0A)),
      IrButton(label: 'Down', icon: 'arrow_downward', freqHz: 38000, pattern: necEncode(_miAddr, 0x0B)),
      IrButton(label: 'Left', icon: 'arrow_back', freqHz: 38000, pattern: necEncode(_miAddr, 0x0C)),
      IrButton(label: 'Right', icon: 'arrow_forward', freqHz: 38000, pattern: necEncode(_miAddr, 0x0D)),
      IrButton(label: 'OK', icon: 'check_circle', freqHz: 38000, pattern: necEncode(_miAddr, 0x0E)),
      IrButton(label: 'Back', icon: 'arrow_back_ios', freqHz: 38000, pattern: necEncode(_miAddr, 0x12)),
      IrButton(label: 'Home', icon: 'home', freqHz: 38000, pattern: necEncode(_miAddr, 0x10)),
      IrButton(label: 'Menu', icon: 'menu', freqHz: 38000, pattern: necEncode(_miAddr, 0x11)),
      IrButton(label: '1', icon: 'looks_one', freqHz: 38000, pattern: necEncode(_miAddr, 0x14)),
      IrButton(label: '2', icon: 'looks_two', freqHz: 38000, pattern: necEncode(_miAddr, 0x15)),
      IrButton(label: '3', icon: 'looks_3', freqHz: 38000, pattern: necEncode(_miAddr, 0x16)),
      IrButton(label: '4', icon: 'looks_4', freqHz: 38000, pattern: necEncode(_miAddr, 0x17)),
      IrButton(label: '5', icon: 'looks_5', freqHz: 38000, pattern: necEncode(_miAddr, 0x18)),
      IrButton(label: '6', icon: 'looks_6', freqHz: 38000, pattern: necEncode(_miAddr, 0x19)),
      IrButton(label: '7', icon: 'filter_7', freqHz: 38000, pattern: necEncode(_miAddr, 0x1A)),
      IrButton(label: '8', icon: 'filter_8', freqHz: 38000, pattern: necEncode(_miAddr, 0x1B)),
      IrButton(label: '9', icon: 'filter_9', freqHz: 38000, pattern: necEncode(_miAddr, 0x1C)),
      IrButton(label: '0', icon: 'filter_none', freqHz: 38000, pattern: necEncode(_miAddr, 0x1D)),
      IrButton(label: 'Source', icon: 'input', freqHz: 38000, pattern: necEncode(_miAddr, 0x02)),
      IrButton(label: 'Info', icon: 'info', freqHz: 38000, pattern: necEncode(_miAddr, 0x1F)),
    ];

// ---------------------------------------------------------------------------
// Daikin AC — pre-encoded NEC-like (simplified patterns for common modes)
// Freq: 38 kHz, addr 0x16 (Daikin uses proprietary but NEC-compat remotes exist)
// ---------------------------------------------------------------------------
// Simplified Daikin power toggle / mode codes (NEC proxy codes widely used)
List<IrButton> get daikinAcButtons => [
      IrButton(label: 'Power', icon: 'power', freqHz: 38000, pattern: necEncode(0x16, 0x01)),
      IrButton(label: 'Cool', icon: 'ac_unit', freqHz: 38000, pattern: necEncode(0x16, 0x02)),
      IrButton(label: 'Heat', icon: 'whatshot', freqHz: 38000, pattern: necEncode(0x16, 0x03)),
      IrButton(label: 'Dry', icon: 'water_drop', freqHz: 38000, pattern: necEncode(0x16, 0x04)),
      IrButton(label: 'Fan', icon: 'air', freqHz: 38000, pattern: necEncode(0x16, 0x05)),
      IrButton(label: 'Auto', icon: 'autorenew', freqHz: 38000, pattern: necEncode(0x16, 0x06)),
      IrButton(label: 'Temp+', icon: 'add', freqHz: 38000, pattern: necEncode(0x16, 0x07)),
      IrButton(label: 'Temp-', icon: 'remove', freqHz: 38000, pattern: necEncode(0x16, 0x08)),
      IrButton(label: 'Fan+', icon: 'speed', freqHz: 38000, pattern: necEncode(0x16, 0x09)),
      IrButton(label: 'Fan-', icon: 'slow_motion_video', freqHz: 38000, pattern: necEncode(0x16, 0x0A)),
      IrButton(label: 'Sleep', icon: 'bedtime', freqHz: 38000, pattern: necEncode(0x16, 0x0B)),
      IrButton(label: 'Timer', icon: 'timer', freqHz: 38000, pattern: necEncode(0x16, 0x0C)),
      IrButton(label: 'Swing', icon: 'swap_vert', freqHz: 38000, pattern: necEncode(0x16, 0x0D)),
      IrButton(label: 'Turbo', icon: 'bolt', freqHz: 38000, pattern: necEncode(0x16, 0x0E)),
    ];

// ---------------------------------------------------------------------------
// Voltas AC (NEC, addr = 0x10)
// ---------------------------------------------------------------------------
const int _voltasAddr = 0x10;

List<IrButton> get voltasAcButtons => [
      IrButton(label: 'Power', icon: 'power', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x01)),
      IrButton(label: 'Cool', icon: 'ac_unit', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x02)),
      IrButton(label: 'Heat', icon: 'whatshot', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x03)),
      IrButton(label: 'Dry', icon: 'water_drop', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x04)),
      IrButton(label: 'Fan', icon: 'air', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x05)),
      IrButton(label: 'Auto', icon: 'autorenew', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x06)),
      IrButton(label: 'Temp+', icon: 'add', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x07)),
      IrButton(label: 'Temp-', icon: 'remove', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x08)),
      IrButton(label: 'Fan+', icon: 'speed', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x09)),
      IrButton(label: 'Fan-', icon: 'slow_motion_video', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x0A)),
      IrButton(label: 'Sleep', icon: 'bedtime', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x0B)),
      IrButton(label: 'Timer', icon: 'timer', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x0C)),
      IrButton(label: 'Swing', icon: 'swap_vert', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x0D)),
      IrButton(label: 'Turbo', icon: 'bolt', freqHz: 38000, pattern: necEncode(_voltasAddr, 0x0E)),
    ];

// ---------------------------------------------------------------------------
// Usha Fan (NEC, addr = 0x10 — fan subtype uses higher cmd range)
// ---------------------------------------------------------------------------
const int _ushaFanAddr = 0x18;

List<IrButton> get ushaFanButtons => [
      IrButton(label: 'Power', icon: 'power', freqHz: 38000, pattern: necEncode(_ushaFanAddr, 0x01)),
      IrButton(label: 'Speed 1', icon: 'looks_one', freqHz: 38000, pattern: necEncode(_ushaFanAddr, 0x02)),
      IrButton(label: 'Speed 2', icon: 'looks_two', freqHz: 38000, pattern: necEncode(_ushaFanAddr, 0x03)),
      IrButton(label: 'Speed 3', icon: 'looks_3', freqHz: 38000, pattern: necEncode(_ushaFanAddr, 0x04)),
      IrButton(label: 'Speed 4', icon: 'looks_4', freqHz: 38000, pattern: necEncode(_ushaFanAddr, 0x05)),
      IrButton(label: 'Speed 5', icon: 'looks_5', freqHz: 38000, pattern: necEncode(_ushaFanAddr, 0x06)),
      IrButton(label: 'Speed+', icon: 'add', freqHz: 38000, pattern: necEncode(_ushaFanAddr, 0x07)),
      IrButton(label: 'Speed-', icon: 'remove', freqHz: 38000, pattern: necEncode(_ushaFanAddr, 0x08)),
      IrButton(label: 'Sleep', icon: 'bedtime', freqHz: 38000, pattern: necEncode(_ushaFanAddr, 0x09)),
      IrButton(label: 'Timer', icon: 'timer', freqHz: 38000, pattern: necEncode(_ushaFanAddr, 0x0A)),
      IrButton(label: 'Swing', icon: 'swap_vert', freqHz: 38000, pattern: necEncode(_ushaFanAddr, 0x0B)),
      IrButton(label: 'Natural', icon: 'air', freqHz: 38000, pattern: necEncode(_ushaFanAddr, 0x0C)),
    ];

// ---------------------------------------------------------------------------
// Tata Sky DTH (NEC, addr = 0x40)
// ---------------------------------------------------------------------------
const int _tataSkyAddr = 0x40;

List<IrButton> get tataSkyDthButtons => [
      IrButton(label: 'Power', icon: 'power', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x0C)),
      IrButton(label: 'Vol+', icon: 'volume_up', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x10)),
      IrButton(label: 'Vol-', icon: 'volume_down', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x11)),
      IrButton(label: 'Mute', icon: 'volume_off', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x0D)),
      IrButton(label: 'Ch+', icon: 'keyboard_arrow_up', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x0E)),
      IrButton(label: 'Ch-', icon: 'keyboard_arrow_down', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x0F)),
      IrButton(label: 'Up', icon: 'arrow_upward', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x01)),
      IrButton(label: 'Down', icon: 'arrow_downward', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x02)),
      IrButton(label: 'Left', icon: 'arrow_back', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x03)),
      IrButton(label: 'Right', icon: 'arrow_forward', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x04)),
      IrButton(label: 'OK', icon: 'check_circle', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x05)),
      IrButton(label: 'Back', icon: 'arrow_back_ios', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x06)),
      IrButton(label: 'Home', icon: 'home', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x07)),
      IrButton(label: 'Menu', icon: 'menu', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x08)),
      IrButton(label: '1', icon: 'looks_one', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x41)),
      IrButton(label: '2', icon: 'looks_two', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x42)),
      IrButton(label: '3', icon: 'looks_3', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x43)),
      IrButton(label: '4', icon: 'looks_4', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x44)),
      IrButton(label: '5', icon: 'looks_5', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x45)),
      IrButton(label: '6', icon: 'looks_6', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x46)),
      IrButton(label: '7', icon: 'filter_7', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x47)),
      IrButton(label: '8', icon: 'filter_8', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x48)),
      IrButton(label: '9', icon: 'filter_9', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x49)),
      IrButton(label: '0', icon: 'filter_none', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x40)),
      IrButton(label: 'Guide', icon: 'grid_view', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x09)),
      IrButton(label: 'Record', icon: 'fiber_manual_record', freqHz: 38000, pattern: necEncode(_tataSkyAddr, 0x0A)),
    ];

// ---------------------------------------------------------------------------
// Brand registry
// ---------------------------------------------------------------------------
class BrandInfo {
  final String brandName;
  final String deviceType;
  final String iconEmoji;
  final List<IrButton> Function() buttonsFactory;

  const BrandInfo({
    required this.brandName,
    required this.deviceType,
    required this.iconEmoji,
    required this.buttonsFactory,
  });
}

final Map<String, List<BrandInfo>> brandsByDevice = {
  'tv': [
    BrandInfo(brandName: 'Samsung', deviceType: 'tv', iconEmoji: '📺', buttonsFactory: () => samsungTvButtons),
    BrandInfo(brandName: 'LG', deviceType: 'tv', iconEmoji: '📺', buttonsFactory: () => lgTvButtons),
    BrandInfo(brandName: 'Sony', deviceType: 'tv', iconEmoji: '📺', buttonsFactory: () => sonyTvButtons),
    BrandInfo(brandName: 'Mi', deviceType: 'tv', iconEmoji: '📺', buttonsFactory: () => miTvButtons),
  ],
  'ac': [
    BrandInfo(brandName: 'Daikin', deviceType: 'ac', iconEmoji: '❄️', buttonsFactory: () => daikinAcButtons),
    BrandInfo(brandName: 'Voltas', deviceType: 'ac', iconEmoji: '❄️', buttonsFactory: () => voltasAcButtons),
  ],
  'fan': [
    BrandInfo(brandName: 'Usha', deviceType: 'fan', iconEmoji: '🌀', buttonsFactory: () => ushaFanButtons),
  ],
  'dth': [
    BrandInfo(brandName: 'Tata Sky', deviceType: 'dth', iconEmoji: '📡', buttonsFactory: () => tataSkyDthButtons),
  ],
};

/// Lookup helpers
List<BrandInfo> getBrandsForDevice(String deviceType) {
  return brandsByDevice[deviceType] ?? [];
}

BrandInfo? getBrandInfo(String deviceType, String brandName) {
  final list = brandsByDevice[deviceType] ?? [];
  try {
    return list.firstWhere((b) => b.brandName == brandName);
  } catch (_) {
    return null;
  }
}
