import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme.dart';
import '../../data/ir_service.dart';
import '../../domain/remote_model.dart';
import '../widgets/ir_power_button.dart';
import '../widgets/remote_button.dart';

class RemoteScreen extends ConsumerStatefulWidget {
  final RemoteModel remote;

  const RemoteScreen({super.key, required this.remote});

  @override
  ConsumerState<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends ConsumerState<RemoteScreen> {
  int _acTemp = 24;
  int _acFanSpeed = 2; // 1-5
  String _acMode = 'Cool';
  bool _sending = false;

  IrButton? _findButton(String label) {
    try {
      return widget.remote.buttons
          .firstWhere((b) => b.label.toLowerCase() == label.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  Future<void> _send(String label) async {
    final btn = _findButton(label);
    if (btn == null) return;
    if (_sending) return;
    setState(() => _sending = true);
    await HapticFeedback.mediumImpact();
    await IrService.transmit(btn.freqHz, btn.pattern);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _sendPower() async {
    final btn = _findButton('Power');
    if (btn == null) return;
    await HapticFeedback.heavyImpact();
    await IrService.transmit(btn.freqHz, btn.pattern);
  }

  Widget _btn(String label, IconData icon, {Color? color, double size = 56}) {
    return RemoteButton(
      label: label,
      icon: icon,
      size: size,
      color: color,
      onPressed: () => _send(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.remote.name,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.onBackground,
              ),
            ),
            Text(
              widget.remote.brandName,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
            ),
            child: Text(
              widget.remote.deviceType.toUpperCase(),
              style: GoogleFonts.poppins(
                color: AppTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Power button
            Center(
              child: IrPowerButton(onPressed: _sendPower),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppTheme.dividerColor),
            const SizedBox(height: 12),
            // Device-specific controls
            _buildDeviceControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceControls() {
    switch (widget.remote.deviceType) {
      case 'tv':
      case 'dth':
        return _buildTvDthControls();
      case 'ac':
        return _buildAcControls();
      case 'fan':
        return _buildFanControls();
      default:
        return _buildTvDthControls();
    }
  }

  // -------------------------------------------------------------------------
  // TV / DTH controls
  // -------------------------------------------------------------------------
  Widget _buildTvDthControls() {
    return Column(
      children: [
        // Volume + Channel row
        _sectionLabel('Volume & Channel'),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _btn('Vol-', Icons.volume_down_rounded),
            _btn('Mute', Icons.volume_off_rounded, color: AppTheme.surfaceVariant),
            _btn('Vol+', Icons.volume_up_rounded),
            const SizedBox(width: 16),
            _btn('Ch+', Icons.keyboard_arrow_up_rounded),
            _btn('Ch-', Icons.keyboard_arrow_down_rounded),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 12),

        // D-Pad
        _sectionLabel('Navigation'),
        const SizedBox(height: 10),
        _buildDPad(),

        const SizedBox(height: 20),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 12),

        // Back / Home / Menu
        _sectionLabel('Controls'),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _btn('Back', Icons.arrow_back_ios_rounded),
            _btn('Home', Icons.home_rounded),
            _btn('Menu', Icons.menu_rounded),
            if (widget.remote.deviceType == 'tv')
              _btn('Source', Icons.input_rounded),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 12),

        // Number pad
        _sectionLabel('Number Pad'),
        const SizedBox(height: 10),
        _buildNumPad(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDPad() {
    const double btnSize = 54;
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center circle background
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceVariant,
              border: Border.all(color: AppTheme.dividerColor),
            ),
          ),
          // UP
          Positioned(
            top: 0,
            child: _btn('Up', Icons.keyboard_arrow_up_rounded, size: btnSize),
          ),
          // DOWN
          Positioned(
            bottom: 0,
            child: _btn('Down', Icons.keyboard_arrow_down_rounded, size: btnSize),
          ),
          // LEFT
          Positioned(
            left: 0,
            child: _btn('Left', Icons.keyboard_arrow_left_rounded, size: btnSize),
          ),
          // RIGHT
          Positioned(
            right: 0,
            child: _btn('Right', Icons.keyboard_arrow_right_rounded, size: btnSize),
          ),
          // OK
          RemoteButton(
            label: 'OK',
            icon: Icons.check_circle_outline_rounded,
            size: 60,
            color: AppTheme.primary.withOpacity(0.2),
            onPressed: () => _send('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildNumPad() {
    final numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', ''];
    final icons = [
      Icons.looks_one_rounded,
      Icons.looks_two_rounded,
      Icons.looks_3_rounded,
      Icons.looks_4_rounded,
      Icons.looks_5_rounded,
      Icons.looks_6_rounded,
      Icons.filter_7_rounded,
      Icons.filter_8_rounded,
      Icons.filter_9_rounded,
      null,
      Icons.filter_none_rounded,
      null,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final label = numbers[index];
        final icon = icons[index];
        if (label.isEmpty || icon == null) {
          return const SizedBox();
        }
        return Center(
          child: _btn(label, icon, size: 52),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // AC controls
  // -------------------------------------------------------------------------
  Widget _buildAcControls() {
    return Column(
      children: [
        // Temp display
        _sectionLabel('Temperature'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (_acTemp > 16) {
                    setState(() => _acTemp--);
                    _send('Temp-');
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surfaceVariant,
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: const Icon(Icons.remove_rounded,
                      color: AppTheme.secondary, size: 24),
                ),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    '$_acTemp°C',
                    style: GoogleFonts.poppins(
                      color: AppTheme.secondary,
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _acMode,
                    style: GoogleFonts.poppins(
                      color: AppTheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () {
                  if (_acTemp < 30) {
                    setState(() => _acTemp++);
                    _send('Temp+');
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surfaceVariant,
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: AppTheme.secondary, size: 24),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 12),

        // Mode selector
        _sectionLabel('Mode'),
        const SizedBox(height: 10),
        _buildModeSelector(),

        const SizedBox(height: 20),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 12),

        // Fan speed
        _sectionLabel('Fan Speed'),
        const SizedBox(height: 10),
        _buildFanSpeedRow(),

        const SizedBox(height: 20),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 12),

        // Extra controls
        _sectionLabel('Extra'),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _btn('Sleep', Icons.bedtime_rounded),
            _btn('Timer', Icons.timer_rounded),
            _btn('Swing', Icons.swap_vert_rounded),
            _btn('Turbo', Icons.bolt_rounded),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildModeSelector() {
    final modes = [
      ('Cool', Icons.ac_unit_rounded, AppTheme.secondary),
      ('Heat', Icons.whatshot_rounded, const Color(0xFFFF7043)),
      ('Dry', Icons.water_drop_rounded, const Color(0xFF66BB6A)),
      ('Fan', Icons.air_rounded, const Color(0xFF78909C)),
      ('Auto', Icons.autorenew_rounded, const Color(0xFFFFB74D)),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: modes.map((m) {
        final isSelected = _acMode == m.$1;
        return GestureDetector(
          onTap: () {
            setState(() => _acMode = m.$1);
            _send(m.$1);
          },
          child: Container(
            width: 56,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected
                  ? m.$3.withOpacity(0.2)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? m.$3 : AppTheme.dividerColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(m.$2, color: isSelected ? m.$3 : AppTheme.onSurface, size: 22),
                const SizedBox(height: 4),
                Text(
                  m.$1,
                  style: TextStyle(
                    color: isSelected ? m.$3 : AppTheme.onSurface,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFanSpeedRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RemoteButton(
          label: 'Fan-',
          icon: Icons.remove_rounded,
          size: 50,
          onPressed: () {
            if (_acFanSpeed > 1) {
              setState(() => _acFanSpeed--);
              _send('Fan-');
            }
          },
        ),
        const SizedBox(width: 16),
        ...List.generate(5, (i) {
          final speed = i + 1;
          final isActive = speed <= _acFanSpeed;
          return GestureDetector(
            onTap: () {
              setState(() => _acFanSpeed = speed);
            },
            child: Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppTheme.secondary.withOpacity(0.8)
                    : AppTheme.surfaceVariant,
                border: Border.all(
                  color: isActive ? AppTheme.secondary : AppTheme.dividerColor,
                ),
              ),
              child: Center(
                child: Text(
                  '$speed',
                  style: TextStyle(
                    color: isActive ? Colors.white : AppTheme.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 16),
        RemoteButton(
          label: 'Fan+',
          icon: Icons.add_rounded,
          size: 50,
          onPressed: () {
            if (_acFanSpeed < 5) {
              setState(() => _acFanSpeed++);
              _send('Fan+');
            }
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Fan controls
  // -------------------------------------------------------------------------
  Widget _buildFanControls() {
    return Column(
      children: [
        _sectionLabel('Speed'),
        const SizedBox(height: 12),
        // Speed presets
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final speed = i + 1;
            return _btn('Speed $speed', _speedIcon(speed));
          }),
        ),

        const SizedBox(height: 20),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 12),

        // Speed +/-
        _sectionLabel('Adjust'),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _btn('Speed-', Icons.remove_rounded, size: 60),
            _btn('Speed+', Icons.add_rounded, size: 60),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(color: AppTheme.dividerColor),
        const SizedBox(height: 12),

        _sectionLabel('Extra'),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _btn('Sleep', Icons.bedtime_rounded),
            _btn('Timer', Icons.timer_rounded),
            _btn('Swing', Icons.swap_vert_rounded),
            _btn('Natural', Icons.air_rounded),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  IconData _speedIcon(int speed) {
    switch (speed) {
      case 1:
        return Icons.looks_one_rounded;
      case 2:
        return Icons.looks_two_rounded;
      case 3:
        return Icons.looks_3_rounded;
      case 4:
        return Icons.looks_4_rounded;
      case 5:
        return Icons.looks_5_rounded;
      default:
        return Icons.speed;
    }
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: AppTheme.onSurface.withOpacity(0.6),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
