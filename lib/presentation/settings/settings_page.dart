import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/calibration_provider.dart';
import '../providers/permission_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext c) {
    final s = c.watch<SettingsProvider>();
    final cal = c.watch<CalibrationProvider>();
    final permissions = c.watch<PermissionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text('الوضع الداكن'),
            value: s.darkMode,
            onChanged: s.setDarkMode,
          ),
          const Divider(),
          ListTile(
            title: const Text('اللغة'),
            trailing: DropdownButton<String>(
              value: s.locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) {
                if (v != null) s.setLanguage(v);
              },
            ),
          ),
          const SizedBox(height: 8),
          const Text('مدة التثبيت'),
          Slider(
            value: s.dwellMs.toDouble(),
            min: 500,
            max: 2000,
            divisions: 15,
            label: '${s.dwellMs} ms',
            onChanged: (v) => s.setDwellMs(v.round()),
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text('الوصول إلى صلاحيات النظام'),
          ListTile(
            title: const Text('الكاميرا'),
            trailing: Icon(
              permissions.camera ? Icons.check_circle : Icons.chevron_left,
              color: permissions.camera
                  ? Theme.of(c).colorScheme.primary
                  : null,
            ),
            onTap: permissions.requestCamera,
          ),
          ListTile(
            title: const Text('العرض فوق التطبيقات'),
            trailing: Icon(
              permissions.overlay ? Icons.check_circle : Icons.chevron_left,
              color: permissions.overlay
                  ? Theme.of(c).colorScheme.primary
                  : null,
            ),
            onTap: permissions.requestOverlay,
          ),
          ListTile(
            title: const Text('إمكانية الوصول'),
            trailing: Icon(
              permissions.accessibility
                  ? Icons.check_circle
                  : Icons.chevron_left,
              color: permissions.accessibility
                  ? Theme.of(c).colorScheme.primary
                  : null,
            ),
            onTap: permissions.requestAccessibility,
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: cal.busy ? null : cal.clear,
            icon: const Icon(Icons.delete_outline),
            label: const Text('حذف المعايرة'),
          ),
        ],
      ),
    );
  }
}
