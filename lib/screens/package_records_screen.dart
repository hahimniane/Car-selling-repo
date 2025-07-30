import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/language_toggle.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class PackageRecordsScreen extends StatefulWidget {
  const PackageRecordsScreen({super.key});

  @override
  State<PackageRecordsScreen> createState() => _PackageRecordsScreenState();
}

class _PackageRecordsScreenState extends State<PackageRecordsScreen> {
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
        final senderName = record['senderName']?.toString().toLowerCase() ?? '';
        final receiverName = record['receiverName']?.toString().toLowerCase() ?? '';
        final receiverPhone = record['receiverPhone']?.toString().toLowerCase() ?? '';
        final destination = record['destination']?.toString().toLowerCase() ?? '';
        final trackingNumber = record['trackingNumber']?.toString().toLowerCase() ?? '';
        
        return senderName.contains(query) ||
            receiverName.contains(query) ||
            receiverPhone.contains(query) ||
            destination.contains(query) ||
            trackingNumber.contains(query);
      }).toList();
    }
  }

  Future<void> _deleteRecord(String recordId) async {
    try {
      await FirebaseFirestore.instance
          .collection('package_records')
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

  void _showDeleteDialog(BuildContext context, String recordId, String senderName) {
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
    final currentStatus = record['status'] ?? 'Pending';
    String selectedStatus = currentStatus;

    final statusOptions = [
      'Pending',
      'Processing',
      'In Transit',
      'At Destination Warehouse',
      'Out for Delivery',
      'Delivered',
      'Cancelled',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.updatePackageStatus),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracking: ${record['trackingNumber'] ?? 'N/A'}',
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
                          await _updatePackageStatus(recordDoc.id, selectedStatus, record);
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

  Future<void> _updatePackageStatus(String recordId, String newStatus, Map<String, dynamic> record) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('You must be logged in to update status.');
      }

      // Update the package status and add to status history
      final currentHistory = record['statusHistory'] as List<dynamic>? ?? [];
      currentHistory.add({
        'status': newStatus,
        'timestamp': DateTime.now(),
        'updatedBy': user.uid,
        'updatedByEmail': user.email,
      });

      await FirebaseFirestore.instance
          .collection('package_records')
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
    final senderNameController = TextEditingController(text: record['senderName'] ?? '');
    final senderAddressController = TextEditingController(text: record['senderAddress'] ?? '');
    final receiverNameController = TextEditingController(text: record['receiverName'] ?? '');
    final receiverPhoneController = TextEditingController(text: record['receiverPhone'] ?? '');
    final priceController = TextEditingController(text: record['priceRange'] ?? record['price']?.toString() ?? '');
    final weightController = TextEditingController(text: record['weight']?.toString() ?? '');
    final trackingNumberController = TextEditingController(text: record['trackingNumber'] ?? '');
    
    // Initialize dropdown values
    String selectedStatus = record['status'] ?? 'Pending';
    String selectedDestination = record['destination'] ?? 'Guinea';
    String selectedPackageType = record['packageType'] ?? 'Barrel/Package';
    DateTime? selectedEstimatedDelivery = (record['estimatedDelivery'] as Timestamp?)?.toDate();
    
    final statusOptions = [
      'Pending',
      'Processing',
      'In Transit',
      'At Destination Warehouse',
      'Out for Delivery',
      'Delivered',
      'Cancelled',
    ];
    
    final destinationOptions = ['Guinea', 'Senegal', 'Mali', 'Burkina Faso', 'Ivory Coast'];
    final packageTypeOptions = ['Barrel/Package', 'Box', 'Envelope', 'Other'];

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
                      // Tracking Number
                      TextField(
                        controller: trackingNumberController,
                        decoration: InputDecoration(
                          labelText: 'Tracking Number',
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
                      
                      // Sender Name
                      TextField(
                        controller: senderNameController,
                        decoration: InputDecoration(
                          labelText: 'Sender Name',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Sender Address
                      TextField(
                        controller: senderAddressController,
                        decoration: InputDecoration(
                          labelText: 'Sender Address',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      
                      // Receiver Name
                      TextField(
                        controller: receiverNameController,
                        decoration: InputDecoration(
                          labelText: 'Receiver Name',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Receiver Phone
                      TextField(
                        controller: receiverPhoneController,
                        decoration: InputDecoration(
                          labelText: 'Receiver Phone',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      
                      // Package Type
                      DropdownButtonFormField<String>(
                        value: selectedPackageType,
                        decoration: InputDecoration(
                          labelText: 'Package Type',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: packageTypeOptions.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPackageType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Weight
                      TextField(
                        controller: weightController,
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
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
                    await _updatePackageRecord(context, recordDoc, {
                      'trackingNumber': trackingNumberController.text.trim(),
                      'status': selectedStatus,
                      'senderName': senderNameController.text.trim(),
                      'senderAddress': senderAddressController.text.trim(),
                      'address': senderAddressController.text.trim(), // Keep for backward compatibility
                      'receiverName': receiverNameController.text.trim(),
                      'receiverPhone': receiverPhoneController.text.trim(),
                      'packageType': selectedPackageType,
                      'weight': weightController.text.isNotEmpty ? double.tryParse(weightController.text) : null,
                      'price': priceController.text.isNotEmpty ? double.tryParse(priceController.text.replaceAll(',', '')) : null,
                      'priceRange': priceController.text.trim(),
                      'destination': selectedDestination,
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

  Future<void> _updatePackageRecord(BuildContext context, DocumentSnapshot recordDoc, Map<String, dynamic> updatedData) async {
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
          .collection('package_records')
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
                        l10n.managePackageRecords,
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
                            hintText: 'Search packages...',
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
                              .collection('package_records')
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
                                      Icons.inventory_2_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No package records found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Package records will appear here once you start using the Package Shipping service',
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
                                
                                return _PackageRecordCard(
                                  record: record,
                                  onEdit: () => _showEditDialog(context, recordDoc),
                                  onUpdateStatus: () => _showStatusDialog(context, recordDoc),
                                  onDelete: () => _showDeleteDialog(
                                    context, 
                                    recordDoc.id, 
                                    record['senderName'] ?? 'Unknown'
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

class _PackageRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  final VoidCallback onEdit;
  final VoidCallback onUpdateStatus;
  final VoidCallback onDelete;

  const _PackageRecordCard({
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
            // Header with tracking number and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    record['trackingNumber'] ?? 'No Tracking Number',
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
            
            // Sender info
            _buildInfoRow(Icons.person, 'From', record['senderName'] ?? 'N/A'),
            _buildInfoRow(Icons.location_on, 'Address', record['senderAddress'] ?? 'N/A'),
            
            const SizedBox(height: 8),
            
            // Receiver info
            _buildInfoRow(Icons.person_outline, 'To', record['receiverName'] ?? 'N/A'),
            _buildInfoRow(Icons.phone, 'Phone', record['receiverPhone'] ?? 'N/A'),
            _buildInfoRow(Icons.flag, 'Destination', record['destination'] ?? 'N/A'),
            
            const SizedBox(height: 8),
            
            // Package details
            if (record['packageType'] != null)
              _buildInfoRow(Icons.inventory_2, 'Type', record['packageType']),
            if (record['weight'] != null)
              _buildInfoRow(Icons.scale, 'Weight', '${record['weight']} kg'),
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
                          icon: const Icon(Icons.update, size: 18),
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
      case 'out for delivery':
        return Colors.lightGreen;
      case 'at destination warehouse':
        return Colors.teal;
      case 'in transit':
        return Colors.blue;
      case 'processing':
        return Colors.indigo;
      case 'pending':
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