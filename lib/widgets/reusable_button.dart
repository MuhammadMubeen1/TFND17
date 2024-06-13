import 'package:flutter/material.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import '../themes/color.dart';

class ReusableButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLoading;
  final Color buttonColor;

  const ReusableButton({
    Key? key,
    required this.title,
    required this.onTap,
    this.isLoading = false,
    this.buttonColor = AppColor.btnColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ), backgroundColor: isLoading ? AppColor.btnColor : buttonColor,
        padding: EdgeInsets.zero,
        alignment: Alignment.center
      ),
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: isLoading
            ? CircularProgressIndicator(
                color: AppColor.blackColor,
              )
            : Center(
              child: ReusableText(
                  title: title,
                  size: 16,
                  weight: FontWeight.w900,
                  color: AppColor.blackColor,
                ),
            ),
      ),
    );
  }
}
