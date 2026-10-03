import '../../core/strings.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings.dart';
import '../../core/widgets.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});
  @override
  ConsumerState<RemindersScreen> createState() => _RemindersState();
}

class _RemindersState extends ConsumerState<RemindersScreen> {
  List<Map<String, dynamic>> items = [];
  @override
  void initState() {
    super.initState();
    final raw = ref.read(preferencesProvider).getString('reminders');
    items = raw == null
        ? [
            {
              'name': 'A moment for water',
              'time': '10:00',
              'enabled': true,
              'repeat': 'Daily',
            },
            {
              'name': 'Evening wind-down',
              'time': '21:30',
              'enabled': true,
              'repeat': 'Daily',
            },
            {
              'name': 'Vitamins',
              'time': '08:00',
              'enabled': false,
              'repeat': 'Weekdays',
            },
          ]
        : List<Map<String, dynamic>>.from(
            (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
          );
  }

  Future<void> save() async {
    await ref
        .read(preferencesProvider)
        .setString('reminders', jsonEncode(items));
    if (mounted) setState(() {});
  }

  Future<void> edit([int? index]) async {
    final title = TextEditingController(
      text: index == null ? '' : items[index]['name'],
    );
    String repeat = index == null ? 'Daily' : items[index]['repeat'];
    TimeOfDay time = const TimeOfDay(hour: 9, minute: 0);
    if (index != null) {
      final parts = (items[index]['time'] as String).split(':');
      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          title: LText(index == null ? 'A gentle reminder' : 'Edit reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: InputDecoration(labelText: 'Name')
                    .localized(context),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.schedule),
                label: LText(time.format(context)),
                onPressed: () async {
                  final chosen = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (chosen != null) refresh(() => time = chosen);
                },
              ),
              DropdownButton<String>(
                value: repeat,
                isExpanded: true,
                items: ['Daily', 'Weekdays', 'Weekly']
                    .map((v) => DropdownMenuItem(value: v, child: LText(v)))
                    .toList(),
                onChanged: (v) => refresh(() => repeat = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const LText('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (title.text.trim().isNotEmpty) Navigator.pop(context, true);
              },
              child: const LText('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      final item = {
        'name': title.text.trim(),
        'time':
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        'repeat': repeat,
        'enabled': true,
      };
      if (index == null) {
        items.add(item);
      } else {
        items[index] = item;
      }
      await save();
    }
    title.dispose();
  }

  @override
  Widget build(BuildContext context) => HerlyPage(
    title: 'Reminders',
    subtitle: 'Small nudges, on your terms. Scheduling is a demo; no notifications are sent.',
    children: [
      for (var i = 0; i < items.length; i++)
        HerlyCard(
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: LText(items[i]['name']),
                subtitle: LText('${items[i]['time']} · ${items[i]['repeat']}'),
                value: items[i]['enabled'],
                onChanged: (v) {
                  items[i]['enabled'] = v;
                  save();
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => edit(i),
                    child: const LText('Edit'),
                  ),
                  IconButton(
                    tooltip: context.tr('Delete reminder'),
                    onPressed: () {
                      items.removeAt(i);
                      save();
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      HerlyButton('Add a reminder', icon: Icons.add, onPressed: () => edit()),
    ],
  );
}
