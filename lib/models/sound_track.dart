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
      final tmpFile = File('${file.path}.tmp');
      await tmpFile.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
      await tmpFile.rename(file.path);
    }
    if (await file.length() <= 0) {
      await file.delete();
      return getCachedFile();
    }
    return file;
  }

  /// Curated library of built-in studio analog tapes
  static const List<SoundTrack> builtInLibrary = [
    SoundTrack(
      id: 'funk_smooth_party',
      title: 'Funk Smooth Party',
      genre: 'Nu-Funk / Retro',
      bpm: '124 BPM',
      vibe: 'Upbeat 1970s funk groove with brass hits and dynamic breaks',
      assetPath: 'assets/audio/funk_smooth_party.mp3',
      durationSeconds: 71.5,
      fileName: 'funk_smooth_party.mp3',
    ),
    SoundTrack(
      id: 'urban_boom_bap',
      title: 'Urban Boom Bap (46s)',
      genre: 'Hip-Hop / Rap',
      bpm: '92 BPM',
      vibe: 'Punchy 46-second classic boom-bap rhythm with crisp snare snaps',
      assetPath: 'assets/audio/urban_boom_bap.mp3',
      durationSeconds: 46.0,
      fileName: 'urban_boom_bap.mp3',
    ),
    SoundTrack(
      id: 'rap_beat_extended',
      title: 'Urban Boom Bap (66s)',
      genre: 'Hip-Hop / Rap',
      bpm: '92 BPM',
      vibe: 'Extended 66-second boom-bap rhythm with heavy kick & hi-hat chops',
      assetPath: 'assets/audio/rap_beat_extended.mp3',
      durationSeconds: 66.4,
      fileName: 'rap_beat_extended.mp3',
    ),
    SoundTrack(
      id: 'hood_90s_boombap',
      title: '90s Hood Boom Bap',
      genre: 'Golden Era / 90s',
      bpm: '90 BPM',
      vibe: 'Authentic 90s vinyl texture with vintage drum chops and street warmth',
      assetPath: 'assets/audio/hood_90s_boombap.mp3',
      durationSeconds: 174.0,
      fileName: 'hood_90s_boombap.mp3',
    ),
    SoundTrack(
      id: 'voicemails_90s_boombap',
      title: '90s Voicemails',
      genre: 'Lo-Fi / 90s',
      bpm: '88 BPM',
      vibe: 'Nostalgic telephone intro leading into a laidback dusty boom-bap beat',
      assetPath: 'assets/audio/voicemails_90s_boombap.mp3',
      durationSeconds: 176.1,
      fileName: 'voicemails_90s_boombap.mp3',
    ),
    SoundTrack(
      id: 'sweet_life_chill',
      title: 'Sweet Life Lounge',
      genre: 'Downtempo / Chill',
      bpm: '85 BPM',
      vibe: 'Deep synth basslines and stylish luxury lounge sunset vibes',
      assetPath: 'assets/audio/sweet_life_chill.mp3',
      durationSeconds: 102.3,
      fileName: 'sweet_life_chill.mp3',
    ),
    SoundTrack(
      id: 'lofi_sunset_beat',
      title: 'Lo-Fi Sunset Beat',
      genre: 'Lo-Fi / Study',
      bpm: '80 BPM',
      vibe: 'Warm vinyl crackle, gentle electric piano chords, and soothing tempo',
      assetPath: 'assets/audio/lofi_sunset_beat.mp3',
      durationSeconds: 113.5,
      fileName: 'lofi_sunset_beat.mp3',
    ),
    SoundTrack(
      id: 'chill_vlog_beat',
      title: 'Chill Vlog Hip-Hop',
      genre: 'Lo-Fi / Vlog',
      bpm: '90 BPM',
      vibe: 'Mellow electric keys and relaxing sunny beats for aesthetic reels',
      assetPath: 'assets/audio/chill_vlog_beat.mp3',
      durationSeconds: 96.0,
      fileName: 'chill_vlog_beat.mp3',
    ),
    SoundTrack(
      id: 'percussion_drive',
      title: 'Percussion Drive',
      genre: 'Acoustic / Stomp',
      bpm: '115 BPM',
      vibe: 'Organic stomps, handclaps, and rhythmic cajon builds',
      assetPath: 'assets/audio/percussion_drive.mp3',
      durationSeconds: 76.0,
      fileName: 'percussion_drive.mp3',
    ),
    SoundTrack(
      id: 'action_stinger',
      title: 'Action Stinger',
      genre: 'Dynamic / Short',
      bpm: '130 BPM',
      vibe: 'Fast-paced hype track tailor-made for rapid beat transitions',
      assetPath: 'assets/audio/action_stinger.mp3',
      durationSeconds: 44.9,
      fileName: 'action_stinger.mp3',
    ),
    SoundTrack(
      id: 'celebration_anthem',
      title: 'Celebration Anthem',
      genre: 'Festive / Pop',
      bpm: '120 BPM',
      vibe: 'Joyful celebration fanfare and driving rhythm for party reels',
      assetPath: 'assets/audio/celebration_anthem.mp3',
      durationSeconds: 130.9,
      fileName: 'celebration_anthem.mp3',
    ),
    SoundTrack(
      id: 'heavy_bass_dubstep',
      title: 'Heavy Bass Dubstep',
      genre: 'Bass / Dubstep',
      bpm: '140 BPM',
      vibe: 'High-energy electronic drop with heavy sub-bass wobble',
      assetPath: 'assets/audio/heavy_bass_dubstep.mp3',
      durationSeconds: 156.0,
      fileName: 'heavy_bass_dubstep.mp3',
    ),
    SoundTrack(
      id: 'melodic_techno_journey',
      title: 'Melodic Techno Journey',
      genre: 'Techno / Deep',
      bpm: '126 BPM',
      vibe: 'Hypnotic rolling bassline and cinematic synth progressions',
      assetPath: 'assets/audio/melodic_techno_journey.mp3',
      durationSeconds: 304.0,
      fileName: 'melodic_techno_journey.mp3',
    ),
    SoundTrack(
      id: 'melody_so_melody',
      title: 'Melody So Melody',
      genre: 'House / Dance',
      bpm: '122 BPM',
      vibe: 'Catchy progressive dance groove with sparkling vocal hooks',
      assetPath: 'assets/audio/melody_so_melody.mp3',
      durationSeconds: 166.6,
      fileName: 'melody_so_melody.mp3',
    ),
    SoundTrack(
      id: 'aerobic_edm_remix',
      title: 'Aerobic EDM Remix',
      genre: 'EDM / Workout',
      bpm: '97 BPM',
      vibe: 'Driving electronic beat, high motivation drop, and club energy',
      assetPath: 'assets/audio/aerobic_edm_remix.mp3',
      durationSeconds: 156.9,
      fileName: 'aerobic_edm_remix.mp3',
    ),
    SoundTrack(
      id: 'emotional_happy_boombap',
      title: 'Goodbye Emotional Beat',
      genre: 'Emotional / Hip-Hop',
      bpm: '88 BPM',
      vibe: 'Soulful piano chords, warm vinyl snare, and heartfelt storytelling rhythm',
      assetPath: 'assets/audio/emotional_happy_boombap.mp3',
      durationSeconds: 243.6,
      fileName: 'emotional_happy_boombap.mp3',
    ),
  ];
}
