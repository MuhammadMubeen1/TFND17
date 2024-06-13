import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
// Import your country picker package

class ReusableCountryPickerFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final void Function(Country) onSelect;

  const ReusableCountryPickerFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (v) {
        if (v == null || v.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      style: const TextStyle(color: Colors.blueGrey), // Customize text color
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle:const  TextStyle(color: Colors.blueGrey),
        prefixIcon: const Icon(
          Icons.flag_outlined,
          color: Colors.blueGrey,
        ),
        suffixIcon:const  Icon(
          Icons.arrow_drop_down,
          color: Colors.blueGrey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.0),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      onTap: () {
        showCountryPicker(
          context: context,
          countryListTheme: CountryListThemeData(
            flagSize: 25,
            backgroundColor: Colors.white,
            textStyle:const  TextStyle(fontSize: 16, color: Colors.blueGrey),
            bottomSheetHeight: 500,
            borderRadius:const  BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            inputDecoration: InputDecoration(
              hintText: 'Select Your Nationality',
              hintStyle:const TextStyle(color: Colors.blueGrey),
              prefixIcon:const  Icon(
                Icons.search,
                color: Colors.blueGrey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18.0),
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18.0),
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
            ),
          ),
          onSelect: onSelect,
        );
      },
    );
  }
}
