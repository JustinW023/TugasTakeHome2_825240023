import 'package:flutter/material.dart';
import '../widgets/songcard.dart';
import '../widgets/emptyresult.dart';
import '../widgets/sectiontitle.dart';

class HomePage extends StatelessWidget {
  final List songs;
  final List<String> categories;
  final String selectedCategory;
  final Map<String, dynamic>? currentSong;
  final bool isPlaying;
  final bool Function(Map<String, dynamic>) isInFavourite;
  final Function(String) onSelectCategory;
  final VoidCallback onOpenSearch;
  final Function(Map<String, dynamic>) onPlaySong;
  final Function(Map<String, dynamic>) onToggleFavourite;

  const HomePage({
    super.key,
    required this.songs,
    required this.categories,
    required this.selectedCategory,
    required this.currentSong,
    required this.isPlaying,
    required this.isInFavourite,
    required this.onSelectCategory,
    required this.onOpenSearch,
    required this.onPlaySong,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitleWidget(
            title: 'Hasil Pencarian Terakhir',
            subtitle: 'Lagu pencarian terakhir',
          ),
          const SizedBox(height: 9),
          if (songs.isEmpty)
            const EmptyResultWidget(
              icon: Icons.music_note,
              title: 'Belum ada lagu',
              subtitle: 'Gunakan pencarian untuk mengdisplay lagu terakhir',
            )
          else
            ...songs.take(5).map(
                  (song) => SongCardWidget(
                    song: song,
                    isCurrentSong: currentSong?['trackId'] == song['trackId'],
                    isPlaying: isPlaying,
                    isInFavourite: isInFavourite(song),
                    onPlay: () => onPlaySong(song),
                    onToggleFavourite: () => onToggleFavourite(song),
                  ),
                ),
        ],
      ),
    );
  }
}