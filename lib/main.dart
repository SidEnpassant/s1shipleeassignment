import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/book_shipment_screen.dart';
import 'providers/shipping_provider.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShippingProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shipping Booking App',
        theme: AppTheme.theme,
        home: const BookShipmentScreen(),
      ),
    );
  }
}
