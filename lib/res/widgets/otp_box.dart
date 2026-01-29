// res/widgets/otp_box.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';

class OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final Function(String)? onChanged;
  final bool obscureText;

  const OtpBox({
    Key? key,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    this.onChanged,
    this.obscureText = false,
  }) : super(key: key);

  @override
  State<OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<OtpBox> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));

    widget.focusNode.addListener(() {
      widget.focusNode.hasFocus ? _anim.forward() : _anim.reverse();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.controller.text.isNotEmpty;

    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: widget.focusNode.hasFocus
              ? AppColors.primaryRed.withOpacity(0.05)
              : hasValue
                  ? AppColors.backgroundLight
                  : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.focusNode.hasFocus
                ? AppColors.black
                : hasValue
                    ? AppColors.backgroundWhite
                    : Colors.grey[300]!,
            width: widget.focusNode.hasFocus ? 2.5 : 1.5,
          ),
          boxShadow: widget.focusNode.hasFocus
              ? [BoxShadow(color: AppColors.backgroundLight, blurRadius: 8, offset: const Offset(0, 2))]
              : hasValue
                  ? [BoxShadow(color: AppColors.backgroundLight, blurRadius: 4, offset: const Offset(0, 2))]
                  : null,
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          maxLength: 1,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          obscureText: widget.obscureText,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: hasValue ? Colors.black87 : Colors.grey[400],
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) {
            widget.onChanged?.call(v);
            if (v.length == 1) widget.nextFocusNode?.requestFocus();
          },
        ),
      ),
    );
  }
}