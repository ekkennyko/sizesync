import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizesync/data/models/user_profile.dart';
import 'package:sizesync/shared/providers/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _bustCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _shouldersCtrl = TextEditingController();
  final _footCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  final _bustFocus = FocusNode();
  final _waistFocus = FocusNode();
  final _hipsFocus = FocusNode();
  final _shouldersFocus = FocusNode();

  String? _activeField;
  String _selectedFit = 'regular';

  @override
  void initState() {
    super.initState();
    _addFocusListener(_bustFocus, 'bust');
    _addFocusListener(_waistFocus, 'waist');
    _addFocusListener(_hipsFocus, 'hips');
    _addFocusListener(_shouldersFocus, 'shoulders');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider);
      if (profile != null) _prefill(profile);
    });
  }

  void _addFocusListener(FocusNode node, String field) {
    node.addListener(() {
      if (node.hasFocus) {
        setState(() => _activeField = field);
      } else if (_activeField == field) {
        setState(() => _activeField = null);
      }
    });
  }

  void _prefill(UserProfile profile) {
    if (profile.bustCm != null) _bustCtrl.text = profile.bustCm!.toStringAsFixed(1);
    if (profile.waistCm != null) _waistCtrl.text = profile.waistCm!.toStringAsFixed(1);
    if (profile.hipsCm != null) _hipsCtrl.text = profile.hipsCm!.toStringAsFixed(1);
    if (profile.shoulderWidthCm != null) _shouldersCtrl.text = profile.shoulderWidthCm!.toStringAsFixed(1);
    if (profile.footLengthCm != null) _footCtrl.text = profile.footLengthCm!.toStringAsFixed(1);
    if (profile.heightCm != null) _heightCtrl.text = profile.heightCm!.toStringAsFixed(0);
    if (profile.weightKg != null) _weightCtrl.text = profile.weightKg!.toStringAsFixed(0);
    setState(() => _selectedFit = profile.preferredFit);
  }

  @override
  void dispose() {
    _bustCtrl.dispose();
    _waistCtrl.dispose();
    _hipsCtrl.dispose();
    _shouldersCtrl.dispose();
    _footCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _bustFocus.dispose();
    _waistFocus.dispose();
    _hipsFocus.dispose();
    _shouldersFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfile(
      bustCm: double.tryParse(_bustCtrl.text),
      waistCm: double.tryParse(_waistCtrl.text),
      hipsCm: double.tryParse(_hipsCtrl.text),
      shoulderWidthCm: double.tryParse(_shouldersCtrl.text),
      footLengthCm: double.tryParse(_footCtrl.text),
      heightCm: double.tryParse(_heightCtrl.text),
      weightKg: double.tryParse(_weightCtrl.text),
      preferredFit: _selectedFit,
    );

    await ref.read(userProfileProvider.notifier).save(profile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Measurements saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your measurements')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 220,
                child: CustomPaint(
                  painter: _SilhouettePainter(
                    bust: double.tryParse(_bustCtrl.text),
                    waist: double.tryParse(_waistCtrl.text),
                    hips: double.tryParse(_hipsCtrl.text),
                    shoulders: double.tryParse(_shouldersCtrl.text),
                    activeField: _activeField,
                    primaryColor: theme.colorScheme.primary,
                    outlineColor: theme.colorScheme.outline,
                    labelColor: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _sectionLabel(context, 'Measurements'),
              const SizedBox(height: 8),
              _MeasurementField(
                label: 'Bust',
                icon: Icons.straighten,
                controller: _bustCtrl,
                focusNode: _bustFocus,
                onChanged: (_) => setState(() {}),
                validator: _rangeValidator('Bust', 60, 150),
                onHelpTap: () => _showHowToMeasure(context, 'bust'),
              ),
              _MeasurementField(
                label: 'Waist',
                icon: Icons.straighten,
                controller: _waistCtrl,
                focusNode: _waistFocus,
                onChanged: (_) => setState(() {}),
                validator: _rangeValidator('Waist', 50, 130),
                onHelpTap: () => _showHowToMeasure(context, 'waist'),
              ),
              _MeasurementField(
                label: 'Hips',
                icon: Icons.straighten,
                controller: _hipsCtrl,
                focusNode: _hipsFocus,
                onChanged: (_) => setState(() {}),
                validator: _rangeValidator('Hips', 60, 160),
                onHelpTap: () => _showHowToMeasure(context, 'hips'),
              ),
              _MeasurementField(
                label: 'Shoulder width',
                icon: Icons.straighten,
                controller: _shouldersCtrl,
                focusNode: _shouldersFocus,
                onChanged: (_) => setState(() {}),
                validator: _rangeValidator('Shoulder width', 30, 60),
                onHelpTap: () => _showHowToMeasure(context, 'shoulders'),
              ),
              _MeasurementField(
                label: 'Foot length',
                icon: Icons.directions_walk,
                controller: _footCtrl,
                validator: _rangeValidator('Foot length', 15, 35),
                onHelpTap: () => _showHowToMeasure(context, 'foot'),
              ),
              const SizedBox(height: 16),
              _sectionLabel(context, 'Optional'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MeasurementField(
                      label: 'Height',
                      icon: Icons.height,
                      controller: _heightCtrl,
                      validator: _rangeValidator('Height', 100, 250),
                      onHelpTap: () => _showHowToMeasure(context, 'height'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MeasurementField(
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight_outlined,
                      controller: _weightCtrl,
                      validator: _rangeValidator('Weight', 30, 300),
                      onHelpTap: () => _showHowToMeasure(context, 'weight'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionLabel(context, 'Fit preference'),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'tight', label: Text('Slim')),
                  ButtonSegment(value: 'regular', label: Text('Regular')),
                  ButtonSegment(value: 'loose', label: Text('Loose')),
                ],
                selected: {_selectedFit},
                onSelectionChanged: (selection) => setState(() => _selectedFit = selection.first),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _save,
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text('Save')),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary));
  }

  String? Function(String?) _rangeValidator(String label, double min, double max) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final v = double.tryParse(value);
      if (v == null) return 'Enter a number';
      if (v < min || v > max) return '$label: $min–$max cm';
      return null;
    };
  }

  void _showHowToMeasure(BuildContext context, String field) {
    const instructions = {
      'bust': 'Measure around the fullest part of the chest, keeping the tape parallel to the floor.',
      'waist': 'Measure around the narrowest part of the waist, usually above the navel.',
      'hips': 'Measure around the fullest part of the hips and buttocks.',
      'shoulders': 'Measure from the tip of one shoulder to the tip of the other across the back.',
      'foot': 'Place your foot on paper, trace the outline, and measure from heel to the longest toe.',
      'height': 'Stand straight against a wall and measure from the floor to the top of your head.',
      'weight': 'Your current body weight in kilograms.',
    };

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How to measure', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(instructions[field] ?? '', style: Theme.of(ctx).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _MeasurementField extends StatelessWidget {
  const _MeasurementField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.onHelpTap,
    this.focusNode,
    this.validator,
    this.onChanged,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback onHelpTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}'))],
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: '$label (cm)',
          prefixIcon: Icon(icon),
          suffixIcon: IconButton(icon: const Icon(Icons.help_outline, size: 18), onPressed: onHelpTap),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  const _SilhouettePainter({
    required this.bust,
    required this.waist,
    required this.hips,
    required this.shoulders,
    required this.activeField,
    required this.primaryColor,
    required this.outlineColor,
    required this.labelColor,
  });

  final double? bust;
  final double? waist;
  final double? hips;
  final double? shoulders;
  final String? activeField;
  final Color primaryColor;
  final Color outlineColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.38;

    final headR = size.height * 0.072;
    final headCY = headR + 2;
    final neckBotY = headCY + headR + size.height * 0.04;
    final shoulderY = neckBotY + size.height * 0.03;
    final bustY = shoulderY + size.height * 0.14;
    final waistY = bustY + size.height * 0.15;
    final hipY = waistY + size.height * 0.14;
    final legBotY = size.height * 0.97;

    final neckHW = size.width * 0.022;
    final shoulderHW = size.width * 0.13;
    final bustHW = size.width * 0.105;
    final waistHW = size.width * 0.07;
    final hipHW = size.width * 0.115;
    final legHW = size.width * 0.032;

    final bodyPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Head
    canvas.drawCircle(Offset(cx, headCY), headR, bodyPaint);

    // Body path
    final body = Path()
      ..moveTo(cx - neckHW, headCY + headR)
      ..lineTo(cx - shoulderHW, shoulderY)
      ..lineTo(cx - bustHW, bustY)
      ..lineTo(cx - waistHW, waistY)
      ..lineTo(cx - hipHW, hipY)
      ..lineTo(cx - legHW, legBotY)
      ..moveTo(cx + legHW, legBotY)
      ..lineTo(cx + hipHW, hipY)
      ..lineTo(cx + waistHW, waistY)
      ..lineTo(cx + bustHW, bustY)
      ..lineTo(cx + shoulderHW, shoulderY)
      ..lineTo(cx + neckHW, headCY + headR);

    canvas.drawPath(body, bodyPaint);

    // Measurement indicator lines
    _drawIndicator(canvas, size, cx + shoulderHW, shoulderY, 'shoulders', shoulders);
    _drawIndicator(canvas, size, cx + bustHW, bustY, 'bust', bust);
    _drawIndicator(canvas, size, cx + waistHW, waistY, 'waist', waist);
    _drawIndicator(canvas, size, cx + hipHW, hipY, 'hips', hips);
  }

  void _drawIndicator(Canvas canvas, Size size, double startX, double y, String field, double? value) {
    final isActive = field == activeField;
    final color = isActive ? primaryColor : outlineColor.withValues(alpha: 0.6);
    final endX = size.width - 4;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = isActive ? 1.5 : 1.0;

    canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);
    canvas.drawCircle(Offset(startX, y), isActive ? 3.5 : 2.5, Paint()..color = color);

    final label = value != null ? '${value.toStringAsFixed(0)} cm' : '—';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: isActive ? primaryColor : labelColor.withValues(alpha: 0.6),
          fontSize: 11,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(endX - tp.width, y - tp.height - 2));
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) =>
      old.bust != bust || old.waist != waist || old.hips != hips || old.shoulders != shoulders || old.activeField != activeField;
}
