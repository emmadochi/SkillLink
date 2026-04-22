import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_button.dart';
import '../../../../shared/widgets/skilllink_input.dart';
import '../../../../shared/widgets/skilllink_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink_app/features/booking/presentation/providers/booking_provider.dart';
import 'package:skilllink_app/features/artisan/presentation/providers/artisan_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String artisanId;
  const BookingScreen({super.key, required this.artisanId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _descCtrl = TextEditingController();
  String _selectedService = '';
  int _step = 0; // 0: service, 1: date/time, 2: confirm
  bool _isLoading = false;

  static const _services = [
    'Wiring & Installation',
    'Fault Diagnosis & Repair',
    'Panel Installation',
    'CCTV Setup',
    'Solar Panel Setup',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Book Service',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontFamily: 'PlusJakartaSans',
                )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _step > 0 ? setState(() => _step--) : context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(children: List.generate(3, (i) {
              return Expanded(
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: i <= _step ? AppColors.primary : AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: i < _step
                          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                          : Text('${i + 1}',
                              style: AppTypography.labelSm.copyWith(
                                  color: i == _step ? Colors.white : AppColors.outline)),
                    ),
                  ),
                  if (i < 2)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 2,
                        color: i < _step ? AppColors.primary : AppColors.surfaceContainerHighest,
                      ),
                    ),
                ]),
              );
            })),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _step == 0
                  ? _ServiceStep(
                      services: _services,
                      selected: _selectedService,
                      onSelect: (s) => setState(() => _selectedService = s),
                    )
                  : _step == 1
                      ? _DateTimeStep(
                          selectedDate: _selectedDate,
                          selectedTime: _selectedTime,
                          descCtrl: _descCtrl,
                          onDatePick: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 60)),
                              builder: (c, child) => Theme(
                                data: Theme.of(c).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primary,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (d != null) setState(() => _selectedDate = d);
                          },
                          onTimePick: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(hour: 9, minute: 0),
                            );
                            if (t != null) setState(() => _selectedTime = t);
                          },
                        )
                      : _ConfirmStep(
                          artisanId: widget.artisanId,
                          service: _selectedService,
                          date: _selectedDate,
                          time: _selectedTime,
                          desc: _descCtrl.text,
                        ),
            ),
          ),

          // Bottom CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SkillLinkButton.gradient(
              label: _step < 2 ? 'Continue' : 'Confirm Booking',
              isLoading: _isLoading,
              onPressed: _canProceed()
                  ? () async {
                      if (_step < 2) {
                        setState(() => _step++);
                      } else {
                        setState(() => _isLoading = true);
                        try {
                          final repo = ref.read(bookingRepositoryProvider);
                          await repo.createBooking({
                            'artisan_id': widget.artisanId,
                            'service_description': '$_selectedService: ${_descCtrl.text}',
                            'booking_date': _selectedDate!.toIso8601String().split('T')[0],
                            'booking_time': '${_selectedTime!.hour}:${_selectedTime!.minute}',
                          });
                          if (mounted) {
                            context.go(AppRoutes.bookingConfirmation);
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    if (_step == 0) return _selectedService.isNotEmpty;
    if (_step == 1) return _selectedDate != null && _selectedTime != null;
    return true;
  }
}

class _ServiceStep extends StatelessWidget {
  final List<String> services;
  final String selected;
  final ValueChanged<String> onSelect;

  const _ServiceStep({
    required this.services,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select a Service', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text('What do you need help with?',
            style: AppTypography.bodyMd.copyWith(color: AppColors.outline)),
        const SizedBox(height: 24),
        ...services.map((s) {
          final sel = selected == s;
          return GestureDetector(
            onTap: () => onSelect(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary.withOpacity(0.06) : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: sel
                    ? Border.all(color: AppColors.primary.withOpacity(0.40))
                    : null,
              ),
              child: Row(children: [
                Icon(Icons.bolt_outlined,
                    color: sel ? AppColors.primary : AppColors.outline),
                const SizedBox(width: 14),
                Expanded(child: Text(s, style: Theme.of(context).textTheme.titleSmall)),
                if (sel)
                  const Icon(Icons.radio_button_checked,
                      color: AppColors.primary, size: 20)
                else
                  const Icon(Icons.radio_button_off_outlined,
                      color: AppColors.outlineVariant, size: 20),
              ]),
            ),
          );
        }),
      ],
    );
  }
}

class _DateTimeStep extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final TextEditingController descCtrl;
  final VoidCallback onDatePick;
  final VoidCallback onTimePick;

  const _DateTimeStep({
    required this.selectedDate,
    required this.selectedTime,
    required this.descCtrl,
    required this.onDatePick,
    required this.onTimePick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Schedule', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text('Pick a date and time that works for you.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.outline)),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: onDatePick,
          child: SkillLinkCard(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
              const SizedBox(width: 14),
              Text(
                selectedDate != null
                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                    : 'Select Date',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selectedDate != null ? AppColors.onSurface : AppColors.outline,
                    ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTimePick,
          child: SkillLinkCard(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              const Icon(Icons.access_time_rounded, color: AppColors.primary),
              const SizedBox(width: 14),
              Text(
                selectedTime != null
                    ? selectedTime!.format(context)
                    : 'Select Time',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selectedTime != null ? AppColors.onSurface : AppColors.outline,
                    ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        SkillLinkInput(
          label: 'Describe the Problem',
          hint: 'E.g. My main power socket is faulty...',
          controller: descCtrl,
          maxLines: 4,
        ),
      ],
    );
  }
}

class _ConfirmStep extends ConsumerWidget {
  final String artisanId;
  final String service;
  final DateTime? date;
  final TimeOfDay? time;
  final String desc;

  const _ConfirmStep({
    required this.artisanId,
    required this.service,
    this.date,
    this.time,
    required this.desc,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artisanAsync = ref.watch(artisanProfileProvider(int.parse(artisanId)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm Booking', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text('Review your booking details.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.outline)),
        const SizedBox(height: 28),
        SkillLinkCard(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            _ConfirmRow(
                label: 'Artisan',
                value: artisanAsync.when(
                  data: (a) => a.user?.name ?? 'Artisan',
                  loading: () => 'Loading...',
                  error: (_, __) => 'Error',
                )),
            _ConfirmRow(label: 'Service', value: service),
            if (date != null)
              _ConfirmRow(label: 'Date', value: '${date!.day}/${date!.month}/${date!.year}'),
            if (time != null)
              _ConfirmRow(label: 'Time', value: time!.format(context)),
            _ConfirmRow(label: 'Rate', value: '₦5,000/hr'),
          ]),
        ),
        const SizedBox(height: 16),
        SkillLinkCard(
          backgroundColor: AppColors.tertiaryFixed.withOpacity(0.30),
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded,
                color: AppColors.onTertiaryFixed, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'Payment will be collected after service completion.',
              style: AppTypography.bodySm.copyWith(
                  color: AppColors.onTertiaryFixed),
            )),
          ]),
        ),
      ],
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ]),
    );
  }
}
