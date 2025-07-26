import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/police_fir_data.dart';
import 'file_new_fir_screen.dart';
import 'track_firs_screen.dart';
import 'fir_detail_screen.dart'; // For future navigation if needed
import '../login_selection_screen.dart';

class PoliceDashboardScreen extends StatelessWidget {
  const PoliceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome, Officer Raj (ID: INP3489) 👮',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.navyBlue,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      const LoginSelectionScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navyBlue, AppColors.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const <Widget>[
                      DashboardStatItem(
                          title: 'Total FIRs', value: '230', color: Colors.blue),
                      DashboardStatItem(
                          title: 'Approved', value: '90', color: Colors.green),
                      DashboardStatItem(
                          title: 'Pending', value: '50', color: Colors.orange),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: <Widget>[
                    DashboardTile(
                      icon: Icons.add_circle_outline,
                      label: 'File New FIR',
                      iconColor: Colors.green,
                      textColor: AppColors.navyBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                ChangeNotifierProvider<PoliceFirData>(
                              create: (context) => PoliceFirData(),
                              builder: (context, child) =>
                                  const FileNewFIRPoliceScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    DashboardTile(
                      icon: Icons.track_changes,
                      label: 'Track FIRs',
                      iconColor: Colors.blue,
                      textColor: AppColors.navyBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const TrackFIRsPoliceScreen(),
                          ),
                        );
                      },
                    ),
                    DashboardTile(
                      icon: Icons.folder_open,
                      label: 'Manage Case Types',
                      iconColor: Colors.purple,
                      textColor: AppColors.navyBlue,
                      onTap: () {
                        // TODO: BACKEND: Navigate to case type manager screen and fetch case types from <YOUR_BACKEND_URL>/case_types
                      },
                    ),
                    DashboardTile(
                      icon: Icons.bar_chart,
                      label: 'FIR Reports & Stats',
                      iconColor: Colors.orange,
                      textColor: AppColors.navyBlue,
                      onTap: () {
                        // TODO: BACKEND: Navigate to analytics screen, fetch data from <YOUR_BACKEND_URL>/analytics
                      },
                    ),
                    DashboardTile(
                      icon: Icons.settings,
                      label: 'Settings',
                      iconColor: Colors.grey,
                      textColor: AppColors.navyBlue,
                      onTap: () {
                        // TODO: BACKEND: Implement police settings screen if needed
                      },
                    ),
                    DashboardTile(
                      icon: Icons.exit_to_app,
                      label: 'Logout',
                      iconColor: Colors.red,
                      textColor: AppColors.navyBlue,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const LoginSelectionScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reusable Widgets (You can move these to widgets folder) ---
class DashboardStatItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const DashboardStatItem(
      {super.key,
      required this.title,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const DashboardTile(
      {super.key,
      required this.icon,
      required this.label,
      required this.iconColor,
      required this.textColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50, color: iconColor),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
