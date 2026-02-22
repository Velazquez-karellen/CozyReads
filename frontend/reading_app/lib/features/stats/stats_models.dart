class StatsOverview {
  // Counts
  final int books;
  final int fanfics;

  // Avg rating (overall + split)
  final double avgRating;
  final double avgRatingBooks;
  final double avgRatingFanfics;

  // Rereads (overall + split)
  final int rereads;
  final int rereadsBooks;
  final int rereadsFanfics;

  // Charts
  // Timeline: YYYY-MM -> count
  final Map<String, int> timelineAll;
  final Map<String, int> timelineBooks;
  final Map<String, int> timelineFanfics;

  // Ratings distribution: "1".."5" -> count
  final Map<String, int> ratingsAll;
  final Map<String, int> ratingsBooks;
  final Map<String, int> ratingsFanfics;

  // Re-reads split chart: labels -> count
  final Map<String, int> rereadsBreakdown;

  StatsOverview({
    required this.books,
    required this.fanfics,
    required this.avgRating,
    required this.avgRatingBooks,
    required this.avgRatingFanfics,
    required this.rereads,
    required this.rereadsBooks,
    required this.rereadsFanfics,
    required this.timelineAll,
    required this.timelineBooks,
    required this.timelineFanfics,
    required this.ratingsAll,
    required this.ratingsBooks,
    required this.ratingsFanfics,
    required this.rereadsBreakdown,
  });
}
