import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/status_card.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  Future<void> go(BuildContext context) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('onboarding.done', true);
    if (context.mounted) {
      context.go('/permissions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NewVision'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Icon(
              Icons.visibility,
              size: 84,
              color: Colors.teal,
            ),
            const SizedBox(height: 24),
            Text(
              'تحكم بالنظر، محلياً وخصوصياً.',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const StatusCard(
              ready: true,
              title: 'معالجة على الجهاز',
              subtitle: 'لا يتم حفظ أو رفع إطارات الكاميرا.',
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => go(context),
              child: const Text('متابعة'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
