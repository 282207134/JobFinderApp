import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../data/app_state.dart';
import '../data/jobs.dart';

void openPage(BuildContext context, String route, {Object? arguments}) =>
    Navigator.of(context).pushNamed(route, arguments: arguments);
void goHome(BuildContext context) =>
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
void message(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));
TextStyle heading(BuildContext context, [double size = 22]) => TextStyle(
  fontSize: size,
  fontWeight: FontWeight.w600,
  color: Theme.of(context).colorScheme.onSurface,
);
Color softColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF292E3A)
    : Palette.field;

class AssetImageView extends StatelessWidget {
  const AssetImageView(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.radius = 0,
    this.fit = BoxFit.cover,
  });
  final String name;
  final double? width, height;
  final double radius;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/images/$name.png',
      width: width,
      height: height,
      fit: fit,
    ),
  );
}

class SquareButton extends StatelessWidget {
  const SquareButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
    this.blue = false,
    this.size = 54,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final bool blue;
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: IconButton(
      tooltip: label,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: blue ? Palette.blue : softColor(context),
        foregroundColor: blue
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      icon: Icon(icon, size: 26),
    ),
  );
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.title,
    required this.child,
    this.bottom,
    this.navIndex,
    this.home = false,
    this.trailing,
    this.padding = true,
  });
  final String title;
  final Widget child;
  final Widget? bottom, trailing;
  final int? navIndex;
  final bool home, padding;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              32,
              MediaQuery.sizeOf(context).height < 750 ? 28 : 68,
              32,
              40,
            ),
            child: Row(
              children: [
                SquareButton(
                  icon: home
                      ? Icons.grid_view_rounded
                      : Icons.arrow_left_rounded,
                  label: home ? 'Categories' : 'Back',
                  onTap: () => home
                      ? openPage(context, '/categories')
                      : Navigator.of(context).canPop()
                      ? Navigator.of(context).pop()
                      : goHome(context),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    title,
                    style: heading(context, title.length > 14 ? 22 : 24),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: padding
                  ? const EdgeInsets.symmetric(horizontal: 32)
                  : EdgeInsets.zero,
              child: child,
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: bottom != null
        ? BottomAction(child: bottom!)
        : navIndex == null
        ? null
        : BottomNav(selected: navIndex!),
  );
}

class BottomAction extends StatelessWidget {
  const BottomAction({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(32, 24, 32, 20),
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: SafeArea(top: false, child: child),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) =>
      FilledButton(onPressed: onPressed, child: Text(label));
}

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.selected});
  final int selected;
  @override
  Widget build(BuildContext context) {
    const entries = [
      (Icons.home_rounded, 'Home', '/home'),
      (Icons.bookmark_rounded, 'Save', '/saved'),
      (Icons.notifications_rounded, 'Notification', '/notifications'),
      (Icons.person_rounded, 'Profile', '/profile'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < entries.length; i++)
              Expanded(
                child: Semantics(
                  selected: i == selected,
                  child: InkWell(
                    key: ValueKey('nav-$i'),
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      if (i == selected) return;
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(entries[i].$3, (_) => false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            entries[i].$1,
                            size: 28,
                            color: i == selected ? Palette.blue : Palette.muted,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entries[i].$2,
                            style: TextStyle(
                              fontSize: 12,
                              color: i == selected
                                  ? Palette.blue
                                  : Palette.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 28,
  });
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .025),
          blurRadius: 48,
          offset: const Offset(0, 16),
        ),
      ],
    ),
    child: child,
  );
}

class FormFieldView extends StatefulWidget {
  const FormFieldView(
    this.label, {
    super.key,
    required this.controller,
    this.hint,
    this.password = false,
    this.keyboard,
    this.validator,
    this.onChanged,
    this.formatters,
    this.suffix,
    this.maxLength,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool password;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? formatters;
  final Widget? suffix;
  final int? maxLength;
  @override
  State<FormFieldView> createState() => _FormFieldViewState();
}

class _FormFieldViewState extends State<FormFieldView> {
  bool obscure = true;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          key: ValueKey('field-${widget.label}'),
          controller: widget.controller,
          onChanged: widget.onChanged,
          validator: widget.validator,
          obscureText: widget.password && obscure,
          keyboardType: widget.keyboard,
          maxLength: widget.maxLength,
          inputFormatters: widget.formatters,
          textInputAction: TextInputAction.next,
          autocorrect: !widget.password,
          enableSuggestions: !widget.password,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '',
            suffixIcon: widget.password
                ? IconButton(
                    tooltip: obscure ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: Palette.muted,
                    ),
                  )
                : widget.suffix,
          ),
        ),
      ],
    ),
  );
}

