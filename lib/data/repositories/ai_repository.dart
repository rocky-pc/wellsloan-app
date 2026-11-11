import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

class AiRepository {
  final ApiClient _client;

  AiRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<Map<String, dynamic>> askAdvisor({
    required String prompt,
    List<Map<String, String>> conversationHistory = const [],
    Map<String, dynamic> userContext = const {},
  }) async {
    final response = await _client.post(
      ApiEndpoints.aiAdvisor,
      data: {
        'prompt': prompt,
        'conversationHistory': conversationHistory,
        'userContext': userContext,
      },
    );

    return {
      'reply': response.data['reply'] ?? 'Unable to process advice at this time.',
      'model': response.data['model'] ?? 'gemini-flash',
      'isSimulated': response.data['isSimulated'] ?? false,
    };
  }
}
