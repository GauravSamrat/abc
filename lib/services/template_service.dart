import 'dart:convert';
import '../models/template_model.dart';
import '../models/node_model.dart';
import '../templates/dhamma_template.dart'; // 👈 Import

class TemplateService {
  static List<MapTemplate> getTemplates() {
    return [
      // ==========================================
      // 1. YOGA & PRANAYAMA
      // ==========================================
      MapTemplate(
        id: 'tpl_yoga',
        title: 'Yoga & Pranayama',
        description:
            'A complete guide to physical postures, breathing techniques, and meditation.',
        category: 'Health',
        colorHex: '#5E8C61', // Green
        nodes: [
          MindMapNode(
              id: 'yoga_root',
              title: 'Yoga & Wellness',
              parentId: null,
              type: 'note',
              colorHex: '#5E8C61',
              notes:
                  "# Welcome to your Practice\n\n> \"Yoga is the journey of the self, through the self, to the self.\"\n\nThis map is your guide to physical and mental well-being. Expand the branches to view specific poses."),
          MindMapNode(
              id: 'yoga_asanas',
              title: 'Asanas (Postures)',
              parentId: 'yoga_root',
              type: 'note',
              colorHex: '#A5A58D',
              notes:
                  "## Physical Postures\n\nAsanas are designed to bring balance and health to the physical body."),
          MindMapNode(
              id: 'yoga_tadasana',
              title: 'Tadasana (Mountain)',
              parentId: 'yoga_asanas',
              type: 'study',
              colorHex: '#A5A58D',
              notes:
                  "### How to Perform\n1. Stand straight with feet together.\n2. Engage thighs, lift kneecaps.\n3. Lengthen tailbone, lift chest.\n\n> **Benefits:** Improves posture, strengthens thighs and ankles."),
          MindMapNode(
              id: 'yoga_vrikshasana',
              title: 'Vrikshasana (Tree)',
              parentId: 'yoga_asanas',
              type: 'study',
              colorHex: '#A5A58D',
              notes:
                  "### How to Perform\n1. From Tadasana, shift weight to left foot.\n2. Bend right knee, place sole on inner left thigh.\n3. Bring hands together overhead.\n\n> **Benefits:** Improves balance and focus."),
          MindMapNode(
              id: 'yoga_bhujangasana',
              title: 'Bhujangasana (Cobra)',
              parentId: 'yoga_asanas',
              type: 'study',
              colorHex: '#A5A58D',
              notes:
                  "### How to Perform\n1. Lie face down, hands under shoulders.\n2. Inhale, lift chest off the floor.\n\n> **Benefits:** Strengthens the spine, stretches chest and lungs."),
          MindMapNode(
              id: 'yoga_pranayama',
              title: 'Pranayama',
              parentId: 'yoga_root',
              type: 'note',
              colorHex: '#7B9EA8',
              notes:
                  "## Breath Control\n\nPranayama is the practice of breath regulation. It bridges the body and the mind."),
          MindMapNode(
              id: 'yoga_anulom',
              title: 'Anulom Vilom',
              parentId: 'yoga_pranayama',
              type: 'routine',
              colorHex: '#7B9EA8',
              notes:
                  "### Alternate Nostril Breathing\n\n- Sit comfortably.\n- Close right nostril, inhale left.\n- Close left, exhale right.\n- Repeat for 5 minutes.\n\n*Do this daily in the morning.*"),
          MindMapNode(
              id: 'yoga_kapalbhati',
              title: 'Kapalbhati',
              parentId: 'yoga_pranayama',
              type: 'routine',
              colorHex: '#7B9EA8',
              notes:
                  "### Skull Shining Breath\n\n- Sit straight.\n- Exhale forcefully through both nostrils, pulling navel in.\n- Inhalation is passive.\n\n> **Caution:** Avoid during pregnancy or high blood pressure."),
          MindMapNode(
              id: 'yoga_meditation',
              title: 'Meditation',
              parentId: 'yoga_root',
              type: 'note',
              colorHex: '#9C89B8',
              notes:
                  "## Stillness of Mind\n\nThe final goal of yoga is meditation."),
          MindMapNode(
              id: 'yoga_body_scan',
              title: 'Body Scan',
              parentId: 'yoga_meditation',
              type: 'study',
              colorHex: '#9C89B8',
              notes:
                  "### Practice\n\n1. Lie down in Savasana.\n2. Bring awareness to your toes.\n3. Slowly move awareness up through the body.\n4. Notice sensations without judgment."),
        ],
      ),

      // ==========================================
      // 2. FINANCIAL FREEDOM
      // ==========================================
      MapTemplate(
        id: 'tpl_finance',
        title: 'Financial Freedom 2025',
        description:
            'Master your money, create budgets, and build wealth with this blueprint.',
        category: 'Finance',
        colorHex: '#D18B47', // Orange/Gold
        nodes: [
          MindMapNode(
              id: 'fin_root',
              title: 'Wealth OS',
              parentId: null,
              type: 'note',
              colorHex: '#D18B47',
              notes:
                  "# Build Your Wealth\n\n> \"An investment in knowledge pays the best interest.\"\n\nUse this map to track your income, control expenses, and plan investments."),
          MindMapNode(
              id: 'fin_income',
              title: 'Income Streams',
              parentId: 'fin_root',
              type: 'note',
              colorHex: '#D4A373',
              notes:
                  "## Where does money come from?\n\n- Active Income (Salary, Freelance)\n- Passive Income (Dividends, Rent)"),
          MindMapNode(
              id: 'fin_active',
              title: 'Active Income',
              parentId: 'fin_income',
              type: 'task',
              colorHex: '#D4A373',
              notes:
                  "### Primary Job\n\n- [ ] Negotiate a raise\n- [ ] Upskill to increase hourly rate"),
          MindMapNode(
              id: 'fin_passive',
              title: 'Passive Income',
              parentId: 'fin_income',
              type: 'idea',
              colorHex: '#D4A373',
              notes:
                  "### Ideas for Passive Income\n\n- Digital Products\n- Dividend Stocks\n- Rental Property"),
          MindMapNode(
              id: 'fin_budget',
              title: 'Monthly Budget',
              parentId: 'fin_root',
              type: 'project',
              colorHex: '#E8D5B7',
              notes:
                  "## The 50/30/20 Rule\n\n- **50% Needs:** Rent, Groceries, Utilities\n- **30% Wants:** Dining out, Travel, Shopping\n- **20% Savings & Investments**\n\n*Review this budget every 1st of the month.*"),
          MindMapNode(
              id: 'fin_tracking',
              title: 'Track Expenses',
              parentId: 'fin_budget',
              type: 'routine',
              colorHex: '#E8D5B7',
              notes:
                  "### Daily Habit\n\nTake 5 minutes every night to log your expenses in a spreadsheet or app."),
          MindMapNode(
              id: 'fin_invest',
              title: 'Investments',
              parentId: 'fin_root',
              type: 'note',
              colorHex: '#A5A58D',
              notes:
                  "## Growing your money\n\nDon't just save, invest to beat inflation."),
          MindMapNode(
              id: 'fin_index',
              title: 'Index Funds',
              parentId: 'fin_invest',
              type: 'study',
              colorHex: '#A5A58D',
              notes:
                  "### Why Index Funds?\n\n- Low fees\n- Automatic diversification\n- Beat most active fund managers over time\n\n*Strategy:* SIP (Systematic Investment Plan) monthly."),
          MindMapNode(
              id: 'fin_debt',
              title: 'Debt Management',
              parentId: 'fin_root',
              type: 'note',
              colorHex: '#B5838D',
              notes:
                  "## Getting out of debt\n\nPrioritize high-interest debt first (Credit Cards)."),
          MindMapNode(
              id: 'fin_emergency',
              title: 'Emergency Fund',
              parentId: 'fin_debt',
              type: 'task',
              colorHex: '#B5838D',
              notes:
                  "### Safety Net\n\nSave 3 to 6 months of living expenses in a high-yield savings account before investing."),
          MindMapNode(
              id: 'fin_networth',
              title: 'Net Worth',
              parentId: 'fin_root',
              type: 'study',
              colorHex: '#CB997E',
              notes:
                  "## Know Your Numbers\n\n**Formula:** Total Assets - Total Liabilities = Net Worth.\n\nCalculate this at the end of every quarter."),
        ],
      ),

      // ==========================================
      // 3. STARTUP BLUEPRINT
      // ==========================================
      MapTemplate(
        id: 'tpl_startup',
        title: 'Startup Blueprint',
        description: 'From idea validation to MVP launch and marketing.',
        category: 'Business',
        colorHex: '#7B9EA8', // Blue
        nodes: [
          MindMapNode(
              id: 'startup_root',
              title: 'Startup Blueprint',
              parentId: null,
              type: 'note',
              colorHex: '#7B9EA8',
              notes:
                  "# From Idea to Launch\n\n> \"The best way to predict the future is to create it.\"\n\nValidate before you build. Build before you scale."),
          MindMapNode(
              id: 'startup_idea',
              title: 'Idea Validation',
              parentId: 'startup_root',
              type: 'note',
              colorHex: '#9C89B8',
              notes:
                  "## Is there a real problem?\n\n- What is the specific pain point?\n- How are people solving it now?"),
          MindMapNode(
              id: 'startup_problem',
              title: 'The Problem',
              parentId: 'startup_idea',
              type: 'study',
              colorHex: '#9C89B8',
              notes:
                  "### Write a problem statement\n\n[Target Audience] has a problem with [Pain Point] because [Reason]."),
          MindMapNode(
              id: 'startup_interviews',
              title: 'Customer Interviews',
              parentId: 'startup_idea',
              type: 'task',
              colorHex: '#9C89B8',
              notes:
                  "### Action Item\n\nTalk to 10 potential customers. Do not pitch them your solution, just ask about their problems."),
          MindMapNode(
              id: 'startup_mvp',
              title: 'Build MVP',
              parentId: 'startup_root',
              type: 'project',
              colorHex: '#D18B47',
              notes:
                  "## Minimum Viable Product\n\nBuild the smallest version of your product that solves the core problem."),
          MindMapNode(
              id: 'startup_core',
              title: 'Core Feature',
              parentId: 'startup_mvp',
              type: 'task',
              colorHex: '#D18B47',
              notes:
                  "### What is the ONE thing your product must do?\n\n- [ ] Design UI\n- [ ] Code Backend\n- [ ] Test with 5 users"),
          MindMapNode(
              id: 'startup_marketing',
              title: 'Go-to-Market',
              parentId: 'startup_root',
              type: 'note',
              colorHex: '#5E8C61',
              notes:
                  "## Marketing & Sales\n\nHow will people find out about you?"),
          MindMapNode(
              id: 'startup_content',
              title: 'Content Marketing',
              parentId: 'startup_marketing',
              type: 'routine',
              colorHex: '#5E8C61',
              notes:
                  "### Strategy\n\nPost 1 valuable tip/article per day on Twitter/LinkedIn related to your niche."),
          MindMapNode(
              id: 'startup_seo',
              title: 'SEO Basics',
              parentId: 'startup_marketing',
              type: 'study',
              colorHex: '#5E8C61',
              notes:
                  "### Keywords\n\nIdentify 5 low-competition keywords your customers are searching for and write blog posts around them."),
          MindMapNode(
              id: 'startup_finance',
              title: 'Financials',
              parentId: 'startup_root',
              type: 'note',
              colorHex: '#E8D5B7',
              notes:
                  "## Money Matters\n\nKeep burn rate low. Revenue is vanity, profit is sanity."),
          MindMapNode(
              id: 'startup_revenue',
              title: 'Revenue Model',
              parentId: 'startup_finance',
              type: 'study',
              colorHex: '#E8D5B7',
              notes:
                  "### How will you make money?\n\n- Subscription (SaaS)\n- One-time purchase\n- Freemium\n- Ads"),
          MindMapNode(
              id: 'startup_runway',
              title: 'Calculate Runway',
              parentId: 'startup_finance',
              type: 'study',
              colorHex: '#E8D5B7',
              notes:
                  "### Formula\n\nCash in Bank / Monthly Expenses = Months of runway.\n\n*Goal:* Keep runway above 6 months."),
        ],
      ),

      // ==========================================
      // 4. STUDY PLANNER
      // ==========================================
      MapTemplate(
        id: 'tpl_study',
        title: 'Study Planner & Memory',
        description:
            'Plan your syllabus, use active recall, and track your study progress.',
        category: 'Education',
        colorHex: '#9C89B8', // Purple
        nodes: [
          MindMapNode(
              id: 'study_root',
              title: 'Study OS 2025',
              parentId: null,
              type: 'note',
              colorHex: '#9C89B8',
              notes:
                  "# Master Any Subject\n\n> \"Memory is the treasury and guardian of all things.\"\n\nUse this map to organize subjects and track your learning with spaced repetition."),
          MindMapNode(
              id: 'study_syllabus',
              title: 'Syllabus Breakdown',
              parentId: 'study_root',
              type: 'note',
              colorHex: '#7B9EA8',
              notes:
                  "## What needs to be learned?\n\nBreak down big subjects into manageable chapters."),
          MindMapNode(
              id: 'study_math',
              title: 'Mathematics',
              parentId: 'study_syllabus',
              type: 'project',
              colorHex: '#7B9EA8',
              notes:
                  "### Chapters to cover\n- Algebra\n- Calculus\n- Statistics"),
          MindMapNode(
              id: 'study_science',
              title: 'Science',
              parentId: 'study_syllabus',
              type: 'project',
              colorHex: '#7B9EA8',
              notes:
                  "### Chapters to cover\n- Physics\n- Chemistry\n- Biology"),
          MindMapNode(
              id: 'study_techniques',
              title: 'Study Techniques',
              parentId: 'study_root',
              type: 'note',
              colorHex: '#B5838D',
              notes:
                  "## Work Smarter, Not Harder\n\nStop highlighting. Start testing yourself."),
          MindMapNode(
              id: 'study_pomodoro',
              title: 'Pomodoro Method',
              parentId: 'study_techniques',
              type: 'routine',
              colorHex: '#B5838D',
              notes:
                  "### Focus Cycles\n\n- Study for 25 minutes.\n- Take a 5-minute break.\n- Every 4 cycles, take a 30-minute break.\n\n*Use a timer!*"),
          MindMapNode(
              id: 'study_active_recall',
              title: 'Active Recall',
              parentId: 'study_techniques',
              type: 'study',
              colorHex: '#B5838D',
              notes:
                  "### The Best Way to Learn\n\nClose the book and write down everything you remember. Then check the book to see what you missed."),
          MindMapNode(
              id: 'study_feynman',
              title: 'Feynman Technique',
              parentId: 'study_techniques',
              type: 'study',
              colorHex: '#B5838D',
              notes:
                  "### Teach it to learn it\n\n1. Choose a concept.\n2. Explain it in simple language (like to a 5-year-old).\n3. Identify gaps in your explanation.\n4. Review and simplify."),
          MindMapNode(
              id: 'study_routine',
              title: 'Daily Routine',
              parentId: 'study_root',
              type: 'note',
              colorHex: '#D18B47',
              notes:
                  "## Consistency is Key\n\nStudy at the same time every day."),
          MindMapNode(
              id: 'study_morning',
              title: 'Morning Review',
              parentId: 'study_routine',
              type: 'routine',
              colorHex: '#D18B47',
              notes:
                  "### 15 Minutes\n\nReview your flashcards or notes from yesterday. This moves info to long-term memory."),
          MindMapNode(
              id: 'study_night',
              title: 'Night Prep',
              parentId: 'study_routine',
              type: 'routine',
              colorHex: '#D18B47',
              notes:
                  "### 10 Minutes\n\nPrepare your desk and materials for the next day. Plan what you will study."),
        ],
      ),
    ];
  }

