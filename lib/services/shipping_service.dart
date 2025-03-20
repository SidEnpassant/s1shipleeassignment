import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'models/shipping_model.dart';

class ShippingService {
  static const String baseUrl = 'https://lindo.free.beeceptor.com/api';

  Future<List<Courier>> getCouriers() async {
    try {
      log('Fetching couriers from $baseUrl/couriers');
      final response = await http.get(Uri.parse('$baseUrl/couriers'));
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (!data.containsKey('couriers')) {
          throw Exception('API response missing "couriers" key');
        }

        final List<dynamic> couriersJson = data['couriers'];
        return couriersJson.map((json) => Courier.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load couriers: HTTP ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      log('Error fetching couriers: $e\n$stackTrace');
      throw Exception('Failed to load couriers: $e');
    }
  }

  Future<ShippingQuote> calculateShippingRate({
    required String courierId,
    required ShippingAddress pickup,
    required ShippingAddress delivery,
    required double weight,
  }) async {
    try {
      log('Calculating shipping rate for courier: $courierId');
      final response = await http.post(
        Uri.parse('$baseUrl/calculate-rate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'courierId': courierId,
          'pickup': pickup.toJson(),
          'delivery': delivery.toJson(),
          'weight': weight,
        }),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return ShippingQuote.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to calculate rate: HTTP ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      log('Error calculating rate: $e\n$stackTrace');
      throw Exception('Failed to calculate shipping rate: $e');
    }
  }

  Future<bool> bookShipment({
    required String courierId,
    required ShippingAddress pickup,
    required ShippingAddress delivery,
    required double weight,
    required double price,
  }) async {
    try {
      log('Booking shipment for courier: $courierId');
      final response = await http.post(
        Uri.parse('$baseUrl/book-shipment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'courierId': courierId,
          'pickup': pickup.toJson(),
          'delivery': delivery.toJson(),
          'weight': weight,
          'price': price,
        }),
      );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        throw Exception('Failed to book shipment: HTTP ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      log('Error booking shipment: $e\n$stackTrace');
      throw Exception('Failed to book shipment: $e');
    }
  }
}
