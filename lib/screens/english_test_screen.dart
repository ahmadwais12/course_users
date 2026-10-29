import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// English Test Levels Screen
class EnglishTestScreen extends StatelessWidget {
  const EnglishTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Your English'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Choose Your Level',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select a level to start your English proficiency test',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            _LevelCard(
              level: 'Basic',
              description:
                  'A1-A2 Level: 20 questions covering basic vocabulary, grammar, and comprehension',
              icon: Icons.star,
              color: Colors.black87,
              onTap: () => _startTest(context, 'Basic'),
            ),
            const SizedBox(height: 16),
            _LevelCard(
              level: 'Intermediate',
              description:
                  'B1-B2 Level: 25 questions testing intermediate grammar, reading, and writing skills',
              icon: Icons.star_half,
              color: Colors.black87,
              onTap: () => _startTest(context, 'Intermediate'),
            ),
            const SizedBox(height: 16),
            _LevelCard(
              level: 'Advanced',
              description:
                  'C1-C2 Level: 30 questions on advanced grammar, vocabulary, and critical thinking',
              icon: Icons.workspace_premium,
              color: Colors.purple,
              onTap: () => _startTest(context, 'Advanced'),
            ),
          ],
        ),
      ),
    );
  }

  void _startTest(BuildContext context, String level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestQuestionScreen(level: level),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String level;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

// Test Question Screen
class TestQuestionScreen extends StatefulWidget {
  final String level;

  const TestQuestionScreen({super.key, required this.level});

  @override
  State<TestQuestionScreen> createState() => _TestQuestionScreenState();
}

class _TestQuestionScreenState extends State<TestQuestionScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _isLoading = true;

  Map<String, List<Map<String, dynamic>>> _questions = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    // No english_test_questions table exists in the schema, so each
    // level ships with a built-in question bank.
    const banks = {
      'Basic': [
        {
          'question': 'Choose the correct word: “She ___ to school every day.”',
          'options': ['go', 'goes', 'going', 'gone'],
          'correct': 1,
        },
        {
          'question': 'What is the plural of “child”?',
          'options': ['childs', 'children', 'childes', 'child'],
          'correct': 1,
        },
        {
          'question': 'Choose the correct sentence:',
          'options': [
            'He don\'t like tea.',
            'He doesn\'t like tea.',
            'He not like tea.',
            'He doesn\'t likes tea.',
          ],
          'correct': 1,
        },
        {
          'question': 'The opposite of “hot” is:',
          'options': ['warm', 'cool', 'cold', 'humid'],
          'correct': 2,
        },
        {
          'question': 'Fill in the blank: “I ___ a student.”',
          'options': ['am', 'is', 'are', 'be'],
          'correct': 0,
        },
      ],
      'Intermediate': [
        {
          'question': 'Which sentence is grammatically correct?',
          'options': [
            'I have seen him yesterday.',
            'I saw him yesterday.',
            'I seen him yesterday.',
            'I did saw him yesterday.',
          ],
          'correct': 1,
        },
        {
          'question': 'Choose the correct word: “He is interested ___ science.”',
          'options': ['at', 'on', 'in', 'for'],
          'correct': 2,
        },
        {
          'question': '“If I ___ rich, I would travel the world.”',
          'options': ['am', 'was', 'were', 'be'],
          'correct': 2,
        },
        {
          'question': 'Which word means the same as “quickly”?',
          'options': ['slowly', 'rapidly', 'quietly', 'rarely'],
          'correct': 1,
        },
        {
          'question': 'Choose the correct passive form: “The letter ___ yesterday.”',
          'options': [
            'was sent',
            'is sent',
            'has sent',
            'were sent',
          ],
          'correct': 0,
        },
      ],
      'Advanced': [
        {
          'question': 'Which sentence uses “however” correctly?',
          'options': [
            'However, he was tired, he kept working.',
            'He was tired; however, he kept working.',
            'He was tired however kept working.',
            'He was tired, however kept working.',
          ],
          'correct': 1,
        },
        {
          'question': 'Choose the word closest in meaning to “ubiquitous”:',
          'options': ['rare', 'everywhere', 'unique', 'hidden'],
          'correct': 1,
        },
        {
          'question': '“Had I known, I ___ differently.”',
          'options': ['would act', 'would have acted', 'will act', 'acted'],
          'correct': 1,
        },
        {
          'question': 'Which sentence is punctuated correctly?',
          'options': [
            'She asked “where are you going?”',
            'She asked, “Where are you going?”',
            'She asked “Where are you going”?',
            'She asked where are you going?',
          ],
          'correct': 1,
        },
        {
          'question': 'The phrase “to bite the bullet” means:',
          'options': [
            'to act quickly',
            'to endure a difficult situation',
            'to be aggressive',
            'to eat quickly',
          ],
          'correct': 1,
        },
      ],
    };
    _questions = Map<String, List<Map<String, dynamic>>>.from(banks.map(
        (k, v) => MapEntry(
            k, List<Map<String, dynamic>>.from(v))));
    if (mounted) setState(() => _isLoading = false);
  }

  void _selectAnswer(int selected, int correct) {
    if (_selectedAnswer != null) return;
    setState(() {
      _selectedAnswer = selected;
      if (selected == correct) _score++;
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestion++;
      _selectedAnswer = null;
    });
  }

  void _showResults() {
    final questions = _questions[widget.level]!;
    final percentage = (_score / questions.length * 100).round();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You scored $_score out of ${questions.length}'),
            const SizedBox(height: 8),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: percentage >= 70 ? Colors.black87 : Colors.orange,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    ).then((_) => _saveTestResult());
  }

  Future<void> _saveTestResult() async {
    try {
      final questions = _questions[widget.level]!;
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (questions.isEmpty) return;
      // Persist the placement score on the student's real record.
      final studentRows = await supabase
          .from('students')
          .select('id')
          .eq('profile_id', userId ?? '')
          .limit(1);
      if (studentRows.isNotEmpty) {
        final percentage = (_score / questions.length * 100).round();
        await supabase.from('students').update({
          'placement_test_score': percentage,
          'placement_test_date': DateTime.now().toIso8601String(),
        }).eq('id', studentRows.first['id']);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.level} Test'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final questions = _questions[widget.level]!;
    final question = questions[_currentQuestion];
    final correctIndex = question['correct'] as int;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.level} Test'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / questions.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${_currentQuestion + 1} of ${questions.length}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            // Question
            Text(
              question['question'],
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            // Options
            ...List.generate(
              question['options'].length,
              (index) {
                final isSelected = _selectedAnswer == index;
                final isCorrect = index == correctIndex;
                final showResult = _selectedAnswer != null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: showResult
                        ? null
                        : () => _selectAnswer(index, correctIndex),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: !showResult
                            ? theme.colorScheme.surface
                            : isCorrect
                                ? Colors.black.withValues(alpha: 0.1)
                                : isSelected
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !showResult
                              ? theme.dividerColor
                              : isCorrect
                                  ? Colors.black87
                                  : isSelected
                                      ? Colors.red
                                      : theme.dividerColor,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.black87
                                  : isSelected
                                      ? Colors.red
                                      : theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  color: isCorrect || isSelected
                                      ? Colors.white
                                      : theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question['options'][index],
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            if (_selectedAnswer != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _currentQuestion < questions.length - 1
                      ? _nextQuestion
                      : _showResults,
                  child: Text(
                    _currentQuestion < questions.length - 1
                        ? 'Next Question'
                        : 'See Results',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
