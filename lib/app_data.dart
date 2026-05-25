import 'package:dharma_guide/models.dart' hide GitaVerse, Topic, GuidanceStyle, Mood;

import '../models/models.dart';

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
const kTechniques = [
  ManifestationTechnique(
    name: '21-Day Journaling',
    tag: '21-DAY CHALLENGE',
    emoji: '📓',
    listSub: 'Write your intention 21 days straight',
    sub: 'Rewire your subconscious through daily written intention over 21 consecutive days.',
    badges: ['21 days', '10 min/day', 'Beginner'],
    what: 'It takes roughly 21 days to form a new neural pathway. Writing the same clear intention every single day — without skipping — moves your desire from conscious thought into subconscious belief. The subconscious mind does not distinguish between what is real and what is vividly imagined, so consistent repetition trains it to accept your desire as truth.',
    steps: [
      {
        't': 'Choose ONE clear intention',
        'd': 'Before Day 1, decide exactly what you want to manifest. Be specific. Instead of "I want money", write "I am grateful that I now earn ₹1,00,000 per month doing work I love." Keep it present tense, positive, and emotionally charged.',
      },
      {
        't': 'Set a fixed daily ritual time',
        'd': 'Pick the same time every day — ideally right after waking up (6–8am) when your mind is most receptive. Keep your journal and pen on your bedside table so there is zero friction to starting.',
      },
      {
        't': 'Write your intention 15 times',
        'd': 'Sit quietly, take 3 deep breaths, then write your intention exactly 15 times. Do not rush or copy-paste mentally. Write each line slowly and FEEL the emotion of it being true — joy, gratitude, relief. If your mind wanders, gently bring it back.',
      },
      {
        't': 'Add a gratitude close',
        'd': 'After your 15 lines, write 3 things you are genuinely grateful for today. This shifts your energy from lack to abundance and seals the practice on a high vibration. Example: "I am grateful for my health, my family, and this morning\'s sunlight."',
      },
      {
        't': 'Track your streak — restart if you skip',
        'd': 'Mark each completed day with a tick or star in your journal. Consistency is EVERYTHING in this practice. If you miss even one day, the neural pathway resets. Start fresh from Day 1 with full commitment and no guilt.',
      },
      {
        't': 'On Day 21, read all entries aloud',
        'd': 'On the final day, sit with your journal and read all 21 entries from the beginning. Notice how your handwriting changes, how the words start to feel more natural and true. This is your subconscious integrating the belief.',
      },
    ],
    tips: [
      'Use a dedicated journal ONLY for this practice — never mix it with shopping lists or daily notes. Sacred space matters.',
      'If you feel resistance or boredom while writing, that is the old belief system fighting back. Write through it — that discomfort is growth.',
      'Light a candle or incense before starting to signal to your brain that this is a ritual, not a chore.',
      'Do not share your intention with others during the 21 days. Protect your energy and let the seed grow in silence.',
      'Pair this with a 2-minute visualisation immediately after writing — close your eyes and SEE your intention as already real.',
    ],
  ),
  ManifestationTechnique(
    name: '3-6-9 Method',
    tag: 'NIKOLA TESLA METHOD',
    emoji: '🔢',
    listSub: 'Affirm 3× morning, 6× afternoon, 9× night',
    sub: "Use Tesla's sacred numbers to anchor your affirmation into the rhythm of your entire day.",
    badges: ['33× daily', '5 min/session', 'Structured'],
    what: 'Nikola Tesla believed 3, 6, and 9 were the keys to the universe. This method structures your affirmations in alignment with the three natural energy peaks of a day — creation in the morning, amplification in the afternoon, and surrender at night. The number 3 connects to the universe, 6 to inner strength, and 9 to releasing what no longer serves you. Together they create a complete energetic cycle repeated daily.',
    steps: [
      {
        't': 'Craft your affirmation (do this on Day 0)',
        'd': 'Write ONE powerful affirmation in the present tense. It must feel slightly beyond your comfort zone but still believable. Example: "I am confidently attracting abundant wealth and opportunities into my life every single day." Keep it under 20 words.',
      },
      {
        't': 'Morning — Write 3 times (within 30 min of waking)',
        'd': 'The moment you wake up, before checking your phone, pick up your journal and write your affirmation exactly 3 times. Your mind is in a theta brainwave state just after waking — this is when your subconscious is most open to new programming. Feel each word as you write it.',
      },
      {
        't': 'Afternoon — Write 6 times (around 12–2pm)',
        'd': 'Set a phone alarm for midday. Find a quiet moment — even in the bathroom if needed — and write your affirmation 6 times. This is the amplification phase. You are reinforcing the morning seed with midday energy. Whisper each line aloud as you write for extra impact.',
      },
      {
        't': 'Night — Write 9 times (just before sleep)',
        'd': 'The last thing before you close your eyes, write your affirmation 9 times in your journal. Your subconscious mind is most receptive in the hypnagogic state (the drowsy period before sleep). The 9 repetitions act as a final deep imprint. Let the feeling linger as you drift off.',
      },
      {
        't': 'Commit to a minimum of 33 days',
        'd': 'One full cycle of 3-6-9 is 33 days (3+3 = 6, 3×3 = 9 — all sacred). Do not switch affirmations mid-cycle. If you feel your affirmation is wrong, finish the current week and adjust. Results often appear subtly around Day 11 and more visibly around Day 33.',
      },
    ],
    tips: [
      'Set 3 phone alarms labelled "3 — Morning Power", "6 — Afternoon Boost", "9 — Night Seal" so you never miss a session.',
      'Never write "I want" or "I will have" — always "I am" or "I have". The subconscious only understands the present tense.',
      'The emotion you feel while writing is more important than the words themselves. If you feel nothing, pause, breathe, and reconnect before continuing.',
      'If you miss one session (not a full day), just continue with the next scheduled one. Missing one session is not the same as missing a full day.',
      'Keep the same affirmation for the entire 33-day cycle even if it feels repetitive — that repetition IS the medicine.',
    ],
  ),
  ManifestationTechnique(
    name: '5×55 Method',
    tag: 'INTENSIVE 5-DAY SPRINT',
    emoji: '✍️',
    listSub: 'Write your affirmation 55 times for 5 days',
    sub: 'A concentrated burst of written intention — 55 repetitions per day for 5 powerful days.',
    badges: ['5 days', '20–30 min/day', 'Intermediate'],
    what: 'The 5×55 method compresses high-frequency repetition into an intensive short window to create rapid energetic shifts. The number 5 represents change and transformation, while 55 is a master number in numerology symbolising major life shifts and new beginnings. By writing your affirmation 55 times in a single focused sitting for 5 consecutive days, you create an energetic intensity that is difficult to ignore — both for your subconscious and the universe.',
    steps: [
      {
        't': 'Write your affirmation on a fresh page first',
        'd': 'Before Day 1 begins, spend 10 minutes crafting the perfect affirmation. It must be: specific (not vague), present tense ("I am", not "I will"), positively framed (no "I don\'t want"), and emotionally resonant. Test it by reading it aloud — if it gives you a feeling of excitement mixed with slight disbelief, it is perfect.',
      },
      {
        't': 'Prepare your space before each session',
        'd': 'This is non-negotiable: silence your phone completely (not vibrate — off). Sit at a desk or table, not on a bed. Pour a glass of water. Light incense or a candle if possible. Take 5 slow deep breaths before picking up your pen. You are entering a focused ritual, not completing a task.',
      },
      {
        't': 'Write 55 times — do not stop, do not count mid-flow',
        'd': 'Number each line from 1 to 55 in the margin before you start so you never have to think about counting. Then write continuously. Keep your handwriting legible — sloppy writing signals a sloppy signal to your subconscious. If your hand cramps, shake it out for 5 seconds and continue. Do not stop to check your phone.',
      },
      {
        't': 'Pause every 11 lines to reconnect emotionally',
        'd': 'At lines 11, 22, 33, and 44, stop for ONE full breath. Close your eyes and FEEL the affirmation as if it is already real for just 10 seconds. Then continue. This prevents the writing from becoming purely mechanical and keeps the emotional frequency high throughout.',
      },
      {
        't': 'After line 55 — release and let go',
        'd': 'When you finish all 55 lines, close your journal. Do not immediately jump to your phone or another task. Sit quietly for 2 minutes. Place your hand on your heart and say aloud: "It is done. I release this to the universe with full trust." Then go about your day without obsessing over results.',
      },
      {
        't': 'Repeat for exactly 5 consecutive days',
        'd': 'Days 1–5 form one complete cycle. Do not skip a day — if you do, you must start from Day 1 again. After Day 5, do NOT repeat the cycle immediately. Give the universe at least 1–2 weeks to respond before starting a new cycle on the same or a different desire.',
      },
    ],
    tips: [
      'Number your lines 1–55 in the margin BEFORE you start writing — this removes the mental burden of counting while you write.',
      'If strong resistance, doubt, or frustration arises around line 30–40, write through it. That is almost always the moment the old belief system cracks open.',
      'Do not do 5×55 on more than one desire simultaneously. The power comes from singular focused intention.',
      'After completing all 5 days, engage in a completely unrelated enjoyable activity. Detachment from the outcome is what allows manifestation to flow.',
      'Morning is the best time for this practice — ideally before 9am when cortisol is naturally higher and focus is sharper.',
    ],
  ),
  ManifestationTechnique(
    name: 'Scripting',
    tag: 'FUTURE SELF JOURNALING',
    emoji: '🌟',
    listSub: 'Write your future as if it already happened',
    sub: 'Write detailed diary entries from the perspective of your future self, as if it has all already happened.',
    badges: ['Ongoing', '15 min/day', 'Creative'],
    what: 'Scripting is one of the most powerful Law of Attraction tools because it simultaneously engages your imagination, your emotions, and your narrative mind — the three deepest languages of the subconscious. Unlike affirmations which repeat a single line, scripting has you write full, rich, sensory diary entries from the future. Your brain cannot fully distinguish between a vividly imagined experience and a real one, which is why this technique works so profoundly when done with genuine emotion.',
    steps: [
      {
        't': 'Pick a specific future date to write from',
        'd': 'Choose a date 6 to 12 months in the future. Write it at the top of your page as if it is today\'s date. Example: "15th January 2026." This small act immediately shifts your brain into future-self mode and sets the scene for everything that follows.',
      },
      {
        't': 'Start with your morning — describe it in full sensory detail',
        'd': 'Begin your entry with waking up. Where are you? What does the room look, smell, and feel like? Is there sunlight? What can you hear? Who is with you? The more sensory detail you include, the more real your subconscious believes it to be. Example: "I woke up to the sound of birds outside my new apartment in Bandra. The morning light was golden and warm on my skin..."',
      },
      {
        't': 'Describe what your life looks and feels like NOW (in the future)',
        'd': 'Write about your work, relationships, health, finances, and daily routine as they exist in this future reality. Use past tense for the journey ("It all started when...") and present tense for the current state ("Every morning I wake up feeling..."). Include specific numbers, places, and names where possible.',
      },
      {
        't': 'Write about how you FEEL — in detail',
        'd': 'This is the most important part. Do not just describe events — describe the feelings. "I feel a deep sense of peace I never had before." "There is a quiet confidence in everything I do now." "I am proud of the person I became." Emotion is the bridge between your current reality and your desired one.',
      },
      {
        't': 'Mention the journey — how things fell into place',
        'd': 'Write about how it happened — the unexpected opportunities, the people who appeared, the synchronicities. This makes the script feel real and believable to your subconscious. Example: "Six months ago I never imagined this would happen, but then I got that one call that changed everything..."',
      },
      {
        't': 'Read your entry aloud before sleep',
        'd': 'After writing, read your full entry aloud slowly — as if you are telling your story to a dear friend. Then close your journal and let the feelings carry you into sleep. Your subconscious will process and integrate the script during your sleep cycle.',
      },
    ],
    tips: [
      'Write as if you are speaking to a close friend — warm, natural, and conversational. Stiff or formal language kills the emotion.',
      'Use ALL five senses in your descriptions: sight, sound, smell, taste, and touch. The brain responds most powerfully to multi-sensory input.',
      'Keep a dedicated scripting journal. Rereading entries from 3–6 months ago is one of the most powerful ways to notice how much has actually manifested.',
      'Do not force or strain for detail. If a part feels flat or unexciting, skip it and write what DOES excite you. Only write what genuinely lights you up.',
      'You can script the same desire multiple times over different days — each entry will naturally add new layers and detail as your vision becomes clearer.',
      'Never script from a place of desperation or lack. Always write from a place of gratitude and fullness. If you are feeling low, do a 5-minute breathing exercise first.',
    ],
  ),
  ManifestationTechnique(
    name: 'Vision Board',
    tag: 'VISUAL MANIFESTATION',
    emoji: '🖼️',
    listSub: 'Visualise and feel your desired reality daily',
    sub: 'Curate images and words that represent your desired life and interact with them every single day.',
    badges: ['Ongoing', 'Setup: 1–2 hr', 'Visual learners'],
    what: 'A vision board makes your desires tangible, visible, and emotionally accessible every single day. By surrounding yourself with carefully chosen images of what you want, you prime your Reticular Activating System (RAS) — the part of your brain that filters what you notice — to spot opportunities, people, and resources aligned with your goals. The key is not just making the board, but interacting with it daily with genuine emotion.',
    steps: [
      {
        't': 'Clarify your desires across 4 life areas first',
        'd': 'Before touching a single image, spend 20 minutes journaling on what you truly want in: (1) Health & body, (2) Wealth & career, (3) Relationships & love, (4) Purpose & lifestyle. Be honest — not what you think you should want, but what genuinely excites you. This clarity makes your board powerful rather than random.',
      },
      {
        't': 'Gather images that make you FEEL something',
        'd': 'Search Pinterest, magazines, or Google Images for photos that provoke a genuine emotional reaction — not just ones that look nice. The test: when you look at the image, do you feel excitement, inspiration, or a warm sense of "yes, that is mine"? If not, skip it. Quality over quantity — 15 powerful images beat 50 mediocre ones.',
      },
      {
        't': 'Add words, quotes, and affirmations',
        'd': 'Find or write 5–10 short words or phrases that anchor your vision. Examples: "Abundant", "Free", "₹1 Crore", "Dream home in Goa", "Published author", "Deeply loved". These words should make your heart beat slightly faster when you read them.',
      },
      {
        't': 'Arrange and create your board',
        'd': 'Physical board: use a large poster board, print images, and arrange them by life area. Place the most emotionally powerful image at the centre. Add a recent photo of yourself smiling. Digital board: use Canva or Pinterest. Make it your phone wallpaper AND computer desktop so you see it multiple times a day passively.',
      },
      {
        't': 'Place it where you will see it every single day',
        'd': 'The most powerful placement: directly across from where you sleep so it is the first thing you see in the morning and the last at night. If not possible: bathroom mirror, study desk wall, or phone lock screen. The goal is unavoidable daily exposure.',
      },
      {
        't': 'Spend 5 intentional minutes with it each morning',
        'd': 'Every morning, stand or sit in front of your board for 5 full minutes. Look at each image one by one. As you look at each one, feel AS IF it is already yours — feel the gratitude, the pride, the joy. Do not just glance. This daily emotional activation is what separates a decorative board from a manifesting tool.',
      },
    ],
    tips: [
      'Update your board every 3–6 months. Remove images of desires that have manifested (with gratitude!) and replace with new ones. A stale board loses its power.',
      'A physical board you can touch and stand in front of has significantly stronger psychological impact than a purely digital one.',
      'If an image no longer excites you or feels wrong, remove it immediately. Your board should feel alive and electric, never obligatory.',
      'Add a "why" card — a small note explaining WHY you want each desire. The why amplifies the emotional pull every time you read it.',
      'Never place images of things you feel you "should" want. Only include what genuinely makes your heart sing when you imagine having it.',
      'Some people add a photo of themselves at their happiest to the centre of the board — this anchors the feeling of joy to the entire vision.',
    ],
  ),
];

