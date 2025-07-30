import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/language_toggle.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class TransportCarScreen extends StatefulWidget {
  const TransportCarScreen({super.key});

  @override
  State<TransportCarScreen> createState() => _TransportCarScreenState();
}

class _TransportCarScreenState extends State<TransportCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _vinController = TextEditingController();
  final _priceController = TextEditingController();

  // Dropdown selections
  String? _selectedMake;
  String? _selectedModel;
  String? _selectedYear;
  DateTime? _selectedTransportDate;
  
  bool _isLoading = false;

  // Car data - same as other screens
  final Map<String, List<String>> _carModels = {
    'Toyota': ['Camry', 'Corolla', 'RAV4', 'Highlander', 'Prius', 'Tacoma', 'Tundra', 'Sienna', 'Avalon', 'Venza'],
    'Honda': ['Accord', 'Civic', 'CR-V', 'Pilot', 'Odyssey', 'Ridgeline', 'Passport', 'HR-V', 'Insight', 'Fit'],
    'Ford': ['F-150', 'Escape', 'Explorer', 'Mustang', 'Edge', 'Expedition', 'Ranger', 'Bronco', 'Fusion', 'Focus'],
    'Chevrolet': ['Silverado', 'Equinox', 'Malibu', 'Traverse', 'Tahoe', 'Suburban', 'Camaro', 'Corvette', 'Blazer', 'Colorado'],
    'Nissan': ['Altima', 'Sentra', 'Rogue', 'Pathfinder', 'Murano', 'Frontier', 'Titan', 'Armada', 'Maxima', 'Versa'],
    'BMW': ['3 Series', '5 Series', '7 Series', 'X3', 'X5', 'X7', 'Z4', 'i3', 'i4', 'iX'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC', 'GLE', 'GLS', 'A-Class', 'CLA', 'G-Class', 'SL'],
    'Audi': ['A3', 'A4', 'A6', 'A8', 'Q3', 'Q5', 'Q7', 'Q8', 'TT', 'R8'],
    'Volkswagen': ['Jetta', 'Passat', 'Tiguan', 'Atlas', 'Golf', 'Beetle', 'Arteon', 'ID.4', 'Taos', 'Atlas Cross Sport'],
    'Hyundai': ['Elantra', 'Sonata', 'Tucson', 'Santa Fe', 'Palisade', 'Veloster', 'Genesis', 'Kona', 'Venue', 'Nexo'],
    'Kia': ['Forte', 'Optima', 'Sorento', 'Telluride', 'Sportage', 'Soul', 'Stinger', 'Niro', 'Seltos', 'Carnival'],
    'Mazda': ['Mazda3', 'Mazda6', 'CX-5', 'CX-9', 'MX-5 Miata', 'CX-30', 'CX-50', 'Mazda2', 'CX-3', 'RX-8'],
    'Subaru': ['Outback', 'Forester', 'Impreza', 'Legacy', 'Ascent', 'Crosstrek', 'WRX', 'BRZ', 'Tribeca', 'Baja'],
  };

  final List<String> _years = List.generate(30, (index) => (2024 - index).toString());

  @override
  void dispose() {
    _ownerNameController.dispose();
    _vinController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectTransportDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTransportDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B365D),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTransportDate) {
      setState(() {
        _selectedTransportDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMake == null || _selectedModel == null || _selectedYear == null || _selectedTransportDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseEnterAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('You must be logged in to submit a transport record.');
      }

      // Generate a unique transport ID
      final transportId = 'TRP_${DateTime.now().millisecondsSinceEpoch}';

      // Create transport record in Firestore
      await FirebaseFirestore.instance.collection('transport_records').add({
        'transportId': transportId,
        'ownerName': _ownerNameController.text.trim(),
        'make': _selectedMake,
        'model': _selectedModel,
        'year': int.tryParse(_selectedYear!) ?? 0,
        'vinNumber': _vinController.text.trim(),
        'transportDate': Timestamp.fromDate(_selectedTransportDate!),
        'price': double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0,
        'priceRange': _priceController.text.trim(),
        'destination': 'Guinea', // Default destination
        'status': 'Scheduled', // Default status
        'createdBy': user.uid,
        'createdByEmail': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Clear the form
        _formKey.currentState!.reset();
        _ownerNameController.clear();
        _vinController.clear();
        _priceController.clear();
        setState(() {
          _selectedMake = null;
          _selectedModel = null;
          _selectedYear = null;
          _selectedTransportDate = null;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transport record created successfully!\nTransport ID: $transportId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating transport record: $e'),
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
                        AppLocalizations.of(context)!.transportCarsToGuinea,
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
                                Icons.directions_car,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.carTransportService,
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
                              AppLocalizations.of(context)!.enterCarTransportDetailsForGuinea,
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
                              // Owner Name Field
                              _RoundedTextField(
                                label: AppLocalizations.of(context)!.ownerName,
                                controller: _ownerNameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Owner name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Car Make Dropdown
                              _RoundedDropdown<String>(
                                label: AppLocalizations.of(context)!.carMake,
                                value: _selectedMake,
                                items: _carModels.keys.toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMake = value;
                                    _selectedModel = null; // Reset model when make changes
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Car Model Dropdown
                              _RoundedDropdown<String>(
                                label: AppLocalizations.of(context)!.carModel,
                                value: _selectedModel,
                                items: _selectedMake != null ? _carModels[_selectedMake!]! : [],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedModel = value;
                                  });
                                },
                                enabled: _selectedMake != null,
                              ),
                              const SizedBox(height: 16),
                              
                              // Car Year Dropdown
                              _RoundedDropdown<String>(
                                label: AppLocalizations.of(context)!.carYear,
                                value: _selectedYear,
                                items: _years,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYear = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // VIN Number Field
                              _RoundedTextField(
                                label: AppLocalizations.of(context)!.vinNumber,
                                controller: _vinController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'VIN number is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Transport Date Picker
                              _DatePickerField(
                                label: AppLocalizations.of(context)!.transportDate,
                                selectedDate: _selectedTransportDate,
                                onTap: _selectTransportDate,
                              ),
                              const SizedBox(height: 16),
                              
                              // Price Field
                              _RoundedTextField(
                                label: AppLocalizations.of(context)!.price,
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Price is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              
                              // Submit Button
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
          borderSide: const BorderSide(color: Colors.red),
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

class _RoundedDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final void Function(T?)? onChanged;
  final bool enabled;

  const _RoundedDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: enabled ? onChanged : null,
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
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
      ),
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
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
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1B365D)),
          ),
          controller: TextEditingController(
            text: selectedDate != null 
                ? DateFormat('MMM dd, yyyy').format(selectedDate!)
                : '',
          ),
          validator: (value) {
            if (selectedDate == null) {
              return 'Transport date is required';
            }
            return null;
          },
        ),
      ),
    );
  }
}
