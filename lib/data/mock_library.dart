import '../models/library_models.dart';
import '../models/track_item.dart';

const libraryAlbums = <LibraryAlbum>[
  LibraryAlbum(
    id: '1',
    title: 'Neon Nights',
    artist: 'Luna Wave',
    year: 2024,
    imageUrl:
        'https://images.unsplash.com/photo-1644855640845-ab57a047320e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNpYyUyMGFsYnVtJTIwY292ZXIlMjBhcnR8ZW58MXx8fHwxNzc0NDkzMTQ0fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  LibraryAlbum(
    id: '2',
    title: 'Throwback',
    artist: 'Retro Beats',
    year: 2023,
    imageUrl:
        'https://images.unsplash.com/photo-1603850121303-d4ade9e5ba65?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx2aW55bCUyMHJlY29yZCUyMHBsYXllcnxlbnwxfHx8fDE3NzQ0NzI4NTZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  LibraryAlbum(
    id: '3',
    title: 'Live Session',
    artist: 'Electric Vibe',
    year: 2022,
    imageUrl:
        'https://images.unsplash.com/photo-1689793354800-de168c0a4c9b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb25jZXJ0JTIwc3RhZ2UlMjBsaWdodHN8ZW58MXx8fHwxNzc0NDY4MDc1fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  LibraryAlbum(
    id: '4',
    title: 'Rock Anthems',
    artist: 'Thunder Road',
    year: 2021,
    imageUrl:
        'https://images.unsplash.com/photo-1717978227404-4d3db15e3d13?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyb2NrJTIwYmFuZCUyMGNvbmNlcnR8ZW58MXx8fHwxNzc0NDg0NDE1fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
];

const libraryArtists = <LibraryArtist>[
  LibraryArtist(
    id: '1',
    name: 'Luna Wave',
    songCount: 24,
    imageUrl:
        'https://images.unsplash.com/photo-1644855640845-ab57a047320e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNpYyUyMGFsYnVtJTIwY292ZXIlMjBhcnR8ZW58MXx8fHwxNzc0NDkzMTQ0fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  LibraryArtist(
    id: '2',
    name: 'Retro Beats',
    songCount: 15,
    imageUrl:
        'https://images.unsplash.com/photo-1603850121303-d4ade9e5ba65?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx2aW55bCUyMHJlY29yZCUyMHBsYXllcnxlbnwxfHx8fDE3NzQ0NzI4NTZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  LibraryArtist(
    id: '3',
    name: 'Electric Vibe',
    songCount: 42,
    imageUrl:
        'https://images.unsplash.com/photo-1692176548571-86138128e36c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxlbGVjdHJvbmljJTIwbXVzaWMlMjBkanxlbnwxfHx8fDE3NzQ1MjI2MTJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  LibraryArtist(
    id: '4',
    name: 'Symphony Orchestra',
    songCount: 8,
    imageUrl:
        'https://images.unsplash.com/photo-1685954154829-5ebdf5956824?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjbGFzc2ljYWwlMjBvcmNoZXN0cmElMjB2aW9saW58ZW58MXx8fHwxNzc0NTQzNjYwfDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
];

const libraryAlbumArtists = <LibraryAlbumArtist>[
  LibraryAlbumArtist(
    id: '1',
    name: 'Luna Wave',
    albumCount: 3,
    imageUrl:
        'https://images.unsplash.com/photo-1644855640845-ab57a047320e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNpYyUyMGFsYnVtJTIwY292ZXIlMjBhcnR8ZW58MXx8fHwxNzc0NDkzMTQ0fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  LibraryAlbumArtist(
    id: '2',
    name: 'Various Artists',
    albumCount: 5,
    imageUrl:
        'https://images.unsplash.com/photo-1603850121303-d4ade9e5ba65?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx2aW55bCUyMHJlY29yZCUyMHBsYXllcnxlbnwxfHx8fDE3NzQ0NzI4NTZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  LibraryAlbumArtist(
    id: '3',
    name: 'Electric Vibe',
    albumCount: 2,
    imageUrl:
        'https://images.unsplash.com/photo-1692176548571-86138128e36c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxlbGVjdHJvbmljJTIwbXVzaWMlMjBkanxlbnwxfHx8fDE3NzQ1MjI2MTJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  LibraryAlbumArtist(
    id: '4',
    name: 'Symphony Orchestra',
    albumCount: 4,
    imageUrl:
        'https://images.unsplash.com/photo-1685954154829-5ebdf5956824?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjbGFzc2ljYWwlMjBvcmNoZXN0cmElMjB2aW9saW58ZW58MXx8fHwxNzc0NTQzNjYwfDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
];

const libraryGenres = <LibraryGenre>[
  LibraryGenre(
    id: '1',
    name: 'Electronic',
    songCount: 42,
    imageUrl:
        'https://images.unsplash.com/photo-1692176548571-86138128e36c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxlbGVjdHJvbmljJTIwbXVzaWMlMjBkanxlbnwxfHx8fDE3NzQ1MjI2MTJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  LibraryGenre(
    id: '2',
    name: 'Rock',
    songCount: 38,
    imageUrl:
        'https://images.unsplash.com/photo-1717978227404-4d3db15e3d13?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyb2NrJTIwYmFuZCUyMGNvbmNlcnR8ZW58MXx8fHwxNzc0NDg0NDE1fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  LibraryGenre(
    id: '3',
    name: 'Classical',
    songCount: 26,
    imageUrl:
        'https://images.unsplash.com/photo-1685954154829-5ebdf5956824?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjbGFzc2ljYWwlMjBvcmNoZXN0cmElMjB2aW9saW58ZW58MXx8fHwxNzc0NTQzNjYwfDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  LibraryGenre(
    id: '4',
    name: 'Jazz',
    songCount: 31,
    imageUrl:
        'https://images.unsplash.com/photo-1546058256-47154de4046c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaWFubyUyMGtleXMlMjBibGFja3xlbnwxfHx8fDE3NzQ1NDY0NDl8MA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
];

const librarySongs = <TrackItem>[
  TrackItem(
    id: 101,
    title: 'Midnight Dreams',
    artist: 'Luna Wave',
    album: 'Neon Nights',
    durationSeconds: 225,
    imageUrl:
        'https://images.unsplash.com/photo-1644855640845-ab57a047320e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNpYyUyMGFsYnVtJTIwY292ZXIlMjBhcnR8ZW58MXx8fHwxNzc0NDkzMTQ0fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  TrackItem(
    id: 102,
    title: 'Vinyl Memories',
    artist: 'Retro Beats',
    album: 'Throwback',
    durationSeconds: 252,
    imageUrl:
        'https://images.unsplash.com/photo-1603850121303-d4ade9e5ba65?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx2aW55bCUyMHJlY29yZCUyMHBsYXllcnxlbnwxfHx8fDE3NzQ0NzI4NTZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  TrackItem(
    id: 103,
    title: 'Stage Light',
    artist: 'Electric Vibe',
    album: 'Live Session',
    durationSeconds: 208,
    imageUrl:
        'https://images.unsplash.com/photo-1689793354800-de168c0a4c9b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb25jZXJ0JTIwc3RhZ2UlMjBsaWdodHN8ZW58MXx8fHwxNzc0NDY4MDc1fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  TrackItem(
    id: 104,
    title: 'Silent Waves',
    artist: 'Ambient Flow',
    album: 'Soundscapes',
    durationSeconds: 301,
    imageUrl:
        'https://images.unsplash.com/photo-1649956736509-f359d191bbcb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoZWFkcGhvbmVzJTIwbXVzaWN8ZW58MXx8fHwxNzc0NTE5MDE2fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  TrackItem(
    id: 105,
    title: 'Thunder Road',
    artist: 'Stone Arcade',
    album: 'Rock Anthems',
    durationSeconds: 272,
    imageUrl:
        'https://images.unsplash.com/photo-1717978227404-4d3db15e3d13?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyb2NrJTIwYmFuZCUyMGNvbmNlcnR8ZW58MXx8fHwxNzc0NDg0NDE1fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
];

const libraryAlbumTracksByAlbumId = <String, List<TrackItem>>{
  '1': [
    TrackItem(
      id: 101,
      title: 'Midnight Dreams',
      artist: 'Luna Wave',
      album: 'Neon Nights',
      durationSeconds: 225,
      imageUrl:
          'https://images.unsplash.com/photo-1644855640845-ab57a047320e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNpYyUyMGFsYnVtJTIwY292ZXIlMjBhcnR8ZW58MXx8fHwxNzc0NDkzMTQ0fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    TrackItem(
      id: 106,
      title: 'Neon Signals',
      artist: 'Luna Wave',
      album: 'Neon Nights',
      durationSeconds: 238,
      imageUrl:
          'https://images.unsplash.com/photo-1644855640845-ab57a047320e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNpYyUyMGFsYnVtJTIwY292ZXIlMjBhcnR8ZW58MXx8fHwxNzc0NDkzMTQ0fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    TrackItem(
      id: 107,
      title: 'Satellite Hearts',
      artist: 'Luna Wave',
      album: 'Neon Nights',
      durationSeconds: 246,
      imageUrl:
          'https://images.unsplash.com/photo-1644855640845-ab57a047320e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNpYyUyMGFsYnVtJTIwY292ZXIlMjBhcnR8ZW58MXx8fHwxNzc0NDkzMTQ0fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    TrackItem(
      id: 108,
      title: 'After Hours Bloom',
      artist: 'Luna Wave',
      album: 'Neon Nights',
      durationSeconds: 261,
      imageUrl:
          'https://images.unsplash.com/photo-1644855640845-ab57a047320e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNpYyUyMGFsYnVtJTIwY292ZXIlMjBhcnR8ZW58MXx8fHwxNzc0NDkzMTQ0fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
  ],
  '2': [
    TrackItem(
      id: 102,
      title: 'Vinyl Memories',
      artist: 'Retro Beats',
      album: 'Throwback',
      durationSeconds: 252,
      imageUrl:
          'https://images.unsplash.com/photo-1603850121303-d4ade9e5ba65?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx2aW55bCUyMHJlY29yZCUyMHBsYXllcnxlbnwxfHx8fDE3NzQ0NzI4NTZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    TrackItem(
      id: 109,
      title: 'Tape Deck Love',
      artist: 'Retro Beats',
      album: 'Throwback',
      durationSeconds: 214,
      imageUrl:
          'https://images.unsplash.com/photo-1603850121303-d4ade9e5ba65?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx2aW55bCUyMHJlY29yZCUyMHBsYXllcnxlbnwxfHx8fDE3NzQ0NzI4NTZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    TrackItem(
      id: 110,
      title: 'Dust & Echo',
      artist: 'Retro Beats',
      album: 'Throwback',
      durationSeconds: 228,
      imageUrl:
          'https://images.unsplash.com/photo-1603850121303-d4ade9e5ba65?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx2aW55bCUyMHJlY29yZCUyMHBsYXllcnxlbnwxfHx8fDE3NzQ0NzI4NTZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    TrackItem(
      id: 111,
      title: 'Polaroid Groove',
      artist: 'Retro Beats',
      album: 'Throwback',
      durationSeconds: 243,
      imageUrl:
          'https://images.unsplash.com/photo-1603850121303-d4ade9e5ba65?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx2aW55bCUyMHJlY29yZCUyMHBsYXllcnxlbnwxfHx8fDE3NzQ0NzI4NTZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
  ],
  '3': [
    TrackItem(
      id: 103,
      title: 'Stage Light',
      artist: 'Electric Vibe',
      album: 'Live Session',
      durationSeconds: 208,
      imageUrl:
          'https://images.unsplash.com/photo-1689793354800-de168c0a4c9b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb25jZXJ0JTIwc3RhZ2UlMjBsaWdodHN8ZW58MXx8fHwxNzc0NDY4MDc1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    TrackItem(
      id: 112,
      title: 'Crowd Glow',
      artist: 'Electric Vibe',
      album: 'Live Session',
      durationSeconds: 231,
      imageUrl:
          'https://images.unsplash.com/photo-1689793354800-de168c0a4c9b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb25jZXJ0JTIwc3RhZ2UlMjBsaWdodHN8ZW58MXx8fHwxNzc0NDY4MDc1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    TrackItem(
      id: 113,
      title: 'Voltage Bloom',
      artist: 'Electric Vibe',
      album: 'Live Session',
      durationSeconds: 256,
      imageUrl:
          'https://images.unsplash.com/photo-1689793354800-de168c0a4c9b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb25jZXJ0JTIwc3RhZ2UlMjBsaWdodHN8ZW58MXx8fHwxNzc0NDY4MDc1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    TrackItem(
      id: 114,
      title: 'Encore Pulse',
      artist: 'Electric Vibe',
      album: 'Live Session',
      durationSeconds: 269,
      imageUrl:
          'https://images.unsplash.com/photo-1689793354800-de168c0a4c9b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb25jZXJ0JTIwc3RhZ2UlMjBsaWdodHN8ZW58MXx8fHwxNzc0NDY4MDc1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
  ],
  '4': [
    TrackItem(
      id: 105,
      title: 'Thunder Road',
      artist: 'Stone Arcade',
      album: 'Rock Anthems',
      durationSeconds: 272,
      imageUrl:
          'https://images.unsplash.com/photo-1717978227404-4d3db15e3d13?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyb2NrJTIwYmFuZCUyMGNvbmNlcnR8ZW58MXx8fHwxNzc0NDg0NDE1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    TrackItem(
      id: 115,
      title: 'Amplifier Sky',
      artist: 'Stone Arcade',
      album: 'Rock Anthems',
      durationSeconds: 236,
      imageUrl:
          'https://images.unsplash.com/photo-1717978227404-4d3db15e3d13?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyb2NrJTIwYmFuZCUyMGNvbmNlcnR8ZW58MXx8fHwxNzc0NDg0NDE1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    TrackItem(
      id: 116,
      title: 'Static Hearts',
      artist: 'Stone Arcade',
      album: 'Rock Anthems',
      durationSeconds: 248,
      imageUrl:
          'https://images.unsplash.com/photo-1717978227404-4d3db15e3d13?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyb2NrJTIwYmFuZCUyMGNvbmNlcnR8ZW58MXx8fHwxNzc0NDg0NDE1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    TrackItem(
      id: 117,
      title: 'Midnight Riot',
      artist: 'Stone Arcade',
      album: 'Rock Anthems',
      durationSeconds: 284,
      imageUrl:
          'https://images.unsplash.com/photo-1717978227404-4d3db15e3d13?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyb2NrJTIwYmFuZCUyMGNvbmNlcnR8ZW58MXx8fHwxNzc0NDg0NDE1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
  ],
};

LibraryAlbum? libraryAlbumById(String albumId) {
  for (final album in libraryAlbums) {
    if (album.id == albumId) {
      return album;
    }
  }

  return null;
}

List<TrackItem>? libraryAlbumTracksById(String albumId) {
  final tracks = libraryAlbumTracksByAlbumId[albumId];
  if (tracks == null) {
    return null;
  }

  return List<TrackItem>.unmodifiable(tracks);
}
