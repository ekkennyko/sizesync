import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizesync/shared/providers/providers.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  static const _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await ref.read(hiveDataSourceProvider).writeOnboardingComplete();
    if (mounted) context.go('/');
  }

  void _next() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentPage == _pageCount - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextButton(
                  onPressed: _complete,
                  child: Text('Пропустить', style: TextStyle(color: theme.colorScheme.outline)),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: const [_Page1(), _Page2(), _Page3()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pageCount,
                    effect: WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      dotColor: theme.colorScheme.surfaceContainerHighest,
                      activeDotColor: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: Text(isLast ? 'Начать' : 'Далее'),
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

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.icon, required this.title, required this.subtitle});

  final Widget icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 48),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingPage(icon: _RulerIcon(), title: 'Найдите свой размер', subtitle: 'Размеры 500+ брендов мгновенно. Без интернета.');
  }
}

class _Page2 extends StatelessWidget {
  const _Page2();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingPage(
      icon: _SilhouetteIcon(),
      title: 'Мерки один раз — размер навсегда',
      subtitle: 'Введите мерки и получайте персональный размер в каждом бренде',
    );
  }
}

class _Page3 extends StatelessWidget {
  const _Page3();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingPage(icon: _CheckIcon(), title: 'Покупайте уверенно', subtitle: 'Больше никаких возвратов из-за неподходящего размера');
  }
}

class _RulerIcon extends StatelessWidget {
  const _RulerIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 120),
      painter: _RulerPainter(color: Theme.of(context).colorScheme.primary),
    );
  }
}

class _RulerPainter extends CustomPainter {
  const _RulerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final tick = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    void drawRuler(double top, double left, double width) {
      const h = 22.0;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(left, top, width, h), const Radius.circular(3)), fill);
      for (int i = 1; i < 10; i++) {
        final x = left + width * i / 10;
        final th = i % 5 == 0 ? 10.0 : 6.0;
        canvas.drawLine(Offset(x, top), Offset(x, top - th), tick);
      }
    }

    drawRuler(size.height * 0.40, 0, size.width);
    drawRuler(size.height * 0.90, size.width * 0.12, size.width * 0.88);
  }

  @override
  bool shouldRepaint(_RulerPainter old) => old.color != color;
}

class _SilhouetteIcon extends StatelessWidget {
  const _SilhouetteIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(160, 200),
      painter: _SilhouettePainter(color: Theme.of(context).colorScheme.primary),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  const _SilhouettePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;

    canvas.drawCircle(Offset(cx, size.height * 0.09), size.width * 0.11, body..color = color.withValues(alpha: 0.25));

    final bodyPath = Path()
      ..moveTo(cx - size.width * 0.22, size.height * 0.20)
      ..lineTo(cx + size.width * 0.22, size.height * 0.20)
      ..lineTo(cx + size.width * 0.17, size.height * 0.65)
      ..lineTo(cx - size.width * 0.17, size.height * 0.65)
      ..close();
    canvas.drawPath(bodyPath, body..color = color.withValues(alpha: 0.15));

    for (final entry in [(0.30, 0.38), (0.43, 0.30), (0.57, 0.36)]) {
      final y = size.height * entry.$1;
      final hl = size.width * entry.$2;
      final innerX = size.width * 0.20;
      canvas.drawLine(Offset(cx - hl, y), Offset(cx - innerX, y), line);
      canvas.drawLine(Offset(cx + innerX, y), Offset(cx + hl, y), line);
      canvas.drawLine(Offset(cx - hl, y - 4), Offset(cx - hl, y + 4), line);
      canvas.drawLine(Offset(cx + hl, y - 4), Offset(cx + hl, y + 4), line);
    }
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) => old.color != color;
}

class _CheckIcon extends StatelessWidget {
  const _CheckIcon();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primaryContainer),
      child: Icon(Icons.check_rounded, size: 72, color: theme.colorScheme.primary),
    );
  }
}
