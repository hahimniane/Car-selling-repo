import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/language_toggle.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class SalesRecordsScreen extends StatefulWidget {
  const SalesRecordsScreen({super.key});

  @override
  State<SalesRecordsScreen> createState() => _SalesRecordsScreenState();
}

class _SalesRecordsScreenState extends State<SalesRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DocumentSnapshot> _filterRecords(List<DocumentSnapshot> allRecords) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return allRecords;
    } else {
      return allRecords.where((recordDoc) {
        final record = recordDoc.data() as Map<String, dynamic>;
        final customerName = record['customerName']?.toString().toLowerCase() ?? '';
        final customerPhone = record['customerPhone']?.toString().toLowerCase() ?? '';
        final carTitle = record['carTitle']?.toString().toLowerCase() ?? '';
        final make = record['make']?.toString().toLowerCase() ?? '';
        final model = record['model']?.toString().toLowerCase() ?? '';
        final saleId = record['saleId']?.toString().toLowerCase() ?? '';
        
        return customerName.contains(query) ||
            customerPhone.contains(query) ||
            carTitle.contains(query) ||
            make.contains(query) ||
            model.contains(query) ||
            saleId.contains(query);
      }).toList();
    }
  }

  Future<void> _deleteRecord(String recordId) async {
    try {
      await FirebaseFirestore.instance
          .collection('sales_records')
          .doc(recordId)
          .delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.recordDeleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting record: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, String recordId, String customerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteConfirmation),
          content: Text(AppLocalizations.of(context)!.confirmDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecord(recordId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.deleteRecord),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot recordDoc) {
    final record = recordDoc.data() as Map<String, dynamic>;
    
    // Initialize controllers with current values
    final customerNameController = TextEditingController(text: record['customerName'] ?? '');
    final customerPhoneController = TextEditingController(text: record['customerPhone'] ?? '');
    final salePriceController = TextEditingController(text: record['salePrice']?.toString() ?? '');
    final saleIdController = TextEditingController(text: record['saleId'] ?? '');
    final carTitleController = TextEditingController(text: record['carTitle'] ?? '');
    
    // Initialize dropdown values
    String selectedStatus = record['status'] ?? 'Completed';
    String? selectedMake = record['make'];
    String? selectedModel = record['model'];
    String? selectedYear = record['year']?.toString();
    DateTime? selectedSaleDate = (record['saleDate'] as Timestamp?)?.toDate();
    
    final carModels = {
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
    
    final years = List.generate(30, (index) => (2024 - index).toString());
    final statusOptions = ['Completed', 'Pending Payment', 'Payment Confirmed', 'Delivered', 'Cancelled', 'Refunded'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.editRecord),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sale ID
                      TextField(
                        controller: saleIdController,
                        decoration: InputDecoration(
                          labelText: 'Sale ID',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Status Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.status,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: statusOptions.map((status) {
                          return DropdownMenuItem(value: status, child: Text(status));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Car Title
                      TextField(
                        controller: carTitleController,
                        decoration: InputDecoration(
                          labelText: 'Car Title',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Car Make
                      DropdownButtonFormField<String>(
                        value: selectedMake,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.carMake,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: carModels.keys.map((make) {
                          return DropdownMenuItem(value: make, child: Text(make));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMake = value;
                            selectedModel = null; // Reset model when make changes
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Car Model
                      DropdownButtonFormField<String>(
                        value: selectedModel,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.carModel,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: selectedMake != null
                            ? carModels[selectedMake!]!.map((model) {
                                return DropdownMenuItem(value: model, child: Text(model));
                              }).toList()
                            : [],
                        onChanged: selectedMake != null
                            ? (value) {
                                setState(() {
                                  selectedModel = value;
                                });
                              }
                            : null,
                      ),
                      const SizedBox(height: 12),
                      
                      // Car Year
                      DropdownButtonFormField<String>(
                        value: selectedYear,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.carYear,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: years.map((year) {
                          return DropdownMenuItem(value: year, child: Text(year));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Customer Name
                      TextField(
                        controller: customerNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.customerName,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Customer Phone
                      TextField(
                        controller: customerPhoneController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.customerPhone,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      
                      // Sale Price
                      TextField(
                        controller: salePriceController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.salePrice,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      
                      // Sale Date
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedSaleDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedSaleDate = picked;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Sale Date',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: selectedSaleDate != null
                                  ? DateFormat('MMM dd, yyyy').format(selectedSaleDate!)
                                  : '',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _updateSalesRecord(context, recordDoc, {
                      'saleId': saleIdController.text.trim(),
                      'status': selectedStatus,
                      'carTitle': carTitleController.text.trim(),
                      'make': selectedMake,
                      'model': selectedModel,
                      'year': selectedYear != null ? int.tryParse(selectedYear!) : null,
                      'customerName': customerNameController.text.trim(),
                      'customerPhone': customerPhoneController.text.trim(),
                      'salePrice': salePriceController.text.isNotEmpty ? double.tryParse(salePriceController.text.replaceAll(',', '')) : null,
                      'saleDate': selectedSaleDate != null ? Timestamp.fromDate(selectedSaleDate!) : null,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B365D),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateSalesRecord(BuildContext context, DocumentSnapshot recordDoc, Map<String, dynamic> updatedData) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('You must be logged in to update records.');
      }

      // Add status history if status changed
      final record = recordDoc.data() as Map<String, dynamic>;
      final currentStatus = record['status'];
      final newStatus = updatedData['status'];
      
      if (currentStatus != newStatus) {
        final currentHistory = record['statusHistory'] as List<dynamic>? ?? [];
        currentHistory.add({
          'status': newStatus,
          'timestamp': DateTime.now(),
          'updatedBy': user.uid,
          'updatedByEmail': user.email,
        });
        updatedData['statusHistory'] = currentHistory;
      }

      updatedData['updatedAt'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('sales_records')
          .doc(recordDoc.id)
          .update(updatedData);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.recordUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating record: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                        l10n.manageSalesRecords,
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
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search sales records...',
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
                      
                      // Records list
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('sales_records')
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
                                      Icons.point_of_sale_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No sales records found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sales records from the car sales will appear here',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            final allRecords = snapshot.data!.docs;
                            final filteredRecords = _filterRecords(allRecords);
                            
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: filteredRecords.length,
                              itemBuilder: (context, index) {
                                final recordDoc = filteredRecords[index];
                                final record = recordDoc.data() as Map<String, dynamic>;
                                
                                return _SalesRecordCard(
                                  record: record,
                                  onEdit: () => _showEditDialog(context, recordDoc),
                                  onDelete: () => _showDeleteDialog(
                                    context, 
                                    recordDoc.id, 
                                    record['customerName'] ?? 'Unknown'
                                  ),
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
}

class _SalesRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SalesRecordCard({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = record['createdAt'] as Timestamp?;
    final saleDate = record['saleDate'] as Timestamp?;
    
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with sale ID and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    record['saleId'] ?? 'No Sale ID',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B365D),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: record['status'] == 'Completed' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record['status'] ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Customer info
            _buildInfoRow(Icons.person, 'Customer', record['customerName'] ?? 'N/A'),
            _buildInfoRow(Icons.phone, 'Phone', record['customerPhone'] ?? 'N/A'),
            if (record['customerEmail'] != null)
              _buildInfoRow(Icons.email, 'Email', record['customerEmail']),
            
            const SizedBox(height: 8),
            
            // Car info
            _buildInfoRow(Icons.directions_car, 'Vehicle', record['carTitle'] ?? 'N/A'),
            _buildInfoRow(Icons.build, 'Details', 
                '${record['make'] ?? 'N/A'} ${record['model'] ?? 'N/A'} (${record['year'] ?? 'N/A'})'),
            if (record['mileage'] != null)
              _buildInfoRow(Icons.speed, 'Mileage', '${record['mileage']} km'),
            
            const SizedBox(height: 8),
            
            // Sale details
            _buildInfoRow(Icons.attach_money, 'Sale Price', '\$${_formatPrice(record['salePrice'])}'),
            if (record['paymentMethod'] != null)
              _buildInfoRow(Icons.payment, 'Payment', record['paymentMethod']),
            if (record['notes'] != null)
              _buildInfoRow(Icons.note, 'Notes', record['notes']),
            
            const SizedBox(height: 8),
            
            // Dates
            if (saleDate != null)
              _buildInfoRow(Icons.calendar_today, 'Sale Date', 
                  DateFormat('MMM dd, yyyy').format(saleDate.toDate())),
            if (createdAt != null)
              _buildInfoRow(Icons.access_time, 'Created', 
                  DateFormat('MMM dd, yyyy - HH:mm').format(createdAt.toDate())),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(AppLocalizations.of(context)!.editRecord),
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
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: Text(AppLocalizations.of(context)!.deleteRecord),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'N/A';
    if (price is String) {
      final numValue = double.tryParse(price.replaceAll(',', '')) ?? 0;
      return numValue.toInt().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );
    } else if (price is num) {
      return price.toInt().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );
    }
    return 'N/A';
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 