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
class ManifestationTechnique {
  final String name;
  final String tag;
  final String emoji;
  final String listSub;
  final String sub;
  final List<String> badges;
  final String what;
  final List<Map<String, String>> steps;
  final List<String> tips;

  const ManifestationTechnique({
    required this.name,
    required this.tag,
    required this.emoji,
    required this.listSub,
    required this.sub,
    required this.badges,
    required this.what,
    required this.steps,
    required this.tips,
  });
}
// Add to lib/models/models.dart
class Aarti {
  final String name;
  final String deity;
  final String emoji;
  final String sub;
  final List<String> verses;

  const Aarti({
    required this.name,
    required this.deity,
    required this.emoji,
    required this.sub,
    required this.verses,
  });
}
class PujaVidhiStep {
  final String title;
  final String instruction;
  final String? mantra;
  final String? tip;

  const PujaVidhiStep({
    required this.title,
    required this.instruction,
    this.mantra,
    this.tip,
  });
}

class PujaKatha {
  final String title;
  final List<String> paragraphs; // one entry per adhyaya/chapter
  final String phalashruti;      // benefit verse at the end

  const PujaKatha({
    required this.title,
    required this.paragraphs,
    required this.phalashruti,
  });
}

class VistarPuja {
  final String id;
  final String name;
  final String deity;
  final String emoji;
  final String sub;
  final String occasion;
  final List<String> samagri;       // items needed
  final List<PujaVidhiStep> vidhi;  // step-by-step ritual
  final PujaKatha? katha;           // null if no traditional katha
  final String? linkedAartiName;    // to look up in kAartis

  const VistarPuja({
    required this.id,
    required this.name,
    required this.deity,
    required this.emoji,
    required this.sub,
    required this.occasion,
    required this.samagri,
    required this.vidhi,
    this.katha,
    this.linkedAartiName,
  });
}