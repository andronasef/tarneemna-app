import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarneemna/core/values.dart';
import 'package:tarneemna/features/settings/domain/models/app_settings.dart';
import 'package:tarneemna/features/settings/presentation/providers/settings_providers.dart';
import 'package:tarneemna/screens/markdown/markdown_screen.dart';
import 'package:tarneemna/utils/open_urls.dart';

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
            _buildSectionHeader(context, 'المظهر والسمات', Icons.palette_outlined),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'وضع السمة (Theme Mode)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildThemeChip(
                          context: context,
                          label: 'تلقائي (النظام)',
                          icon: Icons.brightness_auto,
                          selected: settings.themeMode == AppThemeMode.system,
                          onTap: () => notifier.setThemeMode(AppThemeMode.system),
                        ),
                        _buildThemeChip(
                          context: context,
                          label: 'فاتح',
                          icon: Icons.light_mode,
                          selected: settings.themeMode == AppThemeMode.light,
                          onTap: () => notifier.setThemeMode(AppThemeMode.light),
                        ),
                        _buildThemeChip(
                          context: context,
                          label: 'داكن',
                          icon: Icons.dark_mode,
                          selected: settings.themeMode == AppThemeMode.dark,
                          onTap: () => notifier.setThemeMode(AppThemeMode.dark),
                        ),
                        _buildThemeChip(
                          context: context,
                          label: 'أسود مطلق (OLED)',
                          icon: Icons.nightlight_round,
                          badge: 'توفير بطارية',
                          selected: settings.themeMode == AppThemeMode.oled,
                          onTap: () => notifier.setThemeMode(AppThemeMode.oled),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    const Text(
                      'اللون الروحي الأساسي',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: SpiritualAccent.values.map((accent) {
                        final isSelected = settings.accent == accent;
                        return InkWell(
                          onTap: () => notifier.setAccent(accent),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accent.color.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? accent.color : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: accent.color,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  accent.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? accent.color : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Senior Accessibility & Typography
            _buildSectionHeader(context, 'إمكانية الوصول والخط لكبار السن', Icons.accessibility_new),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'حجم الخط العام',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _getFontScaleLabel(settings.fontScale),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: settings.fontScale,
                      min: 0.85,
                      max: 1.30,
                      divisions: 3,
                      label: _getFontScaleLabel(settings.fontScale),
                      onChanged: (val) => notifier.setFontScale(val),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('صغير (0.85x)', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                        Text('عادي (1.0x)', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                        Text('كبير (1.15x)', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                        Text('كبار السن (1.30x)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Live Preview Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'معاينة قراءة الكلمات والترانيم:',
                            style: TextStyle(
                              fontSize: 12 * settings.fontScale,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '«يا صاحب الحنان.. يا ملجأ الأنام.. إليك ألتجئ، ترنيمتي أنت في ليل الآلام»',
                            style: TextStyle(
                              fontSize: 15 * settings.fontScale,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 28),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'تباين عالي للنصوص (High Contrast)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'زيادة وضوح الحروف لقراءة مريحة للعين',
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

            // Section 3: Audio & Downloads
            _buildSectionHeader(context, 'خيارات التشغيل والتحميل', Icons.music_note_outlined),
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
                  SwitchListTile(
                    title: const Text(
                      'تشغيل مستمر ومتصل (Gapless Playback)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'الانتقال التلقائي للترنيمة التالية بدون انقطاع',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: settings.gaplessPlayback,
                    onChanged: (val) => notifier.setGaplessPlayback(val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      'تحميل الترانيم المفضلة على Wi-Fi',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'حفظ الترانيم المضافة للمفضلة تلقائياً للاستماع دون إنترنت',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: settings.autoDownloadFavoritesWifi,
                    onChanged: (val) => notifier.setAutoDownloadFavoritesWifi(val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.sd_storage_outlined),
                    title: const Text(
                      'إدارة التخزين والكاش',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Get.toNamed('/storage-manager'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.download_done_rounded),
                    title: const Text(
                      'الترانيم المحملة',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Get.toNamed('/downloads'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 4: Community & Support
            _buildSectionHeader(context, 'المساعدة والتواصل', Icons.favorite_border),
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
                    title: const Text('شارك التطبيق مع أصدقائك', style: TextStyle(fontSize: 14)),
                    onTap: () => Share.share(
                      'استمع وحمل آلاف الترانيم الروحية عبر تطبيق ترانيمنا: ${AppUrls.share}',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: const Text('قيّم التطبيق على المتجر', style: TextStyle(fontSize: 14)),
                    onTap: () => openUrl(AppUrls.rate),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lightbulb_outline),
                    title: const Text('طلب ترنيمة مفقودة أو ميزة جديدة', style: TextStyle(fontSize: 14)),
                    onTap: () => openUrl(AppUrls.support),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('سياسة الخصوصية', style: TextStyle(fontSize: 14)),
                    onTap: () => Get.to(() => const MarkdownPage('assets/md/tarneemna.md')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'تطبيق ترانيمنا • الإصدار 2.0.0 الحديث',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'لتمجيد اسم المسيح وبناء الأرواح في كل زمان ومكان',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    String? badge,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.15)
              : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? primary : null),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? primary : null,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getFontScaleLabel(double scale) {
    if (scale <= 0.90) return 'صغير (0.85x)';
    if (scale <= 1.05) return 'عادي (1.0x)';
    if (scale <= 1.20) return 'كبير (1.15x)';
    return 'كبار السن (1.30x)';
  }
}
