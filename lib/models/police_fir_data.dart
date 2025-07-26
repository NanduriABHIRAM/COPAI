import 'package:flutter/foundation.dart';

class PoliceFirData extends ChangeNotifier {
  String _recordedAudioText = '';
  String _transcribedEnglishText = '';
  String _incidentType = '';
  String _victimName = '';
  String _incidentDate = '';
  String _incidentLocation = 'Fetching location...';
  String _description = '';
  String? _selectedCaseType;
  String? _selectedCasePriority;
  String? _fromLanguage;
  String? _toLanguage;

  // Getters
  String get recordedAudioText => _recordedAudioText;
  String get transcribedEnglishText => _transcribedEnglishText;
  String get incidentType => _incidentType;
  String get victimName => _victimName;
  String get incidentDate => _incidentDate;
  String get incidentLocation => _incidentLocation;
  String get description => _description;
  String? get selectedCaseType => _selectedCaseType;
  String? get selectedCasePriority => _selectedCasePriority;
  String? get fromLanguage => _fromLanguage;
  String? get toLanguage => _toLanguage;

  // Setters
  set recordedAudioText(String value) {
    _recordedAudioText = value;
    notifyListeners();
  }

  set transcribedEnglishText(String value) {
    _transcribedEnglishText = value;
    notifyListeners();
  }

  set incidentType(String value) {
    _incidentType = value;
    notifyListeners();
  }

  set victimName(String value) {
    _victimName = value;
    notifyListeners();
  }

  set incidentDate(String value) {
    _incidentDate = value;
    notifyListeners();
  }

  set incidentLocation(String value) {
    _incidentLocation = value;
    notifyListeners();
  }

  set description(String value) {
    _description = value;
    notifyListeners();
  }

  set selectedCaseType(String? value) {
    _selectedCaseType = value;
    notifyListeners();
  }

  set selectedCasePriority(String? value) {
    _selectedCasePriority = value;
    notifyListeners();
  }

  set fromLanguage(String? value) {
    _fromLanguage = value;
    notifyListeners();
  }

  set toLanguage(String? value) {
    _toLanguage = value;
    notifyListeners();
  }

  void clearAllFields() {
    _recordedAudioText = '';
    _transcribedEnglishText = '';
    _incidentType = '';
    _victimName = '';
    _incidentDate = '';
    _incidentLocation = 'Fetching location...';
    _description = '';
    _selectedCaseType = null;
    _selectedCasePriority = null;
    _fromLanguage = null;
    _toLanguage = null;
    notifyListeners();
  }
}
