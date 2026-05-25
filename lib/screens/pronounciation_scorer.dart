library pronunciation_scorer;

class PronunciationScorer {
  static double score(String recognised, String expected) {
    final r = _pipeline(recognised);
    final e = _pipeline(expected);

    if (e.isEmpty) return 1.0;
    if (r.isEmpty) return 0.0;

    final tokenScore = _tokenOverlap(r, e);
    final editScore  = _normalisedEdit(r, e);

    return (tokenScore * 0.65 + editScore * 0.35).clamp(0.0, 1.0);
  }

  // ── Full normalisation pipeline ───────────────────────────────────────

  static String _pipeline(String s) {
    s = s.toLowerCase().trim();
    s = _devanagariToRoman(s);   // handle if STT returns Hindi script
    s = _expandSandhi(s);        // split common Sanskrit sandhi joins
    s = _sanskritPhonetics(s);   // map phonetic variations
    s = _indianEnglishPhonetics(s);
    s = s.replaceAll(RegExp(r"[^\w\s]"), '')
         .replaceAll(RegExp(r'\s+'), ' ')
         .trim();
    return s;
  }

  // ── Devanagari → Roman transliteration (for hi-IN STT output) ─────────

  static String _devanagariToRoman(String s) {
    const map = {
      'ॐ': 'om',   'श्री': 'shri',  'नमः': 'namah',
      'नमस्': 'namas', 'शिव': 'shiva', 'विष्णु': 'vishnu',
      'गणेश': 'ganesh', 'कृष्ण': 'krishna', 'राम': 'ram',
      'हरे': 'hare',    'हरि': 'hari',       'देवी': 'devi',
      'महा': 'maha',    'मन्त्र': 'mantra',  'शान्ति': 'shanti',
      'स्वाहा': 'swaha', 'फट': 'phat',       'हुम': 'hum',
      'क्लीं': 'klim',  'ह्रीं': 'hrim',    'श्रीं': 'shrim',
      'ऐं': 'aim',      'दुर्गा': 'durga',  'काली': 'kali',
      'लक्ष्मी': 'lakshmi', 'सरस्वती': 'saraswati',
      'गायत्री': 'gayatri', 'भवानी': 'bhavani',
    };
    map.forEach((dev, roman) => s = s.replaceAll(dev, roman));
    return s;
  }

  // ── Sandhi expansion (common joins that STT breaks differently) ────────

  static String _expandSandhi(String s) {
    return s
      .replaceAll('namaste',     'namas te')
      .replaceAll('namaskaram',  'namas karam')
      .replaceAll('tattvam',     'tat tvam')
      .replaceAll('tatvam',      'tat tvam')
      .replaceAll('satyam',      'sat yam')
      .replaceAll('shivoham',    'shiva aham')
      .replaceAll('soham',       'sa aham')
      .replaceAll('ahambraham',  'aham brahma')
      .replaceAll('satchitanand','sat chit anand')
      .replaceAll('omnamah',     'om namah')
      .replaceAll('ommani',      'om mani')
      .replaceAll('hariom',      'hari om');
  }

  // ── Sanskrit phonetic equivalences ────────────────────────────────────
  // Maps how a pandit pronounces vs how STT captures it

