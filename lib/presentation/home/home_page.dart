import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'home_view_model.dart';

final GoRouter appRouter = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, state) => const HomePage())],
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('NewVision')),
      body: Center(
        child: FilledButton.icon(
          onPressed: () => viewModel.setCameraEnabled(!viewModel.cameraEnabled),
          icon: Icon(viewModel.cameraEnabled ? Icons.visibility : Icons.visibility_off),
          label: Text(viewModel.cameraEnabled ? 'Eye control enabled' : 'Enable eye control'),
        ),
      ),
    );
  }
}
