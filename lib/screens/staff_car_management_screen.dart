import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/language_toggle.dart';
import '../l10n/app_localizations.dart';
import 'add_car_screen.dart';

class StaffCarManagementScreen extends StatefulWidget {
  const StaffCarManagementScreen({super.key});

  @override
  State<StaffCarManagementScreen> createState() =>
      _StaffCarManagementScreenState();
}

class _StaffCarManagementScreenState extends State<StaffCarManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCarScreen()),
          );
        },
        backgroundColor: const Color(0xFF1B365D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cars').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Still show the main layout but with empty lists
            return _buildUI(context, l10n, []);
          }

          final carDocs = snapshot.data!.docs;
          return _buildUI(context, l10n, carDocs);
        },
      ),
    );
  }

  Widget _buildUI(BuildContext context, AppLocalizations l10n, List<DocumentSnapshot> carDocs) {
    return Container(
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
            _buildHeader(context, l10n),
            _buildDashboard(context, l10n, carDocs),
            _buildCarListSection(context, l10n, carDocs),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.manageCars,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const LanguageToggle(),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, AppLocalizations l10n, List<DocumentSnapshot> carDocs) {
    final activeCars = carDocs.where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'Active').toList();
    final inactiveCars = carDocs.where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'Inactive').toList();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B365D), Color(0xFF2C5282)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.directions_car,
            value: carDocs.length.toString(),
            label: l10n.totalCars,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            value: activeCars.length.toString(),
            label: l10n.activeCars,
          ),
          _buildStatItem(
            icon: Icons.pause_circle,
            value: inactiveCars.length.toString(),
            label: l10n.inactiveCars,
          ),
        ],
      ),
    );
  }

  Widget _buildCarListSection(BuildContext context, AppLocalizations l10n, List<DocumentSnapshot> carDocs) {
    return Expanded(
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
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF1B365D),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF1B365D),
              tabs: [
                Tab(text: l10n.active),
                Tab(text: l10n.inactive),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCarList(context, l10n, carDocs, isActive: true),
                  _buildCarList(context, l10n, carDocs, isActive: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarList(BuildContext context, AppLocalizations l10n, List<DocumentSnapshot> allCarDocs, {required bool isActive}) {
    final carsToShow = allCarDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // A car is active if its status is 'Active'
      return (data['status'] == 'Active') == isActive;
    }).toList();

    if (carsToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.directions_car_outlined : Icons.pause_circle_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${isActive ? 'active' : 'inactive'} cars yet.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: carsToShow.length,
      itemBuilder: (context, index) {
        final carDoc = carsToShow[index];
        final car = carDoc.data() as Map<String, dynamic>;
        final imageUrls = car['imageUrls'] as List<dynamic>?;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image and status indicator
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: Colors.grey[200],
                    ),
                    child: imageUrls != null && imageUrls.isNotEmpty
                        ? PageView.builder(
                            itemCount: imageUrls.length,
                            itemBuilder: (context, imageIndex) {
                              return ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      imageUrls[imageIndex] as String,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                          ),
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
                                    // Image counter
                                    if (imageUrls.length > 1)
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${imageIndex + 1}/${imageUrls.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.directions_car,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                  // Status indicator
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: car['status'] == 'Sold' 
                          ? Colors.red 
                          : isActive 
                            ? Colors.green 
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        car['status'] == 'Sold' 
                          ? l10n.sold 
                          : isActive 
                            ? 'Active' 
                            : 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Swipe indicator
                  if (imageUrls != null && imageUrls.length > 1)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.swipe, color: Colors.white, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '${imageUrls.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // Car details and actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and year
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            car['title'] ?? '${car['make'] ?? ''} ${car['model'] ?? ''}'.trim(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B365D),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            car['year']?.toString() ?? 'N/A',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Price and mileage
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 16, color: Colors.green[600]),
                        Text(
                          _formatPrice(car['price']),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatMileage(car['mileage']),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Additional car info
                    if (car['fuelType'] != null || car['transmission'] != null || car['bodyType'] != null)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (car['fuelType'] != null)
                            _buildInfoChip(car['fuelType'], Icons.local_gas_station),
                          if (car['transmission'] != null)
                            _buildInfoChip(car['transmission'], Icons.settings),
                          if (car['bodyType'] != null)
                            _buildInfoChip(car['bodyType'], Icons.directions_car_outlined),
                          if (car['condition'] != null)
                            _buildInfoChip(car['condition'], Icons.star, 
                              color: _getConditionColor(car['condition'])),
                        ],
                      ),
                    if (car['fuelType'] != null || car['transmission'] != null || car['bodyType'] != null)
                      const SizedBox(height: 12),
                    // Description
                    if (car['description'] != null && car['description'].toString().isNotEmpty)
                      Text(
                        car['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      children: [
                        // Toggle active/inactive or mark as sold
                        Expanded(
                          child: car['status'] == 'Sold' 
                            ? ElevatedButton.icon(
                                onPressed: null, // Disabled for sold cars
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: Text(l10n.sold),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () => _toggleCarStatus(carDoc.id, !isActive),
                                icon: Icon(
                                  isActive ? Icons.pause : Icons.play_arrow,
                                  size: 18,
                                ),
                                label: Text(isActive ? 'Deactivate' : 'Activate'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActive ? Colors.orange : Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                        ),
                        const SizedBox(width: 8),
                        // Mark as sold button (only for active cars)
                        if (car['status'] != 'Sold')
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showMarkAsSoldDialog(context, carDoc),
                              icon: const Icon(Icons.sell, size: 18),
                              label: Text(l10n.markSold),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B365D),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        // Delete button
                        ElevatedButton.icon(
                          onPressed: car['status'] == 'Sold' 
                            ? null // Don't allow deleting sold cars
                            : () => _showDeleteDialog(context, carDoc.id, car['title'] ?? 'this car'),
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: car['status'] == 'Sold' ? Colors.grey : Colors.red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleCarStatus(String carId, bool makeActive) async {
    try {
      await FirebaseFirestore.instance
          .collection('cars')
          .doc(carId)
          .update({'status': makeActive ? 'Active' : 'Inactive'});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Car ${makeActive ? 'activated' : 'deactivated'} successfully'),
            backgroundColor: makeActive ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating car status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, String carId, String carTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Car'),
          content: Text('Are you sure you want to delete "$carTitle"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCar(carId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCar(String carId) async {
    try {
      await FirebaseFirestore.instance.collection('cars').doc(carId).delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting car: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMarkAsSoldDialog(BuildContext context, DocumentSnapshot carDoc) {
    final l10n = AppLocalizations.of(context)!;
    final car = carDoc.data() as Map<String, dynamic>;
    final customerNameController = TextEditingController();
    final customerPhoneController = TextEditingController();
    final salePriceController = TextEditingController(
      text: car['price']?.toString() ?? ''
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.markCarAsSold),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Car: ${car['title'] ?? 'Unknown'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: customerNameController,
                  decoration: InputDecoration(
                    labelText: l10n.customerName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: customerPhoneController,
                  decoration: InputDecoration(
                    labelText: l10n.customerPhone,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: salePriceController,
                  decoration: InputDecoration(
                    labelText: l10n.salePrice,
                    border: const OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (customerNameController.text.trim().isEmpty ||
                    customerPhoneController.text.trim().isEmpty ||
                    salePriceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.pleaseEnterAllFields),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                await _markCarAsSold(
                  carDoc.id,
                  car,
                  customerNameController.text.trim(),
                  customerPhoneController.text.trim(),
                  salePriceController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B365D),
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.markAsSold),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markCarAsSold(
    String carId,
    Map<String, dynamic> car,
    String customerName,
    String customerPhone,
    String salePrice,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Generate a unique sale ID
      final saleId = 'SALE_${DateTime.now().millisecondsSinceEpoch}';
      
      // Update car status to 'Sold'
      await FirebaseFirestore.instance.collection('cars').doc(carId).update({
        'status': 'Sold',
        'soldAt': FieldValue.serverTimestamp(),
        'soldPrice': double.tryParse(salePrice.replaceAll(',', '')) ?? 0,
      });

      // Create sales record
      await FirebaseFirestore.instance.collection('sales_records').add({
        'saleId': saleId,
        'carId': carId,
        'carTitle': car['title'] ?? '${car['make'] ?? ''} ${car['model'] ?? ''}'.trim(),
        'make': car['make'] ?? '',
        'model': car['model'] ?? '',
        'year': car['year'] ?? 0,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'salePrice': double.tryParse(salePrice.replaceAll(',', '')) ?? 0,
        'originalPrice': car['price'] ?? 0,
        'sellerId': car['sellerId'],
        'sellerEmail': car['sellerEmail'],
        'saleDate': FieldValue.serverTimestamp(),
        'status': 'Completed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.carMarkedAsSoldSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorMarkingCarAsSold}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, IconData icon, {Color? color}) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      avatar: Icon(icon, color: color ?? Colors.blue, size: 16),
      backgroundColor: Colors.grey[100],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Color _getConditionColor(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
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
}
