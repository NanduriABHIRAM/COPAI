import 'package:flutter/material.dart';

class LanguageDropdowns extends StatelessWidget {
  final String? fromLanguage;
  final String? toLanguage;
  final List<String> languages;
  final ValueChanged<String?> onFromLanguageChanged;
  final ValueChanged<String?> onToLanguageChanged;

  const LanguageDropdowns({
    super.key,
    required this.fromLanguage,
    required this.toLanguage,
    required this.languages,
    required this.onFromLanguageChanged,
    required this.onToLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: DropdownButtonFormField<String>(
            value: fromLanguage,
            items: languages
                .map((lang) =>
                    DropdownMenuItem(value: lang, child: Text(lang)))
                .toList(),
            onChanged: onFromLanguageChanged,
            decoration: const InputDecoration(labelText: 'From'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: toLanguage,
            items: languages
                .map((lang) =>
                    DropdownMenuItem(value: lang, child: Text(lang)))
                .toList(),
            onChanged: onToLanguageChanged,
            decoration: const InputDecoration(labelText: 'To'),
          ),
        ),
      ],
    );
  }
}
