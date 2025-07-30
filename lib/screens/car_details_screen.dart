import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/language_toggle.dart';
import '../l10n/app_localizations.dart';

class CarDetailsScreen extends StatefulWidget {
  final String carId;

  const CarDetailsScreen({
    super.key,
    required this.carId,
  });

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  Map<String, dynamic>? carData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCarDetails();
  }

  Future<void> _fetchCarDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.carId)
          .get();
      
      if (doc.exists) {
        setState(() {
          carData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching car details: $e');
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
                        AppLocalizations.of(context)!.carDetails,
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
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : carData == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Car not found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Car Images Gallery
                                  Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: _buildImageGallery(),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Car Title and Price
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          carData!['title'] ?? 'Unknown Car',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1B365D),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                      Text(
                                        _formatPrice(carData!['price']),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B365D),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Car Info Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${AppLocalizations.of(context)!.year}: ${carData!['year'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${AppLocalizations.of(context)!.mileage}: ${_formatMileage(carData!['mileage'])}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Additional Car Details
                                  if (carData!['make'] != null || carData!['model'] != null)
                                    _buildDetailRow(
                                      'Make & Model',
                                      '${carData!['make'] ?? ''} ${carData!['model'] ?? ''}'.trim(),
                                    ),
                                  
                                  if (carData!['fuelType'] != null)
                                    _buildDetailRow('Fuel Type', carData!['fuelType']),
                                  
                                  if (carData!['transmission'] != null)
                                    _buildDetailRow('Transmission', carData!['transmission']),
                                  
                                  if (carData!['bodyType'] != null)
                                    _buildDetailRow('Body Type', carData!['bodyType']),
                                  
                                  if (carData!['condition'] != null)
                                    _buildDetailRow('Condition', carData!['condition']),

                                  const SizedBox(height: 24),

                                  // Car Description
                                  Text(
                                    AppLocalizations.of(context)!.carDescription,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    carData!['description'] ?? 'No description available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Features
                                  Text(
                                    AppLocalizations.of(context)!.features,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFeaturesList(),

                                  const SizedBox(height: 24),

                                  // Contact Information
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.contactInfo,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone,
                                              color: Color(0xFF1B365D),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              carData!['sellerPhone'] ?? 'Phone not available',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // WhatsApp Button
                                  if (carData!['sellerPhone'] != null)
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF25D366),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                          splashFactory: NoSplash.splashFactory,
                                        ),
                                        onPressed: () => _sendWhatsAppMessage(context),
                                        icon: const Icon(Icons.message, size: 24),
                                        label: Text(
                                          AppLocalizations.of(context)!.sendWhatsAppMessage,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = carData!['images'] as List<dynamic>?;
    
    if (images == null || images.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(
            Icons.directions_car,
            size: 80,
            color: Colors.grey,
          ),
        ),
      );
    }

    return PageView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Image.network(
          images[index],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade100,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    // Create features based on car data
    List<String> features = [];
    
    if (carData!['transmission'] != null) {
      features.add('${carData!['transmission']} transmission');
    }
    if (carData!['fuelType'] != null) {
      features.add('${carData!['fuelType']} engine');
    }
    if (carData!['bodyType'] != null) {
      features.add('${carData!['bodyType']} body style');
    }
    if (carData!['condition'] != null) {
      features.add('${carData!['condition']} condition');
    }
    
    // Add some common features
    features.addAll([
      'Bluetooth connectivity',
      'Air conditioning',
      'Power steering',
      'Safety features included',
    ]);

    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF1B365D),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Price not available';
    
    double numValue;
    if (price is String) {
      numValue = double.tryParse(price.replaceAll(',', '')) ?? 0;
    } else if (price is num) {
      numValue = price.toDouble();
    } else {
      return 'Price not available';
    }
    
    if (numValue == 0) return 'Price not available';
    
    String formatted = numValue.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '\$$formatted';
  }

  String _formatMileage(dynamic mileage) {
    if (mileage == null) return 'N/A';
    
    double numValue;
    if (mileage is String) {
      numValue = double.tryParse(mileage.replaceAll(',', '')) ?? 0;
    } else if (mileage is num) {
      numValue = mileage.toDouble();
    } else {
      return 'N/A';
    }
    
    if (numValue == 0) return 'N/A';
    
    String formatted = numValue.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '$formatted km';
  }

  void _sendWhatsAppMessage(BuildContext context) {
    final carTitle = carData!['title'] ?? 'Car';
    final carYear = carData!['year']?.toString() ?? 'Unknown';
    final carPrice = _formatPrice(carData!['price']);
    final sellerPhone = carData!['sellerPhone'] ?? '';
    
    if (sellerPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final message = AppLocalizations.of(context)!.whatsAppMessage(carTitle, carYear, carPrice);

    final whatsappUrl =
        'https://wa.me/$sellerPhone?text=${Uri.encodeComponent(message)}';

    launchUrl(Uri.parse(whatsappUrl)).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open WhatsApp: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}
