// res/widgets/otp_row.dart
import 'package:aishwarya_gold/res/widgets/otp_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpRow extends StatefulWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String, int)? onChanged;
  final bool obscureText;
  final int length;

  const OtpRow({
    Key? key,
    required this.controllers,
    required this.focusNodes,
    this.onChanged,
    this.obscureText = false,
    this.length = 4,
  }) : super(key: key);

  @override
  State<OtpRow> createState() => _OtpRowState();
}

class _OtpRowState extends State<OtpRow> {
  late final FocusNode _listener;

  @override
  void initState() {
    super.initState();
    _listener = FocusNode();
    // Grab keyboard focus once the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) => _listener.requestFocus());
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _listener,
      onKey: (event) {
        if (event is! RawKeyDownEvent) return;
        if (event.logicalKey != LogicalKeyboardKey.backspace) return;

        final focusedIdx = widget.focusNodes.indexWhere((n) => n.hasFocus);
        if (focusedIdx == -1) return;

        final ctrl = widget.controllers[focusedIdx];

        // **Empty box → move left immediately**
        if (ctrl.text.isEmpty && focusedIdx > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.focusNodes[focusedIdx - 1].requestFocus();
          });
        }
        // **Has digit → TextField deletes it and stays**
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.length, (i) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: OtpBox(
                  controller: widget.controllers[i],
                  focusNode: widget.focusNodes[i],
                  nextFocusNode: i < widget.length - 1 ? widget.focusNodes[i + 1] : null,
                  obscureText: widget.obscureText,
                  onChanged: (v) => widget.onChanged?.call(v, i),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}