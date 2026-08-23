import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MementoMoriApp());
}

class MementoMoriApp extends StatelessWidget {
  const MementoMoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memento Mori',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B0B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Georgia',
      ),
      home: const AgeCounterPage(),
    );
  }
}

class AgeCounterPage extends StatefulWidget {
  const AgeCounterPage({super.key});

  @override
  State<AgeCounterPage> createState() => _AgeCounterPageState();
}

class _AgeCounterPageState extends State<AgeCounterPage> {
  DateTime? _birthDate;
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();

    // Step 1: pick the date.
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your birth date',
    );
    if (pickedDate == null) return;

    // Step 2: optionally pick the time of birth for precision.
    // If skipped, defaults to midnight.
    final pickedTime = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: _birthDate != null
          ? TimeOfDay(hour: _birthDate!.hour, minute: _birthDate!.minute)
          : const TimeOfDay(hour: 0, minute: 0),
      helpText: 'Time of birth (optional, defaults to 00:00)',
    );

    setState(() {
      _birthDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? 0,
        pickedTime?.minute ?? 0,
      );
    });
  }

  /// Calendar-accurate breakdown of the time elapsed between [birth] and [now].
  /// Not a naive division of total seconds — this respects actual month
  /// lengths and leap years, the way a birthday count should.
  _AgeBreakdown _calculateAge(DateTime birth, DateTime now) {
    int years = now.year - birth.year;
    int months = now.month - birth.month;
    int days = now.day - birth.day;
    int hours = now.hour - birth.hour;
    int minutes = now.minute - birth.minute;
    int seconds = now.second - birth.second;

    if (seconds < 0) {
      seconds += 60;
      minutes--;
    }
    if (minutes < 0) {
      minutes += 60;
      hours--;
    }
    if (hours < 0) {
      hours += 24;
      days--;
    }
    if (days < 0) {
      // Borrow days from the month preceding "now"'s month.
      final prevMonthLastDay = DateTime(now.year, now.month, 0).day;
      days += prevMonthLastDay;
      months--;
    }
    if (months < 0) {
      months += 12;
      years--;
    }

    return _AgeBreakdown(
      years: years,
      months: months,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = _birthDate != null
        ? _calculateAge(_birthDate!, _now)
        : null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'MEMENTO MORI',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'remember that you must die',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 48),
                if (breakdown == null)
                  const Text(
                    'Your time is not yet counted.',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  )
                else
                  _AgeDisplay(breakdown: breakdown),
                const SizedBox(height: 48),
                OutlinedButton(
                  onPressed: _pickBirthDate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    _birthDate == null ? 'Set birth date' : 'Change birth date',
                    style: const TextStyle(letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgeBreakdown {
  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  const _AgeBreakdown({
    required this.years,
    required this.months,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  String get formatted => '$years.$months.$days.$hours.$minutes.$seconds';
}

class _AgeDisplay extends StatelessWidget {
  final _AgeBreakdown breakdown;

  const _AgeDisplay({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          breakdown.formatted,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        const _LabelRow(),
      ],
    );
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow();

  @override
  Widget build(BuildContext context) {
    const labels = ['Years', 'Months', 'Days', 'Hrs', 'Min', 'Sec'];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      children: labels
          .map(
            (l) => Text(
              l,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          )
          .toList(),
    );
  }
}
