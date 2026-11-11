import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final ApiClient _client;

  PaymentRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<PaymentModel>> getPayments() async {
    final response = await _client.get(ApiEndpoints.payments);
    final list = response.data['payments'] as List? ?? [];
    return list.map((item) => PaymentModel.fromJson(item)).toList();
  }

  Future<PaymentModel> payPayment(String paymentId, {String method = "UPI"}) async {
    final response = await _client.post(
      ApiEndpoints.payPayment(paymentId),
      data: {'method': method},
    );
    return PaymentModel.fromJson(response.data['payment']);
  }
}
