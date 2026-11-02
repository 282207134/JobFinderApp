import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/jobs.dart';
import '../../widgets/ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Home',
    home: true,
    navIndex: 0,
    padding: false,
    trailing: InkWell(
      onTap: () => openPage(context, '/profile'),
      child: const AssetImageView('avatar', width: 54, height: 54, radius: 18),
    ),
    child: ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SearchBox(
            onTap: () => openPage(context, '/search'),
            onFilter: () => openPage(context, '/filter'),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SectionTitle(
            'Recommended',
            onViewAll: () => openPage(context, '/popular'),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 256,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 24),
            itemBuilder: (_, i) => JobCard(jobs[i], featured: true),
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SectionTitle(
            'Recently Posted',
            onViewAll: () => openPage(context, '/popular'),
          ),
        ),
        const SizedBox(height: 18),
        for (final job in [jobs[2], jobs[8], jobs[3]])
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
            child: JobCard(job),
          ),
      ],
    ),
  );
}

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.initialQuery = '',
    this.initialFilter = const JobFilter(),
  });
  final String initialQuery;
  final JobFilter initialFilter;
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final query = TextEditingController(text: widget.initialQuery);
  late JobFilter filter = widget.initialFilter;
  String sort = 'New';
  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  Future<void> editFilter() async {
    final result = await Navigator.pushNamed(
      context,
      '/filter',
      arguments: filter,
    );
    if (result is JobFilter && mounted) setState(() => filter = result);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hasQuery =
        query.text.isNotEmpty ||
        filter.category != null ||
        filter.location != null ||
        filter.type != null ||
        filter.min != 0 ||
        filter.max != 150;
    final results = hasQuery
        ? findJobs(query.text, filter: filter, sort: sort)
        : [jobs[3], jobs[4], jobs[5]];
    return PageFrame(
      title: 'Search',
      navIndex: 0,
      child: Column(
        children: [
          SearchBox(
            controller: query,
            onChanged: (_) => setState(() {}),
            onSubmitted: state.rememberSearch,
            onFilter: editFilter,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                if (!hasQuery) ...[
                  SectionTitle('Recently Search'),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final text
                            in (state.recent.isEmpty
                                ? ['Engineering', 'Real Estate', 'Accounting']
                                : state.recent))
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surface,
                                foregroundColor: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                setState(() => query.text = text);
                                state.rememberSearch(text);
                              },
                              child: Text(
                                text,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ] else ...[
                  ChoiceRow(
                    values: const ['New', 'Top', 'All'],
                    selected: sort,
                    onSelected: (v) => setState(() => sort = v),
                  ),
                  const SizedBox(height: 28),
                ],
                SectionTitle(
                  hasQuery ? 'Search Result' : 'Popular Jobs',
                  onViewAll: () => openPage(context, '/popular'),
                ),
                const SizedBox(height: 20),
                if (results.isEmpty)
                  EmptyState(
                    'No jobs found',
                    'Try another keyword or adjust your filters.',
                    action: PrimaryButton(
                      'Clear filters',
                      onPressed: () => setState(() {
                        query.clear();
                        filter = const JobFilter();
                      }),
                    ),
                  ),
                for (final job in results)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: JobCard(job),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChoiceRow extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.values,
    this.selected,
    required this.onSelected,
  });
  final List<String> values;
  final String? selected;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < values.length; i++) ...[
        if (i > 0) const SizedBox(width: 14),
        Expanded(
          child: TextButton(
            onPressed: () => onSelected(values[i]),
            style: TextButton.styleFrom(
              backgroundColor: values[i] == selected
                  ? Palette.blue
                  : Theme.of(context).colorScheme.surface,
              foregroundColor: values[i] == selected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(values[i], style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
    ],
  );
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool all = false;
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = categories
        .where((c) => c.name.toLowerCase().contains(search.text.toLowerCase()))
        .take(all ? 6 : 4)
        .toList();
    return PageFrame(
      title: 'Category',
      navIndex: 0,
      child: Column(
        children: [
          if (!all) ...[
            SearchBox(
              controller: search,
              onChanged: (_) => setState(() {}),
              onFilter: () => openPage(context, '/filter'),
            ),
            const SizedBox(height: 32),
          ],
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                mainAxisExtent: 196,
              ),
              itemBuilder: (context, i) {
                final category = items[i];
                return InkWell(
                  key: ValueKey('category-${category.name}'),
                  borderRadius: BorderRadius.circular(24),
                  onTap: () =>
                      openPage(context, '/search', arguments: category.name),
                  child: Surface(
                    padding: const EdgeInsets.all(12),
                    radius: 24,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AssetImageView(
                          category.image,
                          width: 78,
                          height: 78,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${category.count}+ Jobs',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Palette.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (!all)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PrimaryButton(
                'Show All',
                onPressed: () => setState(() => all = true),
              ),
            ),
        ],
      ),
    );
  }
}

class JobListPage extends StatelessWidget {
  const JobListPage({super.key, this.saved = false, this.applied = false});
  final bool saved, applied;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = saved
        ? jobs.where((j) => state.saved.contains(j.id)).toList()
        : applied
        ? jobs.where((j) => state.applied.contains(j.id)).toList()
        : [jobs[3], jobs[4], jobs[2], jobs[5], jobs[0], jobs[8]];
    return PageFrame(
      title: saved
          ? 'Saved Jobs'
          : applied
          ? 'My Applications'
          : 'Popular Jobs',
      navIndex: saved ? 1 : 0,
      child: ListView(
        children: [
          if (items.isEmpty)
            EmptyState(
              saved ? 'Your next opportunity awaits' : 'No applications yet',
              saved
                  ? 'Save a job from its details to find it here.'
                  : 'Explore jobs and apply when you find the right fit.',
              icon: saved
                  ? Icons.bookmark_border_rounded
                  : Icons.work_outline_rounded,
              action: PrimaryButton(
                'Explore jobs',
                onPressed: () => goHome(context),
              ),
            ),
          for (final job in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: JobCard(job, removable: saved),
            ),
        ],
      ),
    );
  }
}

class FilterPage extends StatefulWidget {
  const FilterPage({super.key, this.initial = const JobFilter()});
  final JobFilter initial;
  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late String? category = widget.initial.category,
      location = widget.initial.location,
      type = widget.initial.type;
  late RangeValues range = RangeValues(widget.initial.min, widget.initial.max);
  bool get active =>
      category != null ||
      location != null ||
      type != null ||
      range.start != 0 ||
      range.end != 150;
  Widget dropdown(
    String label,
    String hint,
    List<String> items,
    String? value,
    ValueChanged<String?> changed,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: heading(context, 18)),
      const SizedBox(height: 20),
      DropdownButtonFormField<String>(
        key: ValueKey('filter-$label-$value'),
        initialValue: value,
        isExpanded: true,
        hint: Text(
          hint,
          style: const TextStyle(color: Palette.muted, fontSize: 14),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Palette.muted,
        ),
        items: items
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(s, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: changed,
      ),
      const SizedBox(height: 32),
    ],
  );
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Filter',
    trailing: active
        ? IconButton(
            tooltip: 'Reset filters',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () => setState(() {
              category = null;
              location = null;
              type = null;
              range = const RangeValues(0, 150);
            }),
          )
        : null,
    bottom: PrimaryButton(
      'Apply Filter',
      onPressed: active
          ? () {
              final result = JobFilter(
                category: category,
                location: location,
                min: range.start,
                max: range.end,
                type: type,
              );
              // A search caller consumes the result; direct entry opens filtered results.
              final previous = ModalRoute.of(context)?.settings.arguments;
              if (previous is JobFilter) {
                Navigator.of(context).pop(result);
              } else {
                Navigator.of(context)
                    .pushReplacementNamed('/search', arguments: result);
              }
            }
          : null,
    ),
    child: ListView(
      children: [
        dropdown(
          'Category',
          'Select a category',
          [
            'Business Management',
            ...categories.map((c) => c.name),
            'Engineering',
          ],
          category,
          (v) => setState(() => category = v),
        ),
        dropdown(
          'Location',
          'Select location',
          ['New York, NY 10003', 'San Francisco, CA', 'Remote'],
          location,
          (v) => setState(() => location = v),
        ),
        Text('Price', style: heading(context, 18)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Surface(
                radius: 14,
                padding: const EdgeInsets.all(20),
                child: Text('\$${range.start.toStringAsFixed(2)}'),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Surface(
                radius: 14,
                padding: const EdgeInsets.all(20),
                child: Text('\$${range.end.toStringAsFixed(2)}'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        RangeSlider(
          values: range,
          min: 0,
          max: 150,
          divisions: 30,
          labels: RangeLabels(
            '\$${range.start.round()}',
            '\$${range.end.round()}',
          ),
          onChanged: (v) => setState(() => range = v),
        ),
        const SizedBox(height: 30),
        Text('Job Type', style: heading(context, 18)),
        const SizedBox(height: 20),
        ChoiceRow(
          values: const ['Full Time', 'Part Time', 'Contract'],
          selected: type,
          onSelected: (v) => setState(() => type = type == v ? null : v),
        ),
        const SizedBox(height: 24),
      ],
    ),
  );
}
