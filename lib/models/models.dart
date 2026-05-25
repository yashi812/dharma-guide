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

// A single step in the Vidhi (ritual procedure)
class VidhiStep {
  final String title;
  final String description;
  final String? mantra; // optional mantra to chant during this step
  const VidhiStep({
    required this.title,
    required this.description,
    this.mantra,
  });
}

// A section of the Katha (sacred story)
class KathaSection {
  final String heading;
  final String body;
  const KathaSection({required this.heading, required this.body});
}

// Full puja ritual with Vidhi + Katha
class PujaRitual {
  final String id;
  final String name;       // e.g. "Satyanarayan Katha"
  final String deity;      // e.g. "Lord Vishnu"
  final String emoji;
  final String tagline;    // short subtitle
  final String importance; // why this puja is performed
  final List<VidhiStep> vidhi;   // step-by-step ritual guide
  final List<KathaSection> katha; // sacred story
  final List<String> samagri;    // required puja items

  const PujaRitual({
    required this.id,
    required this.name,
    required this.deity,
    required this.emoji,
    required this.tagline,
    required this.importance,
    required this.vidhi,
    required this.katha,
    required this.samagri,
  });
}
