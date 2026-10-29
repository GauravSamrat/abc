const String rawDhammaJson = r'''
[
  {
    "id": "dhamma_root",
    "title": "Dhamma / धम्म — The True Teaching",
    "parentId": null,
    "type": "note",
    "colorHex": "#E8D5B7",
    "notes": "Welcome to the Manuals of Dhamma. Click on the sub-nodes to explore the deep teachings of Ven. Ledi Sayadaw."
  },
  {
    "id": "vipassana_dipani",
    "title": "Vipassana Dipani (The Manual of Insight)",
    "parentId": "dhamma_root",
    "type": "study",
    "colorHex": "#E8D5B7",
    "notes": "Yeh Ledi Sayadaw ji ka sabse famous manual hai. Isme Vipassana (Insight) meditation ke core concepts, jaise Vipallasa (Bhram), Manana (Fantasy), Abhinivesa (Firm Belief), aur Two Truths ko bahut gehrai se samjhaya gaya hai. Yeh manual aapko samajhne mein help karega ki hum duniya ko galat kaise dekhte hain aur satya tak kaise pahunchte hain.",
    "links": [
      { "title": "VRI PDF (Full Text)", "url": "https://www.vridhamma.org/file/5469/download?token=CcwLLEuK" },
      { "title": "Wisdomlib (Vipassana Dipani)", "url": "https://www.wisdomlib.org/buddhism/book/the-vipassana-dipani" }
    ]
  },
  {
    "id": "three_vipallasa",
    "title": "1. The Three Vipallasa (Teen Bhram)",
    "parentId": "vipassana_dipani",
    "type": "study",
    "colorHex": "#A5A58D",
    "notes": "Vipallasa matlab aisi galat samajh (hallucination) jisme hum reality ko ulta samajh lete hain. Hum jo bhi dekhte, sochte ya maante hain, woh zyadatar 'Vipallasa' se affected hota hai. Buddha ne bataya ki hum 3 tarike se dhokha khate hain:\n\n1. **Sanna-vipallasa (Perception)**: Galat dekhna. (Jaise raste me rassi ko saanp samajh lena).\n2. **Citta-vipallasa (Thought)**: Galat sochna. (Jaise jadugar ke dikhaye hue jhadu ko sona samajhna).\n3. **Ditthi-vipallasa (View)**: Galat maan lena. (Jaise galat raste ko sahi samajh kar adna).\n\nYeh teeno hi humein Anicca (impermanence) ko Nicca (permanent) samajhne par majboor karte hain.",
    "links": [
      { "title": "Vipallasa Sutta (Dharma Seed)", "url": "https://sr.dharmaseed.org/talks/2015/07/22/distortions-of-perception-mind-view/" },
      { "title": "Tricycle: Mistaking a Stick for a Snake", "url": "https://tricycle.org/magazine/perception-vipallasa/" }
    ]
  },
  {
    "id": "three_manana",
    "title": "2. The Three Manana (Teen Fantasy)",
    "parentId": "vipassana_dipani",
    "type": "study",
    "colorHex": "#D4A373",
    "notes": "Manana ka matlab hai 'fantasy' ya 'high imagination'. Jab hum Vipallasa (bhram) ke through duniya ko galat dekhte hain, toh hum apne mann mein 'Manana' create karte hain.\n\n1. **Tanha-manana (Fantasy by Lust)**: Yeh kehna ki 'Yeh mera hai' (Mine) aur 'Yeh mera apna hai' (My Own), jabki asal mein kuch bhi hamara nahi hai.\n2. **Mana-manana (Fantasy by Conceit)**: Yeh sochna ki 'Main hoon' (I am) aur 'Main sabse alag/bada hoon'. Yeh ahankar (ego) se aata hai.\n3. **Ditthi-manana (Fantasy by Error)**: Yeh galat belief ki 'Mera shareer hi mera aatma (soul) hai' ya 'Mera mann hi mera core hai'.\n\nIn teeno 'Manana' ko 'Three Gahas' (Three Holds) bhi kaha jata hai, kyunki yeh humein kaskar pakad lete hain.",
    "links": [
      { "title": "Wisdomlib: The Three Mannana", "url": "https://www.wisdomlib.org/buddhism/book/the-vipassana-dipani/d/doc2923.html" }
    ]
  },
  {
    "id": "two_abhinivesa",
    "title": "3. The Two Abhinivesa (Do Pakki Beliefs)",
    "parentId": "vipassana_dipani",
    "type": "study",
    "colorHex": "#B5838D",
    "notes": "Abhinivesa matlab woh belief jo mann mein itna firmly set ho jaye jaise deewar mein laga hua khamba (doorpost), jise kisi bhi tarah hilaya na ja sake.\n\n1. **Tanha-abhinivesa**: Yeh firmly believe karna ki 'Yeh body, yeh haath, yeh pair mera hai', jabki asal mein yeh sirf elements ka combination hai.\n2. **Ditthi-abhinivesa**: Yeh firmly believe karna ki 'Mere andar ek permanent Soul (Aatma) hai jo sab kuch control karti hai'. \n\nYeh dono hi 'Puthujjana' (ordinary person) ke do bade resting places hain.",
    "links": [
      { "title": "Abhinivesa Definition", "url": "https://www.wisdomlib.org/definition/abhinivesa" }
    ]
  },
  {
    "id": "two_bhumi",
    "title": "4. The Two Bhumi (Do Stages)",
    "parentId": "vipassana_dipani",
    "type": "study",
    "colorHex": "#CB997E",
    "notes": "Bhumi matlab woh zameen ya stage jahan koi cheez khadi hoti hai. Yahan yeh bataya gaya hai ki koi insaan kis level par hai:\n\n1. **Puthujjana-bhumi**: Yeh ordinary insaan ka stage hai. Yahan insaan 'Ditthi-vipallasa' (galat view) par khada hota hai aur maanta hai ki uske andar kuch permanent aur achha hai.\n2. **Ariya-bhumi**: Yeh Noble (Ariya) insaan ka stage hai. Yahan insaan 'Samma Ditthi' (Right View) par khada hota hai aur jaanta hai ki uske andar kuch bhi permanent nahi hai.\n\nJab koi insaan apni galat views ko completely khatam kar deta hai, toh woh Puthujjana-bhumi se nikal kar Ariya-bhumi mein aa jata hai.",
    "links": [
      { "title": "Puthujjana vs Ariya", "url": "https://www.buddhanet.net/e-learning/buddhism/glossary.htm" }
    ]
  },
  {
    "id": "two_gati",
    "title": "5. The Two Gati (Do Destinations)",
    "parentId": "vipassana_dipani",
    "type": "study",
    "colorHex": "#7B9EA8",
    "notes": "Gati ka matlab hai 'transmigration' ya 'change of existences' (ek life se dusri life mein jana).\n\n1. **Puthujjana-gati**: Ordinary insaan ki gati. Yeh 'Vinipatana' (dispersion) hai, matlab aapko nahi pata ki aap next life mein kahan jaoge. Jaise nariyal ped se girta hai, use nahi pata kahan girega. Aap kisi bhi lower world (hell, animal) mein ja sakte ho.\n2. **Ariya-gati**: Noble insaan ki gati. Yeh 'deliverance' (mukti) hai. Ariya jaanta hai ki woh sirf higher worlds (Deva, Brahma) mein hi jaayega. Jaise ek pakshi udta hai aur apni marzi se ped par baithta hai, waise hi Ariya apni marzi se higher existence choose karta hai.",
    "links": [
      { "title": "Gati in Buddhism", "url": "https://www.wisdomlib.org/definition/gati" }
    ]
  },
  {
    "id": "two_saccas",
    "title": "6. The Two Saccas (Do Satya / Truths)",
    "parentId": "vipassana_dipani",
    "type": "study",
    "colorHex": "#9C89B8",
    "notes": "Sacca matlab Truth (Satya). Buddhism mein do level ke truths hote hain:\n\n1. **Sammuti-sacca (Conventional Truth)**: Yeh woh satya hai jo aam aadmi maanta hai. Jaise 'Main exist karta hoon', 'Mera shareer hai', 'Ped hai', 'Gaadi hai'. Yeh practical life ke liye zaroori hai.\n2. **Paramattha-sacca (Ultimate Truth)**: Yeh woh satya hai jo reality mein hai. Jaise 'Koi permanent main nahi hai', 'Sirf elements (Mahabhuta) hain', 'Gaadi nahi hai, sirf lakdi aur dhaatu hain'. \n\nLedi Sayadaw kehte hain, dono truths sahi hain apne-apne jagah par. Lekin agar humein dukh (Samsara) se nikalna hai, toh humein 'Conventional' ko chhod kar 'Ultimate Truth' ko samajhna hoga.",
    "links": [
      { "title": "Study Buddhism: Two Truths", "url": "https://studybuddhism.com/en/advanced-studies/abhidharma/two-truths/introduction-to-the-two-truths-in-theravada" },
      { "title": "Encyclopedia: Two Truths", "url": "https://onlinelibrary.wiley.com/doi/10.1002/9781119009924.eopr0385" }
    ]
  },
  {
    "id": "fifty_four_mental_phenomena",
    "title": "7. Fifty-Four Kinds of Mental Phenomena",
    "parentId": "vipassana_dipani",
    "type": "study",
    "colorHex": "#E8D5B7",
    "notes": "Buddha ne bataya ki is duniya mein total 82 ultimate realities (Paramattha dhammas) hain. Inme se 28 Rupa (Physical/Material) hain, aur 54 Nama (Mental) hain. Yeh 54 mental phenomena humare 'Mann' ko banate hain. Inhe samajhna zaroori hai kyunki Vipassana mein humein inhi ko dekhna hota hai.\n\n54 Mental Phenomena = 1 Citta (Consciousness) + 52 Cetasika (Mental Properties) + 1 Nibbana.",
    "links": [
      { "title": "Abhidhamma: 54 Mental Phenomena", "url": "https://www.wisdomlib.org/buddhism/book/the-vipassana-dipani/d/doc2926.html" }
    ]
  },
  {
    "id": "citta_consciousness",
    "title": "7.1 Citta (Consciousness)",
    "parentId": "fifty_four_mental_phenomena",
    "type": "study",
    "colorHex": "#A5A58D",
    "notes": "Citta ka matlab hai 'Consciousness' (Chetna) ya 'Mann'. Yeh wo kshamta hai jo kisi object ko jaanti hai, mehsoos karti hai, ya usko pakadti hai. Jaise aankhon se dekhna, kaanon se sunna, ya mann se sochna.\n\nBuddha ne isko 6 classes mein baanta hai:\n1. **Cakkhu-vinnana**: Aankh se dekhne ki chetna.\n2. **Sota-vinnana**: Kaan se sunne ki chetna.\n3. **Ghana-vinnana**: Naak se sunghne ki chetna.\n4. **Jivha-vinnana**: Jeebh se chatne ki chetna.\n5. **Kaya-vinnana**: Shareer se touch mehsoos karne ki chetna.\n6. **Mano-vinnana**: Dimag/Mann se sochne ki chetna.",
    "links": [
      { "title": "Citta (Consciousness) Definition", "url": "https://www.accesstoinsight.org/ptf/dhamma/sacca/sacca4/samma-ditthi/index.html" }
    ]
  },
  {
    "id": "cetasika_properties",
    "title": "7.2 Fifty-Two Cetasika (Mental Properties)",
    "parentId": "fifty_four_mental_phenomena",
    "type": "study",
    "colorHex": "#D4A373",
    "notes": "Cetasika ka matlab hai woh 'Mental Factors' (mansik gun) jo Citta (Consciousness) ke saath mil kar aate hain. Jaise jab aap koi cheez dekhte hain, toh sirf dekhna (Citta) nahi hota, uske saath feeling (Vedana), pehchan (Sanna), aur ichha (Cetana) bhi hoti hai. Yehi Cetasikas hain.\n\nInhe 4 categories mein baanta gaya hai:\n- 7 Universals (Sabba-cittaka): Ye har chetna ke saath hote hain (e.g., Contact, Feeling).\n- 6 Particulars (Pakinnaka): Ye kabhi-kabhi aate hain (e.g., Effort, Joy).\n- 14 Immorals (Papajati): Ye buraai ki jadein hain (e.g., Greed, Hate, Delusion).\n- 25 Morals (Kalyana): Ye achhaai ki jadein hain (e.g., Faith, Mindfulness, Compassion).",
    "links": [
      { "title": "52 Mental Factors (Cetasika)", "url": "https://en.wikipedia.org/wiki/Mental_factors_(Buddhism)" }
    ]
  },
  {
    "id": "nibbana_freedom",
    "title": "7.3 Nibbana (The Unconditioned)",
    "parentId": "fifty_four_mental_phenomena",
    "type": "study",
    "colorHex": "#B5838D",
    "notes": "Nibbana ka matlab hai 'Freedom from every kind of infelicity' (Har tarah ke dukh se mukti).\n\nLedi Sayadaw kehte hain ki Nibbana ko 3 hisson mein samjha ja sakta hai:\n1. **First Nibbana**: Lower worlds (Hell, Animal, Peta) se mukti. (Yeh Sotapanna ko milta hai).\n2. **Second Nibbana**: Kama-loka (Sensual world) se mukti. (Yeh Anagami ko milta hai).\n3. **Third Nibbana**: Rupa-loka aur Arupa-loka (Brahma worlds) se bhi mukti. (Yeh Arahat ko milta hai).\n\nNibbana hi ek aisa 'Dhamma' hai jo unconditioned (Asankhata) hai, matlab yeh kisi karan se paida nahi hota.",
    "links": [
      { "title": "What is Nibbana?", "url": "https://www.accesstoinsight.org/ptf/dhamma/sacca/sacca3/index.html" }
    ]
  },
  {
    "id": "four_mahabhutas",
    "title": "8. The Four Mahabhutas (Four Great Elements)",
    "parentId": "vipassana_dipani",
    "type": "study",
    "colorHex": "#CB997E",
    "notes": "Humara shareer (Rupa) 28 physical qualities se bana hai. Unme se 4 sabse main (Great Essentials/Mahabhuta) hain. Vipassana mein sabse pehle inhi 4 elements ko mehsoos karna sikhaya jata hai:\n\n1. **Pathavi (Earth/Extension)**: Iska matlab 'Hardness' aur 'Softness'. Shareer mein jahan kathorata (haddi) ya naramipan (maans) hai.\n2. **Apo (Water/Cohesion)**: Iska matlab 'Liquidity' aur 'Cohesion'. Jo shareer ko jod kar rakhta hai (khoon, paseena).\n3. **Tejo (Fire/Heat)**: Iska matlab 'Heat' aur 'Cold'. Shareer ka tapman (garmi, thand).\n4. **Vayo (Wind/Motion)**: Iska matlab 'Support' aur 'Motion'. Shareer mein chalna, hilna, saans lena.\n\nJab hum in 4 elements ko observe karte hain, toh humein samajh aata hai ki 'Main' ya 'Mera Shareer' naam ki koi cheez nahi hai, sirf yeh 4 elements hain.",
    "links": [
      { "title": "Four Great Elements (Dhatu)", "url": "https://www.wisdomlib.org/definition/mahabhuta" },
      { "title": "Vipassana: Observing the 4 Elements", "url": "https://www.dhammatalks.org/books/Meditations1/Section0009.html" }
    ]
  },
  {
    "id": "two_vinnatti",
    "title": "9. The Two Vinnatti-Rupas (Modes of Communication)",
    "parentId": "vipassana_dipani",
    "type": "study",
    "colorHex": "#7B9EA8",
    "notes": "Vinnatti ka matlab hai 'Communication' (Sampreshan). Hamare shareer mein 2 aise rupas (materials) hain jisse hum apni bhavnaayein dusron tak pahunchate hain:\n\n1. **Kaya-vinnatti (Bodily Intimation)**: Shareer ki harkat. Jaise haath hilana, chalna, ya chehre ke bhaav. Isse dusre samajh jaate hain ki hum kya kehna chahte hain.\n2. **Vaci-vinnatti (Vocal Intimation)**: Awaaz (Speech). Jubaan aur gale se nikli awaaz. Isse hum apne thoughts bol kar batate hain.\n\nLedi Sayadaw kehte hain ki yeh dono cheezein 'Citta' (Mann) se paida hoti hain. Agar mann mein kuch nahi hai, toh na shareer hilega na awaaz niklegi.",
    "links": [
      { "title": "Vinnatti Rupa Explanation", "url": "https://www.wisdomlib.org/definition/vinnatti" }
    ]
  },
  {
    "id": "jivita_rupa",
    "title": "10. Jivita-Rupa (Material Quality of Life)",
    "parentId": "vipassana_dipani",
    "type": "study",
    "colorHex": "#9C89B8",
    "notes": "Jivita ka matlab hai 'Life' ya 'Vital Force' (Pran). Yeh ek aisi energy hai jo shareer ko zinda rakhti hai aur usko sadne (decay) se bachati hai.\n\nJaise ek talaab ka paani kamal ke ped ko sadne se bachata hai, waise hi yeh Jivita-rupa humare shareer ko control karta hai. Jab tak yeh hai, hum zinda hain (Living being). Jab yeh khatam ho jata hai, toh hum kehte hain ki insaan mar gaya.\n\nYeh material quality humare Kamma (past actions) se paida hoti hai.",
    "links": [
      { "title": "Jivita Rupa (Life Faculty)", "url": "https://www.wisdomlib.org/definition/jivitindriya" }
    ]
  },
  {
    "id": "sammaditthi_dipani",
    "title": "11. Sammaditthi Dipani (Manual of Right Views)",
    "parentId": "root_dhamma",
    "type": "study",
    "colorHex": "#E8D5B7",
    "notes": "Sammaditthi ka matlab hai 'Right View' ya 'Sahi Samajh'. Ledi Sayadaw is manual mein samjhate hain ki dukh (Samsara) se nikalne ke liye sahi drishti (view) sabse zaroori hai. Isme Buddha ne 3 sabse bade galat views (Wrong Views) ka refute kiya hai jo logon ko galat raste par le jaate hain.",
    "links": [
      { "title": "VRI PDF (Full Text)", "url": "https://www.vridhamma.org/file/5469/download?token=CcwLLEuK" },
      { "title": "Wisdomlib: Sammaditthi Dipani", "url": "https://www.wisdomlib.org/buddhism/book/the-sammaditthi-dipani" }
    ]
  },
  {
    "id": "three_wrong_views",
    "title": "11.1 Three Kinds of Wrong Views",
    "parentId": "sammaditthi_dipani",
    "type": "study",
    "colorHex": "#A5A58D",
    "notes": "Buddha ne bataya ki duniya mein 3 aise views hain jinhe pakad kar log galat raste par chale jaate hain:\n\n1. **Pubbekata-hetu-ditthi**: Yeh view maanta hai ki 'Jo bhi humare saath ho raha hai, wo sirf humare past karmas ki wajah se ho raha hai. Present mein hum kuch nahi kar sakte.' (Inaction)\n2. **Issaranimmana-hetu-ditthi**: Yeh view maanta hai ki 'Sab kuch ek Bhagwan/God/Brahma ne banaya hai. Humare paas koi choice nahi hai.' (Fatalism)\n3. **Ahetu-apaccaya-ditthi**: Yeh view maanta hai ki 'Sab kuch apne aap, bina kisi karan ke ho raha hai. Koi kamma nahi, koi God nahi.' (Chaos)",
    "links": [
      { "title": "Three Wrong Views", "url": "https://www.wisdomlib.org/buddhism/book/the-sammaditthi-dipani/d/doc3033.html" }
    ]
  },
  {
    "id": "refutation_pubbekata",
    "title": "11.2 Refutation of Pubbekata View",
    "parentId": "three_wrong_views",
    "type": "study",
    "colorHex": "#D4A373",
    "notes": "Agar aisa hota ki sab kuch sirf past karmas se hota hai, toh insaan mein 'Desire-to-do' (Chanda) aur 'Energy' (Vayama) naam ki cheez hi nahi hoti. Hum achha ya bura karne ka mann kaise banate?\n\nBuddha kehte hain: Agar present ki koshish ka koi matlab nahi hai, toh koi bhi sikhna, sudharna, ya dhyan (meditation) karne ki koshish kyun karega? Aisa maan lena ki sirf past se sab decide hota hai, ek bahut badi galat samajh (wrong view) hai.",
    "links": [
      { "title": "Refutation of Pubbekata", "url": "https://www.wisdomlib.org/buddhism/book/the-sammaditthi-dipani/d/doc3034.html" }
    ]
  },
  {
    "id": "refutation_issaranimmana",
    "title": "11.3 Refutation of Issaranimmana View",
    "parentId": "three_wrong_views",
    "type": "study",
    "colorHex": "#B5838D",
    "notes": "Yeh view maanta hai ki ek 'Creator God' ne sab kuch banaya hai aur wahi sab chala raha hai. Ledi Sayadaw iska khandan (refute) karte hain.\n\nAgar God hi sab kuch kar raha hai, toh insaan ke paas choice kya hai? Agar humne paap kiya, toh wo God ki marzi hui. Phir humein dukh kyun sehna chahiye?\nAur agar God sab kuch de sakta hai, toh log mehnat (present kamma) kyun karte hain? Roti, kapda, makaan sab God de deta. Asal mein, insaan apne present kamma se hi sab kuch paata hai, God kisi ko kuch nahi deta.",
    "links": [
      { "title": "Refutation of Creator View", "url": "https://www.wisdomlib.org/buddhism/book/the-sammaditthi-dipani/d/doc3035.html" }
    ]
  },
  {
    "id": "refutation_ahetuka",
    "title": "11.4 Refutation of Ahetuka View",
    "parentId": "three_wrong_views",
    "type": "study",
    "colorHex": "#CB997E",
    "notes": "Ahetuka ka matlab hai 'Bina kisi karan ke' (Uncaused). Yeh view maanta hai ki duniya mein sab kuch random ho raha hai. Koi kamma nahi, koi karan nahi.\n\nBuddha kehte hain: Agar sab kuch random hota, toh achhe aur bure karmon ka koi farq nahi hota. Ek dhaarmik aur ek adharmik, dono ka anjaam ek jaisa hota. Lekin hum dekhte hain ki achhe karmon ka fal achha hota hai aur bure karmon ka bura. Isliye, duniya mein 'Cause and Effect' (Karan aur Fal) ka niyam (Law of Kamma) kaam karta hai.",
    "links": [
      { "title": "Refutation of Ahetuka View", "url": "https://www.wisdomlib.org/buddhism/book/the-sammaditthi-dipani/d/doc3036.html" }
    ]
  },
  {
    "id": "kammassakata_sammaditthi",
    "title": "11.5 Kammassakata Sammamditthi (Right View of Kamma)",
    "parentId": "sammaditthi_dipani",
    "type": "study",
    "colorHex": "#7B9EA8",
    "notes": "Yeh sabse zaroori Right View hai. Iska matlab hai: **'Sabhi jeev apne karmon ke maalik hain, karmon ke vaaris hain, kamma hi unki yoni hai, kamma hi unka sabse bada sahara hai.'**\n\nJo bhi achhe ya bure karm hum karte hain (body, speech, mind se), unka fal humein khud hi bhugatna padta hai. Koi dusra humari jagah dukh ya sukh nahi le sakta. Yeh samajh hi 'Samma Ditthi' ki shuruaat hai. Jab humein yeh samajh aata hai, tab hum achhe karmon ki taraf badhte hain aur bure karmon se dur rehte hain.",
    "links": [
      { "title": "Kammassakata Right View", "url": "https://www.wisdomlib.org/buddhism/book/the-sammaditthi-dipani/d/doc3037.html" }
    ]
  },
    {
    "id": "patthanuddesa_dipani",
    "title": "12. Patthanuddesa Dipani (Manual of Relations)",
    "parentId": "root_dhamma",
    "type": "study",
    "colorHex": "#E8D5B7",
    "notes": "Yeh Ledi Sayadaw ji ka sabse advanced manual hai. Yeh 'Patthana' (The Great Treatise) ka summary hai. Patthana Abhidhamma Pitaka ka 7th aur sabse gehra book hai. Isme Buddha ne bataya hai ki is duniya mein koi bhi cheez akele nahi hoti; sab kuch 'Conditions' (Paccaya) se jud kar hota hai. Total 24 conditions hain jo batati hain ki karan (cause) aur fal (effect) kaise kaam karte hain.",
    "links": [
      { "title": "VRI PDF (Full Text)", "url": "https://www.vridhamma.org/file/5469/download?token=CcwLLEuK" },
      { "title": "Wisdomlib: Patthanuddesa Dipani", "url": "https://www.wisdomlib.org/buddhism/book/the-patthanuddesa-dipani" }
    ]
  },
  {
    "id": "what_is_patthana",
    "title": "12.1 What is Patthana? (The Great Treatise)",
    "parentId": "patthanuddesa_dipani",
    "type": "study",
    "colorHex": "#A5A58D",
    "notes": "Patthana ka matlab hai 'Pre-eminent Cause' (Sabse bada karan). \n\nBuddha kehte hain ki koi bhi cheez bina kisi karan ke nahi hoti. Aur ek cheez ke hone mein ek nahi, bahut saare karan hote hain. Jaise ek ped ko ugne ke liye beej (seed), mitti (soil), paani, dhoop, aur hawa—sabka hona zaroori hai. \n\nPatthana ka pura study yeh samjhata hai ki ek 'Dhamma' (phenomenon) doosre 'Dhamma' ko kaise support karta hai. Yeh itna bada subject hai ki Buddha ne ise 24 ghante tak bina ruke samjhaya tha!",
    "links": [
      { "title": "What is Patthana?", "url": "https://www.wisdomlib.org/buddhism/book/the-patthanuddesa-dipani/d/doc2938.html" }
    ]
  },
  {
    "id": "24_paccayas",
    "title": "12.2 The 24 Paccayas (24 Conditions)",
    "parentId": "patthanuddesa_dipani",
    "type": "study",
    "colorHex": "#D4A373",
    "notes": "Patthana mein Buddha ne 24 tarike bataye hain jisse cheezein ek dusre se judi hain. Inhe 'Paccaya' kehte hain. In 24 conditions ko samajhna mushkil hai, isliye hum ise kuch groups mein baant sakte hain:\n\n1. **Hetu (Root)**: Jaise ped ki jad. (Greed, Hate, Delusion, aur unke opposites).\n2. **Arammana (Object)**: Dimag ka kisi cheez par focus karna.\n3. **Anantara (Proximity)**: Ek thought khatam hoke turant dusra thought shuru hona.\n4. **Sahajata (Co-existence)**: Do cheezo ka ek saath paida hona.\n5. **Kamma (Action)**: Karmon ka apna fal dena.\n6. **Ahara (Food)**: Shareer aur mann ko poshit karna.\n\n(In sabki detail links mein di gayi hai. Ek beginner ko sirf yeh samajhna hai ki 'Conditionality' hi duniya ka niyam hai).",
    "links": [
      { "title": "List of 24 Conditions", "url": "https://www.wisdomlib.org/buddhism/book/the-patthanuddesa-dipani/d/doc2941.html" },
      { "title": "Patthana Overview (PDF)", "url": "https://www.bps.lk/olib/wh/wh107_U_Narada_Conditional-Relations.pdf" }
    ]
  },
  {
    "id": "hetu_paccaya",
    "title": "12.3 Hetu-Paccaya (Relation by Root)",
    "parentId": "patthanuddesa_dipani",
    "type": "study",
    "colorHex": "#B5838D",
    "notes": "Jaise ek ped ko zameen mein jad (root) chahiye hoti hai, waise hi mann ke paas bhi 6 roots hote hain:\n\n1. **Lobha (Greed/Ichha)**: Jab ichha hoti hai, toh mann usi ke aas paas ghoomta hai.\n2. **Dosa (Hate/Nafrat)**: Jab nafrat hoti hai, toh mann usme fass jata hai.\n3. **Moha (Delusion/Bhram)**: Jab andhera hota hai, toh mann galat raste par jata hai.\n4. **Alobha (Renunciation)**: Ichha ko chhod dena.\n5. **Adosa (Amity/Daya)**: Nafrat ko chhod dena.\n6. **Amoha (Wisdom/Gyaan)**: Bhram ko chhod dena.\n\nJab hum koi kaam karte hain, toh inhi roots mein se koi ek root mann ko control karta hai.",
    "links": [
      { "title": "Hetu Paccaya (Root Condition)", "url": "https://www.wisdomlib.org/buddhism/book/the-patthanuddesa-dipani/d/doc2942.html" }
    ]
  },
  {
    "id": "arammana_paccaya",
    "title": "12.4 Arammana-Paccaya (Relation of Object)",
    "parentId": "patthanuddesa_dipani",
    "type": "study",
    "colorHex": "#CB997E",
    "notes": "Arammana ka matlab hai 'Object' ya 'Alambana' (Sahara). Hamara mann (Citta) bina kisi object ke nahi reh sakta. Jaise ek aadmi ko pakadne ke liye khamba chahiye, waise hi mann ko kisi na kisi cheez par tika rehna padta hai.\n\nHumein 6 types ke objects hote hain:\n1. **Rupa (Form)**: Jo aankh se dikhta hai.\n2. **Sadda (Sound)**: Jo kaan se sunai deta hai.\n3. **Gandha (Smell)**: Jo naak se sungha jata hai.\n4. **Rasa (Taste)**: Jo jeebh se chakha jata hai.\n5. **Phottabba (Touch)**: Jo shareer se mehsoos hota hai.\n6. **Dhamma (Thoughts)**: Jo dimag mein aate hain.\n\nJab tak mann in objects ko pakadta hai, tab tak woh duniya mein bandha hua hai.",
    "links": [
      { "title": "Arammana Paccaya (Object Condition)", "url": "https://www.wisdomlib.org/buddhism/book/the-patthanuddesa-dipani/d/doc2947.html" }
    ]
  },
  {
    "id": "kamma_paccaya",
    "title": "12.5 Kamma-Paccaya (Relation of Kamma)",
    "parentId": "patthanuddesa_dipani",
    "type": "study",
    "colorHex": "#7B9EA8",
    "notes": "Kamma ka matlab hai 'Chetna' (Volition/Will). Har action ke peeche ek intention hota hai. Patthana mein Kamma ko do tarah se dekha gaya hai:\n\n1. **Sahajata Kamma**: Jo kamma ek saath (same time) fal deta hai. Jaise jab hum koi cheez soch rahe hote hain, toh wahi soch hamare shareer aur mann ko usi waqt shape deti hai.\n2. **Nana-kkhanika Kamma**: Jo kamma baad mein (different time) fal deta hai. Jaise aaj humne daan diya, uska fal humein agle janam mein milega. \n\nYeh condition batati hai ki humare actions humare bhavishya ko kaise banate hain.",
    "links": [
      { "title": "Kamma Paccaya", "url": "https://www.wisdomlib.org/buddhism/book/the-patthanuddesa-dipani/d/doc2955.html" }
    ]
  },
  {
    "id": "sahajata_paccaya",
    "title": "12.6 Sahajata-Paccaya (Relation of Coexistence)",
    "parentId": "patthanuddesa_dipani",
    "type": "study",
    "colorHex": "#9C89B8",
    "notes": "Sahajata ka matlab hai 'Ek saath paida hona'. Jab koi cheez paida hoti hai, toh kuch cheezein uske saath hi paida hoti hain.\n\nExample: Jab sooraj ugta hai, toh uske saath roshni (light) aur garmi (heat) bhi ugti hai. Woh alag nahi ho sakte. \n\nWaise hi, jab mann (Citta) paida hota hai, toh uske saath uske mental factors (Cetasika) aur shareer ke elements (Rupa) ek saath paida hote hain. Woh ek dusre ke bina nahi reh sakte.",
    "links": [
      { "title": "Sahajata Paccaya", "url": "https://www.wisdomlib.org/buddhism/book/the-patthanuddesa-dipani/d/doc2950.html" }
    ]
  }
]
''';