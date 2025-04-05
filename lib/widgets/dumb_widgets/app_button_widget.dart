import 'package:flutter/material.dart';

class AppButtonWidget extends StatelessWidget {
  final Function() onPressed;
  final String? title;
  final double? radius;
  final textStyle;
  final isLoading;
  final bool disabled;
  const AppButtonWidget({
    super.key,
    required this.onPressed,
    this.title,
    this.radius,
    this.textStyle,
    this.isLoading,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      disabledColor: Theme.of(context).disabledColor,
      disabledTextColor: Colors.black,
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius ?? 4),
      ),
      onPressed: disabled ? null : onPressed,
      child:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title ?? '',
                      textAlign: TextAlign.center,
                      style:
                          textStyle ??
                          Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
    );
  }
}
