String cleanBadWords(String text) {
  if (text.isEmpty) return text;

  const badWords = [
    "puto",
    "puta",
    "pendejo",
    "pendeja",
    "chingada",
    "chingar",
    "mierda",
    "verga",
    "cabrón",
    "cabron",
    "culero",
    "culo",
    "culito",
    "putito"
  ];

  String result = text;

  for (final word in badWords) {
    final regex = RegExp(
      r'\b' + word + r'\b',
      caseSensitive: false,
    );

    result = result.replaceAllMapped(regex, (match) {
      return '*' * match.group(0)!.length;
    });
  }

  return result;
}
