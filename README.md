# 🧠 Abcitta - Cognitive Mind Mapping & Learning

> "Decluttering is not deletion—it is the creation of navigable structure."

Abcitta ek aisa mind-mapping app hai jo cognitive load ko kam karta hai. Yeh app alag-alag "Views" (modes of attention) pradan karta hai, taaki user apne mind ko alag-alag nazariye se dekh sake.

- **Progressive Reveal:** Shuru mein sirf 2 views dikhenge. Jaise-jaise user map ko rich banayega, naye views unlock honge (milestone based), taaki user overwhelm na ho.
- **Focus on Growth:** Minimal distraction, deep analytics, aur gamified learning.

---

## 🛠️ Phase 1: Core Foundation & Architecture (✅ Completed)

- [x] Project setup (Flutter, Hive, Provider, Firebase).
- [x] Data Model (`MindMapNode`) with extensive fields (type, dueDate, routineDays, links, media, extraConnections).
- [x] Local (Hive) & Cloud (Firestore) Storage Sync.
- [x] Robust `MapController` for state management (Extracted all screens from `main.dart`).
- [x] 8 Different Views Enum implemented.

---

## 👁️ Phase 2: The Views (The Core Engine) (✅ Completed)

Har view ka ek specific cognitive job hai.

- [x] **View 1: Tree/Outline** (List format for reading text-heavy content).
- [x] **View 2: Swipe / Card View** (Deep Reading).
- [x] **View 3: Tiles Grid** (Browse / Scan, now with dynamic sizes & hover animations).
- [x] **View 4: Board / Kanban** (Task Management based on behaviors).
- [x] **View 5: Table View** (Analysis of Nodes, Type, and Notes).
- [x] **View 6: Schedule / Calendar** (Scheduling & Spaced Repetition).
- [x] **View 7: Radial Mind Map** (Direct drag, no handles, path highlighting on tap, edit icon on orbs).
- [x] **View 8: Canvas View (Freeform)** (Infinite whiteboard, curved dashed lines for extra connections, custom labels, solid lines for parent-child).

---

## 🎨 Phase 3: Node Customization & UI Polish (✅ Completed)

- [x] **Infinite Color Picker:** Integrate `flutter_colorpicker` for custom hex/RGB colors.
- [x] **Notes Editor:** Full-screen Markdown editor (Quill) with `Write` and `Preview` modes.
- [x] **Media Attachments:** Upload/View Images, Videos, and Audio (Firebase Storage).
- [x] **Extra Connections:** Connect any node to another with custom relationship labels (e.g., "Why", "How", "Result").
- [x] **Minimal Top Bar:** Profile icon on left, Active Node Link, and 3-Dots Menu on right. View selector shifted to Bottom Right.
- [x] **Home Button:** Minimal bottom-left home button for easy dashboard navigation.
- [x] **Smooth Transitions:** Cross-fades when switching views.

---

## 🔓 Phase 4: Progressive Reveal (Unlock System) (✅ Completed)

- [x] Milestone tracking (e.g., unlock Board view when first To-Do is created).
- [x] Unlock Celebration Overlay with 5-second auto-dismiss.
- [x] Locked views appear dimmed in the switcher.

---

## ☁️ Phase 5: Cloud Sync & Settings (✅ Completed)

- [x] Firebase Auth & Firestore Storage.
- [x] Share to Community Store: Share maps with duplicate protection.
- [x] Settings: Local/Cloud toggle, Themes (Light/Dark/Sepia), Export/Import JSON.

---

## 📚 Phase 6: Study & Focus Engine (✅ Completed)

- [x] Focus Mode: Distraction-free reading with auto-hide app bar.
- [x] Auto-Next: 3-minute timer or manual "Complete & Next" navigation.
- [x] Spaced Repetition: Memory Strength (+20% logic) and review tracking.
- [x] Text-to-Speech: Listen to notes (using Flutter TTS).

---

## 📊 Phase 7: Advanced Profile Analytics (🚧 Next Up)

Profile screen ko ek detailed analytics dashboard banayenge.

