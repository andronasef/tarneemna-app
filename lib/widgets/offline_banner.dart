import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarneemna/core/connectivity.dart';
import 'package:tarneemna/features/downloads/presentation/screens/offline_downloads_screen.dart';
import 'package:tarneemna/features/taranim_arabia/presentation/providers/taranim_arabia_providers.dart';

/// Shown while offline, with a shortcut to downloads. When the connection
/// returns it reloads whichever home sections failed while we were offline.
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner> {
  @override
  void initState() {
    super.initState();
    Net.online.addListener(_onChange);
  }

  @override
  void dispose() {
    Net.online.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (!Net.online.value) return;
    for (final p in [hymnOfTheDayProvider, randomizedSingersProvider, randomizedAlbumsProvider]) {
      if (ref.read(p).hasError) ref.invalidate(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: Net.online,
      builder: (context, online, _) {
        if (online) return const SizedBox.shrink();
        final scheme = Theme.of(context).colorScheme;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.wifi_off_rounded, size: 18, color: scheme.error),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('أنت غير متصل بالإنترنت', style: TextStyle(fontSize: 13)),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OfflineDownloadsScreen()),
                ),
                child: const Text('تصفح الترانيم المحملة', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }
}
