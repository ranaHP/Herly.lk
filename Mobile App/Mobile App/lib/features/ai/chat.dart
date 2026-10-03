import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/repositories.dart';
import '../../core/settings.dart';
import '../../core/strings.dart';
import '../../core/widgets.dart';
import '../home/home_style.dart';
import '../shared/reference_ui.dart';

const demoQuestion =
    'I’ve been feeling more tired than usual this week. Any ideas why?';
const demoAnswer =
    'I’m sorry to hear you’re feeling more tired 💜\n\nEnergy can change for many reasons. Recording how you feel alongside your cycle can help you notice patterns. This sample conversation cannot determine the cause.\n\nHere are a few gentle things that may help:\n\n💧  Stay hydrated\n🌿  Try light movement like a short walk\n🌙  Get a little extra rest\n💗  Include iron-rich foods in your meals\n\nEveryone’s experience is different. If your fatigue feels severe or continues, speak with a doctor.';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatState();
}

class _ChatState extends ConsumerState<ChatScreen> {
  final input = TextEditingController();
  final scroll = ScrollController();
  bool typing = false;
  int suggestionOffset = 0;
  final Map<int, bool> feedback = {};
  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  void toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (scroll.hasClients) {
      scroll.animateTo(
        scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });
  Future<void> send([String? prompt]) async {
    final text = (prompt ?? input.text).trim();
    if (text.isEmpty || typing) return;
    input.clear();
    setState(() => typing = true);
    toBottom();
    await ref
        .read(chatProvider.notifier)
        .send(text, localizable: prompt != null);
    if (mounted) {
      setState(() => typing = false);
      toBottom();
    }
  }

