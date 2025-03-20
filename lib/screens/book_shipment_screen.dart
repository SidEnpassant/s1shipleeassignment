import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shipping_provider.dart';
import '../widgets/step_progress_indicator.dart';
import '../widgets/address_form.dart';
import '../widgets/review_step.dart';
import 'success_screen.dart';

class BookShipmentScreen extends StatefulWidget {
  const BookShipmentScreen({super.key});

  @override
  State<BookShipmentScreen> createState() => _BookShipmentScreenState();
}

class _BookShipmentScreenState extends State<BookShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PageController _pageController;
  int _currentStep = 0;
  ShippingProvider? _provider;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ShippingProvider>().loadCouriers();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    _provider = Provider.of<ShippingProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!mounted) return;

    final provider = _provider;
    if (provider == null) return;

   
    if (_currentStep == 0 && !provider.isPickupValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.getInvalidPickupFields()),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_currentStep == 1 && !provider.isDeliveryValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all delivery details correctly')),
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _calculateShippingRate() async {
    if (!mounted) return;

    final provider = _provider;
    if (provider == null) return;

    if (!provider.isReviewValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter weight and select a courier'),
        ),
      );
      return;
    }

    await provider.calculateRate();

    if (!mounted) return;

    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
      return;
    }

    _showShippingQuoteBottomSheet();
  }

  void _resetForm() {
    if (!mounted) return;

    final provider = _provider;
    if (provider == null) return;

   
    provider.reset();

    
    _formKey.currentState?.reset();

    
    setState(() {
      _currentStep = 0;
      _pageController.jumpToPage(0);
    });
  }

  void _showShippingQuoteBottomSheet() {
    final provider = _provider;
    if (provider == null || !mounted) return;

    final quote = provider.shippingQuote;
    if (quote == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Shipping Quote',
                style: Theme.of(bottomSheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Cost',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '₹${quote.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimated Delivery',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '${quote.estimatedDays} days',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(bottomSheetContext);
                    final success = await provider.bookShipment();
                    if (success && mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              SuccessScreen(onBackPressed: _resetForm),
                        ),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(provider.error ?? 'Failed to book shipment'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Book Shipment',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Book a Shipment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ShippingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Form(
            key: _formKey,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: StepProgressIndicator(
                    currentStep: _currentStep,
                    totalSteps: 3,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      AddressForm(
                        title: 'Pickup Address',
                        isPickup: true,
                      ),
                      AddressForm(
                        title: 'Delivery Address',
                        isPickup: false,
                      ),
                      ReviewStep(),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        offset: const Offset(0, -2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              child: const Text('Previous'),
                            ),
                          ),
                        ),
                      Expanded(
                        flex: _currentStep > 0 ? 2 : 1,
                        child: ElevatedButton(
                          onPressed: _currentStep < 2
                              ? _nextStep
                              : _calculateShippingRate,
                          child: Text(
                            _currentStep < 2 ? 'Next' : 'Calculate Rate',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