const List<Mood> kMoods = [
  Mood(id: "peaceful", emoji: "😌", label: "Peaceful"),
  Mood(id: "anxious", emoji: "😟", label: "Anxious"),
  Mood(id: "sad", emoji: "😔", label: "Sad"),
  Mood(id: "grateful", emoji: "🙏", label: "Grateful"),
  Mood(id: "lost", emoji: "🌫️", label: "Lost"),
  Mood(id: "energetic", emoji: "✨", label: "Energetic"),
];

const List<GuidanceStyle> kStyles = [
  GuidanceStyle(id: "devotional", icon: "🙏", label: "Devotional", desc: "Heart & bhakti path"),
  GuidanceStyle(id: "philosophical", icon: "📖", label: "Philosophical", desc: "Wisdom & jnana path"),
  GuidanceStyle(id: "practical", icon: "⚡", label: "Practical", desc: "Action & karma path"),
  GuidanceStyle(id: "balanced", icon: "☯️", label: "Balanced", desc: "All paths harmonized"),
];

const List<GitaVerse> kGita = [
  GitaVerse(ch: 2, v: 47, text: "You have a right to perform your duties, but not to the fruits of your actions.", theme: "Non-attachment"),
  GitaVerse(ch: 6, v: 5, text: "Elevate yourself through the power of your mind; do not degrade yourself.", theme: "Self-mastery"),
  GitaVerse(ch: 4, v: 7, text: "Whenever righteousness declines and unrighteousness prevails, I manifest myself.", theme: "Divine purpose"),
  GitaVerse(ch: 9, v: 22, text: "To those who worship me with devotion, I provide what they lack and preserve what they have.", theme: "Divine grace"),
  GitaVerse(ch: 18, v: 66, text: "Surrender all duties to me alone. I shall liberate you from all sins. Do not grieve.", theme: "Surrender"),
  GitaVerse(ch: 2, v: 14, text: "The appearance of happiness and distress, and their disappearance in due course, are like winter and summer.", theme: "Impermanence"),
  GitaVerse(ch: 3, v: 21, text: "Whatever great people do, common people follow. Whatever standards they set, the world follows.", theme: "Leadership"),
];

