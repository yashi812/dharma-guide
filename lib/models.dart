class Mantra {
  final String id, name, deity, diff, meaning;
  final List<String> lines, tr;
  final bool premium;
  const Mantra({
    required this.id,
    required this.name,
    required this.deity,
    required this.diff,
    required this.meaning,
    required this.lines,
    required this.tr,
    this.premium = false,
  });
}

class Mood {
  final String id, emoji, label;
  const Mood({required this.id, required this.emoji, required this.label});
}

class GuidanceStyle {
  final String id, icon, label, desc;
  const GuidanceStyle({
    required this.id,
    required this.icon,
    required this.label,
    required this.desc,
  });
}

class GitaVerse {
  final int ch, v;
  final String text, theme;
  const GitaVerse({
    required this.ch,
    required this.v,
    required this.text,
    required this.theme,
  });
}

class Topic {
  final String id, icon, label;
  const Topic({required this.id, required this.icon, required this.label});
}