  void history() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const ReferenceLabel('Conversation history', size: 20, bold: true),
          const SizedBox(height: 16),
          for (final m in ref.read(chatProvider))
            ListTile(
              leading: Icon(m.user ? Icons.person_outline : Icons.auto_awesome),
              title: Text(
                m.user && !m.localizable ? m.text : context.tr(m.text),
              ),
            ),
          if (ref.read(chatProvider).length < 2)
            const ReferenceLabel('Your conversations will appear here.'),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final name = ref.watch(profileProvider)['name']!.split(' ').first;
    final roomy =
        MediaQuery.textScalerOf(context).scale(1) > 1.3 ||
        MediaQuery.sizeOf(context).width < 360;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ReferenceBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    child: Row(
                      children: [
                        ReferenceButton(
                          Icons.chevron_left,
                          'Back to Home',
                          () => context.go('/home'),
                        ),
                        const SizedBox(width: 5),
                        SvgPicture.asset(
                          'assets/brand/symbol.svg',
                          width: 43,
                          height: 43,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Herly AI',
                                style: HomeStyle.type(
                                  context,
                                  25,
                                  color: HomeStyle.accent(context),
                                  weight: FontWeight.w800,
                                ),
                              ),
                              const ReferenceLabel(
                                'Your private wellbeing companion',
                                size: 8.5,
                              ),
                            ],
                          ),
                        ),
                        ReferenceButton(
                          Icons.history,
                          'Conversation history',
                          history,
                        ),
                        const SizedBox(width: 5),
                        ReferenceButton(
                          Icons.more_horiz,
                          'Chat settings',
                          () => context.push('/more/privacy'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scroll,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      children: [
                        _intro(name),
                        const SizedBox(height: 7),
                        LayoutBuilder(
                          builder: (context, c) => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final item in [
                                ('chat', 'Ask anything'),
                                ('steps', 'Get personalized insights'),
                                ('self-care', 'Practical tips & guidance'),
                                ('shield', 'Safe & private space'),
                              ])
                                SizedBox(
                                  width:
                                      (c.maxWidth - (roomy ? 8 : 24)) /
                                      (roomy ? 2 : 4),
                                  child: HomePanel(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    onTap: () => item.$1 == 'shield'
                                        ? context.push('/more/privacy')
                                        : send(
                                            item.$1 == 'steps'
                                                ? 'Explain my recent pattern'
                                                : 'Tips for better sleep',
                                          ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        HomeArt(item.$1, size: 25),
                                        const SizedBox(height: 7),
                                        ReferenceLabel(item.$2, size: 10),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        HomePanel(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          onTap: () => context.push('/more/privacy'),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 17,
                                color: HomeStyle.accent(context),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: ReferenceLabel(
                                  'Your conversations stay on this device. Demo replies.',
                                  size: 10,
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 17),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _bubble(demoQuestion, true, -1, sample: true),
                        _bubble(demoAnswer, false, -2),
                        for (final pair in messages.indexed)
                          if (pair.$1 > 0)
                            _bubble(
                              pair.$2.text,
                              pair.$2.user,
                              pair.$1,
                              sample: pair.$2.localizable,
                            ),
                        if (typing)
                          const Padding(
                            padding: EdgeInsets.all(14),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                ReferenceLabel('Herly is typing…'),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Expanded(
                              child: ReferenceLabel(
                                'You might also like to ask:',
                                size: 12,
                              ),
                            ),
                            IconButton(
                              tooltip: context.tr('More suggestions'),
                              onPressed: () => setState(
                                () => suggestionOffset =
                                    (suggestionOffset + 1) % 3,
                              ),
                              icon: Icon(
                                Icons.refresh,
                                color: HomeStyle.accent(context),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final q
                                in ([
                                  (
                                    'self-care',
                                    'How can I improve my sleep?',
                                    'Tips for better sleep',
                                  ),
                                  (
                                    'nutrition',
                                    'What foods boost my energy?',
                                    'Nutrition and energy',
                                  ),
                                  (
                                    'calendar',
                                    'Is my period coming soon?',
                                    'Explain my recent pattern',
                                  ),
                                ]..sort(
                                  (a, b) =>
                                      (([
                                                    'self-care',
                                                    'nutrition',
                                                    'calendar',
                                                  ].indexOf(a.$1) +
                                                  suggestionOffset) %
                                              3)
                                          .compareTo(
                                            ([
                                                      'self-care',
                                                      'nutrition',
                                                      'calendar',
                                                    ].indexOf(b.$1) +
                                                    suggestionOffset) %
                                                3,
                                          ),
                                )))
                              SizedBox(
                                width: roomy
                                    ? double.infinity
                                    : (MediaQuery.sizeOf(context).width
                                                  .clamp(0, 620) -
                                              48) /
                                          3,
                                child: HomePanel(
                                  padding: const EdgeInsets.all(10),
                                  onTap: typing ? null : () => send(q.$3),
                                  child: Row(
                                    children: [
                                      HomeArt(q.$1, size: 21),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: ReferenceLabel(q.$2, size: 9),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    decoration: BoxDecoration(
                      color: HomeStyle.dark(context)
                          ? const Color(0xFF302136)
                          : Colors.white.withValues(alpha: .75),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: [
                        ReferenceButton(
                          Icons.attach_file,
                          'Attachments (demo)',
                          () => notify(
                            context,
                            'Attachments are a demo placeholder.',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: input,
                            minLines: 1,
                            maxLines: 4,
                            onSubmitted: (_) => send(),
                            style: HomeStyle.type(context, 12),
                            decoration: InputDecoration(
                              hintText: context.tr('Ask Herly anything…'),
                              filled: true,
                              fillColor: HomeStyle.dark(context)
                                  ? const Color(0xFF3A2942)
                                  : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              suffixIcon: IconButton(
                                tooltip: context.tr('Voice (demo)'),
                                onPressed: () => notify(
                                  context,
                                  'Voice input is a demo placeholder.',
                                ),
                                icon: const Icon(Icons.mic_none, size: 21),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton.filled(
                            tooltip: context.tr('Send message'),
                            style: IconButton.styleFrom(
                              backgroundColor: HomeStyle.accent(context),
                            ),
                            onPressed: typing ? null : send,
                            icon: const Icon(Icons.arrow_forward, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _intro(String name) => HomeEntrance(
    child: LayoutBuilder(
      builder: (context, constraints) => HomePanel(
        padding: EdgeInsets.zero,
        gradient: LinearGradient(
          colors: HomeStyle.dark(context)
              ? [const Color(0xFF39243C), const Color(0xFF532847)]
              : [Colors.white, const Color(0xFFFFDCEE)],
        ),
        child: Stack(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 145),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
                child: SizedBox(
                  width: constraints.maxWidth * .52,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReferenceLabel(
                        '${context.tr('Hi')} $name',
                        size: 23,
                        bold: true,
                        color: HomeStyle.dark(context)
                            ? const Color(0xFFF2A8E5)
                            : const Color(0xFF6E2977),
                      ),
                      const SizedBox(height: 5),
                      const ReferenceLabel(
                        'I’m Herly AI, here to listen, answer your questions and support you on your journey.',
                        size: 11,
                        muted: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -9,
              top: 0,
              bottom: -8,
              width: constraints.maxWidth * .43,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/home/home-robot.png',
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _sampleBody() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final line in demoAnswer.split('\n'))
        if (line.isEmpty)
          const SizedBox(height: 10)
        else if (['💧', '🌿', '🌙', '💗'].any(line.startsWith))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeArt(
                  line.startsWith('💧')
                      ? 'water'
                      : line.startsWith('🌿')
                      ? 'exercise'
                      : line.startsWith('🌙')
                      ? 'sleep'
                      : 'heart',
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context
                        .tr(line)
                        .replaceAll(RegExp('[💧🌿🌙💗]'), '')
                        .trim(),
                    style: HomeStyle.type(context, 12.5, height: 1.42),
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            context.tr(line).replaceAll('💜', ''),
            style: HomeStyle.type(context, 12.5, height: 1.42),
          ),
    ],
  );
  Widget _bubble(String text, bool user, int id, {bool sample = false}) {
    final body = user && !sample ? text : context.tr(text);
    final avatar = ClipOval(
      child: Image.asset(
        'assets/home/${user ? 'home-avatar' : 'home-robot'}.png',
        width: 39,
        height: 39,
        fit: BoxFit.cover,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!user) ...[
            avatar,
            const SizedBox(width: 8),
          ] else
            const SizedBox(width: 72),
          Expanded(
            child: Column(
              crossAxisAlignment: user
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: user
                        ? const LinearGradient(
                            colors: [Color(0xFFFF68AB), Color(0xFFFF3296)],
                          )
                        : null,
                    color: user
                        ? null
                        : (HomeStyle.dark(context)
                              ? const Color(0xFF392B40)
                              : Colors.white.withValues(alpha: .86)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .55),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: HomeStyle.pink.withValues(alpha: .04),
                        blurRadius: 15,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: id == -2
                      ? _sampleBody()
                      : Text(
                          body,
                          style: HomeStyle.type(
                            context,
                            12.5,
                            height: 1.42,
                            color: user ? Colors.white : null,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                ReferenceLabel(
                  id < 0
                      ? 'Sample conversation'
                      : (user ? 'Sent' : 'Demo response'),
                  size: 8,
                  muted: true,
                ),
                if (!user)
                  Row(
                    children: [
                      for (final item in [
                        (Icons.thumb_up_outlined, 'Helpful', true),
                        (Icons.thumb_down_outlined, 'Not helpful', false),
                      ])
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: context.tr(item.$2),
                          color: feedback[id] == item.$3
                              ? HomeStyle.pink
                              : HomeStyle.text(context),
                          onPressed: () =>
                              setState(() => feedback[id] = item.$3),
                          icon: Icon(item.$1, size: 17),
                        ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: context.tr('Copy response'),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: body));
                          notify(context, 'Response copied.');
                        },
                        icon: const Icon(Icons.copy_outlined, size: 17),
                      ),
                      if (text.startsWith('SAFETY:'))
                        IconButton(
                          tooltip: context.tr('Open support resources'),
                          onPressed: () => context.push('/more/safety'),
                          icon: const Icon(Icons.support_agent, size: 18),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          if (user) ...[
            const SizedBox(width: 6),
            avatar,
          ] else
            const SizedBox(width: 35),
        ],
      ),
    );
  }
}