const List<Topic> kTopics = [
  Topic(id: "decision", icon: "🔀", label: "A difficult decision"),
  Topic(id: "pain", icon: "💔", label: "Emotional pain"),
  Topic(id: "purpose", icon: "🌌", label: "Lack of purpose"),
  Topic(id: "relation", icon: "💫", label: "Relationship trouble"),
  Topic(id: "career", icon: "🏔️", label: "Work & career"),
];

const Map<String, String> kTopicFallback = {
  "decision":
      "The Gita's wisdom on decisions: ask which option aligns with your dharma — your duty — rather than your desire. In Chapter 18, Krishna advises that the action done without ego, anger, or greed is always the righteous one. Act from duty; release the outcome.",
  "pain":
      "Pain is a sacred teacher. Chapter 2 teaches the soul is eternal and untouched by sorrow. What you feel is real but temporary. Sit with this pain as a witness, not a victim — it will reveal its lesson when you stop resisting it.",
  "purpose":
      "Purpose is not found; it is remembered. Your svadharma — your unique path — is already within you. Begin with the one activity you do naturally, joyfully, and better than most others. Follow that single thread with dedication.",
  "relation":
      "All relationships are mirrors of the self. The Gita teaches nishkama karma — giving without expectation of return. Ask yourself: am I acting from love or from fear of loss? One liberates you; the other binds you tighter.",
  "career":
      "Krishna tells Arjuna: perform your work as worship. Your career is your karma field. Do your best work not for reward, but as an offering to the divine. Excellence offered selflessly always finds its recognition — in time.",
};

const Map<String, String> kMoodFallback = {
  "peaceful":
      "This stillness is sacred. Rest in it — the Gita calls this state 'sthitaprajna': settled wisdom. Let this peace guide every action you take today.",
  "anxious":
      "Anxiety arises from attachment to outcomes. As Krishna teaches in 2.47: focus only on your action, release the result. Breathe, and act from duty alone.",
  "sad":
      "Grief honors what we love. The soul, says the Gita, is eternal and untouched by sorrow. Allow the feeling as a witness — your unchanging nature remains.",
  "grateful":
      "Gratitude is the closest human emotion to devotion. You are in alignment with the universe today. Channel this into an act of service.",
  "lost":
      "When purpose is unclear, return to your dharma — the one action only you can do. The Gita says confusion ends when we serve with sincerity.",
  "energetic":
      "This vitality is divine shakti moving through you. Direct it with intention, not reaction. A disciplined warrior achieves more than a thousand unchanneled ones.",
};


// In app_data.dart — add pronunciation hints per mantra line
// Format: simplified phonetic spelling an Indian user would naturally read

class PronunciationHint {
  final String devanagari;  // original Sanskrit
  final String iast;        // standard transliteration  
  final String panditHint;  // how a pandit says it — for Indian audience
  final String meaning;     // word by word meaning

  const PronunciationHint({
    required this.devanagari,
    required this.iast,
    required this.panditHint,
    required this.meaning,
  });
}

// Example for Gayatri Mantra
const kGayatriHints = [
  PronunciationHint(
    devanagari: 'ॐ भूर्भुवः स्वः',
    iast: 'Om bhūr bhuvaḥ svaḥ',
    panditHint: 'Om  BHOOR  BHOO-vah  SVAH',
    meaning: 'Om — the earth, the atmosphere, the heavens',
  ),
  PronunciationHint(
    devanagari: 'तत्सवितुर्वरेण्यम्',
    iast: 'tat saviturvareṇyam',
    panditHint: 'tat  sa-VI-tur  va-REN-yam',
    meaning: 'That divine glory of Savitar (the Sun)',
  ),
  PronunciationHint(
    devanagari: 'भर्गो देवस्य धीमहि',
    iast: 'bhargo devasya dhīmahi',
    panditHint: 'BHAR-go  DE-vas-ya  DHEE-ma-hi',
    meaning: 'May we meditate on the radiance of the divine',
  ),
  PronunciationHint(
    devanagari: 'धियो यो नः प्रचोदयात्',
    iast: 'dhiyo yo naḥ pracodayāt',
    panditHint: 'DHI-yo  yo  nah  pra-CHO-da-yaat',
    meaning: 'May that inspire our intellect',
  ),
];

