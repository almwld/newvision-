import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'home_view_model.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
  ],
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'NewVision' : 'NewVision'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: vm.refreshReadiness,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _HeroCard(isArabic: isArabic, ready: vm.ready),
                const SizedBox(height: 20),
                Text(
                  isArabic ? 'متطلبات التحكم بالعين' : 'Eye control setup',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _SetupTile(
                  icon: Icons.camera_alt_outlined,
                  title: isArabic ? 'الكاميرا' : 'Camera',
                  subtitle: isArabic
                      ? 'تحليل الوجه يتم محلياً على الجهاز.'
                      : 'Face analysis runs locally on the device.',
                  ready: vm.cameraEnabled,
                  actionLabel: vm.cameraEnabled
                      ? (isArabic ? 'إيقاف' : 'Stop')
                      : (isArabic ? 'تشغيل' : 'Enable'),
                  onPressed: vm.loading ? null : vm.toggleCamera,
                ),
                _SetupTile(
                  icon: Icons.layers_outlined,
                  title: isArabic ? 'العرض فوق التطبيقات' : 'Overlay',
                  subtitle: isArabic
                      ? 'يُستخدم لعرض مؤشر النظر.'
                      : 'Required for the gaze cursor.',
                  ready: vm.overlayReady,
                  actionLabel: isArabic ? 'السماح' : 'Allow',
                  onPressed: vm.overlayReady ? null : vm.requestOverlay,
                ),
                _SetupTile(
                  icon: Icons.accessibility_new,
                  title: isArabic ? 'إمكانية الوصول' : 'Accessibility',
                  subtitle: isArabic
                      ? 'مطلوبة لتنفيذ النقر بالإيماءة.'
                      : 'Required to execute gaze gestures.',
                  ready: vm.accessibilityReady,
                  actionLabel: isArabic ? 'فتح الإعدادات' : 'Open settings',
                  onPressed:
                      vm.accessibilityReady ? null : vm.requestAccessibility,
                ),
                if (vm.error != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        vm.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  isArabic
                      ? 'المعالجة الأساسية لا تحفظ إطارات الكاميرا.'
                      : 'The core pipeline does not persist camera frames.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.isArabic, required this.ready});

  final bool isArabic;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer,
              scheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 48,
              color: scheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'تحكم طبيعي بنظرك' : 'Natural eye control',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ready
                        ? (isArabic
                            ? 'النظام جاهز للتحكم.'
                            : 'The system is ready.')
                        : (isArabic
                            ? 'أكمل الصلاحيات لتفعيل النظام.'
                            : 'Complete the permissions to enable it.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupTile extends StatelessWidget {
  const _SetupTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ready,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool ready;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(ready ? Icons.check : icon),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: FilledButton(
          onPressed: onPressed,
          child: Text(ready ? '✓' : actionLabel),
        ),
      ),
    );
  }
}
