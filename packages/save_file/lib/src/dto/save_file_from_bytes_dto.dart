class SaveFileFromBytesDto {
  final List<int> bytes;
  final String name;
  final String mime;

  const SaveFileFromBytesDto({required this.bytes, required this.name, required this.mime});

  Map<String, dynamic> toJson() => {'bytes': bytes, 'name': name, 'mime': mime};
}
