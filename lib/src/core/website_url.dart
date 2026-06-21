Uri? normalizedWebsiteUrl(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  final withScheme = trimmed.contains('://') ? trimmed : 'https://$trimmed';
  final uri = Uri.tryParse(withScheme);
  if (uri == null) {
    return null;
  }

  final validScheme = uri.scheme == 'http' || uri.scheme == 'https';
  final host = uri.host.trim();
  if (!validScheme || host.isEmpty || !host.contains('.')) {
    return null;
  }

  return uri;
}

bool isBlankOrValidWebsite(String? value) {
  final trimmed = value?.trim();
  return trimmed == null ||
      trimmed.isEmpty ||
      normalizedWebsiteUrl(trimmed) != null;
}
