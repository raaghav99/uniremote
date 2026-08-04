import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../domain/remote_controller.dart';
import '../../domain/remote_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remotes = ref.watch(remotesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('📡', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              'UniRemote',
              style: GoogleFonts.poppins(
                color: AppTheme.onBackground,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: remotes.isEmpty
          ? _EmptyState()
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: remotes.length,
                itemBuilder: (context, index) {
                  return _RemoteCard(remote: remotes[index]);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        tooltip: 'Add Remote',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surface,
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: const Icon(
              Icons.settings_remote_outlined,
              size: 48,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No remotes yet',
            style: GoogleFonts.poppins(
              color: AppTheme.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first remote',
            style: GoogleFonts.poppins(
              color: AppTheme.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Remote'),
          ),
        ],
      ),
    );
  }
}

class _RemoteCard extends ConsumerWidget {
  final RemoteModel remote;

  const _RemoteCard({required this.remote});

  String get _deviceTypeLabel {
    switch (remote.deviceType) {
      case 'tv':
        return 'TV';
      case 'ac':
        return 'AC';
      case 'fan':
        return 'Fan';
      case 'dth':
        return 'DTH';
      default:
        return remote.deviceType.toUpperCase();
    }
  }

  Color get _accentColor {
    switch (remote.deviceType) {
      case 'tv':
        return AppTheme.primary;
      case 'ac':
        return AppTheme.secondary;
      case 'fan':
        return const Color(0xFF66BB6A);
      case 'dth':
        return const Color(0xFFFFB74D);
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/remote',
          arguments: remote,
        );
      },
      onLongPress: () => _showDeleteDialog(context, ref),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Accent top strip
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _accentColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    remote.iconEmoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const Spacer(),
                  Text(
                    remote.name,
                    style: GoogleFonts.poppins(
                      color: AppTheme.onBackground,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _accentColor.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          _deviceTypeLabel,
                          style: GoogleFonts.poppins(
                            color: _accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          remote.brandName,
                          style: GoogleFonts.poppins(
                            color: AppTheme.onSurface.withOpacity(0.7),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Delete Remote',
          style: GoogleFonts.poppins(
            color: AppTheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Remove "${remote.name}"?',
          style: GoogleFonts.poppins(color: AppTheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppTheme.onSurface)),
          ),
          TextButton(
            onPressed: () {
              ref.read(remotesProvider.notifier).deleteRemote(remote.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete',
                style:
                    GoogleFonts.poppins(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
