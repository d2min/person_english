import 'package:flutter/material.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 22),
                ...children,
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
