import 'package:flutter/material.dart';

class Equalizer extends StatefulWidget {
  final bool isPlaying;

  const Equalizer({super.key, required this.isPlaying});

  @override
  State<Equalizer> createState() => _EqualizerState();
}

class _EqualizerState extends State<Equalizer>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (widget.isPlaying) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant Equalizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying) {
      controller.repeat(reverse: true);
    } else {
      controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) {
      return const Icon(Icons.more_horiz, color: Colors.grey);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        return SizedBox(
          width: 22,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final height = 6 + (controller.value * 14 * (i + 1) / 3);
              return Container(
                width: 3,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}