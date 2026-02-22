import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reading_app/theme/ghibli/widgets/ghibli_palette.dart';
import 'package:reading_app/theme/ghibli/widgets/ghibli_palettes.dart';

import '../../../features/settings/settings_provider.dart';

class GhibliModePage extends ConsumerWidget {
  const GhibliModePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    final palettes = GhibliPalettes.all;
    final selectedId = settings.ghibliPaletteId;
    final brightness = MediaQuery.platformBrightnessOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghibli Mode'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================
            // HEADER
            // =====================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Choose a reading atmosphere',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Inspired by gentle worlds and quiet moments.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // =====================
            // GRID
            // =====================
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: palettes.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final palette = palettes[index];
                  final isSelected = palette.id == selectedId;

                  return _PaletteTile(
                    palette: palette,
                    brightness: brightness,
                    selected: isSelected,
                    onTap: () {
                      notifier.useGhibliTheme(palette.id);
                    },
                  );
                },
              ),
            ),

            // =====================
            // FOOTER
            // =====================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'You can change this anytime from Settings.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// PALETTE TILE
// =======================================================

class _PaletteTile extends StatelessWidget {
  final GhibliPalette palette;
  final Brightness brightness;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteTile({
    required this.palette,
    required this.brightness,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = palette.seedFor(brightness);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          )
              : null,
          boxShadow: selected
              ? [
            BoxShadow(
              color: color.withOpacity(0.45),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        child: Stack(
          children: [
            // LABEL
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  palette.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ),
            ),

            // CHECK ICON
            if (selected)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
