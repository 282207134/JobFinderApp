import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/jobs.dart';
import '../../widgets/ui.dart';

class JobDetailPage extends StatefulWidget {
  const JobDetailPage({super.key, required this.job});
  final Job job;
  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  int tab = 0;
  bool expanded = false;
  Future<void> apply() async {
    final state = AppScope.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apply for this job', style: heading(sheetContext, 24)),
              const SizedBox(height: 16),
              Text(
                widget.job.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Your demo application will be saved for ${state.name}. No information is sent to an employer.',
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                'Confirm Application',
                onPressed: () async {
                  await state.apply(widget.job.id);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                  if (mounted) {
                    message(
                      context,
                      'Application saved. View it in My Account.',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final state = AppScope.of(context);
    return PageFrame(
      title: 'Jobs',
      trailing: IconButton(
        key: const ValueKey('save-job'),
        tooltip: state.saved.contains(job.id) ? 'Unsave job' : 'Save job',
        onPressed: () => state.toggleSaved(job.id),
        icon: Icon(
          state.saved.contains(job.id)
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          color: Palette.blue,
        ),
      ),
      bottom: PrimaryButton(
        state.applied.contains(job.id) ? 'Applied' : 'Apply',
        onPressed: state.applied.contains(job.id) ? null : apply,
      ),
      child: ListView(
        children: [
          AssetImageView(
            'job-hero',
            width: double.infinity,
            height: 200,
            radius: 24,
          ),
          const SizedBox(height: 28),
          Text(
            job.title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontSize: 20),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 20),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  job.location,
                  style: const TextStyle(fontSize: 12, color: Palette.muted),
                ),
              ),
              Rating(job.rating),
            ],
          ),
          const SizedBox(height: 22),
          Rate(job.rate, size: 24),
          const SizedBox(height: 28),
          Surface(
            radius: 16,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Expanded(
                    child: TextButton(
                      key: ValueKey('job-tab-$i'),
                      style: TextButton.styleFrom(
                        foregroundColor: tab == i
                            ? Theme.of(context).colorScheme.onSurface
                            : Palette.muted,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      onPressed: () => setState(() => tab = i),
                      child: Text(
                        ['Description', 'Map', 'Review'][i],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (tab == 0) ...[
            Text(
              'The Project Manager is primarily focused on supporting operational scalability, critical in driving business operational and technology projects, while shaping and building scalable and sustainable processes in support of Visible’s growth. You will partner with cross-functional teams to deliver meaningful results.',
              maxLines: expanded ? null : 6,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, height: 1.7),
            ),
            TextButton(
              onPressed: () => setState(() => expanded = !expanded),
              child: Text(expanded ? 'Read less' : 'Read more'),
            ),
            if (expanded) ...[
              Text('What you’ll bring', style: heading(context, 18)),
              const SizedBox(height: 12),
              const Text(
                'Strong communication and project planning skills.\nExperience working with collaborative teams.\nA thoughtful, practical approach to solving problems.',
                style: TextStyle(height: 1.8),
              ),
            ],
          ],
          if (tab == 1) ...[
            SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: const MapView(compact: true),
              ),
            ),
            TextButton.icon(
              onPressed: () => openPage(context, '/map'),
              icon: const Icon(Icons.open_in_full, size: 16),
              label: const Text('View full map'),
            ),
          ],
          if (tab == 2)
            Surface(
              radius: 22,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AssetImageView(
                        'avatar',
                        width: 36,
                        height: 36,
                        radius: 18,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Grayson Leo', style: TextStyle(fontSize: 14)),
                            Text(
                              '1 June',
                              style: TextStyle(
                                fontSize: 10,
                                color: Palette.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '★★★★★',
                        style: TextStyle(
                          color: Palette.blue,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'A supportive team and a thoughtful hiring process. The work offers a great opportunity to develop practical skills and take ownership of meaningful projects.',
                    maxLines: expanded ? null : 3,
                    overflow: expanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, height: 1.6),
                  ),
                  TextButton(
                    onPressed: () => setState(() => expanded = !expanded),
                    child: Text(expanded ? 'Read less' : 'Read more'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Map',
    padding: false,
    trailing: InkWell(
      onTap: () => openPage(context, '/profile'),
      child: const AssetImageView('avatar', width: 50, height: 50, radius: 16),
    ),
    child: const MapView(),
  );
}

class MapView extends StatefulWidget {
  const MapView({super.key, this.compact = false});
  final bool compact;
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final transform = TransformationController();
  @override
  void dispose() {
    transform.dispose();
    super.dispose();
  }

  void zoom(double factor) {
    final current = transform.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(1.0, 4.0);
    transform.value = Matrix4.diagonal3Values(next, next, 1);
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: InteractiveViewer(
          transformationController: transform,
          minScale: 1,
          maxScale: 4,
          child: ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.compact)
                  const AssetImageView('map', fit: BoxFit.cover),
                CustomPaint(painter: _RoutePainter()),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        right: widget.compact ? 8 : 32,
        bottom: widget.compact ? 8 : 32,
        child: Column(
          children: [
            SquareButton(
              icon: Icons.add,
              onTap: () => zoom(1.3),
              label: 'Zoom in',
              size: widget.compact ? 36 : 50,
            ),
            const SizedBox(height: 8),
            SquareButton(
              icon: Icons.remove,
              onTap: () => zoom(1 / 1.3),
              label: 'Zoom out',
              size: widget.compact ? 36 : 50,
            ),
            const SizedBox(height: 8),
            SquareButton(
              icon: Icons.my_location_rounded,
              onTap: () => transform.value = Matrix4.identity(),
              label: 'Recenter map',
              size: widget.compact ? 36 : 50,
            ),
          ],
        ),
      ),
    ],
  );
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Palette.blue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final start = Offset(size.width * .42, size.height * .68);
    final end = Offset(size.width * .46, size.height * .25);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..relativeLineTo(0, -size.height * .08)
      ..relativeLineTo(size.width * .14, 0)
      ..relativeLineTo(0, -size.height * .08)
      ..relativeLineTo(size.width * .13, 0)
      ..relativeLineTo(0, -size.height * .08)
      ..relativeLineTo(-size.width * .12, 0)
      ..lineTo(size.width * .57, end.dy - 15)
      ..lineTo(end.dx, end.dy - 15)
      ..lineTo(end.dx, end.dy);
    canvas.drawPath(path, paint);
    for (final point in [start, end]) {
      canvas.drawCircle(
        point,
        13,
        Paint()..color = Palette.blue.withValues(alpha: .15),
      );
      canvas.drawCircle(point, 5, Paint()..color = Palette.blue);
    }
    canvas.drawPath(
      Path()
        ..moveTo(size.width * .56, size.height * .53 - 8)
        ..relativeLineTo(-7, 14)
        ..relativeLineTo(7, -4)
        ..relativeLineTo(7, 4)
        ..close(),
      Paint()..color = Palette.blue,
    );
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) => false;
}