  static String _sanskritPhonetics(String s) {
    return s
      // Aspirated consonants — STT often drops the 'h'
      .replaceAll('bha', 'ba')   .replaceAll('bhe', 'be')
      .replaceAll('bhi', 'bi')   .replaceAll('bho', 'bo')
      .replaceAll('dha', 'da')   .replaceAll('dhe', 'de')
      .replaceAll('dhi', 'di')   .replaceAll('dho', 'do')
      .replaceAll('gha', 'ga')   .replaceAll('ghe', 'ge')
      .replaceAll('kha', 'ka')   .replaceAll('khe', 'ke')
      .replaceAll('tha', 'ta')   .replaceAll('the', 'te')
      .replaceAll('pha', 'pa')   .replaceAll('phe', 'pe')

      // Retroflex vs dental — pandits use retroflex
      .replaceAll('tt',  't')    .replaceAll('dd',  'd')
      .replaceAll('nn',  'n')    .replaceAll('ll',  'l')

      // Sibilants — ś (sh) and ṣ (sh) both become 'sh' or 's' in STT
      .replaceAll('sh',  's')    .replaceAll('shh', 's')
      .replaceAll('ssh', 's')

      // Anusvara (ṃ) and visarga (ḥ) — nasals and breath
      .replaceAll('ng',  'n')    .replaceAll('nk',  'n')
      .replaceAll('ah',  'a')    .replaceAll('ih',  'i')
      .replaceAll('uh',  'u')    .replaceAll('eh',  'e')

      // Vowel length — STT ignores long/short distinction
      .replaceAll('aa', 'a')     .replaceAll('ii', 'i')
      .replaceAll('uu', 'u')     .replaceAll('ee', 'i')
      .replaceAll('oo', 'u')     .replaceAll('ai', 'e')
      .replaceAll('au', 'o')     .replaceAll('ri', 'r')

      // Om variations
      .replaceAll('aum', 'om')   .replaceAll('ohm', 'om')
      .replaceAll('oum', 'om')

      // Common mantra word endings
      .replaceAll('aya',  'a')   .replaceAll('aye',  'a')
      .replaceAll('aye',  'a')   .replaceAll('ani',  'an')
      .replaceAll('aye namaha', 'a namah')

      // Namah variations
      .replaceAll('namaha', 'namah')  .replaceAll('namay',  'namah')
      .replaceAll('nama',   'namah')  .replaceAll('namo',   'namah')
      .replaceAll('namar',  'namah')

      // Swaha variations
      .replaceAll('svaha',  'swaha')  .replaceAll('swah',   'swaha')
      .replaceAll('suaha',  'swaha')

      // Shri/Sri
      .replaceAll('sri',   'shri')    .replaceAll('shree',  'shri')
      .replaceAll('sree',  'shri');
  }

  // ── Indian English phonetics ───────────────────────────────────────────

  static String _indianEnglishPhonetics(String s) {
    return s
      .replaceAll('w',  'v')     // "wery" = "very"
      .replaceAll('z',  'j')     // "zero" = "jero"
      .replaceAll('f',  'ph')    // labio-dental f → ph
      .replaceAll('x',  'ksh')   // "moksha" → "mokxa"
      .replaceAll('q',  'k')
      .replaceAll('jn', 'gy')    // "jnana" → "gyana"
      .replaceAll('ksh','x');
  }

  // ── Token overlap ─────────────────────────────────────────────────────

  static double _tokenOverlap(String r, String e) {
    final rTokens = r.split(' ').toSet();
    final eTokens = e.split(' ').toSet();
    if (eTokens.isEmpty) return 1.0;
    final matched = rTokens.intersection(eTokens).length;
    return matched / eTokens.length;
  }

  // ── Normalised Levenshtein ─────────────────────────────────────────────

  static double _normalisedEdit(String r, String e) {
    final dist = _levenshtein(r, e);
    final maxLen = r.length > e.length ? r.length : e.length;
    if (maxLen == 0) return 1.0;
    return 1.0 - (dist / maxLen);
  }

  static int _levenshtein(String a, String b) {
    final m = a.length, n = b.length;
    List<int> prev = List.generate(n + 1, (j) => j);
    List<int> curr = List.filled(n + 1, 0);
    for (int i = 1; i <= m; i++) {
      curr[0] = i;
      for (int j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [curr[j - 1] + 1, prev[j] + 1, prev[j - 1] + cost]
            .reduce((x, y) => x < y ? x : y);
      }
      final tmp = prev; prev = curr; curr = tmp;
    }
    return prev[n];
  }
}