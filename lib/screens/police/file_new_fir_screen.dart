import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/police_fir_data.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/app_alert_dialog.dart';
import '../../widgets/language_dropdowns.dart';
import '../../widgets/police_validation_checklist_item.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class FileNewFIRPoliceScreen extends StatefulWidget {
  const FileNewFIRPoliceScreen({super.key});

  @override
  State<FileNewFIRPoliceScreen> createState() => _FileNewFIRPoliceScreenState();
}

class _FileNewFIRPoliceScreenState extends State<FileNewFIRPoliceScreen> {
  int _currentStep = 0;
  bool _isRecording = false;

  // Controllers
  late final TextEditingController _incidentTypeController;
  late final TextEditingController _victimNameController;
  late final TextEditingController _incidentDateController;
  late final TextEditingController _incidentLocationController;
  late final TextEditingController _descriptionController;

  final List<String> _languages = <String>[
    'Hindi',
    'English',
    'Marathi',
    'Bengali',
    'Tamil',
    'Telugu',
  ];

  final List<String> _caseTypes = <String>[
    'Theft',
    'Assault',
    'Missing Person',
    'Fraud',
    'Traffic Violation',
  ];

  final List<String> _casePriorities = <String>['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    final firData = context.read<PoliceFirData>();

    _incidentTypeController = TextEditingController(text: firData.incidentType);
    _victimNameController = TextEditingController(text: firData.victimName);
    _incidentDateController = TextEditingController(text: firData.incidentDate);
    _incidentLocationController =
        TextEditingController(text: firData.incidentLocation);
    _descriptionController = TextEditingController(text: firData.description);

    _fetchLocation(); // Simulated GPS fetch
  }

  void _fetchLocation() async {
    final firData = context.read<PoliceFirData>();
    await Future<void>.delayed(const Duration(seconds: 2));
    firData.incidentLocation = 'GPS: 28.7041° N, 77.1025° E (Delhi)';
  }

