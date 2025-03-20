import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shipping_model.dart';

class ShippingService {
  static const String baseUrl = 'https://lindo.free.beeceptor.com/api';

  Future<List<Courier>> getCouriers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/couriers'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> couriersJson = data['couriers'];
        return couriersJson.map((json) => Courier.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load couriers');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<ShippingQuote> calculateShippingRate({
    required String courierId,
    required ShippingAddress pickup,
    required ShippingAddress delivery,
    required double weight,
  }) async {
    try {
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

      if (response.statusCode == 200) {
        return ShippingQuote.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to calculate shipping rate');
      }
    } catch (e) {
      throw Exception('Error: $e');
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

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        throw Exception('Failed to book shipment');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
