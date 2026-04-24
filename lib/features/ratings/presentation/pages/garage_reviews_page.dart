import 'package:flutter/material.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/error/user_friendly_errors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../data/datasources/garage_ratings_remote_datasource.dart';
import '../../data/models/garage_rating_model.dart';

class GarageReviewsPage extends StatefulWidget {
  const GarageReviewsPage({super.key});

  @override
  State<GarageReviewsPage> createState() => _GarageReviewsPageState();
}

class _GarageReviewsPageState extends State<GarageReviewsPage> {
  bool _loading = true;
  String? _error;
  double _averageRating = 0;
  int _totalRatings = 0;
  List<GarageRatingModel> _ratings = const [];

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await sl<GarageRatingsRemoteDataSource>().getMyReviews();
      if (!mounted) return;
      setState(() {
        _averageRating = result.averageRating;
        _totalRatings = result.totalRatings;
        _ratings = result.reviews;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = toUserFriendlyMessage(e.toString());
        _loading = false;
      });
    }
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return 'Unknown date';
    final local = dt.toLocal();
    final month = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][local.month - 1];
    return '$month ${local.day}, ${local.year}';
  }

  Widget _buildStars(double rating, {double size = 18}) {
    final rounded = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rounded ? Icons.star_rounded : Icons.star_border_rounded,
          color: i < rounded ? AppColors.primary : AppColors.textSecondary,
          size: size,
        );
      }),
    );
  }

  String _initials(String? name) {
    final value = (name ?? '').trim();
    if (value.isEmpty) return 'C';
    final parts = value.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Future<void> _openReviewDetail(GarageRatingModel detail) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.driverName ?? 'Customer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildStars(detail.rating),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  detail.comment?.trim().isNotEmpty == true
                      ? detail.comment!
                      : 'No written review provided.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Reviewed: ${_fmtDate(detail.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (detail.appointmentScheduledAt != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Appointment: ${_fmtDate(detail.appointmentScheduledAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Reviews & Ratings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: _loadRatings,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _ratings.isEmpty
                  ? Center(
                      child: Text(
                        'No reviews yet',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRatings,
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _averageRating.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _buildStars(_averageRating),
                                const Spacer(),
                                Text(
                                  '$_totalRatings review${_totalRatings == 1 ? '' : 's'}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Material(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _ratings.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final review = _ratings[i];
                                final displayName = review.driverName ?? 'Customer';
                                return InkWell(
                                  onTap: () => _openReviewDetail(review),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: AppColors.textPrimary,
                                          child: Text(
                                            _initials(displayName),
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      displayName,
                                                      style: AppTextStyles.bodyMedium.copyWith(
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: AppSpacing.sm),
                                                  _buildStars(review.rating, size: 15),
                                                ],
                                              ),
                                              const SizedBox(height: AppSpacing.xs),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      review.comment?.trim().isNotEmpty == true
                                                          ? review.comment!
                                                          : 'No comment',
                                                      style: AppTextStyles.bodySmall.copyWith(
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: AppSpacing.sm),
                                                  Text(
                                                    _fmtDate(review.createdAt),
                                                    style: AppTextStyles.bodySmall.copyWith(
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
