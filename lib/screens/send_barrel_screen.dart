import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../widgets/language_toggle.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class SendBarrelScreen extends StatefulWidget {
  const SendBarrelScreen({super.key});

  @override
  State<SendBarrelScreen> createState() => _SendBarrelScreenState();
}

class _SendBarrelScreenState extends State<SendBarrelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senderNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _senderNameController.dispose();
    _addressController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('You must be logged in to submit a package record.');
      }

      // Generate a unique package ID and tracking number
      final packageId = 'PKG_${DateTime.now().millisecondsSinceEpoch}';
      final trackingNumber = 'TN${DateTime.now().year}${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      // Create package record in Firestore
      await FirebaseFirestore.instance.collection('package_records').add({
        'packageId': packageId,
        'trackingNumber': trackingNumber,
        'senderName': _senderNameController.text.trim(),
        'senderAddress': _addressController.text.trim(),
        'address': _addressController.text.trim(), // Keep for backward compatibility
        'receiverName': _receiverNameController.text.trim(),
        'receiverPhone': _receiverPhoneController.text.trim(),
        'price': double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0,
        'priceRange': _priceController.text.trim(),
        'destination': 'Guinea', // Default destination
        'packageType': 'Barrel/Package', // Default type
        'status': 'Pending', // Default status
        'statusHistory': [
          {
            'status': 'Pending',
            'timestamp': DateTime.now(),
            'updatedBy': user.uid,
            'updatedByEmail': user.email,
          }
        ],
        'estimatedDelivery': DateTime.now().add(const Duration(days: 30)), // Default to creation date + 30 days
        'createdBy': user.uid,
        'createdByEmail': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Clear the form
        _formKey.currentState!.reset();
        _senderNameController.clear();
        _addressController.clear();
        _receiverNameController.clear();
        _receiverPhoneController.clear();
        _priceController.clear();

        // Show success message with tracking number
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.packageRecordCreated}\nTracking Number: $trackingNumber'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting package record: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B365D), Color(0xFF2C5282)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and language toggle
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.sendBarrelsToGuinea,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const LanguageToggle(),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.06,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.06,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Icon(
                                Icons.local_shipping,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.barrelShippingService,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.enterShippingDetailsForGuinea,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Form Section
                      Container(
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.06,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _RoundedTextField(
                                label: AppLocalizations.of(context)!.senderName,
                                controller: _senderNameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter sender name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _RoundedTextField(
                                label: AppLocalizations.of(context)!.address,
                                controller: _addressController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _RoundedTextField(
                                label: AppLocalizations.of(context)!.receiverName,
                                controller: _receiverNameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter receiver name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _RoundedTextField(
                                label: AppLocalizations.of(context)!.receiverPhone,
                                controller: _receiverPhoneController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter receiver phone';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _RoundedTextField(
                                label: AppLocalizations.of(context)!.price,
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter price';
                                  }
                                  final price = double.tryParse(value.replaceAll(',', ''));
                                  if (price == null || price <= 0) {
                                    return 'Please enter a valid price';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B365D),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  onPressed: _isLoading ? null : _submitForm,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          AppLocalizations.of(context)!.submit,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _RoundedTextField({
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B365D), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
