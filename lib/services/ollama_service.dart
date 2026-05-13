import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}

class ModuleContent {
  final String summary;
  final String notes;
  final List<QuizQuestion> questions;

  ModuleContent({
    required this.summary,
    required this.notes,
    required this.questions,
  });
}

class OllamaService {
  static const String _baseUrl = 'http://localhost:11434';
  static const String _model = 'gemma4:latest';

  Future<String> _generate(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': _model,
        'prompt': prompt,
        'stream': false,
      }),
    ).timeout(const Duration(minutes: 3));

    if (response.statusCode != 200) {
      throw Exception('Ollama error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return data['response'] as String;
  }

  Future<ModuleContent> generateModuleContent(
      String moduleTitle, String transcript) async {
    // Truncate transcript to avoid huge prompts
    final trimmed = transcript.length > 4000
        ? transcript.substring(0, 4000)
        : transcript;

    // Step 1: Generate summary + notes
    final notesPrompt = '''
You are a learning assistant. Based on this transcript from a module titled "$moduleTitle", generate:
1. A concise summary (2-3 sentences)
2. Detailed study notes in markdown format with headers, bullet points, and key concepts

Transcript:
$trimmed

Respond in this exact JSON format (no markdown code blocks, just raw JSON):
{
  "summary": "2-3 sentence summary here",
  "notes": "# Module Notes\\n\\n## Key Concepts\\n- point 1\\n- point 2\\n\\n## Details\\n..."
}
''';

    final notesRaw = await _generate(notesPrompt);
    String summary = '';
    String notes = '';

    try {
      final cleaned = notesRaw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final parsed = jsonDecode(cleaned);
      summary = parsed['summary'] ?? '';
      notes = parsed['notes'] ?? '';
    } catch (e) {
      summary = 'Summary unavailable.';
      notes = '# $moduleTitle\n\n$notesRaw';
    }

    // Step 2: Generate MCQ questions
    final quizPrompt = '''
Based on this transcript from "$moduleTitle", generate 5 multiple choice questions to test understanding.

Transcript:
$trimmed

Respond in this exact JSON format (no markdown code blocks, raw JSON only):
{
  "questions": [
    {
      "question": "Question text here?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctIndex": 0,
      "explanation": "Brief explanation of why this is correct"
    }
  ]
}
''';

    final quizRaw = await _generate(quizPrompt);
    List<QuizQuestion> questions = [];

    try {
      final cleaned = quizRaw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final parsed = jsonDecode(cleaned);
      questions = (parsed['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList();
    } catch (e) {
      questions = [];
    }

    return ModuleContent(
      summary: summary,
      notes: notes,
      questions: questions,
    );
  }
}