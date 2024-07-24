class PdfFields {
  static final List<String> values = [
    id, name, path
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String path = 'path';
}

class PdfModel {
  final int? id;
  final String name;
  final String path;

  PdfModel({
    this.id,
    required this.name,
    required this.path,
  });

  PdfModel copyWith({
    int? id,
    String? name,
    String? path,
  }) {
    return PdfModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      PdfFields.id: id,
      PdfFields.name: name,
      PdfFields.path: path,
    };
  }

  factory PdfModel.fromMap(Map<String, dynamic> map) {
    return PdfModel(
      id: map[PdfFields.id] as int?,
      name: map[PdfFields.name] as String,
      path: map[PdfFields.path] as String,
    );
  }
}
