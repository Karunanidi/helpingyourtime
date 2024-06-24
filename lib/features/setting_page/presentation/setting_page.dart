import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _historyLast24Hours = true;
  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.bodyMedium!;
    final List<Widget> aboutBoxChildren = <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              style: textStyle,
              text: "Timytime is your go-to app for managing tasks efficiently. "
                  'Add tasks, mark them as complete, and keep track of your daily activities. '
                  'Customize your profile and settings to tailor the app to your needs.',
            ),
            TextSpan(
              style: textStyle,
              text: '\n\nHow to use the app:\n'
                  '1. Add tasks using the + button.\n'
                  '2. Swipe left on a task to delete it.\n'
                  '3. Check off tasks when completed.\n'
                  '4. Customize settings in this page.',
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Customize Profile'),
            onTap: () {
              // Navigate to profile customization page
            },
          ),
          SwitchListTile(
            title: const Text('Set History Last for 24 Hours'),
            value: _historyLast24Hours,
            onChanged: (bool value) {
              setState(() {
                _historyLast24Hours = value;
              });
            },
          ),
          ListTile(
            title: const Text('Set Color Theme'),
            onTap: () {
              // Open color picker dialog
              _openColorPickerDialog();
            },
            trailing: Container(
              width: 24,
              height: 24,
              color: _selectedColor,
            ),
          ),
          AboutListTile(
            applicationIcon: const FlutterLogo(),
            applicationName: 'Timytime',
            applicationVersion: '1.0.0',
            applicationLegalese: '\u{a9} 2024 Timytime Authors',
            aboutBoxChildren: aboutBoxChildren,
          ),
        ],
      ),
    );
  }

  void _openColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Color Theme'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}
