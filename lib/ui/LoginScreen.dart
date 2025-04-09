import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:royaltrader/cubit/auth_cubit.dart';
import 'package:royaltrader/cubit/auth_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../config/routes/routes_name.dart';
import '../const/resource.dart';
import '../widgets/dumb_widgets/app_button_widget.dart';
import '../widgets/dumb_widgets/app_text_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesName.homeScreen,
                (route) => false,
              );
            } else if (state is AuthError) {
              setState(() {
                _errorMessage = state.message;
              });
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Center(
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
                      controller: _emailController,
                      helpText: 'Enter your email',
                    ),
                    SizedBox(height: 20.h),
                    AppTextField(
                      labelText: 'Password',
                      isObscured: true,
                      type: TextInputType.visiblePassword,
                      controller: _passwordController,
                      helpText: 'Enter your password',
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              RoutesName.registerScreen,
                            );
                          },
                          //   child: Text(
                          //     'Register?',
                          //     style: Theme.of(context).textTheme.labelMedium,
                          //   ),
                          // ),
                          // TextButton(
                          //   onPressed: () {
                          //     Navigator.pushNamed(
                          //       context,
                          //       RoutesName.forgotMyPassword,
                          //     );
                          //   },
                          child: Text(
                            'Forgot Password?',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Skeletonizer(
                      enabled: isLoading,
                      effect: ShimmerEffect(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                      ),
                      child: AppButtonWidget(
                        onPressed: () {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;
                          if (email.isNotEmpty && password.isNotEmpty) {
                            context.read<AuthCubit>().signInWithEmailPassword(
                              email,
                              password,
                            );
                          }
                        },
                        title: 'Login',
                        textStyle: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                        disabled: false,
                        isLoading: false,
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
