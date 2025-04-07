import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:royaltrader/auth/AuthService.dart';
import 'package:royaltrader/cubit/auth_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../config/routes/routes_name.dart';
import '../const/resource.dart';
import '../widgets/dumb_widgets/app_button_widget.dart';
import '../widgets/dumb_widgets/app_text_field_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    final error = await _authService.registerUser(email, password);

    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });

    if (error == null) {
      Navigator.pushNamed(context, RoutesName.homeScreen);
    }
  }

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
                          'Register',
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Create an account to access Royal Tiles And Sanitary',
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
                  controller: _emailController,
                ),
                SizedBox(height: 20.h),
                AppTextField(
                  labelText: 'Password',
                  isObscured: true,
                  type: TextInputType.visiblePassword,
                  helpText: 'Enter your password',
                  controller: _passwordController,
                ),
                SizedBox(height: 10.h),
                _errorMessage != null
                    ? Text(_errorMessage!, style: TextStyle(color: Colors.red))
                    : SizedBox.shrink(),
                SizedBox(height: 20.h),
                Skeletonizer(
                  enabled: _isLoading,
                  effect: ShimmerEffect(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                  ),
                  child: AppButtonWidget(
                    onPressed: () {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text;
                      if (email.isNotEmpty && password.isNotEmpty) {
                        context.read<AuthCubit>().registerWithEmailPassword(
                          email,
                          password,
                        );
                      }
                    },
                    title: 'Register',
                    textStyle: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    disabled: false,
                    isLoading: false,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RoutesName.loginScreen);
                      },
                      child: Text(
                        'Login',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
