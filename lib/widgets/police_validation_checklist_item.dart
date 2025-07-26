import 'package:flutter/material.dart';
import '../models/police_fir_data.dart';

class PoliceValidationChecklist extends StatelessWidget {
  final PoliceFirData firData;

  const PoliceValidationChecklist({super.key, required this.firData});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Incident Type Filled', 'valid': firData.incidentType.isNotEmpty},
      {'label': 'Victim Name Filled', 'valid': firData.victimName.isNotEmpty},
      {'label': 'Date/Time Filled', 'valid': firData.incidentDate.isNotEmpty},
      {'label': 'Location Auto-Fetched', 'valid': firData.incidentLocation.isNotEmpty},
      {'label': 'Description Provided', 'valid': firData.description.isNotEmpty},
      {'label': 'Case Type Selected', 'valid': firData.selectedCaseType != null},
      {'label': 'Case Priority Selected', 'valid': firData.selectedCasePriority != null},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return ListTile(
          leading: Icon(
            item['valid'] as bool ? Icons.check_circle : Icons.cancel,
            color: item['valid'] as bool ? Colors.green : Colors.red,
          ),
          title: Text(item['label'] as String),
        );
      }).toList(),
    );
  }
}
