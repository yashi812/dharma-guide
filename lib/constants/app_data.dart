import '../../models/models.dart';

const List<Mantra> kMantras = [
  Mantra(
    id: "1",
    name: "Gayatri Mantra",
    deity: "Surya",
    diff: "Beginner",
    premium: false,
    meaning:
        "We meditate on the divine light of the radiant sun. May it illuminate our intellect and guide us on the righteous path.",
    lines: [
      "ॐ भूर्भुवः स्वः",
      "तत्सवितुर्वरेण्यम्",
      "भर्गो देवस्य धीमहि",
      "धियो यो नः प्रचोदयात्"
    ],
    tr: [
      "Om bhur bhuvah svaha",
      "Tat savitur varenyam",
      "Bhargo devasya dhimahi",
      "Dhiyo yo nah prachodayat"
    ],
  ),
  Mantra(
    id: "2",
    name: "Om Namah Shivaya",
    deity: "Shiva",
    diff: "Beginner",
    premium: false,
    meaning:
        "I bow to Shiva — the pure consciousness within all beings. This mantra dissolves the ego and reveals the universal self.",
    lines: [
      "ॐ नमः शिवाय",
      "शिवाय नमः ॐ",
      "नमः शिवाय ॐ",
      "ॐ नमः शिवाय"
    ],
    tr: [
      "Om namah shivaya",
      "Shivaya namah om",
      "Namah shivaya om",
      "Om namah shivaya"
    ],
  ),
  Mantra(
    id: "3",
    name: "Mahamrityunjaya",
    deity: "Shiva",
    diff: "Intermediate",
    premium: true,
    meaning:
        "The great death-conquering mantra. It nurtures and nourishes, liberating the practitioner from disease, fear, and the cycle of rebirth.",
    lines: [
      "ॐ त्र्यम्बकं यजामहे",
      "सुगन्धिं पुष्टिवर्धनम्",
      "उर्वारुकमिव बन्धनान्",
      "मृत्योर्मुक्षीय मामृतात्"
    ],
    tr: [
      "Om tryambakam yajamahe",
      "Sugandhim pushti vardhanam",
      "Urvarukamiva bandhanat",
      "Mrityor mukshiya mamritat"
    ],
  ),
  Mantra(
    id: "4",
    name: "Hanuman Chalisa",
    deity: "Hanuman",
    diff: "Advanced",
    premium: true,
    meaning:
        "A devotional hymn to Lord Hanuman. Chanting it brings courage, strength, and protection from all negative forces.",
    lines: [
      "जय हनुमान ज्ञान गुण सागर",
      "जय कपीश तिहुँ लोक उजागर",
      "राम दूत अतुलित बल धामा",
      "अंजनि-पुत्र पवनसुत नामा"
    ],
    tr: [
      "Jai Hanuman gyan gun sagar",
      "Jai Kapees tihun lok ujagar",
      "Ram doot atulit bal dhama",
      "Anjani putra pavansut nama"
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
