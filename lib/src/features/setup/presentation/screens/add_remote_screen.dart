import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../remote/data/ir_codes.dart';
import '../../../remote/data/ir_service.dart';
import '../../../remote/domain/remote_controller.dart';
import '../../../remote/domain/remote_model.dart';

class AddRemoteScreen extends ConsumerStatefulWidget {
  const AddRemoteScreen({super.key});

  @override
  ConsumerState<AddRemoteScreen> createState() => _AddRemoteScreenState();
}

class _AddRemoteScreenState extends ConsumerState<AddRemoteScreen> {
  int _step = 0;
  String? _selectedDeviceType;
  BrandInfo? _selectedBrand;
  final _nameController = TextEditingController();
  bool _testSent = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() => _step++);
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _testPower() async {
    if (_selectedBrand == null) return;
    final buttons = _selectedBrand!.buttonsFactory();
    try {
      final powerBtn = buttons.firstWhere((b) => b.label == 'Power');
      await IrService.transmit(powerBtn.freqHz, powerBtn.pattern);
      setState(() => _testSent = true);
    } catch (_) {}
  }

  Future<void> _save() async {
    if (_selectedBrand == null) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for the remote')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final remote = RemoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      deviceType: _selectedBrand!.deviceType,
      brandName: _selectedBrand!.brandName,
      iconEmoji: _selectedBrand!.iconEmoji,
      buttons: _selectedBrand!.buttonsFactory(),
    );
    await ref.read(remotesProvider.notifier).addRemote(remote);
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Add Remote',
          style: GoogleFonts.poppins(
            color: AppTheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: _step == 0
            ? null
            : IconButton(
                onPressed: _prevStep,
                icon: const Icon(Icons.arrow_back_ios_rounded),
              ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i <= _step;
          final isCurrent = i == _step;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _Step1DeviceType(
          key: const ValueKey('step1'),
          onSelected: (type) {
            setState(() => _selectedDeviceType = type);
            _nextStep();
          },
        );
      case 1:
        return _Step2Brand(
          key: const ValueKey('step2'),
          deviceType: _selectedDeviceType!,
          onSelected: (brand) {
            setState(() {
              _selectedBrand = brand;
              _nameController.text = '${brand.brandName} ${brand.deviceType.toUpperCase()}';
            });
            _nextStep();
          },
        );
      case 2:
        return _Step3TestAndSave(
          key: const ValueKey('step3'),
          brand: _selectedBrand!,
          nameController: _nameController,
          testSent: _testSent,
          isSaving: _isSaving,
          onTest: _testPower,
          onSave: _save,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Step 1 — Pick device type
// ---------------------------------------------------------------------------
class _Step1DeviceType extends StatelessWidget {
  final void Function(String) onSelected;

  const _Step1DeviceType({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final devices = [
      ('tv', '📺', 'Television', 'Smart TVs, LED, OLED'),
      ('ac', '❄️', 'Air Conditioner', 'Split, Window, Portable'),
      ('fan', '🌀', 'Fan / Cooler', 'Ceiling, Table, Tower fans'),
      ('dth', '📡', 'Set-Top Box', 'DTH, Cable, Streaming'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you\ncontrolling?',
            style: GoogleFonts.poppins(
              color: AppTheme.onBackground,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the device type',
            style: GoogleFonts.poppins(
              color: AppTheme.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ...devices.map((d) {
            return _DeviceCard(
              emoji: d.$2,
              title: d.$3,
              subtitle: d.$4,
              onTap: () => onSelected(d.$1),
            );
          }),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DeviceCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: AppTheme.onBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: AppTheme.onSurface.withOpacity(0.65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.onSurface),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — Pick brand
// ---------------------------------------------------------------------------
class _Step2Brand extends StatelessWidget {
  final String deviceType;
  final void Function(BrandInfo) onSelected;

  const _Step2Brand({
    super.key,
    required this.deviceType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final brands = getBrandsForDevice(deviceType);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your brand',
            style: GoogleFonts.poppins(
              color: AppTheme.onBackground,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the manufacturer',
            style: GoogleFonts.poppins(
              color: AppTheme.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          if (brands.isEmpty)
            Center(
              child: Text(
                'No brands available for this device type.',
                style: GoogleFonts.poppins(color: AppTheme.onSurface),
              ),
            )
          else
            ...brands.map((brand) {
              return GestureDetector(
                onTap: () => onSelected(brand),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Text(brand.iconEmoji,
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              brand.brandName,
                              style: GoogleFonts.poppins(
                                color: AppTheme.onBackground,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${brand.buttonsFactory().length} buttons',
                              style: GoogleFonts.poppins(
                                color: AppTheme.onSurface.withOpacity(0.65),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppTheme.onSurface),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — Test & Save
// ---------------------------------------------------------------------------
class _Step3TestAndSave extends StatelessWidget {
  final BrandInfo brand;
  final TextEditingController nameController;
  final bool testSent;
  final bool isSaving;
  final VoidCallback onTest;
  final VoidCallback onSave;

  const _Step3TestAndSave({
    super.key,
    required this.brand,
    required this.nameController,
    required this.testSent,
    required this.isSaving,
    required this.onTest,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test & Save',
            style: GoogleFonts.poppins(
              color: AppTheme.onBackground,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Point at your device and test',
            style: GoogleFonts.poppins(
              color: AppTheme.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Brand summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Row(
              children: [
                Text(brand.iconEmoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.brandName,
                      style: GoogleFonts.poppins(
                        color: AppTheme.onBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      brand.deviceType.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Test power button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTest,
              icon: Icon(
                Icons.power_settings_new_rounded,
                color: testSent ? Colors.green : AppTheme.primary,
              ),
              label: Text(
                testSent ? 'Signal sent! Did it work?' : 'Send Power Signal',
                style: GoogleFonts.poppins(
                  color: testSent ? Colors.green : AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: testSent ? Colors.green : AppTheme.primary,
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (testSent) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'If your device responded, save below!',
                    style: GoogleFonts.poppins(
                        color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Name input
          Text(
            'Name your remote',
            style: GoogleFonts.poppins(
              color: AppTheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            style: GoogleFonts.poppins(color: AppTheme.onBackground),
            decoration: InputDecoration(
              hintText: 'e.g. Living Room TV',
              prefixIcon:
                  const Icon(Icons.edit_rounded, color: AppTheme.onSurface),
            ),
          ),

          const SizedBox(height: 28),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                isSaving ? 'Saving...' : 'Save Remote',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
