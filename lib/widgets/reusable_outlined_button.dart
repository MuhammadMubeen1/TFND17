import 'package:flutter/material.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import '../themes/color.dart';

class ReusableOutlinedButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLoading;
  final Color buttonColor;

  const ReusableOutlinedButton({
    Key? key,
    required this.title,
    required this.onTap,
    this.isLoading = false,
    this.buttonColor = AppColor.transparentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: AppColor.primaryColor),
        ), backgroundColor: AppColor.bgColor, // Background color added here
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
      ),
      child: SizedBox(
        height: 43,
        width: 250,
        child: isLoading
            ? CircularProgressIndicator(
                color: AppColor.pinktextColor,
              )
            : Center(
              child: ReusableText(
                  title: title,
                  size: 12,
                  weight: FontWeight.bold,
                  color: AppColor.blackColor,
                ),
            ),
      ),
    );
  }
}
