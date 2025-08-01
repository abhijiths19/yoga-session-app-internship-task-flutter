class PoseSession {
  final Map<String, dynamic> metadata;
  final PoseAssets assets;
  final List<SessionSegment> sequence;

  PoseSession({
    required this.metadata,
    required this.assets,
    required this.sequence,
  });

  factory PoseSession.fromJson(Map<String, dynamic> json) {
    return PoseSession(
      metadata: json['metadata'],
      assets: PoseAssets.fromJson(json['assets']),
      sequence: (json['sequence'] as List)
          .map((e) => SessionSegment.fromJson(e))
          .toList(),
    );
  }
}

class PoseAssets {
  final Map<String, String> images;
  final Map<String, String> audio;

  PoseAssets({required this.images, required this.audio});

  factory PoseAssets.fromJson(Map<String, dynamic> json) {
    return PoseAssets(
      images: Map<String, String>.from(json['images']),
      audio: Map<String, String>.from(json['audio']),
    );
  }
}

class SessionScript {
  final String text;
  final int startSec;
  final int endSec;
  final String imageRef;

  SessionScript({
    required this.text,
    required this.startSec,
    required this.endSec,
    required this.imageRef,
  });

  factory SessionScript.fromJson(Map<String, dynamic> json) {
    return SessionScript(
      text: json['text'],
      startSec: json['startSec'],
      endSec: json['endSec'],
      imageRef: json['imageRef'],
    );
  }
}

class SessionSegment {
  final String type;
  final String name;
  final String audioRef;
  final int durationSec;
  final int? iterations;
  final bool? loopable;
  final List<SessionScript> script;

  SessionSegment({
    required this.type,
    required this.name,
    required this.audioRef,
    required this.durationSec,
    this.iterations,
    this.loopable,
    required this.script,
  });

  factory SessionSegment.fromJson(Map<String, dynamic> json) {
    return SessionSegment(
      type: json['type'],
      name: json['name'],
      audioRef: json['audioRef'],
      durationSec: json['durationSec'],
      iterations: json['iterations'],
      loopable: json['loopable'],
      script: (json['script'] as List)
          .map((e) => SessionScript.fromJson(e))
          .toList(),
    );
  }
}