  static MapTemplate getDhammaTemplate() {
    String fixedJson = rawDhammaJson.trim();
    if (fixedJson.contains(']\n[')) {
      fixedJson = fixedJson.replaceAll(']\n[', ',');
    }

    final List<dynamic> decoded = jsonDecode(fixedJson);
    final List<MindMapNode> nodes = [];

    for (var item in decoded) {
      final map = item as Map<String, dynamic>;

      // 👈 YAHAN FIX HAI: Naye JSON ke hisaab se notes aur links uthayein
      String noteText = map['notes'] ?? '';

      List<Map<String, String>> linksList = [];
      if (map['links'] != null) {
        for (var link in map['links']) {
          linksList.add(Map<String, String>.from(link));
        }
      }

      nodes.add(MindMapNode(
        id: map['id'],
        title: map['title'],
        parentId: map['parentId'],
        colorHex: map['colorHex'] ?? '#CB997E',
        type: map['type'] ?? 'study',
        notes: noteText.trim(),
        links: linksList, // 👈 Links add kiye
      ));
    }

    return MapTemplate(
      id: 'tpl_dhamma_manuals',
      title: 'Manuals of Dhamma',
      description:
          'Deep study of the Four Noble Truths, Dependent Origination, and Abhidhamma.',
      category: 'Spirituality',
      colorHex: '#CB997E',
      nodes: nodes,
    );
  }
}
