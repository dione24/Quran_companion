class Reciter {
  final String identifier;
  final String name;
  final String englishName;
  final String style;
  final String bitrate;

  Reciter({
    required this.identifier,
    required this.name,
    required this.englishName,
    required this.style,
    required this.bitrate,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      identifier: json['identifier'] ?? '',
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      style: json['style'] ?? '',
      bitrate: json['bitrate']?.toString() ?? '128',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'name': name,
      'englishName': englishName,
      'style': style,
      'bitrate': bitrate,
    };
  }
}