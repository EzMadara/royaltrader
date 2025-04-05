import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/routes/routes_name.dart';
import '../const/resource.dart';
import '../widgets/dumb_widgets/app_button_widget.dart';
import '../widgets/dumb_widgets/app_text_field_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                          'Login',
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Welcome to Royal Tiles And Sanitary',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                AppTextField(
                  labelText: 'Email',
                  type: TextInputType.emailAddress,
                  helpText: 'Enter your email',
                  Function: (value) {},
                ),
                SizedBox(height: 20.h),
                AppTextField(
                  labelText: 'Password',
                  isObscured: true,
                  type: TextInputType.visiblePassword,
                  helpText: 'Enter your password',
                  Function: (value) {},
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RoutesName.forgotMyPassword,
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                AppButtonWidget(
                  onPressed: () {
                    Navigator.pushNamed(context, RoutesName.homeScreen);
                  },
                  title: 'Login',
                  textStyle: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  disabled: false,
                  isLoading: false,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
