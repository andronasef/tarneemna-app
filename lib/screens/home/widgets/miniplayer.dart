import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tarneemna/features/audio/presentation/widgets/full_player_view.dart';

import '../../../player.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Worker? _worker;
  bool _isExiting = false;
  static const _flingVelocity = 300.0;

  // Drag-to-expand: a full-player panel in the root overlay that tracks the
  // finger (0 = sitting on the mini player, 1 = full screen).
  late final AnimationController _panel = AnimationController(vsync: this);
  OverlayEntry? _entry;
  double _startTop = 1;
  double _dragDy = 0;

  @override
  void initState() {
    super.initState();
    final hasSong = Player.currentSongTitle.value.isNotEmpty;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
      value: hasSong ? 1.0 : 0.0,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _worker = ever<String>(Player.currentSongTitle, (title) {
      if (!mounted) return;
      if (title.isNotEmpty && !_isExiting) {
        if (_controller.value < 1.0) {
          _controller.forward();
        }
      } else if (title.isEmpty && !_isExiting) {
        if (_controller.value > 0.0) {
          _controller.reverse();
        }
      }
    });
  }

  void _openFullPlayer() {
    Get.to(
      () => FullPlayerView(
        onCollapse: () => Get.back(),
      ),
      transition: Transition.downToUp,
      opaque: false, // keep the page visible behind while the player is dragged down
      duration: const Duration(milliseconds: 300),
    );
  }

  void _onDragStart(DragStartDetails _) {
    if (_isExiting || _panel.isAnimating) return;
    final box = context.findRenderObject() as RenderBox;
    _startTop = box.localToGlobal(Offset.zero).dy.clamp(1.0, double.infinity);
    _dragDy = 0;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_panel.isAnimating) return;
    _dragDy += d.delta.dy;
    if (_dragDy >= 0) return;
    if (_entry == null) {
      _panel.value = 0;
      _entry = OverlayEntry(builder: _panelBuilder);
      Overlay.of(context, rootOverlay: true).insert(_entry!);
    }
    _panel.value = (-_dragDy / _startTop).clamp(0.0, 1.0);
  }

  Widget _panelBuilder(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return AnimatedBuilder(
      animation: _panel,
      builder: (_, child) => Positioned(
        top: _startTop * (1 - _panel.value),
        left: 0,
        right: 0,
        height: height,
        child: child!,
      ),
      child: RepaintBoundary(
        child: Material(
          elevation: 8,
          child: FullPlayerView(onCollapse: () => Get.back()),
        ),
      ),
    );
  }

  Future<void> _onDragEnd(DragEndDetails d) async {
    final v = d.primaryVelocity ?? 0;
    if (_entry == null) {
      if (v > _flingVelocity) _handleExit();
      return;
    }
    final open = v < -_flingVelocity || (v <= _flingVelocity && _panel.value > 0.4);
    await _panel.animateTo(open ? 1 : 0,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic);
    if (open && mounted) {
      // Same full-screen content, so swap the overlay for a real route (back button works).
      Get.to(
        () => FullPlayerView(onCollapse: () => Get.back()),
        transition: Transition.noTransition,
        opaque: false,
        duration: Duration.zero,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _removePanel());
  }

  void _removePanel() {
    _entry?.remove();
    _entry = null;
  }

  Future<void> _handleExit() async {
    if (_isExiting) return;
    _isExiting = true;
    Player.pause();
    await _controller.reverse();
    Player.stop();
    if (mounted) {
      _isExiting = false;
    }
  }

  @override
  void dispose() {
    _worker?.dispose();
    _removePanel();
    _panel.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasSong = Player.currentSongTitle.value.isNotEmpty;
      if (!hasSong && _controller.value == 0.0 && !_isExiting) {
        return const SizedBox.shrink();
      }

      final theme = Theme.of(context);

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.value == 0.0 && !hasSong && !_isExiting) {
            return const SizedBox.shrink();
          }

          return ClipRect(
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: _controller.value.clamp(0.0, 1.0),
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: GestureDetector(
          onVerticalDragStart: _onDragStart,
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          onVerticalDragCancel: () => _onDragEnd(DragEndDetails()),
          child: RepaintBoundary(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Obx(
                    () {
                      final isPlaying = Player.isPlaying.value;
                      final isBuffering = Player.isBuffering.value;
                      final hymn = Player.currentHymn;
                      final singerName = hymn?.singer;

                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            // Clickable area for Artwork + Title/Singer
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _openFullPlayer,
                                child: Row(
                                  children: [
                                    // 1. Artwork (RTL start = right side)
                                    Container(
                                      width: 44,
                                      height: 44,
                                      margin: const EdgeInsetsDirectional.only(
                                          end: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: hymn?.artworkUrl != null
                                          ? Image.network(
                                              hymn!.artworkUrl!,
                                              fit: BoxFit.cover,
                                              cacheWidth: 132,
                                              gaplessPlayback: true,
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset(
                                                'assets/icon.png',
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(Icons.music_note,
                                              color: Colors.white70),
                                    ),

                                    // 2. Title & Singer in center
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Player.currentSongTitle.value,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (singerName != null &&
                                              singerName.isNotEmpty)
                                            Text(
                                              singerName,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 3. Expand / Play / Close buttons (RTL end = left side)
                            IconButton(
                              icon: const Icon(Icons.keyboard_arrow_up_rounded,
                                  size: 28),
                              tooltip: "تكبير المشغل",
                              onPressed: _openFullPlayer,
                            ),
                            if (isBuffering)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              IconButton(
                                icon: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 30,
                                ),
                                onPressed: () {
                                  if (isPlaying) {
                                    Player.pause();
                                  } else {
                                    Player.play();
                                  }
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 22),
                              onPressed: _handleExit,
                              tooltip: "إغلاق",
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
