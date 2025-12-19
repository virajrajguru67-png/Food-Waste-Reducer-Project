import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/clean_button.dart';

class RatingScreen extends StatefulWidget {
  final String restaurantName;
  final String? orderId;
  final List<Map<String, dynamic>>? orderItems;

  const RatingScreen({
    super.key,
    required this.restaurantName,
    this.orderId,
    this.orderItems,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _restaurantRating = 0;
  int _deliveryRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Order'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurantName,
                          style: AppTextStyles.subheading1,
                        ),
                        Text(
                          'How would you rate your experience?',
                          style: AppTextStyles.bodySmallWithColor(
                            AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Restaurant Rating
            Text(
              'Rate Restaurant',
              style: AppTextStyles.subheading2,
            ),
            const SizedBox(height: 12),
            _StarRating(
              rating: _restaurantRating,
              onRatingChanged: (rating) {
                setState(() => _restaurantRating = rating);
              },
            ),
            const SizedBox(height: 24),
            // Comment
            Text(
              'Add a comment (optional)',
              style: AppTextStyles.subheading2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us about your experience...',
                hintStyle: AppTextStyles.bodyMediumWithColor(
                  AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              style: AppTextStyles.bodyMedium,
            ),
            if (widget.orderItems != null) ...[
              const SizedBox(height: 24),
              Text(
                'Order Items',
                style: AppTextStyles.subheading2,
              ),
              const SizedBox(height: 12),
              ...widget.orderItems!.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${item['quantity']} x ${item['name']}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const Spacer(),
                        Text(
                          item['price'] ?? '',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 24),
            // Delivery Rating (if applicable)
            Text(
              'Rate Delivery',
              style: AppTextStyles.subheading2,
            ),
            const SizedBox(height: 12),
            _StarRating(
              rating: _deliveryRating,
              onRatingChanged: (rating) {
                setState(() => _deliveryRating = rating);
              },
            ),
            const SizedBox(height: 32),
            // Submit Button
            CleanButton(
              label: 'Submit',
              icon: Icons.check,
              onPressed: _restaurantRating > 0
                  ? () {
                      // TODO: Submit rating
                      Navigator.pop(context);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;

  const _StarRating({
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingChanged(index + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: index < rating
                  ? AppColors.warning
                  : AppColors.textTertiary,
              size: 40,
            ),
          ),
        );
      }),
    );
  }
}