  void _toggleRecording() async {
    setState(() {
      _isRecording = !_isRecording;
      final firData = context.read<PoliceFirData>();

      if (!_isRecording) {
        // Real backend call: Upload audio file
        String audioFilePath = 'path_to_audio.wav'; // Replace with actual path
        () async {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('http://127.0.0.1:8000/api/fir/auto-generate/'),
          );
          request.files.add(await http.MultipartFile.fromPath('audio', audioFilePath));
          var response = await request.send();
          if (response.statusCode == 201) {
            // Success: handle response
          } else {
            // Error: handle error
          }
        }();
        firData.recordedAudioText =
            'यह एक चोरी का मामला है। पीड़ित रमेश कुमार है। घटना कल रात 10 बजे हुई।';
        showAppSnackBar(context, 'Audio Recorded!', backgroundColor: Colors.green);
      } else {
        firData.clearAllFields();
        showAppSnackBar(context, 'Recording Started...', backgroundColor: AppColors.mediumBlue);
      }
    });
  }

  void _transcribeAndTranslate() async {
    final firData = context.read<PoliceFirData>();
    if (firData.recordedAudioText.isEmpty) {
      showAppSnackBar(context, 'Please record audio first!', backgroundColor: Colors.red);
      return;
    }

    showAppSnackBar(context, 'Transcribing & Translating...', backgroundColor: Colors.purple);

    // Connect to: http://127.0.0.1:8000/api/fir/auto-generate/ (transcription handled in backend)
    await Future<void>.delayed(const Duration(seconds: 3));
    firData.transcribedEnglishText =
        'This is a case of theft. The victim is Ramesh Kumar. The incident happened last night at 10 PM.';
    _autoFillFIRTemplate();
  }

  void _autoFillFIRTemplate() {
    final firData = context.read<PoliceFirData>();
    if (firData.transcribedEnglishText.isEmpty) {
      showAppSnackBar(context, 'Please transcribe first!', backgroundColor: Colors.red);
      return;
    }

    // Connect to: http://127.0.0.1:8000/api/fir/auto-generate/ (autofill handled in backend)
    firData.incidentType = 'Theft';
    firData.victimName = 'Ramesh Kumar';
    firData.incidentDate = 'Yesterday, 10:00 PM';
    firData.description = firData.transcribedEnglishText;
    showAppSnackBar(context, 'FIR Template Auto-filled!', backgroundColor: Colors.green);
  }

  void _submitFIR() async {
    final firData = context.read<PoliceFirData>();

    if (firData.incidentType.isEmpty ||
        firData.victimName.isEmpty ||
        firData.incidentDate.isEmpty ||
        firData.incidentLocation.isEmpty ||
        firData.description.isEmpty ||
        firData.selectedCaseType == null ||
        firData.selectedCasePriority == null) {
      showAppSnackBar(context, 'Please complete all fields!', backgroundColor: Colors.red);
      setState(() => _currentStep = 3);
      return;
    }

    // Connect to: http://127.0.0.1:8000/api/fir/auto-generate/ (submit handled in backend)
    /*
    final response = await http.post(
      Uri.parse('<YOUR_BACKEND_URL>/fir/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "officerId": "INP3489",
        "incidentType": firData.incidentType,
        "victimName": firData.victimName,
        "incidentDate": firData.incidentDate,
        "incidentLocation": firData.incidentLocation,
        "description": firData.description,
        "caseType": firData.selectedCaseType,
        "casePriority": firData.selectedCasePriority
      }),
    );
    */

    showAppSnackBar(
      context,
      '✅ FIR Submitted | FIR ID: FIR_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      backgroundColor: Colors.green,
    );
    Navigator.pop(context);
  }

  List<Step> _buildSteps(PoliceFirData firData) {
    return <Step>[
      Step(
        title: const Text('Record Audio', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(_isRecording ? Icons.mic : Icons.mic_none,
                    size: 30, color: _isRecording ? Colors.red : Colors.grey),
                const SizedBox(width: 10),
                Text(_isRecording ? 'Recording...' : 'Ready to Record'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record, color: Colors.white),
              label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red.shade600 : Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            Text('Recorded Audio: ${firData.recordedAudioText}'),
            const SizedBox(height: 20),
            LanguageDropdowns(
              fromLanguage: firData.fromLanguage,
              toLanguage: firData.toLanguage,
              languages: _languages,
              onFromLanguageChanged: (value) => firData.fromLanguage = value,
              onToLanguageChanged: (value) => firData.toLanguage = value,
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Transcribe & Auto-Fill', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: _transcribeAndTranslate,
              icon: const Icon(Icons.translate, color: Colors.white),
              label: const Text('Transcribe & Translate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            Text('English Translation: ${firData.transcribedEnglishText}'),
          ],
        ),
      ),
      Step(
        title: const Text('Review & Refine Details', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: <Widget>[
            TextField(controller: _incidentTypeController,
              onChanged: (v) => firData.incidentType = v,
              decoration: const InputDecoration(labelText: 'Incident Type'),
            ),
            const SizedBox(height: 10),
            TextField(controller: _victimNameController,
              onChanged: (v) => firData.victimName = v,
              decoration: const InputDecoration(labelText: 'Victim Name'),
            ),
            const SizedBox(height: 10),
            TextField(controller: _incidentDateController,
              onChanged: (v) => firData.incidentDate = v,
              decoration: const InputDecoration(labelText: 'Date/Time'),
            ),
            const SizedBox(height: 10),
            TextField(controller: _incidentLocationController,
              readOnly: true,
              onChanged: (v) => firData.incidentLocation = v,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 10),
            TextField(controller: _descriptionController,
              maxLines: 4,
              onChanged: (v) => firData.description = v,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: firData.selectedCaseType,
              items: _caseTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => firData.selectedCaseType = v,
              decoration: const InputDecoration(labelText: 'Case Type'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: firData.selectedCasePriority,
              items: _casePriorities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => firData.selectedCasePriority = v,
              decoration: const InputDecoration(labelText: 'Case Priority'),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Final Validation', style: TextStyle(fontWeight: FontWeight.bold)),
        content: PoliceValidationChecklist(firData: firData),
      ),
      Step(
        title: const Text('Submit FIR', style: TextStyle(fontWeight: FontWeight.bold)),
        content: ElevatedButton.icon(
          onPressed: _submitFIR,
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text('Submit FIR'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final firData = context.watch<PoliceFirData>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('File New FIR', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.navyBlue,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < _buildSteps(firData).length - 1) {
            setState(() => _currentStep++);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: _buildSteps(firData),
      ),
    );
  }
}
