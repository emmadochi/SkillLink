import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/skilllink_card.dart';

class ArtisanDashboardScreen extends StatefulWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  State<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends State<ArtisanDashboardScreen> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 24,
                right: 24,
                bottom: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Artisan Dashboard',
                              style: AppTypography.headlineSm.copyWith(
                                  color: Colors.white)),
                          Text('Emmanuel Okafor',
                              style: AppTypography.bodyMd.copyWith(
                                  color: Colors.white70)),
                        ],
                      ),
                    ),
                    // Availability toggle
                    Column(
                      children: [
                        Text(_isAvailable ? 'Available' : 'Offline',
                            style: AppTypography.labelSm.copyWith(
                                color: Colors.white70)),
                        const SizedBox(height: 4),
                        Switch(
                          value: _isAvailable,
                          onChanged: (v) => setState(() => _isAvailable = v),
                          activeColor: Colors.green.shade400,
                          trackColor: WidgetStateProperty.all(
                              Colors.white.withOpacity(0.20)),
                        ),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Row(children: [
                    _DashStat(value: '₦48k', label: 'This\nMonth'),
                    _DashStat(value: '23', label: 'Completed\nJobs'),
                    _DashStat(value: '4.9', label: 'Avg\nRating'),
                  ]),
                ],
              ),
            ),
          ),

          // Job requests
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(children: [
                Text('New Job Requests',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryFixed,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('3',
                      style: AppTypography.labelSm.copyWith(
                          color: AppColors.onTertiaryFixed,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: SkillLinkCard(
                  elevated: true,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/60?img=${i + 20}'),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer ${i + 1}',
                                style: Theme.of(context).textTheme.titleSmall),
                            Text('Electrical Wiring',
                                style: Theme.of(context).textTheme.labelMedium),
                          ],
                        ),
                        const Spacer(),
                        Text('₦5,000/hr',
                            style: AppTypography.titleSm.copyWith(
                                color: AppColors.primary)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.outline),
                        const SizedBox(width: 4),
                        Text('${ i + 2} km away • Victoria Island',
                            style: Theme.of(context).textTheme.labelMedium),
                        const Spacer(),
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: AppColors.outline),
                        const SizedBox(width: 4),
                        Text('Tomorrow, 10AM',
                            style: Theme.of(context).textTheme.labelMedium),
                      ]),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.outline),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text('Decline',
                                style: AppTypography.labelLg.copyWith(
                                    color: AppColors.outline)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text('Accept',
                                style: AppTypography.labelLg.copyWith(
                                    color: Colors.white)),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              childCount: 3,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _DashStat extends StatelessWidget {
  final String value;
  final String label;
  const _DashStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value, style: AppTypography.headlineSm.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center,
                style: AppTypography.labelSm.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
