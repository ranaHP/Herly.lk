import '../../core/strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/repositories.dart';
import '../../core/widgets.dart';

Future<void> openTracker(
  BuildContext context,
  String category, {
  DateTime? date,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => TrackerSheet(category: category, date: date),
);

class TrackerSheet extends ConsumerStatefulWidget {
  final String category;
  final DateTime? date;
  const TrackerSheet({super.key, required this.category, this.date});
  @override
  ConsumerState<TrackerSheet> createState() => _TrackerState();
}

class _TrackerState extends ConsumerState<TrackerSheet> {
  final notes = TextEditingController();
  final number = TextEditingController();
  final symptoms = <String>{};
  String? selected;
  bool saving = false;
  String? error;
  late DateTime date;
  @override
  void initState() {
    super.initState();
    date = widget.date ?? dateOnly(DateTime.now());
    final previous = ref
        .read(trackingProvider)
        .where(
          (e) =>
              e.category == widget.category &&
              dateOnly(e.date) == dateOnly(date),
        );
    if (previous.isNotEmpty) {
      final e = previous.last;
      selected = e.value;
      number.text = e.value;
      notes.text = e.notes;
      symptoms.addAll(e.symptoms);
    }
  }

  @override
  void dispose() {
    notes.dispose();
    number.dispose();
    super.dispose();
  }

  List<String> get options => switch (widget.category) {
    'Period' => ['Light', 'Medium', 'Heavy', 'Spotting'],
    'Mood' => ['Great', 'Good', 'Okay', 'Low', 'Anxious'],
    'Energy' => ['High', 'Steady', 'Low'],
    'Skin' => ['Clear', 'Dry', 'Oily', 'Sensitive'],
    'Symptoms' => DemoContent.symptoms,
    _ => [],
  };
  bool get numeric => [
    'Water',
    'Sleep',
    'Weight',
    'Exercise',
    'Steps',
  ].contains(widget.category);
  String get unit => switch (widget.category) {
    'Water' => 'glasses (0–30)',
    'Sleep' => 'hours (0–24)',
    'Weight' => 'kg (1–500)',
    'Exercise' => 'minutes (0–1440)',
    'Steps' => 'steps (0–100000)',
    _ => 'Entry',
  };
  Future<void> save() async {
    final value = numeric
        ? number.text.trim()
        : (options.isEmpty ? notes.text.trim() : selected ?? '');
    if (value.isEmpty) {
      setState(() => error = 'Add an entry before saving.');
      return;
    }
    if (numeric) {
      final n = double.tryParse(value);
      final max = switch (widget.category) {
        'Water' => 30,
        'Sleep' => 24,
        'Weight' => 500,
        'Steps' => 100000,
        _ => 1440,
      };
      if (n == null ||
          n < 0 ||
          n > max ||
          (widget.category == 'Weight' && n == 0)) {
        setState(() => error = 'Enter a valid number of $unit.');
        return;
      }
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await ref
          .read(trackingProvider.notifier)
          .save(
            TrackingEntry(
              category: widget.category,
              value: value,
              date: date,
              notes: notes.text.trim(),
              symptoms: symptoms.toList(),
            ),
          );
      if (mounted) {
        Navigator.pop(context);
        notify(
          context,
          '${widget.category} saved. A little more in tune with you.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'Could not save. Please try again.';
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: DraggableScrollableSheet(
      expand: false,
      initialChildSize: .85,
      minChildSize: .5,
      maxChildSize: .95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: LText(
                  'Log ${widget.category}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                tooltip: context.tr('Close tracker'),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => date = d);
            },
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: LText(
              DateFormat.yMMMMEEEEd(
                Localizations.localeOf(context).languageCode,
              ).format(date),
            ),
          ),
          const SizedBox(height: 24),
          if (options.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options
                  .map(
                    (option) => ChoiceChip(
                      label: LText(option),
                      selected: selected == option,
                      onSelected: (_) => setState(() => selected = option),
                    ),
                  )
                  .toList(),
            ),
          if (numeric)
            TextField(
              controller: number,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: unit).localized(context),
            ),
          if (widget.category == 'Period') ...[
            const SizedBox(height: 24),
            const Section('Symptoms'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DemoContent.symptoms
                  .map(
                    (s) => FilterChip(
                      label: LText(s),
                      selected: symptoms.contains(s),
                      onSelected: (v) => setState(() {
                        v ? symptoms.add(s) : symptoms.remove(s);
                      }),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          TextField(
            controller: notes,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: options.isEmpty && !numeric
                  ? 'Your entry'
                  : 'Notes (optional)',
              hintText: 'A little space for how you feel…',
            ).localized(context),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: LText(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 28),
          HerlyButton(
            'Save',
            busy: saving,
            onPressed: save,
            icon: Icons.check_rounded,
          ),
        ],
      ),
    ),
  );
}
