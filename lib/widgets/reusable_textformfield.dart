import 'package:flutter/material.dart';

import '../themes/color.dart';

class ReusableTextForm extends StatelessWidget {
  final String? Function(String?)? validator;
  final VoidCallback? Function(String?)? onChange;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? hintStyle;
  final bool? obscureText;
  final bool? enabled;
  final bool? readOnly;
  final Widget? suffixIcon;
  final Color? filledColor;
  final Widget? prefixIcon;
  final String? errorText;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;

  const ReusableTextForm({
    Key? key,
    this.validator,
    this.errorText,
    this.controller,
    this.hintStyle,
    this.keyboardType,
    this.hintText,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.filledColor = AppColor.transparentColor,
    this.maxLines = 1,
    this.onChange,
    this.textCapitalization = TextCapitalization.sentences,
    this.focusNode,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: textCapitalization,
      onChanged: onChange,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText!,
      readOnly: readOnly!,
      maxLines: maxLines,
      focusNode: focusNode,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColor.whiteColor,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        enabled: enabled!,
        hintText: hintText,
        hintStyle: TextStyle(color: AppColor.hintColor, fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(vertical: 23, horizontal: 25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColor.borderFormColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColor.borderFormColor, width: 1),
        ),
      ),
      validator: validator,
    );
  }
}
