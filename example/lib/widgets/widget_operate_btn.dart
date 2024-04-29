import 'package:flutter/material.dart';

class OperateBtnWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const OperateBtnWidget({
    required this.onPressed,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
