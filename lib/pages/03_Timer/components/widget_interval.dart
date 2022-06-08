import 'package:flutter/material.dart';
import 'package:my_workout_diary_app/global/enum/item_type.dart';
import 'package:my_workout_diary_app/global/provider/workout_provider.dart';
import 'package:my_workout_diary_app/global/style/ds_colors.dart';
import 'package:my_workout_diary_app/global/style/ds_text_styles.dart';
import 'package:provider/provider.dart';

class WidgetInterval extends StatelessWidget {
  const WidgetInterval({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<WorkoutProvider>().setItemType(ItemType.interval);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(color: Colors.grey, offset: Offset(3, 3), blurRadius: 5),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, color: DSColors.naver_green),
                SizedBox(
                  width: 8,
                ),
                Text('반복횟수', style: DSTextStyles.regular18black),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${context.watch<WorkoutProvider>().interval.toInt()}X',
              style: DSTextStyles.bold18NaverGreen,
            ),
          ],
        ),
      ),
    );
  }
}
