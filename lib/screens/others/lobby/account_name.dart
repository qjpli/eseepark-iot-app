import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase/supabase.dart';

import '../../../customs/custom_textfields.dart';
import '../../../globals.dart';
import '../../../main.dart';
import '../hub.dart';

class AccountName extends StatefulWidget {
  const AccountName({super.key});

  @override
  State<AccountName> createState() => _AccountNameState();
}

class _AccountNameState extends State<AccountName> {
  bool processingName = false;
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Container(
        height: screenHeight,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                left: screenWidth * 0.07,
                right: screenWidth * 0.07,
                top: screenHeight * 0.11,
                bottom: screenHeight * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/general/eseepark-transparent-logo-bnw.png',
                      width: screenWidth * 0.15,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08),
                  Text(
                    'What Should We Call You?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: screenSize * 0.024,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "Let us know how you'd like to be addressed.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      fontWeight: FontWeight.w300,
                      fontSize: screenHeight * 0.017,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  CustomTextFieldWithLabel(
                    title: '',
                    controller: nameController,
                    placeholder: 'Enter Name',
                    cursorColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    titleStyle: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: screenSize * 0.012,
                    ),
                    placeholderStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      fontSize: screenSize * 0.012,
                    ),
                    mainTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: screenSize * 0.012,
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                    horizontalPadding: screenWidth * 0.05,
                    verticalPadding: screenHeight * 0.02,
                    borderRadius: 30,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.03,
              left: screenWidth * 0.07,
              right: screenWidth * 0.07,
              child: ElevatedButton(
                onPressed: nameController.text.trim().length < 8
                    ? null
                    : () async {
                  if (processingName) return;

                  setState(() => processingName = true);
                  FocusScope.of(context).unfocus();

                  final modifyName = await supabase.auth.updateUser(
                    UserAttributes(
                      data: {'name': nameController.text.trim()},
                    ),
                  );

                  setState(() => processingName = false);

                  if (modifyName.user != null) {
                    Get.offAll(
                          () => const Hub(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 400),
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      'Invalid Name',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.0185,
                  ),
                ),
                child: processingName
                    ? CupertinoActivityIndicator()
                    : Text(
                  'Finish Setup',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize * 0.014,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