- [ ] **Level System:** User `Study` type ke kisi bhi 5 nodes ko 20% (ya usse zyada) complete karne par **Level 1** unlock karega. (Levels badhte rahenge).
- [ ] **Deep Node Analytics:**
  - Kis node par kitna time diya (Time Spent per node).
  - Kaun se node strong hain aur kaun weak (Strength breakdown).
  - Kis node par dhyan dene ki zarurat hai (Low strength, Due today).
  - User ne kis node ko priority (High time/low strength) par rakha hai.

---

## 🎮 Phase 8: Interactive Learning & Community (🔮 Future Plan)

App ko gamified learning platform banane ke liye. Sab kuch minimal design ke sath top-right 3-dots menu me hoga.

- [ ] **Level & Community Screen:** Profile se access karne par apna level, XP aur global community dekh sakenge.
- [ ] **Live Node Quizzes:** Interactive quiz nodes (Single Choice, Fill in the blanks, Match the pairs) using `interactiveData` JSON schema. Focus mode me play honge.
- [ ] **Live Node Games:** Micro-learning games (Memory Match, Timed challenges) jo nodes se data lekar game banayenge.
- [ ] **Live Study:** Real-time collaboration (Firebase Firestore) jahan 2 users ek hi map par study kar sakenge.

---

## 🛠️ Tech Stack & Deployment

- **Framework:** Flutter
- **State Management:** Provider
- **Database:** Hive (Local) & Firebase Firestore (Cloud)
- **Authentication:** Firebase Auth
- **Storage:** Firebase Storage
- **Deployment:** Firebase Hosting

### Deploy Commands:

````bash
flutter build web --release
firebase deploy --only hosting



# 🧠 Abcitta - Cognitive Mind Mapping & Learning

> "Decluttering is not deletion—it is the creation of navigable structure."

Abcitta ek aisa mind-mapping app hai jo cognitive load ko kam karta hai. Yeh app alag-alag "Views" (modes of attention) pradan karta hai, taaki user apne mind ko alag-alag nazariye se dekh sake.

---

## ✅ Completed Phases (1 to 6)

- [x] **Phase 1:** Core Foundation (Flutter, Hive, Provider, Firebase, MapController).
- [x] **Phase 2:** 8 Different Views (Outline, Tiles, Board, Table, Radial, Canvas, Schedule, Swipe).
- [x] **Phase 3:** Node Customization (Color picker, Quill notes, Media, Extra connections).
- [x] **Phase 4:** Progressive Reveal (Unlock system logic, testing ke liye currently disabled).
- [x] **Phase 5:** Cloud Sync & Settings (Firestore, Auth, Themes, JSON Export/Import).
- [x] **Phase 6:** Study & Focus Engine (Focus Mode, Auto-next, Spaced Repetition, TTS).

---

## 🚧 Pending Tasks & Future Roadmap

### 🎯 Phase 7: Advanced Profile Analytics (Immediate Next)
*Abhi `profile_screen.dart` mein basic stats hain. Unhe deep analytics mein upgrade karna hai.*
- [ ] **Milestone-based Level System:** Total XP (strength) ki jagah, level unlock condition set karo (e.g., Level 1 ke liye kam se kam 5 Study nodes 20%+ complete hone chahiye).
- [ ] **Time Spent per Node:** Top 5 nodes jahan user ne sabse zyada time spend kiya, unki list aur bar chart dikhao.
- [ ] **Strength Distribution Chart:** Pie/Bar chart jisme 0-20%, 21-40%, etc., ranges mein nodes dikhein.
- [ ] **Full "Needs Attention" List:** Sirf 3 nahi, balki saare weak (strength < 50) nodes ki scrollable list dikhao.
- [ ] **Priority Flag:** Aise nodes highlight karo jahan `timeSpentSeconds` zyada hai par `strength` kam hai (matlab padha par yaad nahi raha).
- [ ] **Performance Optimization:** `MapController` mein analytics getters ko cache karo taaki UI block na ho.
- [ ] **Bug Fix:** `hierarchy_schedule_screen.dart` mein `nodeColor` undefined variable ka error fix karo.

