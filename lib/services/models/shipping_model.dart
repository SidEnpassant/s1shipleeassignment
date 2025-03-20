class ShippingAddress {
  final String fullName;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String phoneNumber;

  ShippingAddress({
    required this.fullName,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'phoneNumber': phoneNumber,
      };
}

class Courier {
  final String id;
  final String name;
  final String logo;
  final double baseRate;

  Courier({
    required this.id,
    required this.name,
    required this.logo,
    required this.baseRate,
  });

  factory Courier.fromJson(Map<String, dynamic> json) => Courier(
        id: json['id'] as String,
        name: json['name'] as String,
        logo: json['logo'] as String,
        baseRate: (json['baseRate'] as num).toDouble(),
      );
}

class ShippingQuote {
  final String courierId;
  final double price;
  final int estimatedDays;

  ShippingQuote({
    required this.courierId,
    required this.price,
    required this.estimatedDays,
  });

  factory ShippingQuote.fromJson(Map<String, dynamic> json) => ShippingQuote(
        courierId: json['courierId'] as String,
        price: (json['price'] as num).toDouble(),
        estimatedDays: json['estimatedDays'] as int,
      );
}
