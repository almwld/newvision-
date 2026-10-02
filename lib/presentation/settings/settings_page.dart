import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/calibration_provider.dart';
import '../providers/permission_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/setting_slider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final calibration = context.watch<CalibrationProvider>();
    final permissions = context.watch<PermissionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _Section(title: 'المظهر', children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('الوضع الداكن'),
              subtitle: const Text('تغيير مظهر الواجهة'),
              value: settings.darkMode,
              onChanged: settings.setDarkMode,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language_rounded),
              title: const Text('اللغة'),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: settings.locale.languageCode,
                  items: const [
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value != null) settings.setLanguage(value);
                  },
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          _Section(title: 'التفاعل الأساسي', children: [
            SettingSlider(
              value: settings.dwellMs.toDouble(),
              label: 'مدة التثبيت',
              onChanged: (value) => settings.setDwellMs(value.round()),
            ),
            Text('المدة الحالية: ' + settings.dwellMs.toString() + ' ms',
                style: Theme.of(context).textTheme.bodySmall),
          ]),
          const SizedBox(height: 14),
          _GazeZonesCard(settings: settings),
          const SizedBox(height: 14),
          _Section(title: 'الصلاحيات', children: [
            _PermissionRow(
              icon: Icons.camera_alt_outlined,
              title: 'الكاميرا',
              active: permissions.camera,
              onTap: permissions.requestCamera,
            ),
            _PermissionRow(
              icon: Icons.layers_outlined,
              title: 'العرض فوق التطبيقات',
              active: permissions.overlay,
              onTap: permissions.requestOverlay,
            ),
            _PermissionRow(
              icon: Icons.accessibility_new_rounded,
              title: 'إمكانية الوصول',
              active: permissions.accessibility,
              onTap: permissions.requestAccessibility,
            ),
          ]),
          const SizedBox(height: 14),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: Icon(Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer),
              title: Text('إعادة ضبط المعايرة',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  )),
              subtitle: Text('يحذف نموذج المعايرة المحلي فقط.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer)),
              onTap: calibration.busy
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('حذف المعايرة؟'),
                          content: const Text(
                              'سيحتاج التطبيق إلى معايرة جديدة قبل الاستخدام الدقيق.'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: const Text('إلغاء'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: const Text('حذف'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) await calibration.clear();
                    },
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text('NewVision 1.0.0',
                style: Theme.of(context).textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}

class _GazeZonesCard extends StatelessWidget {
  const _GazeZonesCard({required this.settings});

  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.track_changes_rounded,
                  color: scheme.onPrimaryContainer),
            ),
            title: const Text('Gaze Zones',
                style: TextStyle(fontWeight: FontWeight.w800)),
            subtitle: const Text('الوضع المتقدم — معطل افتراضياً'),
            trailing: Switch.adaptive(
                value: settings.gazeZonesEnabled,
                onChanged: settings.toggleGazeZones),
          ),
          if (settings.gazeZonesEnabled) ...[
            const Divider(height: 24),
            const _Subheading(title: 'التمرير'),
            _ZoneSwitch(
              icon: Icons.keyboard_arrow_up_rounded,
              title: 'تمرير لأعلى',
              value: settings.scrollUpEnabled,
              onChanged: settings.toggleScrollUp,
            ),
            _ZoneSwitch(
              icon: Icons.keyboard_arrow_down_rounded,
              title: 'تمرير لأسفل',
              value: settings.scrollDownEnabled,
              onChanged: settings.toggleScrollDown,
            ),
            _ZoneSwitch(
              icon: Icons.keyboard_arrow_left_rounded,
              title: 'تمرير لليسار',
              value: settings.scrollLeftEnabled,
              onChanged: settings.toggleScrollLeft,
            ),
            _ZoneSwitch(
              icon: Icons.keyboard_arrow_right_rounded,
              title: 'تمرير لليمين',
              value: settings.scrollRightEnabled,
              onChanged: settings.toggleScrollRight,
            ),
            const Divider(height: 24),
            const _Subheading(title: 'النقر السريع'),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.bolt_rounded),
              title: const Text('Fast Click'),
              subtitle:
                  Text('مدة التحديق: ' + settings.fastClickMs.toString() + ' ms'),
              value: settings.fastClickEnabled,
              onChanged: settings.toggleFastClick,
            ),
            if (settings.fastClickEnabled)
              Slider(
                value: settings.fastClickMs.toDouble(),
                min: 150,
                max: 500,
                divisions: 7,
                label: settings.fastClickMs.toString() + ' ms',
                onChanged: settings.setFastClickMs,
              ),
            const Divider(height: 24),
            const _Subheading(title: 'متقدم'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.crop_free_rounded),
              title: const Text('عرض المنطقة'),
              subtitle: Text(
                (settings.edgeThreshold * 100).round().toString() +
                    '% من حافة الشاشة',
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.timer_outlined),
              title: const Text('زمن تفعيل المنطقة'),
              subtitle: Text(
                settings.activationMs.toString() +
                    ' ms مع تبريد ' +
                    settings.cooldownMs.toString() +
                    ' ms',
              ),
            ),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: settings.resetGazeZones,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('إعادة تعيين'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: settings.saveGazeZones,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('حفظ'),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _Subheading extends StatelessWidget {
  const _Subheading({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
      );
}

class _ZoneSwitch extends StatelessWidget {
  const _ZoneSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(icon),
        title: Text(title),
        value: value,
        onChanged: onChanged,
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ),
            ...children,
          ]),
        ),
      );
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(title),
        trailing: Icon(
          active ? Icons.check_circle_rounded : Icons.open_in_new_rounded,
          color: active ? Theme.of(context).colorScheme.primary : null,
        ),
        onTap: active ? null : onTap,
      );
}