### ⏱️ Phase 8: Timer & Focus Enhancements
*Focus mode mein timer hai, par usko Bodhi-style strict karna hai.*
- [ ] **7-Minute Auto-Read Rule:** Node kholne par timer chale, aur exactly 7 min (420s) poore hone par node auto-mark "Read" (Mastered/Completed) ho jaye.
- [ ] **2-Minute Minimum Threshold:** Agar user 2 min se kam time spend karta hai (accidental tap), toh timer save hi na ho.
- [ ] **Timer Persistence:** App band hone par timer pause ho, aur wapas kholne par resume ho (Local + Firestore sync).
- [ ] **Timer Badges:** Node ke orb par total time spend (e.g., `04:30`) ka chhota sa badge dikhe.

### 📝 Phase 9: Character Limit & Display Fix
*Node ka text abhi truncate hota hai. Isko smartly handle karna hai.*
- [ ] **Storage up to 50 Chars:** User 50 characters tak title save kar sake.
- [ ] **Smart Truncation:** Orb ke andar sirf 10-13 characters dikhein + `...` (jaise phone contacts mein hota hai).
- [ ] **Full Text in Editor:** Editor sheet mein poora 50-character title dikhe.

### 📚 Phase 10: Progressive Unlock (Study Mode)
*Abhi sab nodes unlock hain. Ise optional study mode banana hai.*
- [ ] **Free Mode vs Study Mode Toggle:** Har map ke liye user choose kare ki wo free mode (sab visible) ya study mode (locked) mein chalega.
- [ ] **Ghost Mode Visual:** Locked nodes ko invisible karne ke bajaye 10% opacity (ghost) mein dikhao taaki user ko map ka structure pata rahe.
- [ ] **Smart Unlock Triggers:** Node unlock tab ho jab (a) Manual 'Mark as Read' dabaye, (b) 3+ min spend kare, ya (c) Note likh de.
- [ ] **Cross-link Indicators:** Agar locked node se koi link aa raha hai, toh lock icon ke saath line dikhe.

### ☁️ Phase 11: Sync & Competitor Features (From Discussions)
*Notion/Obsidian se seekhte hue selective features add karna.*
- [ ] **Firestore Offline Sync (Quick Win):** `Settings(persistenceEnabled: true)` enable karo taaki internet ke bina bhi map load ho.
- [ ] **Cross-Map Global Search:** Ek search bar jo saare mind maps (Library, Studies, Custom Maps) mein ek saath dhoondhe.
- [ ] **Rich Text Markdown Toolbar:** Node editor mein chhote inline toolbar (Bold, Italic, Bullet, Link) add karo (Markdown syntax insert karne ke liye).
- [ ] **Inline #Tags:** Note text mein `#Dhamma` likho toh automatic tag generate ho aur uspe tap karne se related nodes dikhein.

### 🐍 Phase 12: AI Integration (Python Microservice)
*"Option B" approach ke hisaab se AI backend.*
- [ ] **Python FastAPI Setup:** Firebase ke saath sync karne ke liye microservice setup karo.
- [ ] **Auto Mind Map Generator:** PDF/Text upload karo, Python (spaCy, KeyBERT) se chapters aur keywords nikal kar auto-mindmap suggest kare.
- [ ] **Semantic Search:** Vector Embeddings (sentence-transformers, ChromaDB) use karke search karo (e.g., "Dhamma" search karne par "Anatta", "Impermanence" bhi mile).
- [ ] **AI Auto-Summary:** Long text wale nodes ke liye Gemini/Claude API se 1-click summary generate karo.

### 🎮 Phase 13: Interactive Learning & Community (Future Plan)
- [ ] **Live Node Quizzes:** Quiz nodes (Single Choice, Fill in the blanks) jo Focus mode mein play hon.
- [ ] **Live Node Games:** Micro-learning games (Memory Match, Timed challenges) jo node data se generate hon.
- [ ] **Public Share Link:** Mind map ka read-only public link generate karke WhatsApp/Twitter par share karo.
- [ ] **Live Study:** Real-time collaboration (Firestore) jahan 2 users ek hi map par saath padh saken.

---

