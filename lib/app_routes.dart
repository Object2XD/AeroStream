abstract final class AppRoutes {
  static const root = '/';
  static const home = '/home';
  static const player = '/player';
  static const queue = '/queue';
  static const library = '/library';
  static const playlists = '/playlists';
  static const info = '/info';
  static const infoGoogleDrive = '/info/google-drive';
  static const infoListeningTime = '/info/listening-time';
  static const infoSongsPlayed = '/info/songs-played';

  static const tabLocations = <String>[home, library, playlists, info];

  static String libraryAlbumDetail(String albumId) => '$library/album/$albumId';
}
