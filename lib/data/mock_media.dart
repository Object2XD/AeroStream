import '../models/playlist_item.dart';
import '../models/track_item.dart';

const currentTrack = TrackItem(
  id: 1,
  title: 'Midnight Dreams',
  artist: 'Luna Wave',
  album: 'Neon Nights',
  durationSeconds: 225,
  imageUrl:
      'https://images.unsplash.com/photo-1644855640845-ab57a047320e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNpYyUyMGFsYnVtJTIwY292ZXIlMjBhcnR8ZW58MXx8fHwxNzc0NDkzMTQ0fDA&ixlib=rb-4.1.0&q=80&w=1080',
);

const recentTracks = <TrackItem>[
  currentTrack,
  TrackItem(
    id: 2,
    title: 'Vinyl Memories',
    artist: 'Retro Beats',
    album: 'Dust & Echo',
    durationSeconds: 252,
    imageUrl:
        'https://images.unsplash.com/photo-1603850121303-d4ade9e5ba65?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx2aW55bCUyMHJlY29yZCUyMHBsYXllcnxlbnwxfHx8fDE3NzQ0NzI4NTZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  TrackItem(
    id: 3,
    title: 'Stage Light',
    artist: 'Electric Vibe',
    album: 'Voltage Bloom',
    durationSeconds: 208,
    imageUrl:
        'https://images.unsplash.com/photo-1689793354800-de168c0a4c9b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb25jZXJ0JTIwc3RhZ2UlMjBsaWdodHN8ZW58MXx8fHwxNzc0NDY4MDc1fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  TrackItem(
    id: 4,
    title: 'Silent Waves',
    artist: 'Ambient Flow',
    album: 'Afterglow Static',
    durationSeconds: 301,
    imageUrl:
        'https://images.unsplash.com/photo-1649956736509-f359d191bbcb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoZWFkcGhvbmVzJTIwbXVzaWN8ZW58MXx8fHwxNzc0NTE5MDE2fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  TrackItem(
    id: 5,
    title: 'Thunder Road',
    artist: 'Stone Arcade',
    album: 'Asphalt Hearts',
    durationSeconds: 272,
    imageUrl:
        'https://images.unsplash.com/photo-1717978227404-4d3db15e3d13?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyb2NrJTIwYmFuZCUyMGNvbmNlcnR8ZW58MXx8fHwxNzc0NDg0NDE1fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
];

const playbackQueue = recentTracks;

const playlists = <PlaylistItem>[
  PlaylistItem(
    name: 'Chill Vibes',
    songCount: 24,
    imageUrl:
        'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxndWl0YXIlMjBhY291c3RpY3xlbnwxfHx8fDE3NzQ1NDY0NDl8MA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  PlaylistItem(
    name: 'Evening Piano',
    songCount: 18,
    imageUrl:
        'https://images.unsplash.com/photo-1546058256-47154de4046c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaWFubyUyMGtleXMlMjBibGFja3xlbnwxfHx8fDE3NzQ1NDY0NDl8MA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  PlaylistItem(
    name: 'Night Drive',
    songCount: 31,
    imageUrl:
        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxuaWdodCUyMGRyaXZlJTIwbXVzaWN8ZW58MXx8fHwxNzc0NTQ4NTAzfDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  PlaylistItem(
    name: 'Focus Flow',
    songCount: 12,
    imageUrl:
        'https://images.unsplash.com/photo-1496293455970-f8581aae0e3b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsb2ZpJTIwbXVzaWN8ZW58MXx8fHwxNzc0NTQ4NTU5fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
];

const quickActions = <String>[
  'Random Play',
  'Recently Added',
  'Most Played',
  'Favorites',
];
