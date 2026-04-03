import 'package:flutter/material.dart';
import 'package:yandex_dance/core/ui/colors/colors.dart';
import 'package:yandex_dance/core/ui/typography/app_text_theme.dart';
import 'package:yandex_dance/core/ui/widgets/person_card/person_photo.dart';

class CoachCard extends StatelessWidget {
  final ImageProvider image;
  final double rating;
  final String styleName;
  final String description;

  const CoachCard({
    super.key,
    required this.image,
    required this.rating,
    required this.styleName,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: Colors.transparent,
        border: Border.all(
          color: AppColors.gray300
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonPhoto(image: image, rating: rating, size: 70),
          const SizedBox(width: 20,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Алексей Ким",
                  style: AppTextTheme.body1Medium18pt,
                ),
                const SizedBox(height: 5,),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.purple500.withAlpha(40),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Center(
                        child: Text(
                          styleName,
                          style: AppTextTheme.body3RegularPurple14pt,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Spacer()
                  ],
                ),
                const SizedBox(height: 5,),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTheme.body2Regular14pt,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
