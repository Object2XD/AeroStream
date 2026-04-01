import 'package:flutter/material.dart';

class InfoStatItem {
  const InfoStatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.routeName,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? routeName;
}

class InfoSettingItem {
  const InfoSettingItem({
    required this.id,
    required this.title,
    required this.icon,
    this.subtitle,
    this.hasSwitch = false,
  });

  final String id;
  final String title;
  final IconData icon;
  final String? subtitle;
  final bool hasSwitch;
}

class InfoOptionItem {
  const InfoOptionItem({
    required this.id,
    required this.title,
    required this.icon,
  });

  final String id;
  final String title;
  final IconData icon;
}

class WeeklyListeningPoint {
  const WeeklyListeningPoint({
    required this.day,
    required this.minutes,
    required this.label,
  });

  final String day;
  final int minutes;
  final String label;
}

class ArtistListeningItem {
  const ArtistListeningItem({
    required this.rank,
    required this.name,
    required this.genre,
    required this.duration,
  });

  final int rank;
  final String name;
  final String genre;
  final String duration;
}

class SongPlayItem {
  const SongPlayItem({
    required this.rank,
    required this.title,
    required this.artist,
    required this.plays,
  });

  final int rank;
  final String title;
  final String artist;
  final int plays;
}
