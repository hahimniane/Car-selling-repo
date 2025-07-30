import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _mileageController = TextEditingController();
  
  List<XFile> _images = [];
  bool _isLoading = false;

  // Dropdown selections
  String? _selectedMake;
  String? _selectedModel;
  String? _selectedYear;
  String? _selectedFuelType;
  String? _selectedTransmission;
  String? _selectedBodyType;
  String? _selectedCondition;

  // Car data
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
    _descriptionController.dispose();
    _priceController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final imagePicker = ImagePicker();
    final pickedImages = await imagePicker.pickMultiImage(imageQuality: 70);
    setState(() {
      _images.addAll(pickedImages);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages(String carId) async {
    final storage = FirebaseStorage.instance;
    List<String> imageUrls = [];

    for (var image in _images) {
      final fileName = '${carId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref().child('car_images/$fileName');
      final uploadTask = ref.putFile(File(image.path));
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  String _formatNumber(String value) {
    // Remove any existing formatting
    String cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanValue.isEmpty) return '';
    
    // Add commas for thousands
    int number = int.parse(cleanValue);
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the price';
    }
    
    String cleanValue = value.replaceAll(',', '');
    double? price = double.tryParse(cleanValue);
    
    if (price == null) {
      return 'Please enter a valid price';
    }
    
    if (price < 100) {
      return 'Price must be at least \$100';
    }
    
    if (price > 10000000) {
      return 'Price cannot exceed \$10,000,000';
    }
    
    return null;
  }

  String? _validateMileage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the mileage';
    }
    
    String cleanValue = value.replaceAll(',', '');
    int? mileage = int.tryParse(cleanValue);
    
    if (mileage == null) {
      return 'Please enter a valid mileage';
    }
    
    if (mileage < 0) {
      return 'Mileage cannot be negative';
    }
    
    if (mileage > 2000000) {
      return 'Mileage cannot exceed 2,000,000 km';
    }
    
    return null;
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate() || _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and add at least one image.'),
          backgroundColor: Colors.orange,
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
        throw Exception('You must be logged in to add a car.');
      }

      final carId = FirebaseFirestore.instance.collection('cars').doc().id;
      final imageUrls = await _uploadImages(carId);

      final title = '$_selectedMake $_selectedModel';
      
      await FirebaseFirestore.instance.collection('cars').doc(carId).set({
        'title': title,
        'make': _selectedMake,
        'model': _selectedModel,
        'year': int.tryParse(_selectedYear ?? '0') ?? 0,
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0,
        'priceRange': _priceController.text,
        'mileage': int.tryParse(_mileageController.text.replaceAll(',', '')) ?? 0,
        'mileageRange': _mileageController.text,
        'fuelType': _selectedFuelType,
        'transmission': _selectedTransmission,
        'bodyType': _selectedBodyType,
        'condition': _selectedCondition,
        'imageUrls': imageUrls,
        'sellerId': user.uid,
        'sellerEmail': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Active',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add car: $e'),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addNewCar),
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B365D), Colors.white],
            stops: [0.2, 0.2],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildImageSection(),
                const SizedBox(height: 24),
                
                // Make and Model
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown<String>(
                        value: _selectedMake,
                        hint: l10n.selectMake,
                        icon: Icons.directions_car,
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
                        hint: l10n.selectModel,
                        icon: Icons.car_repair,
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

                // Year and Body Type
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown<String>(
                        value: _selectedYear,
                        hint: l10n.selectYear,
                        icon: Icons.calendar_today,
                        items: List.generate(30, (index) => (DateTime.now().year - index).toString()),
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown<String>(
                        value: _selectedBodyType,
                        hint: l10n.selectBodyType,
                        icon: Icons.directions_car_outlined,
                        items: [l10n.sedan, l10n.suv, l10n.hatchback, l10n.coupe, l10n.convertible, l10n.pickup, l10n.wagon],
                        onChanged: (value) {
                          setState(() {
                            _selectedBodyType = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price and Mileage Ranges
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _priceController,
                        labelText: l10n.price,
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        isRequired: true,
                        customValidator: _validatePrice,
                        enableFormatting: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _mileageController,
                        labelText: l10n.mileage,
                        icon: Icons.speed,
                        keyboardType: TextInputType.number,
                        isRequired: true,
                        customValidator: _validateMileage,
                        enableFormatting: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Fuel Type and Transmission
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown<String>(
                        value: _selectedFuelType,
                        hint: l10n.selectFuelType,
                        icon: Icons.local_gas_station,
                        items: [l10n.gasoline, l10n.diesel, l10n.hybrid, l10n.electric],
                        onChanged: (value) {
                          setState(() {
                            _selectedFuelType = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown<String>(
                        value: _selectedTransmission,
                        hint: l10n.selectTransmission,
                        icon: Icons.settings,
                        items: [l10n.manual, l10n.automatic],
                        onChanged: (value) {
                          setState(() {
                            _selectedTransmission = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Condition
                _buildDropdown<String>(
                  value: _selectedCondition,
                  hint: l10n.selectCondition,
                  icon: Icons.star,
                  items: [l10n.excellent, l10n.good, l10n.fair, l10n.poor],
                  onChanged: (value) {
                    setState(() {
                      _selectedCondition = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Description
                _buildTextField(
                  controller: _descriptionController,
                  labelText: l10n.description,
                  icon: Icons.description,
                  maxLines: 4,
                  isRequired: false,
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B365D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(l10n.save, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _images.isEmpty
              ? Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Center(
                    child: Text(
                      'No images selected',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_images[index].path),
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Images'),
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFF1B365D),
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required IconData icon,
    required List<T> items,
    required void Function(T?) onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: enabled ? const Color(0xFF1B365D) : Colors.grey),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B365D), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            item.toString(),
            style: const TextStyle(fontSize: 14),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
    String? Function(String?)? customValidator,
    bool enableFormatting = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: enableFormatting ? (value) {
        // Format numbers with commas as user types
        String formatted = _formatNumber(value);
        if (formatted != value) {
          controller.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      } : null,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: const Color(0xFF1B365D)),
        prefixText: keyboardType == TextInputType.number && labelText.toLowerCase().contains('price') ? '\$' : null,
        suffixText: keyboardType == TextInputType.number && labelText.toLowerCase().contains('mileage') ? 'km' : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B365D), width: 2),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
      validator: customValidator ?? (isRequired ? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      } : null),
    );
  }
} 