import 'package:aishwarya_gold/res/constants/app_color.dart';

import '../../utils/exports/exports.dart';

class UiHelper {
  


static void showAppSnackBar(
    BuildContext context, {
    required String message,
    Color backgroundColor = AppColors.primaryRed,
    int durationSeconds = 2,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    double verticalMargin = 16,
    double? horizontalMargin,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: durationSeconds),
        behavior: behavior,
        margin: EdgeInsets.symmetric(
          horizontal: horizontalMargin ?? 15,
          vertical: verticalMargin,
        ),
      ),
    );
  }}
