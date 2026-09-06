import 'package:flutter/material.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/core/theme/app_theme.dart';
import 'package:soultech_vending/features/qr_creator/qr_creator_page.dart';
import 'package:soultech_vending/features/settings/settings_page.dart';

/// App-wide navigation drawer for Soultech Vending.
///
/// Modern Material 3 drawer that follows the light/dark theme, shows the
/// app branding on top and highlights the active destination. Uses the
/// existing `Navigator.push` architecture (no second navigation system).
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, this.current = DrawerSection.home});

  /// Highlighted destination.
  final DrawerSection current;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            // Brand header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.darkCard, AppColors.darkSurface]
                      : [AppColors.navy, AppColors.blue],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_2, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soultech Vending',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'YOUR BREAK, OUR BUSINESS.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerTile(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard,
                    label: AppLang.tr(L.dashboard),
                    selected: current == DrawerSection.home,
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerTile(
                    icon: Icons.qr_code_2,
                    selectedIcon: Icons.qr_code_2,
                    label: AppLang.tr(L.qrCreator),
                    selected: current == DrawerSection.qrCreator,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QrCreatorPage(),
                          ));
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: AppLang.tr(L.settings),
                    selected: current == DrawerSection.settings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ));
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    'Soultech Vending • v2.0.0',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Drawer destinations.
enum DrawerSection { home, qrCreator, settings }

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: .10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          dense: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: Icon(
            selected ? selectedIcon : icon,
            color: selected
                ? scheme.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected
                  ? scheme.primary
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
