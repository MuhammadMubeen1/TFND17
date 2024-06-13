import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:tfnd_app/themes/color.dart';
// Update with your app's import

class ReusablePhoneField extends StatelessWidget {
  final Function(String) onChanged;
  final validator;
  final String hintText;
  final String initialCountryCode;
  final EdgeInsetsGeometry flagsButtonPadding;
  final IconPosition dropdownIconPosition;
  final Color fillColor;
  final TextStyle? style;

  const ReusablePhoneField({
    Key? key,
    required this.onChanged,
    this.validator,
    this.hintText = 'Phone Number',
    this.initialCountryCode = 'AE',
    this.flagsButtonPadding = const EdgeInsets.all(8),
    this.dropdownIconPosition = IconPosition.trailing,
    this.fillColor = Colors.white,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      onChanged: (phoneNumber) {
        onChanged(phoneNumber.completeNumber);
      },
      validator:validator,
      flagsButtonPadding: flagsButtonPadding,
      dropdownIconPosition: dropdownIconPosition,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 23, horizontal: 20),
        filled: true,
        fillColor: fillColor,
        hintText: hintText,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColor.borderFormColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColor.borderFormColor,
            width: 1,
          ),
        ),
      ),
      style: style,
      initialCountryCode: initialCountryCode,
    );
  }
}
