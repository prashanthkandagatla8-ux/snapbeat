import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SoundTrack {
  final String id;
  final String title;
  final String genre;
  final String bpm;
  final String vibe;
  final String assetPath;
  final double durationSeconds;
  final String fileName;

  const SoundTrack({
    required this.id,
    required this.title,
    required this.genre,
    required this.bpm,
    required this.vibe,
    required this.assetPath,
    required this.durationSeconds,
    required this.fileName,
  });

  /// Ensures the asset is extracted to a readable local file in the app's cache directory.
  Future<File> getCachedFile() async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }
    return file;
  }

  /// Curated library of 8 built-in studio analog tapes
  static const List<SoundTrack> builtInLibrary = [
    SoundTrack(
      id: 'funk_smooth_party',
      title: 'Funk Smooth Party',
      genre: 'Nu-Funk / Retro',
      bpm: '124 BPM',
      vibe: 'Upbeat 1970s funk groove with brass hits and dynamic breaks',
      assetPath: 'assets/audio/funk_smooth_party.mp3',
      durationSeconds: 58.0,
      fileName: 'funk_smooth_party.mp3',
    ),
    SoundTrack(
      id: 'urban_boom_bap',
      title: 'Urban Boom Bap',
      genre: 'Hip-Hop / Rap',
      bpm: '92 BPM',
      vibe: 'Punchy 46-second classic boom-bap rhythm with crisp snare snaps',
      assetPath: 'assets/audio/urban_boom_bap.mp3',
      durationSeconds: 46.0,
      fileName: 'urban_boom_bap.mp3',
    ),
    SoundTrack(
      id: 'percussion_drive',
      title: 'Percussion Drive',
      genre: 'Acoustic / Stomp',
      bpm: '110 BPM',
      vibe: 'Organic stomps, handclaps, and rhythmic cajón builds',
      assetPath: 'assets/audio/percussion_drive.mp3',
      durationSeconds: 62.0,
      fileName: 'percussion_drive.mp3',
    ),
    SoundTrack(
      id: 'chill_vlog_beat',
      title: 'Chill Vlog Hip-Hop',
      genre: 'Lo-Fi / Vlog',
      bpm: '88 BPM',
      vibe: 'Mellow electric keys and relaxing sunny beats for aesthetic reels',
      assetPath: 'assets/audio/chill_vlog_beat.mp3',
      durationSeconds: 78.0,
      fileName: 'chill_vlog_beat.mp3',
    ),
    SoundTrack(
      id: 'sweet_life_chill',
      title: 'Sweet Life Lounge',
      genre: 'Downtempo / Chill',
      bpm: '100 BPM',
      vibe: 'Deep synth basslines and stylish luxury lounge vibes',
      assetPath: 'assets/audio/sweet_life_chill.mp3',
      durationSeconds: 83.0,
      fileName: 'sweet_life_chill.mp3',
    ),
    SoundTrack(
      id: 'action_stinger',
      title: 'Action Stinger (18s)',
      genre: 'Dynamic / Short',
      bpm: '128 BPM',
      vibe: 'Fast-paced 18s hype track tailor-made for rapid beat transitions',
      assetPath: 'assets/audio/action_stinger.mp3',
      durationSeconds: 18.0,
      fileName: 'action_stinger.mp3',
    ),
    SoundTrack(
      id: 'celebration_anthem',
      title: 'Celebration Anthem',
      genre: 'Festive / Pop',
      bpm: '120 BPM',
      vibe: 'Joyful celebration fanfare and driving rhythm for party reels',
      assetPath: 'assets/audio/celebration_anthem.mp3',
      durationSeconds: 106.0,
      fileName: 'celebration_anthem.mp3',
    ),
    SoundTrack(
      id: 'heavy_bass_dubstep',
      title: 'Heavy Bass Dubstep',
      genre: 'Bass / Dubstep',
      bpm: '140 BPM',
      vibe: 'High-energy electronic drop with heavy sub-bass wobble',
      assetPath: 'assets/audio/heavy_bass_dubstep.mp3',
      durationSeconds: 126.0,
      fileName: 'heavy_bass_dubstep.mp3',
    ),
  ];
}
