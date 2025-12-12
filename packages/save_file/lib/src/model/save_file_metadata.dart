class SaveFileMetadata {
  final String object, mime, name;

  const SaveFileMetadata({required this.object, required this.mime, required this.name});

  SaveFileMetadata copyWith({String? mime, String? name}) =>
      SaveFileMetadata(object: object, mime: mime ?? this.mime, name: name ?? this.name);

  @override
  String toString() => "$object (name=$name, mime=$mime)";
}
