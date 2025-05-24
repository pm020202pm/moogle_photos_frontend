class DriveFile {
  final String id;
  final String name;
  final String mimeType;
  final String size;
  final DateTime createdTime;
  final String? thumbnailLink;
  final DateTime modifiedTime;
  final String ownerEmail;

  DriveFile({
    required this.id,
    required this.name,
    required this.mimeType,
    this.thumbnailLink,
    required this.createdTime,
    required this.modifiedTime,
    required this.size,
    required this.ownerEmail,
  });

  factory DriveFile.fromJson(Map<String, dynamic> json) {
    return DriveFile(
      id: json['id'],
      name: json['name'],
      mimeType: json['mimeType']??'',
      thumbnailLink: json['thumbnailLink']?? '',
      createdTime: DateTime.parse(json['createdTime']),
      modifiedTime: DateTime.parse(json['modifiedTime']),
      size: json['size'] ?? '0',
      ownerEmail: json['owners'][0]['emailAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mimeType': mimeType,
      'thumbnailLink': thumbnailLink,
      'createdTime': createdTime.toIso8601String(),
      'modifiedTime': modifiedTime.toIso8601String(),
      'size': size,
      'ownerEmail': ownerEmail,
    };
  }
}
