import 'package:flutter/material.dart';
import 'package:tfnd_app/themes/color.dart';
// Update with your app's import

class ReusableDropdown extends StatelessWidget {
  final String? selectedValue;
  final String hint;
  final Icon prefixIcon;
  final Function(String?) onChanged;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final void Function()? onSubmitted;

  final List<String> _uaeStates = [
    'Abu Dhabi',
    'Dubai',
    'Sharjah',
    'Ajman',
    'Umm Al Quwain',
    'Ras Al Khaimah',
    'Fujairah'
  ];

  ReusableDropdown({
    Key? key,
    required this.selectedValue,
    required this.hint,
    required this.prefixIcon,
    required this.onChanged,
    this.validator,
    this.focusNode,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      validator: validator,
      iconEnabledColor: AppColor.btnColor,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: hint,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      focusNode: focusNode,
      value: selectedValue,
      items: _uaeStates.map((state) {
        return DropdownMenuItem<String>(
          value: state,
          child: Text(
            state,
            style: TextStyle(color: AppColor.hintColor),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      
      
    );
  }
}
