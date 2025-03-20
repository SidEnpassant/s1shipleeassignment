import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/shipping_provider.dart';
import 'form_validators.dart';

class AddressForm extends StatelessWidget {
  final String title;
  final bool isPickup;

  const AddressForm({
    super.key,
    required this.title,
    required this.isPickup,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ShippingProvider>(
      builder: (context, provider, _) {
        final updateDetails = isPickup
            ? provider.updatePickupDetails
            : provider.updateDeliveryDetails;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: title,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedFormField(
                  initialValue:
                      isPickup ? provider.pickupName : provider.deliveryName,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  helperText: 'Enter at least 3 characters',
                  onChanged: (value) {
                    updateDetails(name: value);
                    Form.of(context).validate();
                  },
                  validator: FormValidators.validateName,
                ),
                const SizedBox(height: 24),
                AnimatedFormField(
                  initialValue: isPickup
                      ? provider.pickupAddress
                      : provider.deliveryAddress,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  helperText: 'Enter at least 5 characters',
                  maxLines: 2,
                  onChanged: (value) {
                    updateDetails(address: value);
                    Form.of(context).validate();
                  },
                  validator: FormValidators.validateAddress,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedFormField(
                        initialValue: isPickup
                            ? provider.pickupCity
                            : provider.deliveryCity,
                        label: 'City',
                        helperText: 'Enter at least 2 characters',
                        onChanged: (value) {
                          updateDetails(city: value);
                          Form.of(context).validate();
                        },
                        validator: FormValidators.validateCity,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedFormField(
                        initialValue: isPickup
                            ? provider.pickupState
                            : provider.deliveryState,
                        label: 'State',
                        helperText: 'Enter at least 2 characters',
                        onChanged: (value) {
                          updateDetails(state: value);
                          Form.of(context).validate();
                        },
                        validator: FormValidators.validateState,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedFormField(
                        initialValue: isPickup
                            ? provider.pickupPincode
                            : provider.deliveryPincode,
                        label: 'Pincode',
                        helperText: 'Enter 6-digit pincode',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        onChanged: (value) {
                          updateDetails(pincode: value);
                          Form.of(context).validate();
                        },
                        validator: FormValidators.validatePincode,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedFormField(
                        initialValue: isPickup
                            ? provider.pickupPhone
                            : provider.deliveryPhone,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        helperText: 'Enter 10-digit number',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        onChanged: (value) {
                          updateDetails(phone: value);
                          Form.of(context).validate();
                        },
                        validator: FormValidators.validatePhone,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedFormField extends StatefulWidget {
  final String? initialValue;
  final String label;
  final String? helperText;
  final IconData? icon;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String) onChanged;
  final String? Function(String?)? validator;

  const AnimatedFormField({
    super.key,
    this.initialValue,
    required this.label,
    this.helperText,
    this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    required this.onChanged,
    this.validator,
  });

  @override
  State<AnimatedFormField> createState() => _AnimatedFormFieldState();
}

class _AnimatedFormFieldState extends State<AnimatedFormField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
    if (hasFocus) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Focus(
        onFocusChange: _handleFocusChange,
        child: TextFormField(
          initialValue: widget.initialValue,
          decoration: InputDecoration(
            labelText: widget.label,
            helperText: widget.helperText,
            prefixIcon: widget.icon != null
                ? Icon(
                    widget.icon,
                    color: _isFocused
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  )
                : null,
            helperStyle: TextStyle(
              color: _isFocused
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade600,
            ),
          ),
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          textInputAction: TextInputAction.next,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ),
    );
  }
}
