import 'package:flutter/material.dart';

class CustomSliverAppBar extends StatelessWidget {
  final VoidCallback? onSkip;

  const CustomSliverAppBar({Key? key, this.onSkip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true, // keeps it visible when scrolling
      snap: true,
      automaticallyImplyLeading: false, // remove back button
      actions: [
        TextButton(
          onPressed: onSkip,
          child: const Text(
            "SKIP",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