const List<Aarti> kAartis = [
  Aarti(
    name: 'Jai Shiv Omkara',
    deity: 'Shiva',
    emoji: '🔱',
    sub: 'Aarti of Lord Shiva, the destroyer and transformer',
    verses: [
      // Mukhda — no har har
      'ॐ जय शिव ओंकारा, स्वामी जय शिव ओंकारा।\nब्रह्मा विष्णु सदाशिव, अर्द्धांगी धारा॥\nहर हर हर महादेव।',
      // Antara 1
      'एकानन चतुरानन पञ्चानन राजे।\nहंसासन गरुड़ासन वृषवाहन साजे॥\nॐ जय शिव ओंकारा।\nहर हर हर महादेव।',
      // Antara 2
      'दो भुज चार चतुर्भुज दसभुज अति सोहे।\nत्रिगुण रूप निरखते त्रिभुवन जन मोहे॥\nॐ जय शिव ओंकारा।\nहर हर हर महादेव।',
      // Antara 3
      'अक्षमाला वनमाला मुण्डमाला धारी।\nचंदन मृगमद सोहे भाले शशिधारी॥\nॐ जय शिव ओंकारा।\nहर हर हर महादेव।',
      // Antara 4
      'श्वेताम्बर पीताम्बर बाघम्बर अंगे।\nसनकादिक गरुड़ादिक भूतादिक संगे॥\nॐ जय शिव ओंकारा।\nहर हर हर महादेव।',
      // Antara 5
      'कर के मध्य कमण्डलु चक्र त्रिशूलधारी।\nसुखकारी दुखहारी जगपालन कारी॥\nॐ जय शिव ओंकारा।\nहर हर हर महादेव।',
      // Antara 6
      'ब्रह्मा विष्णु सदाशिव जानत अविवेका।\nप्रणवाक्षर के मध्ये ये तीनों एका॥\nॐ जय शिव ओंकारा।\nहर हर हर महादेव।',
      // Antara 7
      'लक्ष्मी व सावित्री पार्वती संगा।\nपार्वती अर्द्धांगिनी, शिवलहरी गंगा॥\nॐ जय शिव ओंकारा।\nहर हर हर महादेव।',
      // Antara 8
      'पर्वत सोहें पार्वती, शंकर कैलासा।\nभांग धतूर का भोजन, भस्मी में वासा॥\nॐ जय शिव ओंकारा।\nहर हर हर महादेव।',
      // Antara 9
      'जटा में गंग बहत है, गल मुण्डन माला।\nशेष नाग लिपटावत, ओढ़त मृगछाला॥\nॐ जय शिव ओंकारा।\nहर हर हर महादेव।',
      // Antara 10
      'काशी में विश्वनाथ विराजत, नन्दी ब्रह्मचारी।\nनित उठि दर्शन पावत, महिमा अति भारी॥\nॐ जय शिव ओंकारा।\nहर हर हर महादेव।',
      // Antara 11 (final)
      'त्रिगुणस्वामी जी की आरती जो कोई नर गावे।\nकहत शिवानन्द स्वामी, मनवांछित फल पावे॥\nॐ जय शिव ओंकारा।\nहर हर हर महादेव।',
    ],
  ),
  Aarti(
    name: 'Jai Ganesh Deva',
    deity: 'Ganesha',
    emoji: '🐘',
    sub: 'Aarti of Lord Ganesha, remover of all obstacles',
    verses: [
      'जय गणेश जय गणेश जय गणेश देवा।\nमाता जाकी पार्वती पिता महादेवा॥\nजय गणेश देवा।',
      'एकदन्त दयावन्त चार भुजाधारी।\nमाथे पर तिलक सोहे मूसे की सवारी॥\nजय गणेश देवा।',
      'पान चढ़े फूल चढ़े और चढ़े मेवा।\nलड्डुअन का भोग लगे सन्त करें सेवा॥\nजय गणेश देवा।',
      'अन्धन को आँख देत कोढ़िन को काया।\nबाँझन को पुत्र देत निर्धन को माया॥\nजय गणेश देवा।',
      'सूर श्याम शरण आये सफल कीजे सेवा।\nमाता जाकी पार्वती पिता महादेवा॥\nजय गणेश देवा।',
      '"हाथी" मुखवाले प्रभु एकदन्त स्वामी।\nविघ्न हरो सब भक्तन के अन्तर्यामी॥\nजय गणेश देवा।',
      'मूषक वाहन मोदक हाथ।\nचामर कर्ण विलम्बित सूत्र।\nवामन रूप महेश्वर पुत्र।\nजय गणेश देवा।',
      'सब की विनती स्वीकारो शरण तुम्हारी।\nजो ध्यावे फल पावे पूरण आस हमारी॥\nजय गणेश देवा।',
    ],
  ),
  Aarti(
    name: 'Om Jai Jagdish Hare',
    deity: 'Vishnu',
    emoji: '🪔',
    sub: 'The universal aarti of Lord Vishnu, preserver of the universe',
    verses: [
      'ॐ जय जगदीश हरे, स्वामी जय जगदीश हरे।\nभक्त जनों के संकट, दास जनों के संकट,\nक्षण में दूर करे॥\nॐ जय जगदीश हरे।',
      'जो ध्यावे फल पावे, दुःख बिनसे मन का।\nस्वामी दुःख बिनसे मन का।\nसुख सम्पत्ति घर आवे, सुख सम्पत्ति घर आवे,\nकष्ट मिटे तन का॥\nॐ जय जगदीश हरे।',
      'मात पिता तुम मेरे, शरण गहूँ मैं किसकी।\nस्वामी शरण गहूँ मैं किसकी।\nतुम बिन और न दूजा, तुम बिन और न दूजा,\nआस करूँ मैं जिसकी॥\nॐ जय जगदीश हरे।',
      'तुम पूरण परमात्मा, तुम अन्तर्यामी।\nस्वामी तुम अन्तर्यामी।\nपार ब्रह्म परमेश्वर, पार ब्रह्म परमेश्वर,\nतुम सब के स्वामी॥\nॐ जय जगदीश हरे।',
      'तुम करुणा के सागर, तुम पालन कर्ता।\nस्वामी तुम पालन कर्ता।\nमैं सेवक तुम स्वामी, मैं सेवक तुम स्वामी,\nकृपा करो भर्ता॥\nॐ जय जगदीश हरे।',
      'तुम हो एक अगोचर, सब के प्राण पति।\nस्वामी सब के प्राण पति।\nकिस विधि मिलूँ दयामय, किस विधि मिलूँ दयामय,\nतुमको मैं कुमति॥\nॐ जय जगदीश हरे।',
      'दीन बन्धु दुःख हर्ता, तुम रक्षक मेरे।\nस्वामी तुम रक्षक मेरे।\nअपने हाथ उठाओ, अपने शरण लगाओ,\nद्वार पड़ा तेरे॥\nॐ जय जगदीश हरे।',
      'विषय विकार मिटाओ, पाप हरो देवा।\nस्वामी पाप हरो देवा।\nश्रद्धा भक्ति बढ़ाओ, श्रद्धा भक्ति बढ़ाओ,\nसन्तन की सेवा॥\nॐ जय जगदीश हरे।',
      'तन मन धन और सम्पत्ति, सब कुछ है तेरा।\nस्वामी सब कुछ है तेरा।\nतेरा तुझको अर्पण, तेरा तुझको अर्पण,\nक्या लागे मेरा॥\nॐ जय जगदीश हरे।',
    ],
  ),
  Aarti(
    name: 'Jai Ambe Gauri',
    deity: 'Durga',
    emoji: '🌺',
    sub: 'Aarti of Goddess Durga, the divine mother and destroyer of evil',
    verses: [
      'जय अम्बे गौरी, मैया जय श्यामा गौरी।\nतुमको निशदिन ध्यावत, हरि ब्रह्मा शिवरी॥\nजय अम्बे गौरी।',
      'माँग सिन्दूर विराजत, टीको मृगमद को।\nउज्ज्वल से दोउ नैना, चन्द्रवदन नीको॥\nजय अम्बे गौरी।',
      'कनक समान कलेवर, रक्ताम्बर राजै।\nरक्तपुष्प गल माला, कण्ठन पर साजै॥\nजय अम्बे गौरी।',
      'केहरि वाहन राजत, खड्ग खप्परधारी।\nसुर-नर मुनिजन सेवत, तिनके दुःखहारी॥\nजय अम्बे गौरी।',
      'कानन कुण्डल शोभित, नासाग्रे मोती।\nकोटिक चन्द्र दिवाकर, राजत सम ज्योति॥\nजय अम्बे गौरी।',
      'शुम्भ निशुम्भ बिडारे, महिषासुर घाती।\nधूम्र विलोचन नैना, निशदिन मदमाती॥\nजय अम्बे गौरी।',
      'चण्ड मुण्ड संहारे, शोणित बीज हरे।\nमधु कैटभ दोउ मारे, सुर भयहीन करे॥\nजय अम्बे गौरी।',
      'ब्रह्माणी रुद्राणी तुम कमला रानी।\nआगम निगम बखानी, तुम शिव पटरानी॥\nजय अम्बे गौरी।',
      'चौंसठ योगिनि मंगल गावत, नृत्य करत भैरू।\nबाजत ताल मृदंगा, अरु बाजत डमरू॥\nजय अम्बे गौरी।',
      'भुजा चार अति शोभित, वर मुद्रा धारी।\nमनवांछित फल पावत, सेवत नर नारी॥\nजय अम्बे गौरी।',
      'कंचन थाल विराजत, अगर कपूर बाती।\nश्री मालकेतु में राजत, कोटि रतन ज्योति॥\nजय अम्बे गौरी।',
      'श्री अम्बेजी की आरती, जो कोई नर गावे।\nकहत शिवानन्द स्वामी, सुख सम्पत्ति पावे॥\nजय अम्बे गौरी।',
    ],
  ),
  Aarti(
    name: 'Jai Lakshmi Mata',
    deity: 'Lakshmi',
    emoji: '🌸',
    sub: 'Aarti of Goddess Lakshmi, bestower of wealth and prosperity',
    verses: [
      'जय लक्ष्मी माता, मैया जय लक्ष्मी माता।\nतुमको निशदिन सेवत, हरि विष्णु विधाता॥\nजय लक्ष्मी माता।',
      'उमा रमा ब्रह्माणी, तुम ही जग-माता।\nसूर्य-चन्द्रमा ध्यावत, नारद ऋषि गाता॥\nजय लक्ष्मी माता।',
      'दुर्गा रूप निरंजनी, सुख सम्पत्ति दाता।\nजो कोई तुमको ध्यावत, ऋद्धि-सिद्धि धन पाता॥\nजय लक्ष्मी माता।',
      'तुम पाताल निवासिनी, तुम ही शुभदाता।\nकर्म प्रभाव प्रकाशिनी, भवनिधि की त्राता॥\nजय लक्ष्मी माता।',
      'जिस घर में तुम रहतीं, सब सद्गुण आता।\nसब सम्भव हो जाता, मन नहीं घबराता॥\nजय लक्ष्मी माता।',
      'तुम बिन यज्ञ न होते, वस्त्र न कोई पाता।\nखान-पान का वैभव, सब तुमसे आता॥\nजय लक्ष्मी माता।',
      'शुभ गुण मन्दिर सुन्दर, क्षीरोदधि जाता।\nरत्न चतुर्दश तुम बिन, कोई नहीं पाता॥\nजय लक्ष्मी माता।',
      'महालक्ष्मी जी की आरती, जो कोई नर गावे।\nउर आनन्द समावे, पाप उतर जावे॥\nजय लक्ष्मी माता।',
    ],
  ),
];
const kVistarPujas = <VistarPuja>[

VistarPuja(
  id: 'ganpati_sthapana',
  name: 'Ganpati Sthapana',
  deity: 'Ganesha',
  emoji: '🐘',
  sub: 'Sacred installation and invocation of Lord Ganesha',
  occasion: 'Ganesh Chaturthi · Griha Pravesh · Any new beginning or festival start',
  linkedAartiName: 'Jai Ganesh Deva',
  samagri: [
    'Ganesh murti (clay idol preferred) or framed image',
    'Wooden chowki with red or yellow cloth',
    'Kalash (copper pot) with water',
    'Mango leaves (5 or 11) for kalash',
    'Coconut for kalash top',
    'Roli, haldi, kumkum, chandan',
    'Akshat (raw rice)',
    'Durva grass — 21 blades (mandatory for Ganesha)',
    'Red hibiscus flowers (Ganesha\'s favourite)',
    'Marigold flowers',
    'Modak or ladoo — 21 pieces',
    'Panchamrit (milk, curd, ghee, honey, sugar)',
    'Incense sticks and camphor',
    'Ghee diya with cotton wick',
    'Sacred thread (mauli / janeu)',
    'Betel leaves and betel nuts (5 pairs)',
    'Panchapalav leaves (mango, peepal, gular, pakad, vat)',
    'Sandalwood paste',
    'Seasonal fruits',
  ],
  vidhi: [
    PujaVidhiStep(
      title: 'Shuddhi — Purification',
      instruction:
          'Bathe and wear clean clothes in yellow or orange. Apply roli-chawal tilak. Sit facing east. Perform aachaman — take a few drops of water in your right palm and sip three times while chanting each name.',
      mantra: 'ॐ केशवाय नमः। ॐ नारायणाय नमः। ॐ माधवाय नमः।',
      tip: 'Sip just enough water to wet the lips. Do with right hand only.',
    ),
    PujaVidhiStep(
      title: 'Chowki Sthapana — Setting the Platform',
      instruction:
          'Place the chowki, spread the cloth, draw a swastika with roli in the centre. Place the Ganesha murti facing you (west-facing murti, east-facing devotee is ideal). Place flowers around the murti.',
      tip: 'Never place Ganesha directly on the floor. The chowki is His divine throne.',
    ),
    PujaVidhiStep(
      title: 'Kalash Sthapana — Consecrating the Pot',
      instruction:
          'Fill kalash 3/4 with clean water. Add pinch of haldi, roli, akshat. Place 5 mango leaves at the rim, coconut on top. Wrap red thread around the neck three times. Place to the right of Ganesha.',
      mantra:
          'ॐ गंगे च यमुने चैव गोदावरी सरस्वती। नर्मदे सिन्धु कावेरी जलेऽस्मिन् सन्निधिं कुरु॥',
      tip: 'The kalash represents the universe and all sacred rivers of India.',
    ),
    PujaVidhiStep(
      title: 'Prana Pratishtha — Invoking the Divine',
      instruction:
          'Place your right hand near (not touching) the murti. Close your eyes. With full devotion, chant the mantra and visualise Lord Ganesha — son of Shiva and Parvati — arriving and becoming present and alive in this murti before you.',
      mantra:
          'ॐ अं ह्रीं क्रों — प्राण इह प्राणाः। अपान इह अपानाः। व्यान इह व्यानाः। अत्रागच्छ अत्रातिष्ठ।\nगणपतये नमः — सुप्रतिष्ठितो भव।',
      tip: 'If unsure of the mantra, say sincerely: "He Ganapati, please be present in this murti and accept my worship." Bhavna (devotion) matters most.',
    ),
    PujaVidhiStep(
      title: 'Shodashopachara — 16 Ritual Services',
      instruction:
          'Offer all 16 services one by one, each with "Ganeshaya Namah":\n\n1. Aavahan — invite Ganesha to be seated\n2. Aasan — offer flowers as His seat\n3. Paadya — offer water for His feet\n4. Arghya — offer water with akshat for His hands\n5. Aachaman — offer water for sipping\n6. Snan (Abhishek) — pour panchamrit over murti (milk → curd → ghee → honey → sugar), then wash with plain water\n7. Vastra — offer a piece of red cloth\n8. Yagnopavit — offer the sacred janeu thread\n9. Chandan — apply sandalwood paste on forehead\n10. Pushpa — offer flowers, then offer 21 durva blades one by one\n11. Dhoop — circle incense three times clockwise\n12. Deep — circle ghee diya three times clockwise\n13. Naivedya — offer 21 modak or ladoo\n14. Aachaman — offer water after the meal\n15. Tambul — offer betel leaf and nut\n16. Pradakshina — three clockwise circumambulations',
      mantra: 'ॐ गणेशाय नमः। ॐ विघ्नराजाय नमः। ॐ लम्बोदराय नमः।',
      tip: 'For durva: hold each blade between thumb and ring finger and offer one at a time. 21 durva = 21 names of Ganesha.',
    ),
    PujaVidhiStep(
      title: 'Ganapati Atharvashirsha or 108 Names',
      instruction:
          'Recite the Ganapati Atharvashirsha (the Upanishad dedicated to Ganesha — ideally 3 or 11 times), or chant the 108 names of Ganesha, or chant the mool mantra 108 times on a mala.',
      mantra:
          'ॐ गं गणपतये नमः (108 बार)\n\nAtharvashirsha opening:\nॐ नमस्ते गणपतये। त्वमेव प्रत्यक्षं तत्त्वमसि। त्वमेव केवलं कर्ताऽसि। त्वमेव केवलं धर्ताऽसि। त्वमेव केवलं हर्ताऽसि। त्वमेव सर्वं खल्विदं ब्रह्मासि। त्वं साक्षादात्माऽसि नित्यम्॥',
    ),
    PujaVidhiStep(
      title: 'Ganesh Katha',
      instruction:
          'Recite or listen to the Ganesh Vrat Katha (included in this puja). All present should be seated and attentive. After the katha say "Shri Ganesha Ki Jai" three times.',
      tip: 'Do not get up or leave during the katha.',
    ),
    PujaVidhiStep(
      title: 'Aarti',
      instruction:
          'Perform Jai Ganesh Deva aarti. Wave the diya clockwise — first at His feet, then middle, then face, then a large circle encompassing His whole form. Ring a bell throughout. Distribute prasad (modak) to all present.',
      tip: 'For Chaturthi: Ganesha stays 1, 3, 5, 7, or 11 days. On the last day perform Uttarpuja and Visarjan (dissolve clay murti in a bucket of water, pour water at roots of a tree).',
      mantra:
          'विसर्जन मंत्र:\nयान्तु देवगणाः सर्वे पूजामादाय मामकीम्। इष्टकामसमृद्ध्यर्थं पुनरागमनाय च॥',
    ),
  ],
  katha: PujaKatha(
    title: 'Shri Ganesh Chaturthi Vrat Katha',
    paragraphs: [
      'एक समय देवताओं और दानवों में भीषण युद्ध था। देवता बार-बार पराजित हो रहे थे। सब देवता मिलकर भगवान शिव के पास गए — "हे महादेव, हमारे कार्यों में विघ्न आते हैं, उपाय बताइए।" शिवजी बोले — "सृष्टि में एक ऐसी शक्ति चाहिए जो हर शुभ कार्य में सबसे पहले पूजी जाए और विघ्न हरे।"',
      'माता पार्वती ने स्नान से पूर्व अपनी काया के मैल से एक सुंदर बालक की मूर्ति बनाई और उसमें प्राण डाले। उस बालक को द्वार पर पहरेदार बिठाया और कहा — "जब तक मैं स्नान न करूँ किसी को अंदर मत आने देना।" बालक ने माँ की आज्ञा स्वीकार की।',
      'कुछ देर बाद शिवजी आए। बालक ने उन्हें भी रोक दिया। शिवजी ने अपना परिचय दिया किंतु बालक नहीं हटा। शिवजी के गण, देवता — सबको बालक ने परास्त किया। क्रोधित शिव ने त्रिशूल से बालक का मस्तक काट दिया।',
      'पार्वती माँ का रोदन सुनकर ब्रह्मांड काँप उठा। उन्होंने शिव से कहा — "मेरे पुत्र को जीवित करो और वरदान दो कि तीनों लोकों में इसकी सबसे पहले पूजा हो।" शिव ने गणों को उत्तर दिशा में भेजा — "जो पहला प्राणी मिले उसका मस्तक लाओ।"',
      'गण उत्तर दिशा में गए। एक हाथी उत्तर की ओर सिर रखकर (शुभ दिशा) सो रहा था। उसका मस्तक लाकर बालक के धड़ पर लगाया। शिव ने उसे जीवित कर दिया। इस प्रकार गजमुख गणेश का जन्म हुआ।',
      'शिव ने वरदान दिया — "हे पुत्र, तुम आज से गणपति हो। हर शुभ कार्य में तुम्हारी पूजा अनिवार्य होगी। भाद्रपद शुक्ल चतुर्थी को जो तुम्हारी पूजा करेगा और कथा सुनेगा, उसके सभी विघ्न दूर होंगे।" सभी देवताओं ने जय-जयकार की।',
      'एक बार चंद्रमा ने गणेश के गजमुख को देखकर हँसी उड़ाई। गणेश ने शाप दिया — "चतुर्थी के दिन जो तुम्हें देखेगा उस पर झूठा कलंक लगेगा।" भगवान कृष्ण पर भी स्यमंतक मणि का झूठा आरोप इसीलिए लगा था। यह कथा सुनने से ऐसे झूठे कलंक से रक्षा होती है।',
    ],
    phalashruti:
        'यह कथा जो श्रद्धा और भक्ति से सुनता या पढ़ता है, उसके जीवन से सभी विघ्न दूर होते हैं। व्यापार में सफलता, परिवार में सुख-शांति, और संतान की प्राप्ति होती है। जीवन के हर नए कार्य में सिद्धि मिलती है — यही श्री गणेश का वरदान है।',
  ),
),
VistarPuja(
  id: 'satyanarayan_puja',
  name: 'Satyanarayan Puja',
  deity: 'Vishnu',
  emoji: '🪔',
  sub: 'The most beloved household puja of Lord Vishnu',
  occasion: 'Purnima · Ekadashi · Housewarming · Marriage · New business · Thanksgiving',
  linkedAartiName: 'Om Jai Jagdish Hare',
  samagri: [
    'Photo or murti of Satyanarayan (Lord Vishnu)',
    'Wooden chowki with yellow cloth',
    'Kalash with water, mango leaves, coconut',
    'Panchamrit (milk, curd, ghee, honey, sugar)',
    'Tulsi leaves — mandatory for Vishnu puja',
    'Yellow flowers — marigold, champa',
    'Roli, haldi, kumkum, chandan',
    'Akshat (rice)',
    'Incense and camphor',
    'Ghee diya',
    'Panchameva — raisin, cashew, almond, date, fig',
    'Seasonal fruits (5 types)',
    'Banana leaves for serving prasad',
    'Sheera/Panjiri prasad — suji 1 cup, ghee ½ cup, sugar 1 cup, milk 2 cups, raisins, cardamom',
    'Betel leaves and betel nuts (5 pairs)',
    'Sacred thread (mauli)',
    'Yellow or white new cloth (for deity)',
    'Coin or dakshina',
  ],
  vidhi: [
    PujaVidhiStep(
      title: 'Sankalpa — Taking the Sacred Vow',
      instruction:
          'All participants bathe and sit together. The main devotee takes water, akshat, flowers, and a coin in the right palm. Declare your name, reason for the puja, and wish. The sankalpa is a formal commitment — state your wish clearly and with devotion. Drop the akshat and water into a copper plate while chanting.',
      mantra:
          'ॐ विष्णुर्विष्णुर्विष्णुः। अद्य [अपना नाम] अहं श्री सत्यनारायण व्रत-पूजनं करिष्ये। श्री सत्यनारायणस्वामिने नमः।',
    ),
    PujaVidhiStep(
      title: 'Ganesh Puja — Always First',
      instruction:
          'Place a Ganesha image or draw a swastika with roli. Offer durva, flowers, and ladoo. Chant 11 times. Ask Ganesha to remove all obstacles from this puja.',
      mantra:
          'ॐ गं गणपतये नमः। वक्रतुण्ड महाकाय सूर्यकोटि समप्रभ। निर्विघ्नं कुरु मे देव सर्वकार्येषु सर्वदा॥',
      tip: 'Never skip Ganesh puja before Satyanarayan puja — even the gods worship Ganesha first.',
    ),
    PujaVidhiStep(
      title: 'Kalash Sthapana',
      instruction:
          'Fill kalash with water. Add haldi, roli, akshat, Ganga jal if available. Place 5 mango leaves at rim, coconut on top. Tie red thread three times around the neck. Place to the right of Lord Satyanarayan. Invoke all sacred rivers into the kalash.',
      mantra:
          'ॐ गंगे च यमुने चैव गोदावरी सरस्वती। नर्मदे सिन्धु कावेरी जलेऽस्मिन् सन्निधिं कुरु॥',
    ),
    PujaVidhiStep(
      title: 'Navgraha Puja',
      instruction:
          'Draw 9 small squares on a copper plate or banana leaf using roli. Place one grain of rice in each — representing the 9 planets. Offer a small flower to each. This neutralises any planetary obstacles to the fulfilment of your wish.',
      mantra:
          'ॐ ब्रह्मा मुरारिस्त्रिपुरान्तकारी भानुः शशी भूमिसुतो बुधश्च। गुरुश्च शुक्रः शनिराहुकेतवः सर्वे ग्रहाः शांतिकरा भवन्तु॥',
      tip: 'If time is short, sprinkle akshat on the navgraha plate and offer one collective prayer.',
    ),
    PujaVidhiStep(
      title: 'Abhishek — Bathing the Lord',
      instruction:
          'Pour panchamrit slowly over the image or murti: milk → curd → ghee → honey → sugar. Then bathe with plain water. Dry gently. Apply chandan on forehead. Offer yellow or white new cloth. Offer tulsi leaves — tulsi is absolutely mandatory for Vishnu. Never offer chameli (jasmine) to Vishnu.',
      mantra: 'ॐ नमो भगवते वासुदेवाय। श्री सत्यनारायणाय नमः। पंचामृतेन स्नपयामि।',
    ),
    PujaVidhiStep(
      title: 'Shodashopachara — 16 Services',
      instruction:
          'Offer all 16 ritual services (same sequence as Ganesh puja). Special additions for Satyanarayan:\n• Offer yellow flowers and yellow cloth\n• Offer 5 types of fruit\n• Offer panchameva (5 dry fruits)\n• Offer tulsi manjari (tulsi flower buds — very auspicious)\n• Light 5 diyas — one for each direction, one centre\n\nFor each service chant: "Shri Satyanarayan Swamine Namah."',
      mantra: 'ॐ नमो भगवते वासुदेवाय। श्री सत्यनारायणाय नमः।',
    ),
    PujaVidhiStep(
      title: 'Satyanarayan Katha — All 5 Chapters',
      instruction:
          'Recite or listen to all five adhyayas of the Satyanarayan Katha (from Skanda Purana). All family members must be seated and listening — no one leaves during katha. After each chapter offer a small amount of sheera prasad and say "Satyanarayana Swami Ki Jai."',
      tip: 'The consequences of disrespecting or leaving the katha midway are described in the katha itself. Never skip or shorten it.',
    ),
    PujaVidhiStep(
      title: 'Aarti and Prasad',
      instruction:
          'Perform Om Jai Jagdish Hare aarti. Wave the panch-aarti diya clockwise before the Lord. Ring bell throughout. After aarti, distribute charnamrit (the panchamrit from abhishek) to all present, then distribute sheera/panjiri prasad. Everyone must accept and eat the prasad.',
      mantra: 'ॐ जय जगदीश हरे, स्वामी जय जगदीश हरे।',
      tip: 'Declining prasad is considered inauspicious. Ensure everyone receives and eats it.',
    ),
  ],
  katha: PujaKatha(
    title: 'Shri Satyanarayan Vrat Katha — Skanda Purana (5 Adhyaya)',
    paragraphs: [
      '॥ प्रथम अध्याय ॥\nनैमिषारण्य तीर्थ में महर्षि शौनक ने सूत जी से पूछा — "कलियुग में मनुष्यों के दुःख हरने का सरल उपाय बताइए।" सूत जी ने कहा — "मैं वह कथा सुनाता हूँ जो भगवान विष्णु ने नारद जी को सुनाई थी।"\n\nएक बार देवर्षि नारद पृथ्वी पर मनुष्यों को दुःख में देख वैकुण्ठ गए। भगवान विष्णु ने कहा — "हे नारद, एक व्रत है जो सब कष्ट हरता है — श्री सत्यनारायण व्रत। इसे पूर्णिमा, सोमवार, या किसी भी शुभ अवसर पर किया जा सकता है। सरल सामग्री से पूजा करो, कथा सुनो, प्रसाद बाँटो — मनोकामनाएँ पूर्ण होंगी।"',
      '॥ द्वितीय अध्याय ॥\nकाशी में एक निर्धन किंतु धर्मपरायण ब्राह्मण रहता था। भगवान ने वृद्ध ब्राह्मण का रूप धारण कर उससे मिले और सत्यनारायण व्रत का महत्व बताया। ब्राह्मण ने अगले दिन जो भी मिला उससे पड़ोसियों को बुलाकर सरल पूजा की और कथा सुनी। भगवान की कृपा से वह धनवान हो गया, संतान हुई और सुखपूर्वक जीवन बिताकर वैकुण्ठ गया। उसी के पड़ोस के एक निर्धन लकड़हारे ने भी व्रत का संकल्प लिया। उस दिन उसकी लकड़ी दोगुने दाम में बिकी। उसने भी पूजा की और उसका जीवन भी सुख से भर गया।',
      '॥ तृतीय अध्याय ॥\nउलकामुख नामक राजा जंगल में शिकार करते हुए एक साधु के आश्रम में बैठे। साधु सत्यनारायण पूजा कर रहे थे। राजा ने पूछा — "यह क्या है?" साधु ने बताया। राजा के पुत्र नहीं था। राजा ने प्रण लिया — "पुत्र होने पर यह व्रत करूँगा।" महल लौटकर रानी के साथ व्रत किया। पुत्री का जन्म हुआ — नाम रखा कलावती।\n\nकलावती बड़ी हुई। शादी के दिन राजा व्रत करना भूल गए — आनंद में भूल हुई। भगवान रूष्ट हुए। कुछ समय बाद राजा का दामाद एक झूठे मुकदमे में फँसा और जेल गया, सारी सम्पत्ति चली गई। कलावती ने जब व्रत का कारण समझा तो माँ के साथ मिलकर विधिपूर्वक सत्यनारायण पूजा की। भगवान प्रसन्न हुए और पति को मुक्ति मिली।',
      '॥ चतुर्थ अध्याय ॥\nसाधु नाम का एक वैश्य (व्यापारी) था — धर्मात्मा किंतु निःसंतान। उसने प्रण लिया — "पुत्र या पुत्री होने पर सत्यनारायण व्रत करूँगा।" पुत्री हुई — नाम रखा कलावती।\n\nएक दिन भगवान की माया से साधु वैश्य एक राज्य में व्यापार करने गया। वहाँ राजा की चोरी हुई थी। साधु और उसके साथियों पर संदेह हुआ — उन्हें बंदीगृह में डाल दिया और सारा माल जब्त कर लिया। घर में पत्नी और पुत्री बेहाल थीं। पुत्री ने भगवान की शरण ली और व्रत किया। भगवान ने साक्षात् प्रकट होकर कहा — "तेरे पिता ने व्रत नहीं किया, इसीलिए यह विपत्ति आई।" पत्नी ने तुरंत व्रत किया। उसी रात राजा को स्वप्न आया — उसने साधु को मुक्त कर सारी सम्पत्ति लौटा दी।',
      '॥ पञ्चम अध्याय ॥\nसाधु वैश्य अपने नगर लौट रहा था नाव पर। भगवान ने साधु की परीक्षा लेने के लिए वृद्ध ब्राह्मण का रूप लिया और पूछा — "नाव पर क्या माल है?" साधु ने घमंड में आकर कहा — "क्या देखना है तुम्हें — लता-पता।" भगवान बोले — "तथास्तु।" पल में नाव पर लदा सारा माल लता-पत्ते में बदल गया।\n\nसाधु घबराया — "यह क्या हुआ?" साथियों ने कहा — "नहीं जानते।" तभी एक साथी ने कहा — "उस वृद्ध ब्राह्मण को तुमने अपमानित किया था।" साधु को समझ आया। वह वृद्ध को ढूँढने लगा किंतु वे अंतर्धान हो चुके थे। साधु ने साष्टांग दंडवत किया और क्षमा माँगी। पश्चात्ताप की भावना देख भगवान प्रकट हुए — सारा माल वापस आ गया। साधु ने नगर में पहुँचकर विधिवत सत्यनारायण पूजा की और जीवनभर यह व्रत किया।',
    ],
    phalashruti:
        'यह पाँच अध्यायों की कथा जो श्रद्धापूर्वक सुनता और पढ़ता है, उसकी सभी मनोकामनाएँ पूर्ण होती हैं। धन, सन्तान, आरोग्य, और मोक्ष की प्राप्ति होती है। जो इस व्रत को करता है वह भगवान विष्णु का प्रिय भक्त बन जाता है। इति श्री सत्यनारायण व्रत कथा समाप्त। श्री सत्यनारायण स्वामी की जय।',
  ),
),
VistarPuja(
  id: 'gangaur_puja',
  name: 'Gangaur Puja',
  deity: 'Gauri (Parvati) & Shiva',
  emoji: '🌺',
  sub: 'The Rajasthani festival of Goddess Gauri — for marital bliss and good husbands',
  occasion: 'Chaitra Shukla Tritiya (3rd day after Holi) — celebrated for 18 days by women of Rajasthan, MP, and Gujarat',
  linkedAartiName: 'Jai Ambe Gauri',
  samagri: [
    'Clay or brass idols of Gauri (Parvati) and Isar (Shiva)',
    'Wooden chowki with red cloth',
    'Desi ghee and sesame oil for diya',
    'Mehndi (henna) — applied by unmarried girls on hands',
    'Roli, kumkum, haldi',
    'Akshat (rice)',
    'Fresh flowers — marigold, rose, jasmine',
    'Mango leaves and ashoka leaves',
    'Coconut',
    'Wheat grains and jaggery (gur)',
    'Fruits — banana, pomegranate, seasonal',
    'Puaniya (sweet fried bread) — traditional prasad',
    'Ghewar or malpua — regional sweet',
    'Suhaag ki chij — bangles, bindi, kajal, comb (for married women)',
    'New clothes (chunri — red or green) to offer to Gauri',
    'Gangaur geet song sheets — traditional folk songs are sung throughout',
    'Brass water pot and durva grass',
    'Red thread (mauli)',
  ],
  vidhi: [
    PujaVidhiStep(
      title: 'Mitti ki Gauri — Preparing the Idol',
      instruction:
          'On the first day (Chaitra Krishna Tritiya, just after Holi), women make small idols of Gauri and Isar (Shiva-Parvati) from clay or sand. The idol may also be bought. The idol is kept on the chowki and a small garden of wheat sprouts (jwara) is grown beside it starting from day one — these green sprouts represent fertility and abundance.',
      tip: 'In Rajasthan, the Gangaur idols are often beautifully dressed in miniature clothes and jewellery. The more lovingly dressed, the more blessed the puja.',
    ),
    PujaVidhiStep(
      title: 'Pratahkal Puja — Morning Worship',
      instruction:
          'Women wake before sunrise, bathe, and wear new or clean clothes (red or green preferred). Apply mehndi (unmarried girls apply it on their palms as Gauri herself did). Go to the puja space, light the diya, and offer fresh flowers to Gauri. Apply roli-akshat tilak to the idol. Offer a small pot of water to Gauri and Isar — they are given water to drink as a married couple.',
      mantra: 'जय गणेश गिरिजासुवन, मंगल मूल सुजान। कहत अयोध्यादास तुम, देहु अभय वरदान॥',
      tip: 'This morning puja is done daily for all 18 days. The evening puja is the main worship.',
    ),
    PujaVidhiStep(
      title: 'Shringar — Adorning Goddess Gauri',
      instruction:
          'Dress the Gauri idol in new clothes (a small red or green chunri). Apply chandan on her forehead. Offer suhaag ki chij — bangles, bindi, kajal, comb, red bead necklace — to the goddess. This act of adorning Gauri with all the symbols of a married woman\'s prosperity is the heart of Gangaur. Married women pray for their husband\'s long life; unmarried women pray for a good husband.',
      tip: 'After the puja ends, married women may take the bangles and wear them as Gauri\'s blessings (prasad).',
    ),
    PujaVidhiStep(
      title: 'Gangaur Geet — Sacred Folk Songs',
      instruction:
          'Women sit together and sing Gangaur folk songs (geet) — these traditional Rajasthani songs narrate the story of Gauri\'s marriage to Shiva, her longing, her journey, and her return. The songs are sung in a group, often with clapping and dholak. This communal singing is as important as the ritual itself — Gangaur is a festival of sisterhood.',
      tip: 'Traditional Gangaur geet begin with: "गणगौर पूजो, गणगौर पूजो, पार्वती माता की पूजो..." Learn at least one geet to participate fully.',
    ),
    PujaVidhiStep(
      title: 'Jwara Pooja — Worshipping the Wheat Sprouts',
      instruction:
          'The jwara (wheat sprouts grown from day one) are watered daily and worshipped as a symbol of fertility and the goddess\'s abundance. On the final day (Tritiya), the jwara are taken to a river, pond, or any water body in a procession and immersed — symbolising the departure of Gauri back to Shiva\'s abode (like a daughter returning to her husband\'s home after a visit).',
    ),
    PujaVidhiStep(
      title: 'Naivedya — Offering Food',
      instruction:
          'Offer the traditional prasad: puaniya (sweet fried bread), ghewar or malpua, and seasonal fruits. Also offer wheat grains and jaggery — these are symbols of the harvest and abundance that Gauri blesses. After the offering, distribute prasad among all women and girls present.',
    ),
    PujaVidhiStep(
      title: 'Shyam Puja — Evening Ceremony and Aarti',
      instruction:
          'In the evening, women dress in their finest clothes and jewellery, gather around the Gauri idol, and perform the aarti. Light multiple diyas around the idol. After aarti, women apply mehndi on each other\'s hands and exchange sweets. On the final day (18th day), the Gauri idol is taken in a grand procession (sawari) through the village or neighbourhood with music, singing, and dancing before being immersed in water.',
      tip: 'In Jaipur and Udaipur, the royal Gangaur sawari (procession) is one of the most spectacular folk festivals in India — elephants, camels, folk dancers, and the Gauri idol on a palanquin.',
    ),
  ],
  katha: PujaKatha(
    title: 'Gangaur Vrat Katha — Gauri Mahatmya',
    paragraphs: [
      'एक समय की बात है। माँ पार्वती भगवान शिव के साथ पृथ्वी-भ्रमण पर निकलीं। चैत्र शुक्ल तृतीया का दिन था। एक गाँव में सुहागिन स्त्रियाँ उनके स्वागत के लिए इकट्ठा हुईं। उन्होंने माँ पार्वती (गौरी) की पूजा की और सुहाग की कामना की। माँ पार्वती उनकी भक्ति से प्रसन्न हुईं और उन सभी को अखंड सौभाग्य का आशीर्वाद दिया।',
      'शिवजी ने पार्वती से पूछा — "तुमने इन स्त्रियों को इतनी जल्दी वर कैसे दे दिया?" पार्वती बोलीं — "हे प्रभु, इन स्त्रियों की भक्ति निष्कपट थी। जो सच्चे मन से मेरी पूजा करती है उसे सुहाग की कभी कमी नहीं होती।" शिवजी ने पूछा — "और जो कुँवारी कन्याएँ पूजती हैं?" पार्वती ने कहा — "उन्हें मनचाहा वर मिलेगा।"',
      'तभी एक गरीब ब्राह्मणी आई जो रोज़ घास काटकर जीवन चलाती थी। उसके पास पूजा की सामग्री नहीं थी। उसने भूमि से थोड़ी मिट्टी लेकर गौरी-ईसर की मूर्ति बनाई, जंगल के फूल चढ़ाए, और सच्चे मन से पूजा की। वह रोई — "हे माँ, मेरे पास और कुछ नहीं, बस मेरी भक्ति है।" माँ गौरी उसकी झोपड़ी में प्रकट हुईं और बोलीं — "मैं प्रसन्न हूँ। तेरे घर में कभी अन्न-धन की कमी नहीं होगी और तेरा सुहाग अखंड रहेगा।"',
      'ब्राह्मणी का जीवन बदल गया। उसके घर में धन आया, पति स्वस्थ और दीर्घायु हुए, और परिवार में आनंद छा गया। गाँव की स्त्रियों को पता चला तो उन्होंने भी उसी तरह श्रद्धा से पूजा करना शुरू किया। तब से चैत्र शुक्ल तृतीया को गणगौर व्रत प्रारंभ हुआ। माँ पार्वती हर वर्ष इस दिन अपनी भक्त स्त्रियों को आशीर्वाद देने आती हैं।',
    ],
    phalashruti:
        'यह कथा जो सुहागिन स्त्री श्रद्धापूर्वक सुनती है, उसका सुहाग अखंड रहता है, पति दीर्घायु होते हैं, और घर में सुख-शांति बनी रहती है। जो कुँवारी कन्या यह व्रत करती है उसे योग्य और प्रेमी वर मिलता है। गणगौर माता की जय।',
  ),
),
VistarPuja(
  id: 'teej_puja',
  name: 'Teej Puja',
  deity: 'Gauri (Parvati) & Shiva',
  emoji: '🌙',
  sub: 'The festival of marital bliss — Parvati\'s reunion with Lord Shiva',
  occasion: 'Hariyali Teej: Shravan Shukla Tritiya · Kajari Teej: Bhadrapada Krishna Tritiya · Hartalika Teej: Bhadrapada Shukla Tritiya (most important)',
  linkedAartiName: 'Jai Ambe Gauri',
  samagri: [
    'Sand or clay idols of Gauri and Shiva (Hartalika Teej)',
    'Or: framed image of Shiva-Parvati',
    'Wooden chowki with green cloth (green = Shravan/monsoon)',
    '16 shringar items — bindi, sindoor, bangles, kajal, mehndi, necklace, earrings, anklets, toe rings, nose pin, maang tikka, armbands, kamarbandh, hairpins, kajal, perfume',
    'Roli, haldi, kumkum',
    'Akshat',
    'Fresh flowers — especially jasmine, marigold, lotus',
    'Bel patra (bilva leaves — sacred to Shiva)',
    'Tulsi leaves',
    'Dhatura flower (sacred to Shiva)',
    'Panchamrit',
    'Incense and camphor',
    'Ghee diya',
    'Fasting prasad — fruits, makhana, dry fruits, coconut (no grains on Hartalika Teej)',
    'Mehndi — henna (applied night before)',
    'Green bangles (chura) — green is the colour of Teej',
    'Swing (jhula) — for Hariyali Teej, women sit on decorated swings',
    'Teej songs (folk songs of Rajasthan and UP)',
    'Red thread (mauli)',
  ],
  vidhi: [
    PujaVidhiStep(
      title: 'Nirjala Vrat — The Complete Fast',
      instruction:
          'Hartalika Teej is a nirjala vrat — no food and no water from sunrise to moonrise. Married women keep this fast for their husband\'s long life. Unmarried women keep it for a good husband. The fast is broken only after performing the puja and seeing the moon. If nirjala is not possible for health reasons, one may take fruit and water — but no grains.',
      tip: 'Prepare the day before by eating a substantial meal the previous night. Apply mehndi the night before — it should be deep red by morning, which is considered very auspicious.',
    ),
    PujaVidhiStep(
      title: 'Snan and Shringar — The Sacred Adornment',
      instruction:
          'Bathe before sunrise (in some traditions, a ritual bath in a river or pond). Wear new green, red, or yellow clothes — green is traditional for Hariyali Teej. Apply full 16 shringar: sindoor (married women), bangles (green chura), bindi, kajal, mehndi, jewellery. This full adornment is itself a form of worship — as Parvati adorned herself for Shiva, you adorn yourself in her honour.',
      tip: 'The 16 shringar is not vanity — each item has sacred significance and represents an aspect of feminine shakti.',
    ),
    PujaVidhiStep(
      title: 'Idol Preparation (Hartalika Teej)',
      instruction:
          'Make idols of Shiva and Parvati from sand or clay. Place them on a banana leaf or clean chowki. Decorate with flowers, bijora (citron) fruit, and bel patra. Parvati\'s idol should face Shiva. Light a diya between them — representing the divine union. Also place a small idol of Ganesha — He is always present at Shiva-Parvati worship.',
      tip: 'The story of Hartalika Teej is that Parvati made idols of Shiva from sand and worshipped them — this very act is replicated in the puja.',
    ),
    PujaVidhiStep(
      title: 'Shiva-Parvati Puja',
      instruction:
          'Perform full worship of Shiva-Parvati with:\n• Panchamrit abhishek on Shiva linga or idol\n• Bel patra offering to Shiva (mandatory — do not offer bel patra to Parvati)\n• Dhatura flower to Shiva\n• Lotus, jasmine, and rose to Parvati\n• Apply chandan and roli to both\n• Offer dhoop, diya, naivedya (fruits only)\n• Offer 16 shringar items to Parvati\'s idol — this is the unique offering of Teej\n• Tie red thread (mauli) around both idols',
      mantra:
          'शिवजी के लिए:\nॐ नमः शिवाय। ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्। उर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय माऽमृतात्॥\n\nपार्वती माँ के लिए:\nॐ उमायै नमः। सर्वमंगलमांगल्ये शिवे सर्वार्थसाधिके। शरण्ये त्र्यम्बके गौरि नारायणि नमोऽस्तुते॥',
      tip: 'Bel patra (bilva leaves) are strictly for Shiva — three-leafed offerings represent His three eyes. Never offer them to Lakshmi or Parvati.',
    ),
    ],
  ),
];

