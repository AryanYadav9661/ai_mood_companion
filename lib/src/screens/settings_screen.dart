import 'package:flutter/material.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SwitchListTile(title: const Text('Enable Orb Animation'), value: true, onChanged: (_){}),
        SwitchListTile(title: const Text('Enable live TTS'), value: true, onChanged: (_){}),
        ListTile(title: const Text('Select TTS voice'), onTap: (){}),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ]),
    );
  }
}
