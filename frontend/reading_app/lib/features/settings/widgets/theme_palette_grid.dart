import 'package:flutter/material.dart';
import '../../../theme/ghibli/widgets/ghibli_palette.dart';

class ThemePaletteGrid extends StatelessWidget {
  final List<GhibliPalette> palettes;
  final String? selectedId;
  final ValueChanged<GhibliPalette> onSelected;

  const ThemePaletteGrid({
    super.key,
    required this.palettes,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: palettes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, index) {
        final palette = palettes[index];
        final selected = palette.id == selectedId;
        final color = palette.seedFor(brightness);

        return GestureDetector(
          onTap: () => onSelected(palette),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              border: selected
                  ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              )
                  : null,
            ),
            child: Center(
              child: Text(
                palette.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
