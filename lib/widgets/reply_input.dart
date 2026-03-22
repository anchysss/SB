import 'package:flutter/material.dart';

class ReplyInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ReplyInput({
    Key? key,
    required this.controller,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Reply...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send, color: Colors.pink),
          onPressed: onSend,
        ),
      ),
    );
  }
}
