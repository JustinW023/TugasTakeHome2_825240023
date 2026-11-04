import 'package:flutter/material.dart';
import '../widgets/songcard.dart';
import '../widgets/emptyresult.dart';

class SearchPage extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final String searchQuery;
  final String errorMessage;
  final List songs;
  final Map<String, dynamic>? currentSong;
  final bool isPlaying;
  final bool Function(Map<String, dynamic>) isInFavourite;
  final Function({String? keyword}) onSearch;
  final Function(Map<String, dynamic>) onPlaySong;
  final Function(Map<String, dynamic>) onToggleFavourite;

  const SearchPage({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.searchQuery,
    required this.errorMessage,
    required this.songs,
    required this.currentSong,
    required this.isPlaying,
    required this.isInFavourite,
    required this.onSearch,
    required this.onPlaySong,
    required this.onToggleFavourite,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        children: [
          TextField(
            controller: widget.controller,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() {}),
            onSubmitted: (_) => widget.onSearch(),
            decoration: InputDecoration(
              hintText: 'Judul lagu atau artis',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        widget.controller.clear();
                        widget.onSearch(keyword: '');
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.isLoading ? null : () => widget.onSearch(),
              icon: const Icon(Icons.search, size: 19),
              label: const Text('Cari Lagu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.searchQuery.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Hasil untuk "${widget.searchQuery}"',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.errorMessage.isNotEmpty && widget.songs.isEmpty) {
      return EmptyResultWidget(
        icon: Icons.search_off,
        title: widget.errorMessage,
        subtitle: 'Coba kata kunci atau nama artis yang lain.',
      );
    }

    if (widget.songs.isEmpty) {
      return const EmptyResultWidget(
        icon: Icons.library_music_outlined,
        title: 'Cari lagu favoritmu',
        subtitle: 'Masukkan judul lagu atau nama artis pada kolom pencarian.',
      );
    }

    return ListView.separated(
      itemCount: widget.songs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 7),
      itemBuilder: (context, index) {
        final song = widget.songs[index];
        return SongCardWidget(
          song: song,
          isCurrentSong: widget.currentSong?['trackId'] == song['trackId'],
          isPlaying: widget.isPlaying,
          isInFavourite: widget.isInFavourite(song),
          onPlay: () => widget.onPlaySong(song),
          onToggleFavourite: () => widget.onToggleFavourite(song),
        );
      },
    );
  }
}