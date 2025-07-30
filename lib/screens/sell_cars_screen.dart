import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/language_toggle.dart';
import '../l10n/app_localizations.dart';
import 'car_details_screen.dart';

class SellCarsScreen extends StatefulWidget {
  const SellCarsScreen({super.key});

  @override
  State<SellCarsScreen> createState() => _SellCarsScreenState();
}

class _SellCarsScreenState extends State<SellCarsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Just trigger rebuild when search changes
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DocumentSnapshot> _filterCars(List<DocumentSnapshot> allCars) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return allCars;
    } else {
      return allCars.where((carDoc) {
        final car = carDoc.data() as Map<String, dynamic>;
        final title = car['title']?.toString().toLowerCase() ?? '';
        final make = car['make']?.toString().toLowerCase() ?? '';
        final model = car['model']?.toString().toLowerCase() ?? '';
        final year = car['year']?.toString() ?? '';
        final price = car['price']?.toString() ?? '';
        
        return title.contains(query) ||
            make.contains(query) ||
            model.contains(query) ||
            year.contains(query) ||
            price.contains(query);
      }).toList();
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'N/A';
    double numValue;
    
    if (price is String) {
      numValue = double.tryParse(price.replaceAll(',', '')) ?? 0;
    } else if (price is num) {
      numValue = price.toDouble();
    } else {
      return 'N/A';
    }
    
    if (numValue == 0) return 'N/A';
    
    // Format with commas for thousands
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
    
    // Format with commas for thousands
    String formatted = numValue.toInt().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    
    return '$formatted km';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        l10n.sellCars,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const LanguageToggle(),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Service info section
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B365D), Color(0xFF2C5282)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Icon(
                                Icons.directions_car,
                                color: Color(0xFF1B365D),
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.carSalesService,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.browseAvailableCarsForSale,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: l10n.searchCars,
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Cars list
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('cars')
                              .where('status', isEqualTo: 'Active')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_car_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.noResultsFound,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No cars available for sale yet.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            final allCars = snapshot.data!.docs;
                            final filteredCars = _filterCars(allCars);
                            
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: filteredCars.length,
                              itemBuilder: (context, index) {
                                final carDoc = filteredCars[index];
                                final car = carDoc.data() as Map<String, dynamic>;
                                final imageUrls = car['imageUrls'] as List<dynamic>?;
                                final firstImage = imageUrls != null && imageUrls.isNotEmpty 
                                    ? imageUrls[0] as String 
                                    : null;
                                
                                return _CarCard(
                                  car: car,
                                  imageUrl: firstImage,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/car-details',
                                      arguments: {'carId': carDoc.id},
                                    );
                                  },
                                );
                              },
                            );
                          },
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

  List<String> _generateFeatures(Map<String, dynamic> car) {
    List<String> features = [];
    
    if (car['transmission'] != null) {
      features.add('${car['transmission']} transmission');
    }
    if (car['fuelType'] != null) {
      features.add('${car['fuelType']} engine');
    }
    if (car['bodyType'] != null) {
      features.add('${car['bodyType']} body style');
    }
    if (car['condition'] != null) {
      features.add('${car['condition']} condition');
    }
    
    // Add some default features
    features.addAll([
      'Bluetooth connectivity',
      'Air conditioning',
      'Power steering',
      'Safety features included',
    ]);
    
    return features;
  }
}

class _CarCard extends StatelessWidget {
  final Map<String, dynamic> car;
  final String? imageUrl;
  final VoidCallback onTap;

  const _CarCard({
    required this.car,
    required this.imageUrl,
    required this.onTap,
  });

  String _formatPrice(dynamic price) {
    if (price == null) return 'N/A';
    double numValue;
    
    if (price is String) {
      numValue = double.tryParse(price.replaceAll(',', '')) ?? 0;
    } else if (price is num) {
      numValue = price.toDouble();
    } else {
      return 'N/A';
    }
    
    if (numValue == 0) return 'N/A';
    
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Car image
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.directions_car, 
                                 size: 40, 
                                 color: Colors.grey[400]),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: const Color(0xFF1B365D),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                  : Icon(Icons.directions_car, 
                         size: 40, 
                         color: Colors.grey[400]),
            ),
            
            // Car details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car['title'] ?? '${car['make'] ?? ''} ${car['model'] ?? ''}'.trim(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B365D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Année: ${car['year'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'kilométrage: ${_formatMileage(car['mileage'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Price
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _formatPrice(car['price']),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
