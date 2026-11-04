import 'package:flutter/material.dart';

class SongCardWidget extends StatelessWidget {
  final Map<String, dynamic> song;
  final bool isCurrentSong;
  final bool isPlaying;
  final bool isInFavourite;
  final VoidCallback onPlay;
  final VoidCallback onToggleFavourite;

  const SongCardWidget({
    super.key,
    required this.song,
    required this.isCurrentSong,
    required this.isPlaying,
    required this.isInFavourite,
    required this.onPlay,
    required this.onToggleFavourite,
  });

  Widget _songPlaceholder() {
    return Container(
      width: 62,
      height: 62,
      color: Colors.white,
      child: const Icon(Icons.music_note, color: Colors.grey, size: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artwork = song['artworkUrl100'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentSong ? Colors.grey : Colors.white,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: artwork != null
                ? Image.network(
                    artwork,
                    width: 62,
                    height: 62,
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
                  song['trackName'] ?? '-',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  song['artistName'] ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  song['collectionName'] ?? 'Single',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: isCurrentSong && isPlaying ? 'Pause Musik' : 'Putar Musik',
            onPressed: onPlay,
            icon: Icon(
              isCurrentSong && isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              color: Colors.grey.shade700,
              size: 30,
            ),
          ),
          IconButton(
            tooltip: isInFavourite ? 'Hapus dari Favourite' : 'Tambah ke Favourite',
            onPressed: onToggleFavourite,
            icon: Icon(
              isInFavourite ? Icons.favorite : Icons.favorite_border,
              color: isInFavourite ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}