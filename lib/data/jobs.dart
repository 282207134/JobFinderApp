class Job {
  const Job(
    this.id,
    this.title,
    this.image,
    this.rate,
    this.rating,
    this.category,
    this.type, {
    this.location = 'New York, NY 10003',
  });
  final String id, title, image, category, type, location;
  final int rate;
  final double rating;
}

const jobs = [
  Job(
    'marketing',
    'Marketing Manager',
    'marketing',
    45,
    4.9,
    'Business',
    'Part Time',
  ),
  Job(
    'developer',
    'Web Developer',
    'developer',
    78,
    4.8,
    'Design',
    'Full Time',
  ),
  Job(
    'civil',
    'Civil Engineering',
    'civil',
    55,
    4.8,
    'Engineering',
    'Full Time',
  ),
  Job(
    'administrative',
    'Administrative',
    'administrative',
    55,
    5.0,
    'Business',
    'Full Time',
  ),
  Job('sales', 'Sales Engineering', 'sales', 55, 4.9, 'Business', 'Part Time'),
  Job('medical', 'Pharmaceutical', 'medical', 55, 4.8, 'Medical', 'Full Time'),
  Job(
    'coordinator',
    'Account Coordinator',
    'coordinator',
    80,
    5.0,
    'Business',
    'Contract',
  ),
  Job(
    'trainee',
    'Management Trainee',
    'trainee',
    55,
    4.8,
    'Management',
    'Full Time',
  ),
  Job(
    'manager',
    'Business Continuity Project Manager',
    'job-hero',
    45,
    4.8,
    'Business',
    'Part Time',
  ),
  Job('chef', 'Food Service Manager', 'sales', 40, 4.7, 'Food', 'Full Time'),
  Job(
    'teacher',
    'Education Coordinator',
    'administrative',
    48,
    4.9,
    'Education',
    'Part Time',
  ),
];
const categories = [
  (name: 'Business', image: 'business', count: 1800),
  (name: 'Food', image: 'food', count: 1350),
  (name: 'Education', image: 'education', count: 1280),
  (name: 'Management', image: 'management', count: 1750),
  (name: 'Medical', image: 'health', count: 1050),
  (name: 'Design', image: 'design', count: 1980),
];

class JobFilter {
  const JobFilter({
    this.category,
    this.location,
    this.min = 0,
    this.max = 150,
    this.type,
  });
  final String? category, location, type;
  final double min, max;
  bool matches(Job job) =>
      (category == null ||
          category == job.category ||
          (category == 'Business Management' &&
              ['Business', 'Management'].contains(job.category))) &&
      (location == null || location == job.location) &&
      (type == null || type == job.type) &&
      job.rate >= min &&
      job.rate <= max;
}

List<Job> findJobs(
  String query, {
  JobFilter filter = const JobFilter(),
  String sort = 'New',
}) {
  final words = query.toLowerCase().trim();
  final result = jobs.where((job) {
    final haystack = '${job.title} ${job.category} ${job.location}'
        .toLowerCase();
    return (words.isEmpty ||
            haystack.contains(words) ||
            (words == 'business management' &&
                ['Business', 'Management'].contains(job.category))) &&
        filter.matches(job);
  }).toList();
  if (sort == 'Top') result.sort((a, b) => b.rating.compareTo(a.rating));
  return result;
}
