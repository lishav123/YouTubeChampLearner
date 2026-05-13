import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../services/ollama_service.dart';
import '../../services/transcript_service.dart';
import '../../models/project.dart';
import '../../viewmodels/stats_viewmodel.dart';
import '../../components/stats/badge_earned_toast.dart';
import '../../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final Module module;
  final String videoUrl;

  const QuizScreen({
    super.key,
    required this.module,
    required this.videoUrl,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OllamaService _ollamaService = OllamaService();
  final TranscriptService _transcriptService = TranscriptService();

  ModuleContent? _content;
  bool _isLoading = true;
  String? _error;

  // Quiz state
  final Map<int, int> _selectedAnswers = {};
  bool _quizSubmitted = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transcriptService.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transcript = await _transcriptService.getTranscriptForModule(
        widget.videoUrl,
        widget.module,
      );
      final content = await _ollamaService.generateModuleContent(
        widget.module.title,
        transcript,
      );
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitQuiz() async {
    if (_content == null) return;
    int correct = 0;
    for (int i = 0; i < _content!.questions.length; i++) {
      if (_selectedAnswers[i] == _content!.questions[i].correctIndex) {
        correct++;
      }
    }
    setState(() {
      _correctCount = correct;
      _quizSubmitted = true;
    });

    // Award points
    final statsVm = context.read<StatsViewModel>();
    final newBadges = await statsVm.onQuizAnswered(correct);
    if (mounted) {
      for (final badge in newBadges) {
        BadgeEarnedToast.show(context, badge);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.module.title),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppTheme.sageGreen,
          tabs: const [
            Tab(icon: Icon(Icons.notes), text: 'Notes & Summary'),
            Tab(icon: Icon(Icons.quiz), text: 'Quiz'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotesTab(),
                    _buildQuizTab(),
                  ],
                ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Generating notes & quiz using gemma4...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a minute',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to generate content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadContent,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.navyBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.summarize, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _content!.summary,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Notes markdown
          const Row(
            children: [
              Icon(Icons.article_outlined, color: AppTheme.navyBlue),
              SizedBox(width: 8),
              Text(
                'Study Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MarkdownBody(
            data: _content!.notes,
            styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyBlue),
              h2: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyBlue),
              p: const TextStyle(fontSize: 15, height: 1.6),
              listBullet:
                  const TextStyle(fontSize: 15, color: AppTheme.forestGreen),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.quiz),
              label: const Text('Take the Quiz'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTab() {
    if (_content!.questions.isEmpty) {
      return const Center(
        child: Text('No quiz questions could be generated for this module.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_quizSubmitted) _buildScoreCard(),
          const SizedBox(height: 16),
          ...List.generate(_content!.questions.length, (i) {
            return _buildQuestionCard(i, _content!.questions[i]);
          }),
          const SizedBox(height: 24),
          if (!_quizSubmitted)
            Center(
              child: ElevatedButton.icon(
                onPressed: _selectedAnswers.length ==
                        _content!.questions.length
                    ? _submitQuiz
                    : null,
                icon: const Icon(Icons.check),
                label: Text(
                  'Submit (${_selectedAnswers.length}/${_content!.questions.length} answered)',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final total = _content!.questions.length;
    final percentage = (_correctCount / total * 100).round();
    final color = percentage >= 80
        ? AppTheme.forestGreen
        : percentage >= 50
            ? Colors.orange
            : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            percentage >= 80
                ? '🎉 Excellent!'
                : percentage >= 50
                    ? '👍 Good effort!'
                    : '📖 Keep studying!',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '$_correctCount / $total correct ($percentage%)',
            style: TextStyle(
                fontSize: 16, color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '+${_correctCount * 5} points earned',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, QuizQuestion question) {
    final isSubmitted = _quizSubmitted;
    final selected = _selectedAnswers[index];
    final correct = question.correctIndex;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.navyBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(question.options.length, (optIndex) {
              Color? tileColor;
              Icon? trailingIcon;

              if (isSubmitted) {
                if (optIndex == correct) {
                  tileColor = AppTheme.forestGreen.withOpacity(0.15);
                  trailingIcon = const Icon(Icons.check_circle,
                      color: AppTheme.forestGreen);
                } else if (optIndex == selected && selected != correct) {
                  tileColor = Colors.red.withOpacity(0.1);
                  trailingIcon =
                      const Icon(Icons.cancel, color: Colors.red);
                }
              } else if (selected == optIndex) {
                tileColor = AppTheme.navyBlue.withOpacity(0.1);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSubmitted && optIndex == correct
                        ? AppTheme.forestGreen
                        : selected == optIndex && !isSubmitted
                            ? AppTheme.navyBlue
                            : Colors.grey.withOpacity(0.3),
                    width: selected == optIndex || (isSubmitted && optIndex == correct) ? 2 : 1,
                  ),
                ),
                child: RadioListTile<int>(
                  value: optIndex,
                  groupValue: selected,
                  onChanged: isSubmitted
                      ? null
                      : (val) {
                          setState(() {
                            _selectedAnswers[index] = val!;
                          });
                        },
                  title: Text(question.options[optIndex]),
                  activeColor: AppTheme.navyBlue,
                ),
              );
            }),
            if (isSubmitted) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.explanation,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}