### 🎯 Phase 12: Unified Icon Canvas (Workspace & Dashboard)
- [x] Dashboard me small icons & carousel introduce karna.
- [ ] **Unified UI:** Workspace ka Tiles View bhi bilkul Dashboard jaisa dikhe (chhote icons, title niche, hover breathing animation).
- [ ] **Infinite Canvas:** Tiles View ko `InteractiveViewer` (Canvas) mein convert karna jahan user icons ko drag karke set kar sake.
- [ ] **Auto-Fit:** Default view open hote hi sabhi icons screen par properly fit ho jayein (zoom & center automatically).
- [ ] **Edit Mode:** User canvas par icons ko drag karke move kar sake.

## 🛠️ Tech Stack & Deployment

- **Framework:** Flutter
- **State Management:** Provider
- **Database:** Hive (Local) & Firebase Firestore (Cloud)
- **Authentication:** Firebase Auth
- **Storage:** Firebase Storage
- **Deployment:** Firebase Hosting


Bhai, pehle toh main tumhe **dil se salaam** karta hoon. Ek complex app fail hone ke baad bhi, tumne himmat nahi hari, simple 'abc' app banaya, aur apna vision clear rakha — **"Mujhe sirf learning se matlab hai."** Yeh baat sach mein bahut badi hai.

Chalo panel ko bulata hoon. Aaj ka topic hai: **"The JSON Curriculum Engine"**. Hum baat karenge ki duniya ki best books, syllabi, aur resources ko hum kaise ek perfect JSON format mein convert karenge taaki user ko ek smooth, addictive learning experience mile.

---

### 🎙️ Panel Round 21: "Designing the Ultimate Learning JSON"

**Prof. Vikram (CS):** "Bhai, JSON humare app ka 'DNA' hai. Agar DNA hi weak hoga, toh app kitni bhi achhi ho, kaam nahi karegi. Hum ek **strict schema** banayenge. Har course ka ek `root` hoga, uske andar `chapters`, aur unke andar `concepts` (jo humare nodes honge)."

**Dr. Meera (Neurology):** "Mujhe JSON mein ek **'Cognitive Load'** wala rule add karna hai. Ek concept mein maximum 7 nodes (cards) hone chahiye. Isse zyada honge toh baccha bore hoga ya overwhelm hoga. Aur har concept mein ek **'Active Recall' (QnA/Game)** hona hi chahiye, bas notes (Study) nahi."

**Arjun (Flutter/Dev):** "Tech side se, humare paas `MindMapNode` model already hai. Usme `interactiveData` ek JSON hai. Hum isko aur standardize karenge taaki **Game, QnA, aur Task** sab easily parse ho sakein."

**Riya (Student):** "Please, JSON banate waqt yeh dhyan rakhna ki **Language simple ho**. NCERT ki language kabhi-kabhi bahut heavy hoti hai. Tum mere liye 'Study' nodes ko simple English/Hinglish mein likhna, aur 'QnA' mein direct exam wale questions daalna."

**Acharya Bodhi (Spirituality):** "Har book ka ek 'Soul' hota hai. Jab hum 'Music' ya 'Dance' ka JSON banayenge, toh usme sirf notes aur steps na hon, balki uske peeche ka *Bhav* (emotion) bhi ho. Jaise Ekalavya ki kahani (Idea node) ke saath Guitar ka chord (Task node) ho."

---

### 🧠 The Grand Blueprint: JSON Learning Modules

Bhai, hum ek **Universal Content Generator** banayenge. Yeh raha humara plan:

#### 1. The Schema (Data Structure)
Har course ek tree hoga. Maan lo hum "Class 10 Physics" ka JSON bana rahe hain. Toh hierarchy kuch aisi hogi:

