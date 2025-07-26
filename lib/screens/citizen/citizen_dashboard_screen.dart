import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() =>
      _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
  List<Map<String, String>> myFirs = [];

  @override
  void initState() {
    super.initState();
    _fetchMyFIRs();
  }

  void _fetchMyFIRs() async {
    // Real backend call (replace with your actual endpoint when available)
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/fir/auto-generate/'),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() { myFirs = List<Map<String, String>>.from(jsonDecode(response.body)); });
    } else {
      // Handle error or show a message
    }
    await Future<void>.delayed(const Duration(seconds: 2));
    setState(() {
      myFirs = [
        {
          'id': 'FIR2231',
          'incidentType': 'Theft',
          'status': 'In Progress',
        },
        {
          'id': 'FIR2232',
          'incidentType': 'Fraud',
          'status': 'Closed',
        },
      ];
    });
  }

  void _fileNewFIR() {
    // TODO: BACKEND: Redirect to citizen FIR filing screen if implemented later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filing FIR will be available soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Citizen Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.navyBlue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _fileNewFIR,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('File New FIR',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mediumBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'My FIRs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: myFirs.length,
              itemBuilder: (context, index) {
                final fir = myFirs[index];
                return Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.lightGold,
                      child: Text(fir['id']![3],
                          style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text('${fir['incidentType']}'),
                    subtitle: Text('Status: ${fir['status']}'),
                    onTap: () {
                      // Connect to: http://127.0.0.1:8000/api/fir/auto-generate/ (only endpoint available for now)
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
