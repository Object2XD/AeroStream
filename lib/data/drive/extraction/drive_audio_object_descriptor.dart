import '../../../media_extraction/core/audio_object_descriptor.dart';
import '../../database/app_database.dart';

class DriveAudioObjectDescriptor {
  const DriveAudioObjectDescriptor._();

  static AudioObjectDescriptor fromTrack(Track track) {
    return AudioObjectDescriptor(
      objectId: track.driveFileId,
      fileName: track.fileName,
      mimeType: track.mimeType,
      sizeBytes: track.sizeBytes,
    );
  }
}
