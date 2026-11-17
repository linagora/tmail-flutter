// UTC time of day; joins recorder entries with each other and with CI log timestamps.
String utcClock() => DateTime.now().toUtc().toIso8601String().substring(11, 23);
