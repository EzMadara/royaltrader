import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:royaltrader/widgets/dumb_widgets/app_button_widget.dart';

import '../const/resource.dart';
import '../widgets/dumb_widgets/app_text_field_widget.dart';

class ForgotMyPassword extends StatelessWidget {
  const ForgotMyPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50.h),
                Container(
                  width: 200.h,
                  height: 200.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(R.ASSETS_LOGO_JPG),
                  ),
                ),
                SizedBox(height: 50.h),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reset Password',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        SizedBox(
                          width: 360.w,
                          child: Text(
                            'Enter the email address associated with your account, and we’ll email you a link to reset your password.',

                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                AppTextField(
                  labelText: 'Email',
                  type: TextInputType.emailAddress,
                  helpText: 'Enter your email',
                ),
                SizedBox(height: 30.h),
                AppButtonWidget(
                  onPressed: () {},
                  title: 'Send Reset Link',
                  textStyle: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  disabled: false,
                  isLoading: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
