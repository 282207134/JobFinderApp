import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../widgets/ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final parts = state.name.split(' ');
    return PageFrame(
      title: 'Profile',
      child: ListView(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: AssetImageView(
              'profile',
              width: 120,
              height: 120,
              radius: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            parts.first,
            style: heading(context, 30).copyWith(fontWeight: FontWeight.w700),
          ),
          if (parts.length > 1)
            Text(
              parts.skip(1).join(' '),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
            ),
          const SizedBox(height: 44),
          AccountRow(
            'My Account',
            Icons.person_rounded,
            onTap: () => openPage(context, '/account'),
          ),
          AccountRow(
            'Notification',
            Icons.notifications_rounded,
            onTap: () => openPage(context, '/notifications'),
          ),
          AccountRow(
            'Settings',
            Icons.settings_rounded,
            onTap: () => openPage(context, '/settings'),
          ),
          AccountRow(
            'Help',
            Icons.groups_rounded,
            onTap: () => openPage(context, '/help'),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: softColor(context),
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                await state.signOut();
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (_) => false);
                }
              },
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Sign out'),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class AccountRow extends StatelessWidget {
  const AccountRow(
    this.label,
    this.icon, {
    super.key,
    this.onTap,
    this.trailing,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 32),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: softColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 24),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ),
          if (trailing != null)
            trailing!
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: softColor(context),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.chevron_right_rounded, size: 20),
            ),
        ],
      ),
    ),
  );
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      phone = TextEditingController();
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    final state = AppScope.of(context);
    name.text = state.name;
    email.text = state.email;
    phone.text = state.phone;
    initialized = true;
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'My Account',
    bottom: PrimaryButton(
      'Save Changes',
      onPressed: () async {
        if (!form.currentState!.validate()) return;
        await AppScope.of(context)
            .updateProfile(name.text, email.text, phone.text);
        if (context.mounted) {
          FocusScope.of(context).unfocus();
          message(context, 'Your profile has been saved.');
        }
      },
    ),
    child: Form(
      key: form,
      child: ListView(
        children: [
          const Center(
            child: AssetImageView(
              'profile',
              width: 100,
              height: 100,
              radius: 50,
            ),
          ),
          const SizedBox(height: 32),
          FormFieldView('Full Name', controller: name, validator: requiredText),
          FormFieldView(
            'Email',
            controller: email,
            keyboard: TextInputType.emailAddress,
            validator: emailValidator,
          ),
          FormFieldView(
            'Phone Number',
            controller: phone,
            keyboard: TextInputType.phone,
            hint: 'Add your phone number',
          ),
          AccountRow(
            'My Applications',
            Icons.work_rounded,
            onTap: () => openPage(context, '/applications'),
          ),
          AccountRow(
            'Payment Methods',
            Icons.credit_card_rounded,
            onTap: () => openPage(context, '/payments'),
          ),
        ],
      ),
    ),
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PageFrame(
      title: 'Settings',
      child: ListView(
        children: [
          const SizedBox(height: 10),
          Text('Other Account', style: heading(context, 24)),
          const SizedBox(height: 36),
          InkWell(
            onTap: () => showDialog<void>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Other account'),
                content: const Text(
                  'Rose Alleyson is a sample account from the design. Manage your current profile in My Account.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            child: Row(
              children: [
                const AssetImageView('rose', width: 70, height: 70, radius: 35),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rose Alleyson',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Manage Account',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text('Settings', style: heading(context, 24)),
          const SizedBox(height: 30),
          AccountRow(
            'Dark Mode',
            Icons.dark_mode_rounded,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.dark ? 'On' : 'Off',
                  style: const TextStyle(fontSize: 12, color: Palette.muted),
                ),
                const SizedBox(width: 8),
                Switch(
                  key: const ValueKey('dark-switch'),
                  value: state.dark,
                  activeThumbColor: Colors.white,
                  activeTrackColor: Palette.blue,
                  onChanged: state.setDark,
                ),
              ],
            ),
          ),
          AccountRow(
            'Language',
            Icons.language_rounded,
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('English', style: TextStyle(fontSize: 12)),
                SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
            onTap: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (c) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ListTile(
                    title: const Text('English'),
                    trailing: const Icon(Icons.check, color: Palette.blue),
                    onTap: () => Navigator.pop(c),
                  ),
                ),
              ),
            ),
          ),
          AccountRow(
            'Notification',
            Icons.notifications_rounded,
            trailing: Switch(
              key: const ValueKey('notification-switch'),
              value: state.notifications,
              activeThumbColor: Colors.white,
              activeTrackColor: Palette.blue,
              onChanged: state.setNotifications,
            ),
          ),
          AccountRow(
            'Earning',
            Icons.savings_rounded,
            onTap: () => openPage(context, '/activity'),
          ),
          AccountRow(
            'About App',
            Icons.info_rounded,
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Job Finder',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(
                Icons.work_rounded,
                color: Palette.blue,
                size: 42,
              ),
              children: [
                const Text(
                  'Find your next opportunity. A Flutter UI preview based on the Job Finder Pixso design.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  static const notices = [
    ('Good News', 'You got a new offer', '1m ago', 'notice-offer'),
    ('Steve Case', 'You are hired', '7m ago', 'notice-hired'),
    ('New Job', 'Go to news feed', '9m ago', 'notice-job'),
    ('Password Change', 'Warning!', '14m ago', 'notice-password'),
    ('Job Finished', 'Congratulations', '19m ago', 'notice-done'),
  ];
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PageFrame(
      title: 'Notification',
      navIndex: 2,
      child: ListView(
        children: [
          for (var i = 0; i < notices.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () async {
                  await state.readNotice(i);
                  if (!context.mounted) return;
                  showDialog<void>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text(notices[i].$1),
                      content: Text(
                        '${notices[i].$2}.\nThis is a sample notification from your Job Finder preview.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('Close'),
                        ),
                        if (i == 2)
                          TextButton(
                            onPressed: () {
                              Navigator.pop(c);
                              openPage(context, '/popular');
                            },
                            child: const Text('View jobs'),
                          ),
                      ],
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(24),
                child: Surface(
                  radius: 24,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AssetImageView(
                        notices[i].$4,
                        width: 46,
                        height: 46,
                        radius: 12,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notices[i].$1,
                              style: TextStyle(
                                fontSize: 17,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontWeight: state.readNotices.contains(i)
                                    ? FontWeight.w400
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notices[i].$2,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Palette.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        notices[i].$3,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Palette.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});
  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String period = '25 Jul';
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Activity',
    child: ListView(
      children: [
        Surface(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text('Earning', style: heading(context, 18))),
                  DropdownButton<String>(
                    value: period,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Palette.slate,
                      fontSize: 12,
                    ),
                    items: ['25 Jul', '18 Jul', '11 Jul']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => period = v!),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 340,
                child: CustomPaint(
                  painter: _EarningsPainter(
                    color:
                        Theme.of(context).textTheme.bodyMedium?.color ??
                        Palette.slate,
                    alternate: period != '25 Jul',
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Surface(
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monthly', style: TextStyle(fontSize: 18)),
                  Text('10% Increase', style: TextStyle(color: Palette.muted)),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    16,
                    (i) => Container(
                      width: 10,
                      height: [
                        20.0,
                        95.0,
                        25.0,
                        40.0,
                        110.0,
                        35.0,
                        75.0,
                        45.0,
                      ][i % 8],
                      decoration: BoxDecoration(
                        color: i % 3 == 1
                            ? Palette.blue
                            : Palette.blue.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '5 Jul',
                    style: TextStyle(fontSize: 12, color: Palette.muted),
                  ),
                  Text(
                    '10 Jul',
                    style: TextStyle(fontSize: 12, color: Palette.muted),
                  ),
                  Text(
                    '15 Jul',
                    style: TextStyle(fontSize: 12, color: Palette.muted),
                  ),
                  Text(
                    '20 Jul',
                    style: TextStyle(fontSize: 12, color: Palette.muted),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    ),
  );
}

class _EarningsPainter extends CustomPainter {
  _EarningsPainter({required this.color, required this.alternate});
  final Color color;
  final bool alternate;
  void label(
    Canvas canvas,
    String text,
    Offset position, {
    Color? ink,
    double size = 10,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: size,
          color: ink ?? Palette.muted,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width - 44, h = size.height - 38;
    for (var i = 0; i < 5; i++) {
      label(canvas, '${50 - i * 10}k', Offset(0, h * i / 4));
    }
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    for (var i = 0; i < 7; i++) {
      label(canvas, days[i], Offset(40 + w * i / 7, h + 20), size: 9);
    }
    final path = Path()
      ..moveTo(40, h * .08)
      ..cubicTo(95, -15, 85, h * .55, 130, h * .34)
      ..cubicTo(180, h * .08, 170, h * .8, 194, h * .6)
      ..cubicTo(222, h * .4, 210, h * 1.15, 236, h * .84)
      ..cubicTo(252, h * .45, w + 26, h * .2, w + 40, alternate ? h * .3 : 0);
    final fill = Path.from(path)
      ..lineTo(w + 40, h)
      ..lineTo(40, h)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Palette.blue.withValues(alpha: .85),
            Palette.blue.withValues(alpha: .01),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Palette.blue
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .4, 6, 90, 38),
      const Radius.circular(5),
    );
    canvas.drawRRect(rect, Paint()..color = Palette.blue);
    label(
      canvas,
      alternate ? r'$3180.00' : r'$4092.00',
      Offset(size.width * .4 + 10, 17),
      ink: Colors.white,
      size: 12,
    );
  }

  @override
  bool shouldRepaint(_EarningsPainter oldDelegate) =>
      oldDelegate.alternate != alternate || oldDelegate.color != color;
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Help',
    child: ListView(
      children: [
        Text('How can we help?', style: heading(context, 24)),
        const SizedBox(height: 24),
        for (final faq in [
          (
            'How do I find a job?',
            'Use Search or browse a category. Filter by location, hourly rate and job type.',
          ),
          (
            'How do I save a job?',
            'Open a job and tap the bookmark at the top. Your saved jobs are available in Save.',
          ),
          (
            'Where are my applications?',
            'Open My Account, then My Applications to see the jobs you have applied for.',
          ),
          (
            'Is this a live recruitment service?',
            'This is an offline UI preview. Jobs, earnings, verification and payment flows use sample data. No applications or payments are sent.',
          ),
        ])
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(faq.$1, style: const TextStyle(fontSize: 16)),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(faq.$2, style: const TextStyle(height: 1.7)),
              ),
            ],
          ),
      ],
    ),
  );
}
