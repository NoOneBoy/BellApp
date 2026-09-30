import 'package:flutter/material.dart';

class BellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BellAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      actions: actions,
    );
  }
}
