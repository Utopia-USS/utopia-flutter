class SaveFileMetadata {
  final String mime, name;

  const SaveFileMetadata({required this.mime, required this.name});

  SaveFileMetadata copyWith({String? mime, String? name}) =>
      SaveFileMetadata(mime: mime ?? this.mime, name: name ?? this.name);
}
