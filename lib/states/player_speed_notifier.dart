import 'package:flutter/cupertino.dart';
import 'package:mikikuru/states/player_notifier.dart';

class PlayerSpeedNotifier extends ValueNotifier<double> {
  static final PlayerSpeedNotifier _shared = PlayerSpeedNotifier._sharedInstance();
  factory PlayerSpeedNotifier() => _shared;
  PlayerSpeedNotifier._sharedInstance() : super(1);

  /// between 0-2
  void set(double volume) {
    value = volume;
    PlayerNotifier().setPlaySpeed(volume);
  }
}
