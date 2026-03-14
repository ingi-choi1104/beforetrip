import 'dart:math';

import 'package:flutter/material.dart';

import '../models/travel_mbti.dart';
import '../services/mbti_storage_service.dart';
import '../widgets/banner_ad_widget.dart';
import 'mbti_recommend_screen.dart';

const int _questionsPerPage = 3;

class MbtiScreen extends StatefulWidget {
  const MbtiScreen({super.key});

  @override
  State<MbtiScreen> createState() => _MbtiScreenState();
}

class _MbtiScreenState extends State<MbtiScreen> {
  late final List<MbtiQuestion> _questions;
  late final List<int?> _answers;
  int _page = 0;
  TravelMbtiResult? _result;

  int get _totalPages =>
      (_questions.length + _questionsPerPage - 1) ~/ _questionsPerPage;

  @override
  void initState() {
    super.initState();
    _questions = [...mbtiQuestions]..shuffle();
    _answers = List.filled(_questions.length, null);
  }

  // 현재 페이지에 해당하는 질문 인덱스 목록
  List<int> get _pageIndices {
    final start = _page * _questionsPerPage;
    final end = min(start + _questionsPerPage, _questions.length);
    return List.generate(end - start, (i) => start + i);
  }

  bool get _allAnswered => _pageIndices.every((i) => _answers[i] != null);
  bool get _isLast => _page == _totalPages - 1;

  void _select(int questionIdx, int score) {
    setState(() => _answers[questionIdx] = score);
  }

  void _next() {
    if (!_allAnswered) return;
    if (_isLast) {
      setState(() => _result = scoreMbti(
            _questions,
            _answers.map((v) => v!).toList(),
          ));
    } else {
      setState(() => _page++);
    }
  }

  void _prev() {
    if (_page > 0) setState(() => _page--);
  }

  void _reset() {
    setState(() {
      _page = 0;
      _questions.shuffle();
      _answers.fillRange(0, _answers.length, null);
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) return _ResultScreen(result: _result!, onRetry: _reset);

    final progress = (_page + 1) / _totalPages;
    final colorScheme = Theme.of(context).colorScheme;
    final indices = _pageIndices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 MBTI'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      bottomNavigationBar: const BottomBannerAd(),
      body: Column(
        children: [
          // 진행 바
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: colorScheme.primary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${_page + 1} / $_totalPages',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // 질문 카드 3개
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final idx in indices)
                  _QuestionCard(
                    number: idx + 1,
                    text: _questions[idx].text,
                    selected: _answers[idx],
                    onSelect: (score) => _select(idx, score),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // 네비게이션 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                if (_page > 0)
                  OutlinedButton(
                    onPressed: _prev,
                    child: const Text('이전'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _allAnswered ? _next : null,
                  child: Text(_isLast ? '결과 보기' : '다음'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 질문 카드 ─────────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final int number;
  final String text;
  final int? selected;
  final ValueChanged<int> onSelect;

  const _QuestionCard({
    required this.number,
    required this.text,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected != null
              ? colorScheme.primary.withAlpha(100)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 10, top: 1),
                decoration: BoxDecoration(
                  color: selected != null
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: selected != null
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ScaleButtons(selected: selected, onSelect: onSelect),
        ],
      ),
    );
  }
}

// ── 5점 척도 버튼 ─────────────────────────────────────────────────────────────

class _ScaleButtons extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelect;

  const _ScaleButtons({required this.selected, required this.onSelect});

  static const _labels = ['전혀\n아니다', '아니다', '보통', '그렇다', '매우\n그렇다'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final score = i + 1;
        final isSelected = selected == score;
        return GestureDetector(
          onTap: () => onSelect(score),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 56,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _labels[i],
                  style: TextStyle(
                    fontSize: 8,
                    height: 1.2,
                    color: isSelected
                        ? colorScheme.onPrimary.withAlpha(200)
                        : colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── 결과 화면 ─────────────────────────────────────────────────────────────────

class _ResultScreen extends StatefulWidget {
  final TravelMbtiResult result;
  final VoidCallback onRetry;

  const _ResultScreen({required this.result, required this.onRetry});

  @override
  State<_ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<_ResultScreen> {
  bool _saved = false;

  Future<void> _save() async {
    await MbtiStorageService.save(widget.result);
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('MBTI가 저장됐습니다'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final result = widget.result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 여행 MBTI'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: const BottomBannerAd(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 타입 코드 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    result.typeCode,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.nickname,
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.onPrimary.withAlpha(220),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 요약 뱃지 행
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TagChip(result.qpLabel, colorScheme.primary),
                _TagChip(result.blLabel, colorScheme.secondary),
                _TagChip(result.style1Label(result.style1), colorScheme.tertiary),
                _TagChip(result.style2Label(result.style2), colorScheme.error),
                _TagChip(result.style3Label(result.style3), colorScheme.outline),
              ],
            ),

            const SizedBox(height: 24),

            // 차원별 설명 카드
            _DimCard(
              icon: Icons.location_on,
              title: result.isP ? 'P — 핫한 관광지' : 'Q — 조용한 관광지',
              desc: result.qpDesc,
              color: colorScheme.primary,
            ),
            _DimCard(
              icon: Icons.luggage,
              title: result.isB ? 'B — 배낭여행' : 'L — 럭셔리 여행',
              desc: result.blDesc,
              color: colorScheme.secondary,
            ),
            _DimCard(
              icon: _style1Icon(result.style1),
              title: '${result.style1} — ${result.style1Label(result.style1)}',
              desc: result.style1Desc(result.style1),
              color: colorScheme.tertiary,
            ),
            _DimCard(
              icon: _style2Icon(result.style2),
              title: '${result.style2} — ${result.style2Label(result.style2)}',
              desc: result.style2Desc(result.style2),
              color: colorScheme.error,
            ),
            _DimCard(
              icon: _style3Icon(result.style3),
              title: '${result.style3} — ${result.style3Label(result.style3)}',
              desc: result.style3Desc(result.style3),
              color: colorScheme.outline,
            ),

            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MbtiRecommendScreen(result: result),
                ),
              ),
              icon: const Icon(Icons.explore),
              label: const Text('내 유형 여행지 추천 보기'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _saved ? null : _save,
              icon: Icon(_saved ? Icons.check : Icons.bookmark_outlined),
              label: Text(_saved ? '저장됨' : '이 MBTI 저장하기'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                disabledBackgroundColor: colorScheme.secondaryContainer,
                disabledForegroundColor: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 검사하기'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _style1Icon(String s) => switch (s) {
    'N' => Icons.park,
    'H' => Icons.account_balance,
    'U' => Icons.location_city,
    'S' => Icons.cottage,
    _ => Icons.travel_explore,
  };

  IconData _style2Icon(String s) => switch (s) {
    'V' => Icons.beach_access,
    'A' => Icons.sports_gymnastics,
    'R' => Icons.restaurant,
    _ => Icons.travel_explore,
  };

  IconData _style3Icon(String s) => switch (s) {
    'N' => Icons.park,
    'H' => Icons.account_balance,
    'U' => Icons.location_city,
    'S' => Icons.cottage,
    'V' => Icons.beach_access,
    'A' => Icons.sports_gymnastics,
    'R' => Icons.restaurant,
    _ => Icons.travel_explore,
  };
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TagChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _DimCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const _DimCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
