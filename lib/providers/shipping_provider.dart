import 'package:flutter/material.dart';
import '../services/models/shipping_model.dart';
import '../services/shipping_service.dart';

class ShippingProvider extends ChangeNotifier {
  final ShippingService _shippingService = ShippingService();


  String? pickupName;
  String? pickupAddress;
  String? pickupCity;
  String? pickupState;
  String? pickupPincode;
  String? pickupPhone;

  String? deliveryName;
  String? deliveryAddress;
  String? deliveryCity;
  String? deliveryState;
  String? deliveryPincode;
  String? deliveryPhone;

  double? weight;

  
  List<Courier> _couriers = [];
  Courier? selectedCourier;
  ShippingQuote? shippingQuote;
  bool isLoading = false;
  String? error;

  List<Courier> get couriers => _couriers;

  
  bool get isPickupValid =>
      pickupName?.isNotEmpty == true &&
      pickupAddress?.isNotEmpty == true &&
      pickupCity?.isNotEmpty == true &&
      pickupState?.isNotEmpty == true &&
      pickupPincode?.isNotEmpty == true &&
      pickupPhone?.length == 10;

  String getInvalidPickupFields() {
    List<String> invalidFields = [];

    if (pickupName?.isNotEmpty != true) invalidFields.add('Name');
    if (pickupAddress?.isNotEmpty != true) invalidFields.add('Address');
    if (pickupCity?.isNotEmpty != true) invalidFields.add('City');
    if (pickupState?.isNotEmpty != true) invalidFields.add('State');
    if (pickupPincode?.isNotEmpty != true) invalidFields.add('Pincode');
    if (pickupPhone?.length != 10)
      invalidFields.add('Phone (must be 10 digits)');

    return invalidFields.isEmpty
        ? ''
        : 'Invalid fields: ${invalidFields.join(', ')}';
  }

  bool get isDeliveryValid =>
      deliveryName?.isNotEmpty == true &&
      deliveryAddress?.isNotEmpty == true &&
      deliveryCity?.isNotEmpty == true &&
      deliveryState?.isNotEmpty == true &&
      deliveryPincode?.isNotEmpty == true &&
      deliveryPhone?.length == 10;

  bool get isReviewValid =>
      weight != null && weight! > 0 && selectedCourier != null;

  
  void updatePickupDetails({
    String? name,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? phone,
  }) {
    pickupName = name ?? pickupName;
    pickupAddress = address ?? pickupAddress;
    pickupCity = city ?? pickupCity;
    pickupState = state ?? pickupState;
    pickupPincode = pincode ?? pickupPincode;
    pickupPhone = phone ?? pickupPhone;
    notifyListeners();
  }

  void updateDeliveryDetails({
    String? name,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? phone,
  }) {
    deliveryName = name ?? deliveryName;
    deliveryAddress = address ?? deliveryAddress;
    deliveryCity = city ?? deliveryCity;
    deliveryState = state ?? deliveryState;
    deliveryPincode = pincode ?? deliveryPincode;
    deliveryPhone = phone ?? deliveryPhone;
    notifyListeners();
  }

  void updateWeight(String value) {
    weight = double.tryParse(value);
    notifyListeners();
  }

  void selectCourier(Courier courier) {
    selectedCourier = courier;
    shippingQuote = null;
    notifyListeners();
  }

  
  Future<void> loadCouriers() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      _couriers = await _shippingService.getCouriers();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> calculateRate() async {
    if (!isPickupValid || !isDeliveryValid || !isReviewValid) {
      error = 'Please fill all required fields';
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final quote = await _shippingService.calculateShippingRate(
        courierId: selectedCourier!.id,
        pickup: ShippingAddress(
          fullName: pickupName!,
          address: pickupAddress!,
          city: pickupCity!,
          state: pickupState!,
          pincode: pickupPincode!,
          phoneNumber: pickupPhone!,
        ),
        delivery: ShippingAddress(
          fullName: deliveryName!,
          address: deliveryAddress!,
          city: deliveryCity!,
          state: deliveryState!,
          pincode: deliveryPincode!,
          phoneNumber: deliveryPhone!,
        ),
        weight: weight!,
      );

      shippingQuote = quote;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bookShipment() async {
    if (shippingQuote == null) {
      error = 'Please calculate shipping rate first';
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final success = await _shippingService.bookShipment(
        courierId: selectedCourier!.id,
        pickup: ShippingAddress(
          fullName: pickupName!,
          address: pickupAddress!,
          city: pickupCity!,
          state: pickupState!,
          pincode: pickupPincode!,
          phoneNumber: pickupPhone!,
        ),
        delivery: ShippingAddress(
          fullName: deliveryName!,
          address: deliveryAddress!,
          city: deliveryCity!,
          state: deliveryState!,
          pincode: deliveryPincode!,
          phoneNumber: deliveryPhone!,
        ),
        weight: weight!,
        price: shippingQuote!.price,
      );

      return success;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    pickupName = null;
    pickupAddress = null;
    pickupCity = null;
    pickupState = null;
    pickupPincode = null;
    pickupPhone = null;

    deliveryName = null;
    deliveryAddress = null;
    deliveryCity = null;
    deliveryState = null;
    deliveryPincode = null;
    deliveryPhone = null;

    weight = null;
    selectedCourier = null;
    shippingQuote = null;
    error = null;
    notifyListeners();
  }
}
