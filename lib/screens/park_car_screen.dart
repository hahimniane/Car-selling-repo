import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/language_toggle.dart';
import '../l10n/app_localizations.dart';

class ParkCarScreen extends StatefulWidget {
  const ParkCarScreen({super.key});

  @override
  State<ParkCarScreen> createState() => _ParkCarScreenState();
}

class _ParkCarScreenState extends State<ParkCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vinController = TextEditingController();

  // Dropdown selections
  String? _selectedMake;
  String? _selectedModel;
  String? _selectedYear;

  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  // Car data - same as add_car_screen.dart
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
    'Jeep': ['Wrangler', 'Grand Cherokee', 'Cherokee', 'Compass', 'Renegade', 'Gladiator', 'Grand Wagoneer', 'Wagoneer', 'Patriot', 'Liberty'],
    'Ram': ['1500', '2500', '3500', 'ProMaster', 'ProMaster City'],
    'GMC': ['Sierra', 'Terrain', 'Acadia', 'Yukon', 'Canyon', 'Savana', 'Envoy', 'Jimmy'],
    'Cadillac': ['Escalade', 'XT5', 'XT6', 'CT5', 'CT4', 'Lyriq', 'Celestiq'],
    'Lincoln': ['Navigator', 'Aviator', 'Corsair', 'Nautilus', 'Continental', 'MKZ'],
    'Infiniti': ['Q50', 'Q60', 'QX50', 'QX60', 'QX80', 'Q70', 'QX30'],
    'Acura': ['TLX', 'ILX', 'RDX', 'MDX', 'NSX', 'Integra', 'ZDX'],
    'Lexus': ['ES', 'IS', 'GS', 'LS', 'RX', 'GX', 'LX', 'NX', 'UX', 'LC'],
  };

  List<String> get _availableModels {
    if (_selectedMake == null) return [];
    return _carModels[_selectedMake] ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    if (Platform.isIOS) {
      // Use iOS-style date picker
      await _showIOSDatePicker();
    } else {
      // Use Android-style date picker
      await _showAndroidDatePicker();
    }
  }

  Future<void> _showIOSDatePicker() async {
    DateTime tempDateTime = _selectedDateTime;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(AppLocalizations.of(context)!.cancel),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      child: Text(AppLocalizations.of(context)!.done),
                      onPressed: () {
                        setState(() {
                          _selectedDateTime = tempDateTime;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: _selectedDateTime,
                    onDateTimeChanged: (DateTime newDateTime) {
                      tempDateTime = newDateTime;
                    },
                    use24hFormat: false,
                    minuteInterval: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAndroidDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
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

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
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

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _generateAndPrintReceipt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save to database first
      await _saveParkingRecord();
      
      // Generate PDF
      final pdf = pw.Document();
      final receiptNumber = 'RCP-${DateTime.now().millisecondsSinceEpoch}';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(10),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'CAR PARKING RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'TAAO Auto Business Services',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Receipt Details
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(10),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Receipt Details',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 15),

                      _buildReceiptRow('Receipt Number:', receiptNumber),
                      _buildReceiptRow(
                        'Parking Date & Time:',
                        DateFormat('MMM dd, yyyy - HH:mm').format(_selectedDateTime),
                      ),
                      _buildReceiptRow(
                        'Generated On:',
                        DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now()),
                      ),

                      pw.SizedBox(height: 20),

                      pw.Text(
                        'Owner Information',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 15),

                      _buildReceiptRow('Owner Name:', _nameController.text),
                      _buildReceiptRow('Phone Number:', _phoneController.text),

                      pw.SizedBox(height: 20),

                      pw.Text(
                        'Vehicle Information',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 15),

                      _buildReceiptRow('Make:', _selectedMake ?? ''),
                      _buildReceiptRow('Model:', _selectedModel ?? ''),
                      _buildReceiptRow('Year:', _selectedYear ?? ''),
                      _buildReceiptRow('VIN Number:', _vinController.text),

                      pw.SizedBox(height: 20),

                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(15),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(8),
                          ),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'Parking Status: ACTIVE',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Vehicle has been successfully parked and secured',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 30),

                      // Footer
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(15),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(8),
                          ),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'Terms & Conditions',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            pw.Text(
                              '• This receipt serves as proof of parking\n'
                              '• Vehicle will be stored securely\n'
                              '• Contact us for any inquiries\n'
                              '• Valid until vehicle is retrieved\n'
                              '• Keep this receipt for vehicle pickup',
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Car_Parking_Receipt_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.receiptGenerated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorGeneratingReceipt(e.toString())),
            backgroundColor: Colors.red,
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

  Future<void> _saveParkingRecord() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('You must be logged in to save parking records.');
      }

      final receiptNumber = 'RCP-${DateTime.now().millisecondsSinceEpoch}';
      
      await FirebaseFirestore.instance.collection('parking_records').add({
        'receiptNumber': receiptNumber,
        'ownerName': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'make': _selectedMake,
        'model': _selectedModel,
        'year': int.tryParse(_selectedYear ?? '0') ?? 0,
        'vinNumber': _vinController.text.trim(),
        'parkingDateTime': Timestamp.fromDate(_selectedDateTime),
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': user.uid,
        'staffEmail': user.email,
      });
    } catch (e) {
      throw Exception('Failed to save parking record: $e');
    }
  }

  pw.Widget _buildReceiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 12))),
        ],
      ),
    );
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
                        AppLocalizations.of(context)!.parkACar,
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
                                Icons.local_parking,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.carParkingService,
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
                              AppLocalizations.of(context)!.enterCarDetailsToGenerateReceipt,
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
                                controller: _nameController,
                                label: AppLocalizations.of(context)!.name,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!.pleaseEnterOwnerName;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _RoundedTextField(
                                controller: _phoneController,
                                label: AppLocalizations.of(context)!.phoneNumber,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!.pleaseEnterPhoneNumber;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Make and Model Dropdowns
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdown<String>(
                                      value: _selectedMake,
                                      hint: AppLocalizations.of(context)!.selectMake,
                                      items: _carModels.keys.toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedMake = value;
                                          _selectedModel = null; // Reset model when make changes
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdown<String>(
                                      value: _selectedModel,
                                      hint: AppLocalizations.of(context)!.selectModel,
                                      items: _availableModels,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedModel = value;
                                        });
                                      },
                                      enabled: _selectedMake != null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Year Dropdown
                              _buildDropdown<String>(
                                value: _selectedYear,
                                hint: AppLocalizations.of(context)!.selectYear,
                                items: List.generate(30, (index) => (DateTime.now().year - index).toString()),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYear = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              _RoundedTextField(
                                controller: _vinController,
                                label: AppLocalizations.of(context)!.vinNumber,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!.pleaseEnterVinNumber;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Date & Time Selector
                              GestureDetector(
                                onTap: _selectDateTime,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.parkingDateTime,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat(
                                                'MMM dd, yyyy - HH:mm',
                                              ).format(_selectedDateTime),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
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
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : _generateAndPrintReceipt,
                                  child:
                                      _isLoading
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.print, size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                AppLocalizations.of(context)!.printReceipt,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
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
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required void Function(T?) onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
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
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            item.toString(),
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (value == null) {
          return 'Please select $hint';
        }
        return null;
      },
    );
  }
