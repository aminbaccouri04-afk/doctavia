import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String role;
  final String content;
  final String? fileBase64;
  final String? fileType; // e.g. 'image/jpeg' or 'application/pdf'

  ChatMessage({
    required this.role,
    required this.content,
    this.fileBase64,
    this.fileType,
  });

  dynamic toJson() {
    if (fileBase64 != null && fileType != null) {
      final type = fileType!.startsWith('image/') ? 'image_url' : 'file_url';
      final urlKey = fileType!.startsWith('image/') ? 'image_url' : 'file_url';

      return {
        'role': role,
        'content': [
          {'type': 'text', 'text': content},
          {
            'type': type,
            urlKey: {'url': 'data:$fileType;base64,$fileBase64'},
          },
        ],
      };
    }
    return {'role': role, 'content': content};
  }
}

class ChatService {
  final String _apiKey = const String.fromEnvironment('OPENROUTER_API_KEY');
  final String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  // Use the latest multimodal model
  final String _model = 'google/gemini-2.5-flash-lite-preview-09-2025';

  ChatService();

  Future<String> sendMessage(List<ChatMessage> history) async {
    try {
      final body = jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content':
                '''You are Doctavia AI, an elite, highly professional medical assistant.
Your directives:
1. Provide highly specific, medically accurate, and scientifically backed information.
2. Maintain a clinical, empathetic, and professional tone at all times.
3. ALWAYS format your responses using clear Markdown (headers, bullet points, bold text).
4. Analyze any provided documents (PDFs, images, etc.) natively using your multimodal capabilities. 
5. State that your analysis is preliminary and not a diagnosis.
6. ALWAYS conclude with a disclaimer advising the user to consult a licensed healthcare professional.''',
          },
          ...history.map((m) => m.toJson()),
        ],
      });

      debugPrint('--- AI CHAT REQUEST (NATIVE MULTIMODAL) ---');
      debugPrint('Model: $_model');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://doctavia.com',
          'X-Title': 'Doctavia Health',
        },
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'];
        }
        throw Exception('AI returned an empty response.');
      } else {
        final errorMsg = data['error']?['message'] ?? response.body;
        throw Exception('AI Server Error: $errorMsg');
      }
    } catch (e) {
      debugPrint('--- AI CHAT ERROR ---');
      debugPrint(e.toString());
      rethrow;
    }
  }
}
