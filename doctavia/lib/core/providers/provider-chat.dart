import 'package:flutter/material.dart';
import '../services/service-chat.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service;
  
  ChatProvider({ChatService? chatService}) : _service = chatService ?? ChatService();
  
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> sendMessage(String text, {String? fileBase64, String? fileType}) async {
    if (text.trim().isEmpty && fileBase64 == null) return;

    // Add user message
    _messages.add(ChatMessage(
      role: 'user',
      content: text,
      fileBase64: fileBase64,
      fileType: fileType,
    ));
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch response
      final response = await _service.sendMessage(_messages);
      _messages.add(ChatMessage(role: 'assistant', content: response));
    } catch (e) {
      _errorMessage = e.toString();
      // Add an error message from assistant
      _messages.add(ChatMessage(
          role: 'assistant',
          content: 'Sorry, I encountered an error analyzing the request. Please try again.'));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
