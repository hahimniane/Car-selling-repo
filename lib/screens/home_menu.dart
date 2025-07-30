import 'package:flutter/material.dart';
import '../widgets/language_toggle.dart';
import '../l10n/app_localizations.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key});

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> with SingleTickerProviderStateMixin {
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
              // Header with language toggle
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: const LanguageToggle(),
                ),
              ),
              
              // Welcome Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.06,
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width * 0.04,
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
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/logo.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.welcomeToBusinessServices,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.chooseServiceToStart,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tab Bar
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.06,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: const Color(0xFF1B365D),
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.business_center),
                      text: 'Services',
                    ),
                    Tab(
                      icon: Icon(Icons.folder_open),
                      text: 'Records',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.06,
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
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Services Tab
                      _buildServicesTab(),
                      // Records Tab
                      _buildRecordsTab(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Create New Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _MenuButton(
                    title: AppLocalizations.of(context)!.parkACar,
                    icon: Icons.local_parking,
                    onTap: () => Navigator.pushNamed(context, '/park'),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    title: AppLocalizations.of(context)!.sendBarrelsToGuinea,
                    icon: Icons.local_shipping,
                    onTap: () => Navigator.pushNamed(context, '/barrel'),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    title: AppLocalizations.of(context)!.transportCarsToGuinea,
                    icon: Icons.directions_car,
                    onTap: () => Navigator.pushNamed(context, '/transport'),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    title: AppLocalizations.of(context)!.sellCars,
                    icon: Icons.sell,
                    onTap: () => Navigator.pushNamed(context, '/sell'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'View & Manage Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _MenuButton(
                    title: AppLocalizations.of(context)!.manageParkingRecords,
                    icon: Icons.local_parking_outlined,
                    onTap: () => Navigator.pushNamed(context, '/parking-records'),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    title: AppLocalizations.of(context)!.managePackageRecords,
                    icon: Icons.inventory_2_outlined,
                    onTap: () => Navigator.pushNamed(context, '/package-records'),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    title: AppLocalizations.of(context)!.manageTransportRecords,
                    icon: Icons.airport_shuttle_outlined,
                    onTap: () => Navigator.pushNamed(context, '/transport-records'),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    title: AppLocalizations.of(context)!.manageSalesRecords,
                    icon: Icons.point_of_sale_outlined,
                    onTap: () => Navigator.pushNamed(context, '/sales-records'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 60, maxHeight: 80),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B365D),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          splashFactory: NoSplash.splashFactory,
        ),
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
