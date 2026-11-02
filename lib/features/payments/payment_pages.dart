import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../widgets/ui.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});
  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cards = [
      ('Master Card', '3197', 'master'),
      ('Visa Master', '7863', 'visa'),
      ('PayPal', '8961', 'paypal'),
      ('American Express', '9716', 'amex'),
      if (state.cardLast4 != null) ('My Card', state.cardLast4!, 'master'),
    ];
    return PageFrame(
      title: 'Payment Methods',
      trailing: IconButton(
        tooltip: 'Add card',
        onPressed: () => openPage(context, '/card'),
        icon: const Icon(Icons.add, color: Palette.blue),
      ),
      bottom: PrimaryButton(
        'Payment',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Payment preview'),
            content: Text(
              'Selected: ${cards[selected].$1} ending in ${cards[selected].$2}.\nNo payment is charged in this preview.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(c);
                  openPage(context, '/card');
                },
                child: const Text('Add card'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
      child: ListView(
        children: [
          for (var i = 0; i < cards.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: InkWell(
                key: ValueKey('payment-$i'),
                onTap: () => setState(() => selected = i),
                borderRadius: BorderRadius.circular(24),
                child: Surface(
                  radius: 24,
                  child: Row(
                    children: [
                      Icon(
                        selected == i
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selected == i ? Palette.blue : Palette.muted,
                        size: 21,
                      ),
                      const SizedBox(width: 18),
                      SizedBox(width: 46, child: PaymentLogo(cards[i].$3)),
                      const SizedBox(width: 22),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cards[i].$1,
                              style: const TextStyle(fontSize: 17),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'xxxx - xxxx - xxxx - ${cards[i].$2}',
                              style: const TextStyle(
                                color: Palette.muted,
                                fontSize: 11,
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
        ],
      ),
    );
  }
}

class PaymentLogo extends StatelessWidget {
  const PaymentLogo(this.type, {super.key});
  final String type;
  @override
  Widget build(BuildContext context) {
    if (type == 'master') {
      return SizedBox(
        width: 42,
        height: 28,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 2,
              child: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3939),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 2,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB51C).withValues(alpha: .9),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Text(
      switch (type) {
        'visa' => 'VISA',
        'paypal' => 'P',
        _ => 'AMEX',
      },
      style: TextStyle(
        color: type == 'paypal'
            ? const Color(0xFF0077BF)
            : const Color(0xFF161944),
        fontSize: type == 'paypal' ? 30 : 13,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

bool validCardNumber(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 13 || digits.length > 19) return false;
  int sum = 0;
  bool doubleDigit = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    int digit = int.parse(digits[i]);
    if (doubleDigit) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
    doubleDigit = !doubleDigit;
  }
  return sum % 10 == 0;
}

String? expiryValidator(String? value) {
  final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(value ?? '');
  if (match == null) return 'Use MM/YY';
  final month = int.parse(match[1]!), year = 2000 + int.parse(match[2]!);
  final now = DateTime.now();
  return month < 1 ||
          month > 12 ||
          year < now.year ||
          (year == now.year && month < now.month)
      ? 'Enter a future date'
      : null;
}

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});
  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      number = TextEditingController(),
      expiry = TextEditingController(),
      cvc = TextEditingController();
  bool get ready => [name, number, expiry, cvc].every((c) => c.text.isNotEmpty);
  @override
  void dispose() {
    for (final c in [name, number, expiry, cvc]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Card Details',
    bottom: PrimaryButton(
      'Add Now',
      onPressed: ready
          ? () async {
              if (!form.currentState!.validate()) return;
              final digits = number.text.replaceAll(RegExp(r'\D'), '');
              await AppScope.of(context)
                  .addCard(digits.substring(digits.length - 4));
              if (!context.mounted) return;
              Navigator.pop(context);
              message(
                context,
                'Demo card added. Only the last four digits are saved.',
              );
            }
          : null,
    ),
    child: Form(
      key: form,
      child: ListView(
        children: [
          Container(
            height: 236,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF71CDF4),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const PaymentLogo('master'),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Text(
                      'USD  ',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      '000.00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '****  ****  ****  ${number.text.length < 4 ? '****' : number.text.substring(number.text.length - 4)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name.text.isEmpty ? 'Name Of Card' : name.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Exp. Date',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                        Text(
                          expiry.text.isEmpty ? '00/00' : expiry.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FormFieldView(
            'Cardholder Name',
            controller: name,
            validator: requiredText,
            onChanged: (_) => setState(() {}),
          ),
          FormFieldView(
            'Card No',
            controller: number,
            keyboard: TextInputType.number,
            maxLength: 19,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            suffix: const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(width: 42, child: PaymentLogo('master')),
            ),
            validator: (v) =>
                validCardNumber(v ?? '') ? null : 'Enter a valid card number',
            onChanged: (_) => setState(() {}),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormFieldView(
                  'Expire Date',
                  controller: expiry,
                  hint: 'MM/YY',
                  keyboard: TextInputType.datetime,
                  maxLength: 5,
                  validator: expiryValidator,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: FormFieldView(
                  'CVC',
                  controller: cvc,
                  password: true,
                  keyboard: TextInputType.number,
                  maxLength: 4,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => RegExp(r'^\d{3,4}$').hasMatch(v ?? '')
                      ? null
                      : 'Use 3–4 digits',
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
