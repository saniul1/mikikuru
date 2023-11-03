import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marqueer/marqueer.dart';

import '../states/cover_art_notifier.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({
    super.key,
  });

  static const height = 80.0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AudioBookCoverNotifier(),
      builder: (context, cover, _) {
        return FutureBuilder(
          future: ColorScheme.fromImageProvider(provider: cover),
          builder: (context, snap) {
            if (snap.data == null) return const SizedBox();
            final colorScheme = snap.data!;
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primaryContainer.withOpacity(0.5),
                    blurRadius: 50,
                    spreadRadius: 4,
                    offset: const Offset(0, -8),
                  ),
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.5),
                    blurRadius: 50,
                    spreadRadius: 4,
                    offset: const Offset(0, 76),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                maxWidth: 360,
                maxHeight: height,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image(
                            image: cover,
                            height: height,
                            fit: BoxFit.cover,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                                  child: SizedBox(
                                    height: 16,
                                    child: PlayerTitle(colorScheme: colorScheme),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            PlayerTImeInfo(colorScheme: colorScheme),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                PlayerConfigContainer(
                                                  colorScheme: colorScheme,
                                                  icon: CupertinoIcons.speaker_2,
                                                  info: ' 50',
                                                ),
                                                const SizedBox(width: 8.0),
                                                PlayerConfigContainer(
                                                  colorScheme: colorScheme,
                                                  icon: CupertinoIcons.speedometer,
                                                  info: '2.0',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      PlayerControl(colorScheme: colorScheme),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: PlayerProgressBar(colorScheme: colorScheme),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class PlayerConfigContainer extends StatefulWidget {
  const PlayerConfigContainer({
    super.key,
    required this.colorScheme,
    required this.icon,
    this.info,
  });

  final ColorScheme colorScheme;
  final IconData icon;
  final String? info;

  @override
  State<PlayerConfigContainer> createState() => _PlayerConfigContainerState();
}

class _PlayerConfigContainerState extends State<PlayerConfigContainer> {
  var isHover = false;
  var isDragging = false;

  Future<void> _maybeCollapse() async {
    await Future.delayed(const Duration(seconds: 2));
    if (isHover && !isDragging) {
      setState(() {
        isHover = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (hover) {
        setState(() {
          isHover = hover;
        });
      },
      onTap: () {
        setState(() {
          isHover = !isHover;
        });
        _maybeCollapse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isHover ? 132 : 52,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: widget.colorScheme.background.withOpacity(0.7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, top: 2, right: 2, bottom: 2),
              child: Icon(
                widget.icon,
                size: 18,
                color: widget.colorScheme.primary,
              ),
            ),
            // if (isHover)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isHover ? 80 : 0,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  overlayShape: SliderComponentShape.noOverlay,
                  trackShape: const RectangularSliderTrackShape(),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0),
                ),
                child: Slider(
                  value: 50,
                  onChangeStart: (_) {
                    isDragging = true;
                  },
                  onChangeEnd: (_) {
                    isDragging = false;
                    _maybeCollapse();
                  },
                  onChanged: (value) {
                    print(value);
                  },
                  min: 0.0,
                  max: 100.0,
                  activeColor: widget.colorScheme.primary.withOpacity(0.7),
                  inactiveColor: widget.colorScheme.primary.withOpacity(0.4),
                ),
              ),
            ),
            if (widget.info != null)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  widget.info!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: widget.colorScheme.primary,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PlayerProgressBar extends StatelessWidget {
  const PlayerProgressBar({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 4,
      color: colorScheme.primary,
    );
  }
}

class PlayerControl extends StatelessWidget {
  const PlayerControl({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          color: colorScheme.primary,
          icon: const Icon(
            CupertinoIcons.arrow_counterclockwise_circle_fill,
          ),
        ),
        IconButton(
          onPressed: () {},
          color: colorScheme.primary,
          icon: const Icon(
            false ? CupertinoIcons.play_fill : CupertinoIcons.pause_fill,
          ),
        ),
      ],
    );
  }
}

class PlayerTImeInfo extends StatelessWidget {
  const PlayerTImeInfo({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      '22:02 / 01:59:00 (7:20:02)',
      softWrap: false,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimaryContainer,
          ),
    );
  }
}

class PlayerTitle extends StatelessWidget {
  const PlayerTitle({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Marqueer(
      child: Text(
        ' This is the end.'
        '     ',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
      ),
    );
  }
}
