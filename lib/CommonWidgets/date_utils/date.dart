String monthName(int month) {
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  return months[month - 1];
}

String formatDateTime(String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) {
    return "Unknown date";
  }

  try {
    final DateTime dateTime = DateTime.parse(createdAt);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else {
      // Format as "day month year" for older dates
      return "${dateTime.day} ${monthName(dateTime.month)} ${dateTime.year}";
    }
  } catch (e) {
    print('Error parsing date: $e');
    return "Invalid date";
  }
}
