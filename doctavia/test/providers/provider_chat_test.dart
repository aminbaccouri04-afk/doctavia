import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doctavia/core/providers/provider-chat.dart';
import 'package:doctavia/core/services/service-chat.dart';

// Create a mock class for ChatService
class MockChatService extends Mock implements ChatService {}

void main() {
  late ChatProvider chatProvider;
  late MockChatService mockChatService;

  setUp(() {
    mockChatService = MockChatService();
    // Inject the mock service into the provider
    chatProvider = ChatProvider(chatService: mockChatService);
  });

  group('ChatProvider Tests', () {
    test('Initial state should be empty and not loading', () {
      expect(chatProvider.messages, isEmpty);
      expect(chatProvider.isLoading, isFalse);
      expect(chatProvider.errorMessage, isNull);
    });

    test('sendMessage should handle text messages correctly', () async {
      // Arrange
      const userText = 'Hello Doctavia';
      const aiResponse = 'Hello! How can I help you today?';
      when(() => mockChatService.sendMessage(any())).thenAnswer((_) async => aiResponse);

      // Act
      await chatProvider.sendMessage(userText);
      
      // Assert
      expect(chatProvider.isLoading, isFalse);
      expect(chatProvider.messages.length, 2);
      expect(chatProvider.messages.first.content, userText);
      expect(chatProvider.messages.last.content, aiResponse);
    });

    test('sendMessage should handle document attachments correctly', () async {
      // Arrange
      const userText = 'Analyze this PDF';
      const fileBase64 = 'JVBERi0xLjQK...';
      const fileType = 'application/pdf';
      const aiResponse = 'I have analyzed the PDF.';
      
      when(() => mockChatService.sendMessage(any())).thenAnswer((_) async => aiResponse);

      // Act
      await chatProvider.sendMessage(userText, fileBase64: fileBase64, fileType: fileType);
      
      // Assert
      final sentMsg = chatProvider.messages.first;
      expect(sentMsg.fileBase64, fileBase64);
      expect(sentMsg.fileType, fileType);
      expect(chatProvider.messages.last.content, aiResponse);
    });

    test('sendMessage should handle errors gracefully', () async {
      // Arrange
      const userText = 'Trigger Error';
      when(() => mockChatService.sendMessage(any())).thenThrow(Exception('API Failure'));

      // Act
      await chatProvider.sendMessage(userText);

      // Assert
      expect(chatProvider.isLoading, isFalse);
      expect(chatProvider.messages.last.content, contains('error'));
    });

    test('clearChat should empty messages and clear errors', () async {
      // Arrange
      when(() => mockChatService.sendMessage(any())).thenAnswer((_) async => 'Response');
      await chatProvider.sendMessage('Test');
      expect(chatProvider.messages, isNotEmpty);

      // Act
      chatProvider.clearChat();

      // Assert
      expect(chatProvider.messages, isEmpty);
      expect(chatProvider.errorMessage, isNull);
    });
  });
}
