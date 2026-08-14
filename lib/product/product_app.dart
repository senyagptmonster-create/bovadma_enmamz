import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../app/brand.dart';
import '../app/store.dart';
import '../app/theme.dart';

/// Stretch routines walked one pose at a time. The screen shows exactly one
/// thing to do, which is the whole point of a stepper flow.
class ProductApp extends StatefulWidget {
  const ProductApp({super.key});

  @override
  State<ProductApp> createState() => _ProductAppState();
}

class _Pose {
  final String name;
  final int seconds;
  final String cue;
  const _Pose(this.name, this.seconds, this.cue);

  static _Pose? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final name = raw['name'];
    final seconds = raw['seconds'];
    final cue = raw['cue'];
    if (name is! String || name.isEmpty) return null;
    if (seconds is! int || seconds <= 0) return null;
    return _Pose(name, seconds, cue is String ? cue : '');
  }
}

class _Routine {
  final String id;
  final String name;
  final String focus;
  final List<_Pose> poses;
  const _Routine(this.id, this.name, this.focus, this.poses);

  int get totalSeconds => poses.fold(0, (sum, p) => sum + p.seconds);

  static _Routine? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    if (id is! String || id.isEmpty) return null;
    if (name is! String || name.isEmpty) return null;
    final rawPoses = raw['poses'];
    if (rawPoses is! List) return null;
    final poses = <_Pose>[];
    for (final p in rawPoses) {
      final parsed = _Pose.tryParse(p);
      if (parsed != null) poses.add(parsed);
    }
    if (poses.isEmpty) return null;
    final focus = raw['focus'];
    return _Routine(id, name, focus is String ? focus : '', poses);
  }
}

class _ProductAppState extends State<ProductApp> {
  static const _kDone = 'st_sessions';

  List<_Routine> _routines = const [];
  bool _loading = true;
  int _sessions = 0;

  _Routine? _active;
  int _index = 0;
  int _remaining = 0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    var routines = <_Routine>[];
    try {
      final raw = await rootBundle.loadString('assets/json/content.json');
      final decoded = jsonDecode(raw);
      if (decoded is Map && decoded['routines'] is List) {
        for (final r in decoded['routines'] as List) {
          final parsed = _Routine.tryParse(r);
          if (parsed != null) routines.add(parsed);
        }
      }
    } catch (_) {
      routines = <_Routine>[];
    }
    final sessions = await Store.getInt(_kDone);
    if (!mounted) return;
    setState(() {
      _routines = routines;
      _sessions = sessions;
      _loading = false;
    });
  }

  void _begin(_Routine routine) {
    setState(() {
      _active = routine;
      _index = 0;
      _remaining = routine.poses.first.seconds;
    });
    _resume();
  }

  void _resume() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    setState(() {});
  }

  void _pause() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {});
  }

  void _tick() {
    if (!mounted) return;
    if (_remaining > 1) {
      setState(() => _remaining--);
      return;
    }
    _advance();
  }

  void _advance() {
    final routine = _active;
    if (routine == null) return;
    if (_index >= routine.poses.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _remaining = routine.poses[_index].seconds;
    });
  }

  void _back() {
    final routine = _active;
    if (routine == null || _index == 0) return;
    setState(() {
      _index--;
      _remaining = routine.poses[_index].seconds;
    });
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    _ticker = null;
    final next = _sessions + 1;
    await Store.setInt(_kDone, next);
    if (!mounted) return;
    setState(() {
      _sessions = next;
      _active = null;
    });
  }

  void _exit() {
    _ticker?.cancel();
    _ticker = null;
    setState(() => _active = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: cBg,
        body: Center(child: CircularProgressIndicator(color: cAccent)),
      );
    }
    if (_routines.isEmpty) {
      return Scaffold(
        backgroundColor: cBg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              'Routine pack unavailable.',
              textAlign: TextAlign.center,
              style: AppTheme.text(15, color: AppTheme.textSecondary),
            ),
          ),
        ),
      );
    }
    return _active == null ? _buildPicker() : _buildSession();
  }

  Widget _buildPicker() {
    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            Text(
              kAppTitle,
              style: TextStyle(
                fontFamily: kDisplayFont,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              kProductTagline,
              style: AppTheme.text(14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              decoration: AppTheme.panel(accented: true),
              child: Row(
                children: [
                  Icon(Icons.self_improvement, color: cAlt, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _sessions == 0
                          ? 'No sessions yet. Pick a routine below.'
                          : 'You have completed $_sessions session'
                                '${_sessions == 1 ? '' : 's'}.',
                      style: AppTheme.text(
                        13.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            for (final routine in _routines) ...[
              _routineCard(routine),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }

  Widget _routineCard(_Routine routine) {
    final minutes = (routine.totalSeconds / 60).ceil();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _begin(routine),
        borderRadius: BorderRadius.circular(kRadius),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.panel(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                routine.name,
                style: TextStyle(
                  fontFamily: kDisplayFont,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                routine.focus,
                style: AppTheme.text(13.5, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('${routine.poses.length} poses'),
                  _chip('about $minutes min'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kRadius * 0.6),
        // cAlt, not cAccent: on the light themes the brand accent can be too
        // pale to read as text, while alt is picked to contrast with the page.
        color: cAlt.withValues(alpha: 0.14),
      ),
      child: Text(
        label,
        style: AppTheme.text(11.5, color: cAlt, weight: FontWeight.w700),
      ),
    );
  }

  Widget _buildSession() {
    final routine = _active!;
    final pose = routine.poses[_index];
    final running = _ticker != null;
    final progress = (_index + 1) / routine.poses.length;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 18, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _exit,
                    icon: const Icon(Icons.close_rounded),
                    color: AppTheme.textSecondary,
                  ),
                  Expanded(
                    child: Text(
                      routine.name,
                      style: AppTheme.text(
                        14,
                        color: AppTheme.textSecondary,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${_index + 1} / ${routine.poses.length}',
                    style: AppTheme.text(13, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation<Color>(cAccent),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                children: [
                  Center(
                    child: Container(
                      width: 168,
                      height: 168,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cAlt.withValues(alpha: 0.14),
                      ),
                      child: Text(
                        '$_remaining',
                        style: TextStyle(
                          fontFamily: kDisplayFont,
                          fontSize: 62,
                          fontWeight: FontWeight.w700,
                          color: cAlt,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    pose.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: kDisplayFont,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pose.cue,
                    textAlign: TextAlign.center,
                    style: AppTheme.text(
                      15,
                      color: AppTheme.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: _index == 0 ? null : _back,
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: running ? _pause : _resume,
                      icon: Icon(
                        running
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(running ? 'Pause' : 'Resume'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    onPressed: _advance,
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
