import 'package:flutter/material.dart';

class MiniPlayerWidget extends StatelessWidget {
  final Map<String, dynamic>? currentSong;
  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final Function(double) onSeek;

  const MiniPlayerWidget({
    super.key,
    required this.currentSong,
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onSeek,
  });

  String formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _songPlaceholder() {
    return Container(
      width: 45,
      height: 45,
      color: const Color(0xFFE8EEF5),
      child: const Icon(Icons.music_note, color: Colors.blueGrey, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentSong == null) {
      return const SizedBox.shrink();
    }

    final artwork = currentSong!['artworkUrl100'];
    final maxPosition =
        duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
    final currentPosition =
        position.inMilliseconds.toDouble().clamp(0.0, maxPosition);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: artwork != null
                    ? Image.network(
                        artwork,
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _songPlaceholder(),
                      )
                    : _songPlaceholder(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSong!['trackName'] ?? 'Unknown Song',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      currentSong!['artistName'] ?? 'Unknown Artist',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isPlaying ? onPause : onResume,
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: Colors.grey,
                  size: 34,
                ),
              ),
              IconButton(
                onPressed: onStop,
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                formatDuration(position),
                style: const TextStyle(fontSize: 9),
              ),
              Expanded(
                child: Slider(
                  min: 0,
                  max: maxPosition,
                  value: currentPosition,
                  activeColor: Colors.grey,
                  onChanged: duration == Duration.zero ? null : onSeek,
                ),
              ),
              Text(
                formatDuration(duration),
                style: const TextStyle(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}