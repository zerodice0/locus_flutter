import 'package:flutter/material.dart';

class RadiusSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  const RadiusSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.5,
    this.max = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('검색 반경'),
                Text(
                  _formatRadius(value),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: _getDivisions(),
                onChanged: onChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatRadius(min),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _formatRadius(max),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildPresetButtons(context),
          ],
        ),
      ),
    );
  }

  String _formatRadius(double radius) {
    if (radius < 1) {
      return '${(radius * 1000).round()}m';
    } else {
      return '${radius.toStringAsFixed(radius == radius.roundToDouble() ? 0 : 1)}km';
    }
  }

  int _getDivisions() {
    // 0.5km부터 10km까지 0.5km 단위로 나누기
    return ((max - min) / 0.5).round();
  }

  Widget _buildPresetButtons(BuildContext context) {
    final presets = [0.5, 1.0, 2.0, 5.0];

    return Wrap(
      spacing: 8,
      children:
          presets.map((preset) {
            final isSelected = (value - preset).abs() < 0.1;

            return FilterChip(
              label: Text(_formatRadius(preset)),
              selected: isSelected,
              onSelected: (_) => onChanged(preset),
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
            );
          }).toList(),
    );
  }
}