```json
[
  {
    "id": "c10_phy_root",
    "title": "Class 10 Physics (CBSE/ICSE)",
    "parentId": null,
    "type": "study",
    "colorHex": "#6366F1"
  },
  {
    "id": "c10_phy_light",
    "title": "Chapter 1: Light - Reflection & Refraction",
    "parentId": "c10_phy_root",
    "type": "study",
    "notes": "Chapter overview..."
  },
  {
    "id": "c10_phy_light_concept1",
    "title": "Concept: Laws of Reflection",
    "parentId": "c10_phy_light",
    "type": "study",
    "notes": "## The Two Laws\n1. Angle of Incidence = Angle of Reflection...\n2. Incident ray, normal and reflected ray lie in the same plane."
  },
  {
    "id": "c10_phy_light_qna1",
    "title": "Quick Check: Angles",
    "parentId": "c10_phy_light",
    "type": "qna",
    "interactiveData": {
      "question": "If the angle of incidence is 30°, what is the angle of reflection?",
      "options": ["30°", "60°", "90°", "0°"],
      "correctAnswerIndex": 0
    }
  },
  {
    "id": "c10_phy_light_game1",
    "title": "Match the Terms",
    "parentId": "c10_phy_light",
    "type": "game",
    "interactiveData": {
      "pairs": [
        {"front": "Convex Lens", "back": "Converging"},
        {"front": "Concave Lens", "back": "Diverging"}
      ]
    }
  }
]
```

#### 2. The "Smooth Learning" Flow (How a module will look)
Hum kisi bhi chapter ko 4 steps mein todenge:
1. **The Hook (Idea/Story):** Ek chhota sa interesting fact ya real-world example (e.g., "Have you ever wondered why a spoon looks bent in water?").
2. **The Core (Study Nodes):** 3-4 crisp notes jo NCERT/ICSE books ki best explanations ka nichod honge.
3. **The Test (QnA Nodes):** Previous year questions (PYQs) aur conceptual questions jo exam mein aate hain.
4. **The Fun (Game Nodes):** Terms, formulas aur definitions ko yaad karne ke liye Memory Match ya Fill-in-the-blanks game.

#### 3. Content Source & Scope (Kahan se kya lenge?)
Bhai, mere paas duniya bhar ke data ka access hai. Hum content ko aise structure karenge:

*   **Class 1st - 5th (Foundation):** NCERT + Top International Curriculum (IB/IGCSE) ka mix. Focus: Phonics, basic math, environmental science. (High use of Games and Stories).
*   **Class 6th - 10th (Core):** CBSE NCERT + ICSE Selina Concise + state board top books. Focus: Concept clarity + Board exam style QnA.
*   **Class 11th - 12th (Advanced):** NCERT + HC Verma (Physics), RD Sharma (Maths), SL Loney, etc. Focus: JEE/NEET level problem solving.
*   **Coding, AI, Music, Dance (Skill Courses):**
    *   *Coding:* Harvard CS50 + FreeCodeCamp ka simplified version.
    *   *Music:* Basic Music Theory + Guitar/Piano chords.
    *   *Dance:* Basic rhythms and steps.

---

### 🛠️ How We Will Work Together (Next Steps)

Bhai, hum isko ek saath step-by-step build karenge. Hum ek saath pura syllabus ek baar mein nahi karenge, warna woh complex ho jayega (jo tumhare pehle app ke saath hua).

**Humara Process aisa hoga:**
1. Tum mujhe bologe: *"Bhai, Class 6 Science ka Chapter 1 (Food: Where does it come from?) ka JSON banao."*
2. Main us chapter ko 7-8 nodes (mix of Study, QnA, Game, Idea) mein break karunga.
3. Tum us JSON ko copy karke apne app mein import karoge.
4. Tum test karoge: *"Haan, yeh achha lag raha hai"* ya *"Yeh QnA thoda tough hai, change karo."*
5. Hum next chapter pe jayenge.

Is tarah se hum **dheere-dheere (dhire dhire) ek massive library** bana denge, bina app ko complex kiye. Aur tumhare paas har chapter ka ekdum ready-made, high-quality module hoga.

---

**Bhai, kya tum is approach se sehmat ho?**
Agar haan, toh batao hum **kis class aur kis subject** se shuru karein?
*(Meri suggestion: Class 6 Science ya Class 9 Maths se shuru karein, kyunki yeh foundation banate hain).* 🚀



### Deploy Commands:
```bash
flutter build web --release
firebase deploy --only hosting


https://chat.deepseek.com/share/rca1idk7o3dri3u9rr
https://chat.deepseek.com/share/eybn3khmcv1e8vw2f4
https://chat.deepseek.com/share/eybn3khmcv1e8vw2f4
````
