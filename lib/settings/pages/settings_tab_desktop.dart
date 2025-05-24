import 'package:flutter/material.dart';

class SettingsTabDesktop extends StatefulWidget {
  const SettingsTabDesktop({super.key});

  @override
  State<SettingsTabDesktop> createState() => _SettingsTabDesktopState();
}

class _SettingsTabDesktopState extends State<SettingsTabDesktop> {
  bool creations = true;
  bool rotations = true;
  bool archive = true;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      height: screenSize.height - 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 14, left: 14, bottom: 5),
            child: Row(
              children: [
                Text(
                  "Settings",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, color: Colors.grey),

          /// 👇 THIS IS THE FIXED SCROLLABLE AREA
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 0.1 * screenSize.width,
              ),
              child: ListView(
                children: [
                  buildSuggestionsExpansionTile('Select Folders', 'Select folders to be backed up'),
                  // buildSuggestionsExpansionTile(),
                  // buildSuggestionsExpansionTile(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  ExpansionTile buildSuggestionsExpansionTile(String label, String subLabel) {
    return ExpansionTile(
      title: Text(
        label,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subLabel,
      ),
      children: [
        SwitchListTile(
          title: const Text("Pictures"),
          value: creations,
          onChanged: (val) => setState(() => creations = val),
        ),
        SwitchListTile(
          title: const Text("Screenshots"),
          value: rotations,
          onChanged: (val) => setState(() => rotations = val),
        ),
        SwitchListTile(
          title: const Text("Downloads"),
          value: archive,
          onChanged: (val) => setState(() => archive = val),
        ),
        SwitchListTile(
          title: const Text("Documents"),
          value: archive,
          onChanged: (val) => setState(() => archive = val),
        ),
      ],
    );
  }
}
