import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarneemna/core/values.dart';
import 'package:tarneemna/features/downloads/presentation/screens/offline_downloads_screen.dart';
import 'package:tarneemna/features/downloads/presentation/screens/storage_manager_screen.dart';
import 'package:tarneemna/features/settings/domain/models/app_settings.dart';
import 'package:tarneemna/features/settings/presentation/providers/settings_providers.dart';
import 'package:tarneemna/screens/markdown/markdown_screen.dart';
import 'package:tarneemna/utils/open_urls.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

class ModernSettingsScreen extends ConsumerWidget {
  const ModernSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الإعدادات والمظهر',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Section 1: Appearance & Theme
            _buildSectionHeader(
                context, 'المظهر والسمات', Icons.palette_outlined),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نمط العرض',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildThemeModeChip(
                          context,
                          label: 'تلقائي',
                          icon: Icons.brightness_auto,
                          selected: settings.themeMode == AppThemeMode.system,
                          onTap: () => notifier.setThemeMode(AppThemeMode.system),
                        ),
                        const SizedBox(width: 8),
                        _buildThemeModeChip(
                          context,
                          label: 'فاتح',
                          icon: Icons.light_mode,
                          selected: settings.themeMode == AppThemeMode.light,
                          onTap: () => notifier.setThemeMode(AppThemeMode.light),
                        ),
                        const SizedBox(width: 8),
                        _buildThemeModeChip(
                          context,
                          label: 'داكن',
                          icon: Icons.dark_mode,
                          selected: settings.themeMode == AppThemeMode.dark,
                          onTap: () => notifier.setThemeMode(AppThemeMode.dark),
                        ),
                        const SizedBox(width: 8),
                        _buildThemeModeChip(
                          context,
                          label: 'OLED',
                          icon: Icons.nightlight_round,
                          selected: settings.themeMode == AppThemeMode.oled,
                          onTap: () => notifier.setThemeMode(AppThemeMode.oled),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    const Text(
                      'لون التمييز الروحي',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SpiritualAccent.values.map((accent) {
                        final isSelected = settings.accent == accent;
                        return ChoiceChip(
                          avatar: CircleAvatar(
                            backgroundColor: accent.color,
                            radius: 8,
                          ),
                          label: Text(accent.label),
                          selected: isSelected,
                          onSelected: (_) => notifier.setAccent(accent),
                          selectedColor: accent.color.withValues(alpha: 0.2),
                          side: BorderSide(
                            color: isSelected
                                ? accent.color
                                : (isDark ? Colors.white24 : Colors.black12),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Reading & Typography
            _buildSectionHeader(
                context, 'القراءة والخط', Icons.format_size_rounded),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'حجم الخط',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(settings.fontScale * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: settings.fontScale,
                      min: 0.85,
                      max: 1.30,
                      divisions: 9,
                      label: '${(settings.fontScale * 100).toInt()}%',
                      onChanged: (val) => notifier.setFontScale(val),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('أصغر (85%)',
                            style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black54)),
                        Text('افتراضي (100%)',
                            style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black54)),
                        Text('أكبر (130%)',
                            style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black54)),
                      ],
                    ),
                    const Divider(height: 28),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.contrast_rounded),
                      title: const Text(
                        'تباين فائق للنصوص',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'تحسين وضوح قراءة النصوص',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: settings.highContrastText,
                      onChanged: (val) => notifier.setHighContrastText(val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 3: Audio & Playback
            _buildSectionHeader(
                context, 'الصوتيات والتشغيل', Icons.headphones_outlined),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.storage_rounded),
                    title: const Text(
                      'إدارة التخزين والمساحة',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StorageManagerScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.download_done_rounded),
                    title: const Text(
                      'الترانيم المحملة',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OfflineDownloadsScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 4: Community & Support
            _buildSectionHeader(
                context, 'المساعدة والتواصل', Icons.favorite_border),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: const Text('شارك التطبيق مع أصدقائك',
                        style: TextStyle(fontSize: 14)),
                    onTap: () => Share.share(
                      'استمع وحمل آلاف الترانيم الروحية عبر تطبيق ${AppDetails.kAppName}: ${AppUrls.share}',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: const Text('قيّم التطبيق على المتجر',
                        style: TextStyle(fontSize: 14)),
                    onTap: () => openUrl(AppUrls.rate),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lightbulb_outline),
                    title: const Text('طلب ترنيمة مفقودة أو ميزة جديدة',
                        style: TextStyle(fontSize: 14)),
                    onTap: () => openUrl(AppUrls.support),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('سياسة الخصوصية',
                        style: TextStyle(fontSize: 14)),
                    onTap: () => Get.to(
                        () => const MarkdownPage('assets/md/tarneemna.md')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About Footer (Dynamic App Name & Version)
            Center(
              child: Column(
                children: [
                  ref.watch(packageInfoProvider).when(
                        data: (info) => Text(
                          'تطبيق ${info.appName.isNotEmpty ? info.appName : AppDetails.kAppName} • الإصدار ${info.version}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        loading: () => Text(
                          'تطبيق ${AppDetails.kAppName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        error: (_, __) => Text(
                          'تطبيق ${AppDetails.kAppName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : (isDark ? Colors.white12 : Colors.black12),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? theme.colorScheme.primary
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
