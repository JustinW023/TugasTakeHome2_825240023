import 'package:flutter/material.dart';
import '../widgets/songcard.dart';
import '../widgets/emptyresult.dart';
import '../widgets/sectiontitle.dart';

class FavouritePage extends StatelessWidget {
  final List FavouriteSongs;
  final Map<String, dynamic>? currentSong;
  final bool isPlaying;
  final bool Function(Map<String, dynamic>) isInFavourite;
  final Function(Map<String, dynamic>) onPlaySong;
  final Function(Map<String, dynamic>) onToggleFavourite;

  const FavouritePage({
    super.key,
    required this.FavouriteSongs,
    required this.currentSong,
    required this.isPlaying,
    required this.isInFavourite,
    required this.onPlaySong,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitleWidget(
            title: 'My Favourite',
            subtitle: 'Lagu favorit yang disimpan',
          ),
          const SizedBox(height: 10),
          if (FavouriteSongs.isEmpty)
            const EmptyResultWidget(
              icon: Icons.favorite_border,
              title: 'Favourite masih kosong',
              subtitle: 'Tekan ikon hati pada lagu untuk menyimpannya.',
            )
          else
            for (final song in FavouriteSongs)
              SongCardWidget(
                song: song,
                isCurrentSong: currentSong?['trackId'] == song['trackId'],
                isPlaying: isPlaying,
                isInFavourite: isInFavourite(song),
                onPlay: () => onPlaySong(song),
                onToggleFavourite: () => onToggleFavourite(song),
              ),
        ],
      ),
    );
  }
}