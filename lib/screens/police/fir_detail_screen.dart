import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FIRDetailPoliceScreen extends StatefulWidget {
  final String firId;
  const FIRDetailPoliceScreen({super.key, required this.firId});

  @override
  State<FIRDetailPoliceScreen> createState() => _FIRDetailPoliceScreenState();
}

class _FIRDetailPoliceScreenState extends State<FIRDetailPoliceScreen> {
  Map<String, dynamic> firDetails = {};
  final TextEditingController _updateController = TextEditingController();
  List<String> caseUpdates = [];

  @override
  void initState() {
    super.initState();
    _fetchFIRDetails();
  }

  void _fetchFIRDetails() async {
    // Real backend call (replace with your actual endpoint when available)
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/fir/auto-generate/'),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.body;
      setState(() { firDetails = jsonDecode(body); });
    } else {
      // Handle error or show a message
    }
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      firDetails = {
        'id': widget.firId,
        'incidentType': 'Theft',
        'victim': 'Ramesh Kumar',
        'status': 'Pending',
        'description':
            'This is a case of theft. The victim is Ramesh Kumar. Happened last night at 10 PM.',
      };
      caseUpdates = ['FIR Filed', 'Assigned to Officer Raj'];
    });
  }

  void _addCaseUpdate() async {
    if (_updateController.text.isEmpty) return;

    // Real backend call (replace with your actual endpoint when available)
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/fir/auto-generate/'),
      body: {
        'firId': widget.firId,
        'updateText': _updateController.text,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        caseUpdates.add(_updateController.text);
      });
      _updateController.clear();
    } else {
      // Handle error or show a message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FIR Details - ${widget.firId}',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.navyBlue,
      ),
      body: firDetails.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Incident Type', firDetails['incidentType']),
                          _buildDetailRow('Victim', firDetails['victim']),
                          _buildDetailRow('Status', firDetails['status']),
                          _buildDetailRow('Description', firDetails['description']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Case Updates',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...caseUpdates.map((update) => ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(update),
                      )),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _updateController,
                    decoration: InputDecoration(
                      labelText: 'Add Case Update',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _addCaseUpdate,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Update'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