String? requiredText(String? value) =>
    value == null || value.trim().isEmpty ? 'Please complete this field' : null;
String? emailValidator(String? value) =>
    value == null ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
    ? 'Enter a valid email address'
    : null;
String? passwordValidator(String? value) =>
    (value?.length ?? 0) < 8 ? 'Use at least 8 characters' : null;

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    required this.onFilter,
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged, onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback onFilter;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextField(
          key: const ValueKey('search-field'),
          controller: controller,
          readOnly: onTap != null,
          onTap: onTap,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search',
            fillColor: softColor(context),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(Icons.search_rounded, color: Palette.muted),
            ),
            suffixIcon: controller != null && controller!.text.isNotEmpty
                ? IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      controller!.clear();
                      onChanged?.call('');
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      SquareButton(
        key: const ValueKey('filter-button'),
        icon: Icons.tune_rounded,
        onTap: onFilter,
        label: 'Filter',
        blue: true,
        size: 64,
      ),
    ],
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.onViewAll});
  final String title;
  final VoidCallback? onViewAll;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: heading(context))),
      if (onViewAll != null)
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: Palette.muted,
            padding: EdgeInsets.zero,
            minimumSize: const Size(54, 40),
          ),
          child: const Text(
            'View All',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
    ],
  );
}

class Rating extends StatelessWidget {
  const Rating(this.value, {super.key});
  final double value;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.star_rounded, color: Color(0xFFFFCF19), size: 19),
      const SizedBox(width: 5),
      Text(
        value.toStringAsFixed(1),
        style: const TextStyle(color: Palette.muted, fontSize: 14),
      ),
    ],
  );
}

class Rate extends StatelessWidget {
  const Rate(this.rate, {super.key, this.size = 18});
  final int rate;
  final double size;
  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: '\$$rate.00',
      style: TextStyle(
        color: Palette.blue,
        fontSize: size,
        fontWeight: FontWeight.w600,
      ),
      children: [
        TextSpan(
          text: '/Hour',
          style: TextStyle(fontSize: size - 2, fontWeight: FontWeight.w400),
        ),
      ],
    ),
  );
}

class JobCard extends StatelessWidget {
  const JobCard(
    this.job, {
    super.key,
    this.featured = false,
    this.removable = false,
  });
  final Job job;
  final bool featured, removable;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return InkWell(
      key: ValueKey('job-${job.id}'),
      borderRadius: BorderRadius.circular(32),
      onTap: () => openPage(context, '/job', arguments: job),
      child: Surface(
        radius: featured ? 36 : 28,
        padding: featured
            ? const EdgeInsets.all(24)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: featured
            ? SizedBox(
                width: 192,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AssetImageView(
                      job.image,
                      width: 192,
                      height: 123,
                      radius: 18,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      job.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Rate(job.rate), Rating(job.rating)],
                    ),
                  ],
                ),
              )
            : Row(
                children: [
                  AssetImageView(job.image, width: 84, height: 98, radius: 20),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontSize: 17),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 14,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Rate(job.rate, size: 17),
                            Rating(job.rating),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (removable)
                    IconButton(
                      tooltip: 'Remove saved job',
                      onPressed: () => state.toggleSaved(job.id),
                      icon: const Icon(
                        Icons.bookmark,
                        color: Palette.blue,
                        size: 22,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState(
    this.title,
    this.subtitle, {
    super.key,
    this.icon = Icons.search_off_rounded,
    this.action,
  });
  final String title, subtitle;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 58, color: Palette.blue),
        const SizedBox(height: 24),
        Text(title, style: heading(context, 20), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(subtitle, textAlign: TextAlign.center),
        if (action != null)
          Padding(padding: const EdgeInsets.only(top: 24), child: action),
      ],
    ),
  );
}
