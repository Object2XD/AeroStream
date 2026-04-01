import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models/info_models.dart';

const infoStats = <InfoStatItem>[
  InfoStatItem(
    label: 'Total Listening Time',
    value: '127 hours',
    icon: Icons.history_rounded,
    routeName: AppRoutes.infoListeningTime,
  ),
  InfoStatItem(
    label: 'Songs Played',
    value: '1,234',
    icon: Icons.music_note_rounded,
    routeName: AppRoutes.infoSongsPlayed,
  ),
  InfoStatItem(
    label: 'Playlists Created',
    value: '18',
    icon: Icons.queue_music_rounded,
  ),
  InfoStatItem(
    label: 'Favorite Songs',
    value: '156',
    icon: Icons.favorite_rounded,
  ),
];

const infoSettings = <InfoSettingItem>[
  InfoSettingItem(
    id: 'notifications',
    title: 'Notifications',
    icon: Icons.notifications_rounded,
    hasSwitch: true,
  ),
  InfoSettingItem(
    id: 'download',
    title: 'Download Quality',
    subtitle: 'High',
    icon: Icons.download_rounded,
  ),
  InfoSettingItem(
    id: 'language',
    title: 'Language',
    subtitle: 'English',
    icon: Icons.language_rounded,
  ),
  InfoSettingItem(
    id: 'theme',
    title: 'Theme',
    subtitle: 'Dark',
    icon: Icons.palette_outlined,
  ),
];

const infoOptions = <InfoOptionItem>[
  InfoOptionItem(
    id: 'help-support',
    title: 'Help & Support',
    icon: Icons.help_outline_rounded,
  ),
  InfoOptionItem(id: 'about', title: 'About', icon: Icons.info_outline_rounded),
];

const weeklyListeningData = <WeeklyListeningPoint>[
  WeeklyListeningPoint(day: 'Mon', minutes: 45, label: '45m'),
  WeeklyListeningPoint(day: 'Tue', minutes: 120, label: '2h'),
  WeeklyListeningPoint(day: 'Wed', minutes: 80, label: '1h 20m'),
  WeeklyListeningPoint(day: 'Thu', minutes: 60, label: '1h'),
  WeeklyListeningPoint(day: 'Fri', minutes: 150, label: '2.5h'),
  WeeklyListeningPoint(day: 'Sat', minutes: 210, label: '3.5h'),
  WeeklyListeningPoint(day: 'Sun', minutes: 180, label: '3h'),
];

const topArtistsByListeningTime = <ArtistListeningItem>[
  ArtistListeningItem(
    rank: 1,
    name: 'Luna Wave',
    genre: 'Electronic',
    duration: '24 hours',
  ),
  ArtistListeningItem(
    rank: 2,
    name: 'Electric Vibe',
    genre: 'Synthwave',
    duration: '18 hours',
  ),
  ArtistListeningItem(
    rank: 3,
    name: 'Retro Beats',
    genre: 'Lo-Fi',
    duration: '15 hours',
  ),
];

const mostPlayedSongs = <SongPlayItem>[
  SongPlayItem(rank: 1, title: 'Midnight City', artist: 'M83', plays: 142),
  SongPlayItem(rank: 2, title: 'Nightcall', artist: 'Kavinsky', plays: 128),
  SongPlayItem(rank: 3, title: 'Resonance', artist: 'HOME', plays: 115),
  SongPlayItem(rank: 4, title: 'Sun Models', artist: 'ODESZA', plays: 98),
  SongPlayItem(rank: 5, title: 'Innerbloom', artist: 'RUFUS DU SOL', plays: 87),
  SongPlayItem(rank: 6, title: 'Gosh', artist: 'Jamie xx', plays: 76),
  SongPlayItem(
    rank: 7,
    title: 'Inspector Norse',
    artist: 'Todd Terje',
    plays: 64,
  ),
];
