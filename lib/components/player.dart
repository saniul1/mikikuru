import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marqueer/marqueer.dart';
import 'package:mikikuru/states/player_notifier.dart';
import 'package:mikikuru/states/player_speed_notifier.dart';
import 'package:mikikuru/states/player_volume_notifier.dart';

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
                                            PlayerTimeInfo(colorScheme: colorScheme),
                                            const SizedBox(height: 4),
                                            PlayerConfigControl(colorScheme: colorScheme),
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

class PlayerConfigControl extends StatefulWidget {
  const PlayerConfigControl({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  State<PlayerConfigControl> createState() => _PlayerConfigControlState();
}

class _PlayerConfigControlState extends State<PlayerConfigControl> {
  double volumeStore = 0;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: controller,
      child: Row(
        children: [
          ValueListenableBuilder(
            valueListenable: PlayerVolumeNotifier(),
            builder: (context, value, _) {
              return PlayerConfigContainer(
                colorScheme: widget.colorScheme,
                icon: PlayerNotifier().player.volume == 0
                    ? CupertinoIcons.speaker_slash
                    : PlayerNotifier().player.volume >= 0.5
                        ? CupertinoIcons.speaker_2
                        : CupertinoIcons.speaker_1,
                info: '${value < 1 ? ' ' : ''}${(100 * value).toInt()}',
                value: value,
                max: 1,
                onIconTap: () {
                  if (PlayerNotifier().player.volume != 0) {
                    volumeStore = PlayerVolumeNotifier().value;
                    PlayerVolumeNotifier().set(0);
                  } else {
                    PlayerVolumeNotifier().set(volumeStore);
                  }
                },
                onChanged: (value) {
                  PlayerVolumeNotifier().set(value);
                },
              );
            },
          ),
          const SizedBox(width: 8.0),
          ValueListenableBuilder(
            valueListenable: PlayerSpeedNotifier(),
            builder: (context, value, _) {
              return PlayerConfigContainer(
                colorScheme: widget.colorScheme,
                icon: CupertinoIcons.speedometer,
                info: value.toStringAsFixed(1),
                value: value,
                min: 0.5,
                max: 2,
                onIconTap: () {
                  PlayerSpeedNotifier().set(1);
                },
                onChanged: (value) {
                  PlayerSpeedNotifier().set(value);
                },
                onExpand: () async {
                  // controller.animateTo(
                  //   10,
                  //   duration: const Duration(milliseconds: 300),
                  //   curve: Curves.bounceIn,
                  // );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class PlayerConfigContainer extends StatefulWidget {
  const PlayerConfigContainer({
    super.key,
    required this.colorScheme,
    required this.icon,
    required this.value,
    this.min = 0,
    required this.max,
    required this.onChanged,
    this.onIconTap,
    this.onExpand,
    this.info,
  });

  final ColorScheme colorScheme;
  final IconData icon;
  final String? info;
  final double value;
  final double min;
  final double max;
  final void Function(double value) onChanged;
  final void Function()? onIconTap;
  final void Function()? onExpand;

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
        onEnd: () {
          if (isHover && widget.onExpand != null) widget.onExpand!();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, top: 2, right: 2, bottom: 2),
              child: GestureDetector(
                onTap: widget.onIconTap,
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: widget.colorScheme.primary,
                ),
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
                  value: widget.value,
                  onChangeStart: (_) {
                    isDragging = true;
                  },
                  onChangeEnd: (_) {
                    isDragging = false;
                    _maybeCollapse();
                  },
                  onChanged: widget.onChanged,
                  min: widget.min,
                  max: widget.max,
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

class PlayerProgressBar extends StatefulWidget {
  const PlayerProgressBar({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  State<PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends State<PlayerProgressBar> {
  Duration runTime = Duration.zero;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    PlayerNotifier().player.onDurationChanged.listen((Duration d) {
      setState(() => runTime = d);
    });
    PlayerNotifier().player.onPositionChanged.listen((Duration p) {
      setState(() {
        progress = (p.inMilliseconds / runTime.inMilliseconds) * 100;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4.0,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0),
          overlayShape: SliderComponentShape.noOverlay,
          trackShape: const RectangularSliderTrackShape(),
          activeTrackColor: widget.colorScheme.onPrimary,
          inactiveTrackColor: widget.colorScheme.primary,
        ),
        child: Slider(
          value: progress,
          min: 0,
          max: 100,
          onChanged: (double value) {},
        ),
      ),
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
          onPressed: () {
            PlayerNotifier().playOrPause();
          },
          color: colorScheme.primary,
          icon: const _PlayPauseIcon(),
        ),
      ],
    );
  }
}

class _PlayPauseIcon extends StatefulWidget {
  const _PlayPauseIcon();

  @override
  State<_PlayPauseIcon> createState() => _PlayPauseIconState();
}

class _PlayPauseIconState extends State<_PlayPauseIcon> {
  PlayerState state = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    PlayerNotifier().player.onPlayerStateChanged.listen((PlayerState value) {
      setState(() {
        state = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      state != PlayerState.playing ? CupertinoIcons.play_fill : CupertinoIcons.pause_fill,
    );
  }
}

extension DurationExtension on Duration {
  String toTimeString() {
    return toString().split('.').firstOrNull ?? '';
  }
}

class PlayerTimeInfo extends StatefulWidget {
  const PlayerTimeInfo({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  State<PlayerTimeInfo> createState() => _PlayerTimeInfoState();
}

class _PlayerTimeInfoState extends State<PlayerTimeInfo> {
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    PlayerNotifier().player.onDurationChanged.listen((Duration d) {
      setState(() => duration = d);
    });
    PlayerNotifier().player.onPositionChanged.listen((Duration p) {
      setState(() => position = p);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${position.toTimeString()} / ${duration.toTimeString()}',
      softWrap: false,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: widget.colorScheme.onPrimaryContainer,
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
