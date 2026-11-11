import 'package:flutter/material.dart';
import '../data/repositories/ai_repository.dart';

class AiAdvisorMessage {
  final String sender; // 'user' or 'advisor'
  final String text;
  final DateTime timestamp;
  final bool isSimulated;

  AiAdvisorMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isSimulated = false,
  });

  bool get isUser => sender == 'user';
}

class AiAdvisorProvider with ChangeNotifier {
  final AiRepository _repo = AiRepository();

  final List<AiAdvisorMessage> _messages = [
    AiAdvisorMessage(
      sender: 'advisor',
      text: "👋 Hello! I am your Wellsloan AI Financial Copilot.\n\n"
          "I can help you analyze loan affordability, compare repayment tenures, calculate exact EMIs, and share tips to save interest.\n\n"
          "How can I assist your financial journey today?",
      timestamp: DateTime.now(),
    ),
  ];

  bool _isLoading = false;
  String? _errorMessage;

  List<AiAdvisorMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const List<String> quickPrompts = [
    "How to reduce my overall loan interest?",
    "Compare 12 vs 24 vs 36 month tenures",
    "Can I afford a ₹2 Lakhs loan on my income?",
    "Does part-prepayment have any penalty?",
  ];

  Future<void> sendMessage(String text, {Map<String, dynamic> userContext = const {}}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    _messages.add(
      AiAdvisorMessage(
        sender: 'user',
        text: cleanText,
        timestamp: DateTime.now(),
      ),
    );
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final history = _messages
          .map((m) => {'sender': m.sender, 'text': m.text})
          .toList();

      final res = await _repo.askAdvisor(
        prompt: cleanText,
        conversationHistory: history,
        userContext: userContext,
      );

      _messages.add(
        AiAdvisorMessage(
          sender: 'advisor',
          text: res['reply'] ?? 'Thank you for your message.',
          timestamp: DateTime.now(),
          isSimulated: res['isSimulated'] ?? false,
        ),
      );
    } catch (e) {
      _messages.add(
        AiAdvisorMessage(
          sender: 'advisor',
          text: "I'm having trouble connecting to the cloud advisor right now. "
              "Remember: Wellsloan offers 0% prepayment charges, and paying even ₹5,000 extra directly towards principal saves you interest!",
          timestamp: DateTime.now(),
          isSimulated: true,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _messages.add(
      AiAdvisorMessage(
        sender: 'advisor',
        text: "👋 Chat reset. What financial question can I help you explore?",
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
