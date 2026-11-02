import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../widgets/ui.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int index = 0;
  static const titles = [
    'Find Your\nDream Job',
    'Submit Job\nApplication',
    'Build Career\n& Hire Staff',
  ];
  static const captions = [
    'Stable Yourself\nWith Your Abilities',
    'Get Free Access\nTo Millions Of Jobs',
    'Find Work Fast\nAnd Build Your Career',
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: SizedBox(
            height: constraints.maxHeight < 760 ? 760 : constraints.maxHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 68, 32, 56),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          titles[index],
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(
                          3,
                          (i) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Semantics(
                              label: 'Onboarding ${i + 1}',
                              selected: i == index,
                              child: InkWell(
                                onTap: () => setState(() => index = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: i == index ? 30 : 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: i == index
                                        ? Palette.blue
                                        : const Color(0xFFDDDFE1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: AssetImageView(
                        'onboarding-${index + 1}',
                        key: ValueKey(index),
                        width: 350,
                        height: 348,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    captions[index],
                    textAlign: TextAlign.center,
                    style: heading(context, 24).copyWith(height: 1.65),
                  ),
                  const SizedBox(height: 46),
                  SizedBox(
                    width: 94,
                    height: 94,
                    child: OutlinedButton(
                      key: const ValueKey('onboarding-next'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: .7),
                        ),
                      ),
                      onPressed: () async {
                        if (index < 2) {
                          setState(() => index++);
                          return;
                        }
                        await AppScope.of(context).completeOnboarding();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.signup = false});
  final bool signup;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(),
      password = TextEditingController(),
      username = TextEditingController(),
      confirm = TextEditingController();
  bool checked = false;
  bool get ready =>
      email.text.isNotEmpty &&
      password.text.isNotEmpty &&
      (!widget.signup ||
          (username.text.isNotEmpty && confirm.text.isNotEmpty && checked));
  @override
  void dispose() {
    for (final c in [email, password, username, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    final state = AppScope.of(context);
    await state.signIn(
      userName: widget.signup ? username.text : null,
      userEmail: email.text,
      remember: widget.signup || checked,
    );
    if (!mounted) return;
    if (widget.signup) {
      Navigator.of(context).pushReplacementNamed('/phone');
    } else {
      goHome(context);
    }
  }

  Future<void> social(String provider) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Try Job Finder', style: heading(sheetContext)),
            const SizedBox(height: 16),
            Text(
              '$provider sign-in is not connected in this preview. Explore the app with the demo account.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              'Continue with demo account',
              onPressed: () async {
                await AppScope.of(context).signIn();
                if (!mounted) return;
                if (sheetContext.mounted) Navigator.pop(sheetContext);
                goHome(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(32, widget.signup ? 68 : 130, 32, 24),
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.signup ? 'Welcome' : 'Welcome Back',
                  style: heading(context, 28),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      widget.signup
                          ? 'Create your account or '
                          : 'Don’t have an account? ',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      widget.signup ? '/login' : '/signup',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        widget.signup ? 'Log In' : 'Sign Up',
                        style: const TextStyle(
                          color: Palette.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final item in [
                    (const Color(0xFF100C3E), 'Apple', ''),
                    (const Color(0xFFFF343E), 'Google', 'G+'),
                    (const Color(0xFF3C5C99), 'Facebook', 'f'),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          onPressed: () => social(item.$2),
                          tooltip: 'Sign in with ${item.$2}',
                          style: IconButton.styleFrom(
                            backgroundColor: item.$1,
                            foregroundColor: Colors.white,
                          ),
                          icon: item.$2 == 'Apple'
                              ? const Icon(Icons.apple, size: 27)
                              : Text(
                                  item.$3,
                                  style: TextStyle(
                                    fontSize: item.$3 == 'f' ? 27 : 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: widget.signup ? 54 : 68),
              if (widget.signup)
                FormFieldView(
                  'Username',
                  controller: username,
                  hint: 'Enter a username',
                  validator: requiredText,
                  onChanged: (_) => setState(() {}),
                ),
              FormFieldView(
                'Email',
                controller: email,
                hint: 'Enter your email address',
                keyboard: TextInputType.emailAddress,
                validator: emailValidator,
                onChanged: (_) => setState(() {}),
              ),
              FormFieldView(
                'Password',
                controller: password,
                hint: 'Password',
                password: true,
                validator: passwordValidator,
                onChanged: (_) => setState(() {}),
              ),
              if (widget.signup)
                FormFieldView(
                  'Confirm Password',
                  controller: confirm,
                  hint: 'Confirm your password',
                  password: true,
                  validator: (v) => v != password.text
                      ? 'Passwords must match'
                      : passwordValidator(v),
                  onChanged: (_) => setState(() {}),
                ),
              Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 28,
                    child: Checkbox(
                      value: checked,
                      activeColor: Palette.blue,
                      side: const BorderSide(color: Palette.muted),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (v) => setState(() => checked = v!),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => checked = !checked),
                      child: Text(
                        widget.signup
                            ? 'I agree to the terms and conditions'
                            : 'Remember me',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Palette.muted,
                        ),
                      ),
                    ),
                  ),
                  if (!widget.signup)
                    InkWell(
                      onTap: () => openPage(context, '/forgot'),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Forgot password',
                          style: TextStyle(color: Palette.blue, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: BottomAction(
      child: PrimaryButton(
        widget.signup ? 'Sign Up' : 'Log In',
        onPressed: ready ? submit : null,
      ),
    ),
  );
}

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key, required this.mode});
  final String mode;
  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(),
      password = TextEditingController(),
      confirm = TextEditingController(),
      phone = TextEditingController();
  final codes = List.generate(4, (_) => TextEditingController());
  final nodes = List.generate(4, (_) => FocusNode());
  Timer? timer;
  int seconds = 95;
  String? error;
  String get title => switch (widget.mode) {
    'forgot' => 'Forget Password',
    'otp' => 'OTP Verification',
    'reset' => 'Reset Password',
    _ => 'Phone Number',
  };
  @override
  void initState() {
    super.initState();
    if (widget.mode == 'otp') {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (seconds > 0 && mounted) setState(() => seconds--);
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    for (final c in [email, password, confirm, phone, ...codes]) {
      c.dispose();
    }
    for (final node in nodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();
    if (!form.currentState!.validate()) return;
    switch (widget.mode) {
      case 'forgot':
        openPage(context, '/otp');
        message(context, 'Preview verification code: 7900');
      case 'otp':
        if (seconds == 0) {
          setState(() => error = 'Code expired. Please resend.');
          return;
        }
        if (codes.map((c) => c.text).join() != '7900') {
          setState(() => error = 'Enter the preview code 7900');
          return;
        }
        openPage(context, '/reset');
      case 'reset':
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        message(
          context,
          'Password reset preview complete. You can log in now.',
        );
      default:
        final state = AppScope.of(context);
        await state.updateProfile(state.name, state.email, phone.text);
        if (mounted) goHome(context);
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: title,
    bottom: PrimaryButton('Continue', onPressed: submit),
    child: Form(
      key: form,
      child: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              widget.mode == 'phone' ? 'Add Number' : title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontSize: 24),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              switch (widget.mode) {
                'forgot' => 'You can change your password for security reasons or reset it if you forget it.',
                'otp' =>
                  'We sent OTP verification to your email. This code will expire in\n${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}',
                'reset' => 'You can reset your password now, enter a new password and secure your account.',
                _ => 'Adding a phone number to your account is a great step toward a better experience.',
              },
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Palette.muted,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 64),
          if (widget.mode == 'forgot')
            FormFieldView(
              'Email',
              controller: email,
              hint: 'Enter your email address',
              keyboard: TextInputType.emailAddress,
              validator: emailValidator,
            ),
          if (widget.mode == 'reset') ...[
            FormFieldView(
              'Password',
              controller: password,
              password: true,
              hint: 'New password',
              validator: passwordValidator,
            ),
            FormFieldView(
              'Confirm Password',
              controller: confirm,
              password: true,
              hint: 'Confirm password',
              validator: (v) => v != password.text
                  ? 'Passwords must match'
                  : passwordValidator(v),
            ),
          ],
          if (widget.mode == 'otp') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (i) => SizedBox(
                  width: 60,
                  child: TextField(
                    key: ValueKey('otp-$i'),
                    controller: codes[i],
                    focusNode: nodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: '-',
                      counterText: '',
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 3) nodes[i + 1].requestFocus();
                      if (v.isEmpty && i > 0) nodes[i - 1].requestFocus();
                    },
                  ),
                ),
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            if (seconds == 0)
              TextButton(
                onPressed: () {
                  setState(() {
                    seconds = 95;
                    error = null;
                    for (final c in codes) {
                      c.clear();
                    }
                  });
                  message(context, 'Preview verification code: 7900');
                },
                child: const Text('Resend code'),
              ),
          ],
          if (widget.mode == 'phone')
            FormFieldView(
              'Phone Number',
              controller: phone,
              hint: '+1 150-9658-1538',
              keyboard: TextInputType.phone,
              suffix: const Icon(
                Icons.verified_rounded,
                color: Palette.blue,
                size: 20,
              ),
              validator: (v) =>
                  (v ?? '').replaceAll(RegExp(r'\D'), '').length < 7
                  ? 'Enter a valid phone number'
                  : null,
            ),
        ],
      ),
    ),
  );
}
