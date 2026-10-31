# 🪷 Citta — Beyond the Mind

> *"A cognitive mind-mapping OS for the consciousness age."*

Citta is not just a note-taking app. It is a **Second Brain** designed to align with **Dhamma** (mindfulness, non-grasping, and letting go). Built with Flutter and heavily co-created with **AI (Large Language Models)**, this app prioritizes *alignment* over *engagement*, and *peace* over *dopamine loops*.

The name itself is a practice: the space between `a` (negation) and `citta` (mind) is the breath.

---

## 🌱 The Vision
My vision was to build an app that understands the user's cognitive load. We live in an age of infinite distractions. Citta is designed to be a sanctuary where users can map their thoughts, learn through active recall, and seamlessly transition into mindfulness. By leveraging AI for architectural design, code generation, and pedagogical game mechanics, Citta bridges the gap between ancient wisdom and modern technology.

---

## ✨ Core Features

*   **7 Dynamic Views:** Tiles, Board, Table, Radial, Timeline, Canvas, and Outline.
*   **Focus Mode:** A clean, minimalist reading environment with Text-to-Speech (TTS) syncing.
*   **SM-2 Spaced Repetition:** Memory algorithms that calculate exactly when to show a node again.
*   **Implicit Grading:** Zero mental load. The app calculates memory strength based on *how long* the user spent reading, not by forcing them to rate themselves 1-5.
*   **Bidirectional Sync:** Seamless merge between Local (Hive) and Cloud (Firebase).
*   **Forest Map Visualization:** A visual representation of your growth. Nodes start as seeds and bloom into trees with flowers/fruits as you master them.

---

## 🎮 The 14-Game Engine (EdTech)

To make learning addictive yet educational, Citta features a JSON-driven Game Engine. The engine routes to any of the following 14 games based on the node's `gameType`:

1.  **QnA (Multiple Choice):** Classic quiz format.
2.  **Fill in the Blanks:** Contextual sentence completion.
3.  **Memory Match:** Flip-card pair matching for short-term recall.
4.  **True or False:** Fast-paced statement validation.
5.  **Odd One Out:** Find the item that doesn't belong in the category.
6.  **Word Scramble:** Unscramble letters to form the correct word.
7.  **Order the Steps:** Drag and drop to sequence processes correctly.
8.  **Sort & Categorize:** Tap-to-sort items into their correct categories.
9.  **Error Spotting:** Find the incorrect word in a sentence.
10. **Cloze Test:** Fill multiple blanks in a short passage from a word bank.
11. **Analogy Matching:** Complete the relationship (A is to B as C is to ___).
12. **Rank Order:** Arrange items based on a specific criteria (e.g., size, date).
13. **Audio Recall:** Listen to the TTS and select the correct word/phrase.
14. **Mini Case Study:** Read a scenario and diagnose/answer the question.

---

## 🔓 Hidden Features & "Powers" (How to Access)

Citta has several hidden modes designed for different mental states. Here is how you can unlock the true power of the app:

*   **🧘 Dhamma Mode (Zero Gamification):**
    *   *How to access:* Go to `Hub` -> `Settings` -> Toggle **"Enable Dhamma Mode"**.
    *   *Power:* Hides all levels, streaks, and confetti. Replaces dopamine hits with gentle breathing animations. It strips the app down to pure, distraction-free learning.
*   **🎓 Exam Mode (Zero Distraction):**
    *   *How to access:* Go to `Hub` -> `Settings` -> Toggle **"Enable Exam Mode"**.
    *   *Power:* Cleans the dashboard to show *only* today's pending reviews. Hide all folders and non-essential widgets.
*   **🎧 Custom Guided Meditations & Scriptures:**
    *   *How to access:* Go to `Hub` -> `Store` -> **Guided Tab** -> Tap "Import Custom Meditation (JSON)".
    *   *Power:* Import JSON scripts for Suttas, Gita, Bible, or your own custom voice guides. They will automatically appear in the Meditation screen's Anchor list.
*   **🔊 Voice Customization (TTS Engine):**
    *   *How to access:* Open any node in `Focus Mode` -> **Long press the Speaker/Volume icon** at the bottom.
    *   *Power:* Change voice pitch, speed, and select specific language voices. You can also toggle "Auto-play on open".
*   **📥 Custom Lessons & Games via JSON:**
    *   *How to access:* Go to `Dashboard` -> Tap the **`+` (FAB) button** -> `Import JSON`.
    *   *Power:* You can generate custom curriculums or game nodes using ChatGPT/Claude and paste the JSON directly into the app.
*   **🌳 The Mind Forest Growth:**
    *   *How to access:* Go to `Hub` -> `Forest`.
    *   *Power:* This isn't just a folder view. It calculates your aggregate strength. 0 nodes mastered = Seed, >30% = Sprout, >75% = Tree with Flowers/Fruits.

---

## 🛠 Tech Stack & Architecture

*   **Frontend:** Flutter (Dart)
*   **State Management:** Provider (Modular Controllers)
*   **Local Database:** Hive (Offline-first architecture)
*   **Cloud Backend:** Firebase (Auth, Firestore, Storage)
*   **TTS Engine:** `flutter_tts` (Multilingual support)
*   **Game Engine:** Custom `GameRouter` with modular JSON parsers for 14 game types.

### Architecture Principles
*   **Crash-Proofing:** All async operations are wrapped in `safeCall()`.
*   **Data Integrity:** Cycle prevention in tree traversal, orphan node rescue, and schema versioning (v2).
*   **Performance:** Debounced database writes, memoized canvas positions, and throttled TTS UI updates.

---

## 🚀 How to Run

1. Ensure you have Flutter installed (SDK `>=3.4.0`).
2. Clone the repository.
3. Run `flutter pub get`.
4. Add your `google-services.json` in the `android/app/` folder for Firebase.
5. Run `flutter run -d chrome` (or Android/iOS).

---

## 🧘 Philosophy
> *"We will not build an app that wakes the user up abruptly.*
> *We will build an app that wakes the user gently.*
> *And when they are awake — the app turns off.*
> ***This is Citta.***"

---
*Built with love and 🤖 by a creator exploring the intersection of Dhamma and AI.*
