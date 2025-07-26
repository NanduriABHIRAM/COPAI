import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'fir_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrackFIRsPoliceScreen extends StatefulWidget {
  const TrackFIRsPoliceScreen({super.key});

  @override
  State<TrackFIRsPoliceScreen> createState() => _TrackFIRsPoliceScreenState();
}

class _TrackFIRsPoliceScreenState extends State<TrackFIRsPoliceScreen> {
  List<Map<String, String>> firList = [];

  @override
  void initState() {
    super.initState();
    _fetchFIRs();
  }

  void _fetchFIRs() async {
    // Real backend call (replace with your actual endpoint when available)
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/fir/auto-generate/'),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() { firList = List<Map<String, String>>.from(jsonDecode(response.body)); });
    } else {
      // Handle error or show a message
    }
    await Future<void>.delayed(const Duration(seconds: 2));
    setState(() {
      firList = [
        {
          'id': 'FIR1234',
          'incidentType': 'Theft',
          'status': 'Pending',
          'victim': 'Ramesh Kumar'
        },
        {
          'id': 'FIR1235',
          'incidentType': 'Fraud',
          'status': 'In Progress',
          'victim': 'Suresh Patil'
        },
      ];
    });
  }

  void _updateFIRStatus(String firId, String newStatus) async {
    // Real backend call (replace with your actual endpoint when available)
    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/fir/auto-generate/'),
      body: { "firId": firId, "status": newStatus },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        final index = firList.indexWhere((f) => f['id'] == firId);
        if (index != -1) {
          firList[index]['status'] = newStatus;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FIR $firId status updated to $newStatus')),
      );
    } else {
      // Handle error or show a message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track FIRs', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.navyBlue,
      ),
      body: ListView.builder(
        itemCount: firList.length,
        itemBuilder: (context, index) {
          final fir = firList[index];
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.lightBlue,
                child: Text(fir['id']![3], style: const TextStyle(color: Colors.white)),
              ),
              title: Text('${fir['incidentType']} (${fir['status']})'),
              subtitle: Text('Victim: ${fir['victim']}'),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _updateFIRStatus(fir['id']!, value),
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem(value: 'Pending', child: Text('Pending')),
                  const PopupMenuItem(value: 'In Progress', child: Text('In Progress')),
                  const PopupMenuItem(value: 'Closed', child: Text('Closed')),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        FIRDetailPoliceScreen(firId: fir['id']!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
