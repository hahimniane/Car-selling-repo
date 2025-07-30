import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/language_toggle.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class TransportRecordsScreen extends StatefulWidget {
  const TransportRecordsScreen({super.key});

  @override
  State<TransportRecordsScreen> createState() => _TransportRecordsScreenState();
}

class _TransportRecordsScreenState extends State<TransportRecordsScreen> {
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
        final ownerName = record['ownerName']?.toString().toLowerCase() ?? '';
        final make = record['make']?.toString().toLowerCase() ?? '';
        final model = record['model']?.toString().toLowerCase() ?? '';
        final destination = record['destination']?.toString().toLowerCase() ?? '';
        final transportId = record['transportId']?.toString().toLowerCase() ?? '';
        
        return ownerName.contains(query) ||
            make.contains(query) ||
            model.contains(query) ||
            destination.contains(query) ||
            transportId.contains(query);
      }).toList();
    }
  }

  Future<void> _deleteRecord(String recordId) async {
    try {
      await FirebaseFirestore.instance
          .collection('transport_records')
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

  void _showDeleteDialog(BuildContext context, String recordId, String ownerName) {
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

  void _showStatusDialog(BuildContext context, DocumentSnapshot recordDoc) {
    final record = recordDoc.data() as Map<String, dynamic>;
    final currentStatus = record['status'] ?? 'Scheduled';
    String selectedStatus = currentStatus;

    final statusOptions = [
      'Scheduled',
      'Pickup Pending',
      'In Transit to Port',
      'At Port',
      'Shipped',
      'In Transit to Guinea',
      'Customs Clearance',
      'Ready for Pickup',
      'Delivered',
      'Cancelled',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.updateTransportStatus),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transport: ${record['transportId'] ?? 'N/A'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.currentStatus,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: selectedStatus != currentStatus
                      ? () async {
                          Navigator.of(context).pop();
                          await _updateTransportStatus(recordDoc.id, selectedStatus, record);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B365D),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.updateStatus),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateTransportStatus(String recordId, String newStatus, Map<String, dynamic> record) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('You must be logged in to update status.');
      }

      // Update the transport status and add to status history
      final currentHistory = record['statusHistory'] as List<dynamic>? ?? [];
      currentHistory.add({
        'status': newStatus,
        'timestamp': DateTime.now(),
        'updatedBy': user.uid,
        'updatedByEmail': user.email,
      });

      await FirebaseFirestore.instance
          .collection('transport_records')
          .doc(recordId)
          .update({
            'status': newStatus,
            'statusHistory': currentHistory,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.statusUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot recordDoc) {
    final record = recordDoc.data() as Map<String, dynamic>;
    
    // Initialize controllers with current values
    final ownerNameController = TextEditingController(text: record['ownerName'] ?? '');
    final vinController = TextEditingController(text: record['vinNumber'] ?? '');
    final priceController = TextEditingController(text: record['priceRange'] ?? record['price']?.toString() ?? '');
    final transportIdController = TextEditingController(text: record['transportId'] ?? '');
    final pickupLocationController = TextEditingController(text: record['pickupLocation'] ?? '');
    final transportMethodController = TextEditingController(text: record['transportMethod'] ?? '');
    
    // Initialize dropdown values
    String selectedStatus = record['status'] ?? 'Scheduled';
    String selectedDestination = record['destination'] ?? 'Guinea';
    String? selectedMake = record['make'];
    String? selectedModel = record['model'];
    String? selectedYear = record['year']?.toString();
    DateTime? selectedTransportDate = (record['transportDate'] as Timestamp?)?.toDate();
    DateTime? selectedEstimatedDelivery = (record['estimatedDelivery'] as Timestamp?)?.toDate();
    
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
    final statusOptions = [
      'Scheduled',
      'Pickup Pending',
      'In Transit to Port',
      'At Port',
      'Shipped',
      'In Transit to Guinea',
      'Customs Clearance',
      'Ready for Pickup',
      'Delivered',
      'Cancelled',
    ];
    final destinationOptions = ['Guinea', 'Senegal', 'Mali', 'Burkina Faso', 'Ivory Coast'];

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
                      // Transport ID
                      TextField(
                        controller: transportIdController,
                        decoration: InputDecoration(
                          labelText: 'Transport ID',
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
                      
                      // Owner Name
                      TextField(
                        controller: ownerNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.ownerName,
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
                      
                      // VIN Number
                      TextField(
                        controller: vinController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.vinNumber,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Pickup Location
                      TextField(
                        controller: pickupLocationController,
                        decoration: InputDecoration(
                          labelText: 'Pickup Location',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Transport Method
                      TextField(
                        controller: transportMethodController,
                        decoration: InputDecoration(
                          labelText: 'Transport Method',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Price
                      TextField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Price (\$)',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      
                      // Destination
                      DropdownButtonFormField<String>(
                        value: selectedDestination,
                        decoration: InputDecoration(
                          labelText: 'Destination',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: destinationOptions.map((destination) {
                          return DropdownMenuItem(value: destination, child: Text(destination));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDestination = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Transport Date
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedTransportDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedTransportDate = picked;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.transportDate,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: selectedTransportDate != null
                                  ? DateFormat('MMM dd, yyyy').format(selectedTransportDate!)
                                  : '',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Estimated Delivery Date
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedEstimatedDelivery ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedEstimatedDelivery = picked;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Estimated Delivery Date',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(
                              text: selectedEstimatedDelivery != null
                                  ? DateFormat('MMM dd, yyyy').format(selectedEstimatedDelivery!)
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
                    await _updateTransportRecord(context, recordDoc, {
                      'transportId': transportIdController.text.trim(),
                      'status': selectedStatus,
                      'ownerName': ownerNameController.text.trim(),
                      'make': selectedMake,
                      'model': selectedModel,
                      'year': selectedYear != null ? int.tryParse(selectedYear!) : null,
                      'vinNumber': vinController.text.trim(),
                      'pickupLocation': pickupLocationController.text.trim(),
                      'transportMethod': transportMethodController.text.trim(),
                      'price': priceController.text.isNotEmpty ? double.tryParse(priceController.text.replaceAll(',', '')) : null,
                      'priceRange': priceController.text.trim(),
                      'destination': selectedDestination,
                      'transportDate': selectedTransportDate != null ? Timestamp.fromDate(selectedTransportDate!) : null,
                      'estimatedDelivery': selectedEstimatedDelivery != null ? Timestamp.fromDate(selectedEstimatedDelivery!) : null,
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

  Future<void> _updateTransportRecord(BuildContext context, DocumentSnapshot recordDoc, Map<String, dynamic> updatedData) async {
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
          .collection('transport_records')
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
                        l10n.manageTransportRecords,
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
                            hintText: 'Search transport records...',
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
                              .collection('transport_records')
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
                                      Icons.airport_shuttle_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No transport records found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Transport records will appear here once you start using the Car Transport service',
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
                                
                                return _TransportRecordCard(
                                  record: record,
                                  onEdit: () => _showEditDialog(context, recordDoc),
                                  onUpdateStatus: () => _showStatusDialog(context, recordDoc),
                                  onDelete: () => _showDeleteDialog(
                                    context, 
                                    recordDoc.id, 
                                    record['ownerName'] ?? 'Unknown'
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

class _TransportRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  final VoidCallback onEdit;
  final VoidCallback onUpdateStatus;
  final VoidCallback onDelete;

  const _TransportRecordCard({
    required this.record,
    required this.onEdit,
    required this.onUpdateStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = record['createdAt'] as Timestamp?;
    final estimatedDelivery = record['estimatedDelivery'] as Timestamp?;
    
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
            // Header with transport ID and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    record['transportId'] ?? 'No Transport ID',
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
                    color: _getStatusColor(record['status']),
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
            
            // Owner info
            _buildInfoRow(Icons.person, 'Owner', record['ownerName'] ?? 'N/A'),
            if (record['ownerPhone'] != null)
              _buildInfoRow(Icons.phone, 'Phone', record['ownerPhone']),
            
            const SizedBox(height: 8),
            
            // Car info
            _buildInfoRow(Icons.directions_car, 'Vehicle', 
                '${record['make'] ?? 'N/A'} ${record['model'] ?? 'N/A'} (${record['year'] ?? 'N/A'})'),
            if (record['vinNumber'] != null)
              _buildInfoRow(Icons.confirmation_number, 'VIN', record['vinNumber']),
            
            const SizedBox(height: 8),
            
            // Transport details
            _buildInfoRow(Icons.flag, 'Destination', record['destination'] ?? 'N/A'),
            if (record['pickupLocation'] != null)
              _buildInfoRow(Icons.location_on, 'Pickup', record['pickupLocation']),
            if (record['transportMethod'] != null)
              _buildInfoRow(Icons.local_shipping, 'Method', record['transportMethod']),
            if (record['price'] != null)
              _buildInfoRow(Icons.attach_money, 'Price', '\$${record['price']}'),
            
            const SizedBox(height: 8),
            
            // Dates
            if (createdAt != null)
              _buildInfoRow(Icons.access_time, 'Created', 
                  DateFormat('MMM dd, yyyy - HH:mm').format(createdAt.toDate())),
            if (estimatedDelivery != null)
              _buildInfoRow(Icons.schedule, 'Est. Delivery', 
                  DateFormat('MMM dd, yyyy').format(estimatedDelivery.toDate())),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final isStaff = authProvider.isStaff;
                final isAdmin = authProvider.isAdmin;
                
                return Column(
                  children: [
                    // Status update button (for all staff)
                    if (isStaff)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onUpdateStatus,
                          icon: const Icon(Icons.local_shipping, size: 18),
                          label: Text(AppLocalizations.of(context)!.updateStatus),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    if (isStaff) const SizedBox(height: 8),
                    
                    // Edit and Delete buttons (for admin only)
                    if (isAdmin)
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
                    
                    // If not staff, show message
                    if (!isStaff)
                      Text(
                        AppLocalizations.of(context)!.contactStaffForUpdates,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'ready for pickup':
        return Colors.lightGreen;
      case 'customs clearance':
        return Colors.amber;
      case 'in transit to guinea':
        return Colors.teal;
      case 'shipped':
        return Colors.deepPurple;
      case 'at port':
        return Colors.indigo;
      case 'in transit to port':
        return Colors.blue;
      case 'pickup pending':
        return Colors.orangeAccent;
      case 'scheduled':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
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