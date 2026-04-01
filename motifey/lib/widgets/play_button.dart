import 'package:flutter/material.dart';

class PlayButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isPlaying;

  const PlayButton({
    super.key,
    required this.onTap,
    required this.isPlaying,
  });

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  double scale = 1.0;

  void _down(_) => setState(() => scale = 0.9);
  void _up(_) => setState(() => scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.green,
        shape: const CircleBorder(),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.onTap,
          onTapDown: _down,
          onTapUp: _up,
          onTapCancel: () => _up(null),
          child: SizedBox(
            width: 50,
            height: 50,
            child: Icon(
              widget.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}