import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:unibites/resources/dimension.dart';
import '../resources/color.dart';

class CustomAlertDialog extends StatelessWidget {
  final List<Widget> actions;
  final String title;
  final String contentText;

  const CustomAlertDialog({
    super.key,
    required this.actions,
    this.title = 'Terms of Use and Privacy Policy',
    this.contentText = 'I confirm that I have read, consent and agree to UniBites\' Terms of Use and Privacy Policy.',
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: AppDimension.paddingDefault / 2),
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: AppColors.textSilver, fontSize: 14),
            children: [
              TextSpan(
                text: contentText,
                style: TextStyle(),
              ),
              TextSpan(
                text: 'Terms of Use',
                style: TextStyle(
                  color: Colors.white,  // Typically blue for links in iOS
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (kDebugMode) {
                      print('Terms of Use tapped!');
                    }
                  },
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: Colors.white,  // Typically blue for links in iOS
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (kDebugMode) {
                      print('Privacy Policy tapped!');
                    }
                  },
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
      ),
      actions: actions,
    );
  }
}

void showCustomAlertDialog(BuildContext context, List<Widget> actions) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog(actions: actions);
    },
  );
}
