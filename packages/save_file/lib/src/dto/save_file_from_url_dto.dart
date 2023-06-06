class SaveFileFromUrlDto {
  final String url;
  final String name;

  const SaveFileFromUrlDto({required this.url, required this.name});

  Map<String, dynamic> toJson() => {'url': url, 'name': name};
}
