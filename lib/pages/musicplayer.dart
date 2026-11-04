import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

import 'homepage.dart';
import 'category.dart';
import 'search.dart';
import 'favourite.dart';
import '../widgets/miniplayer.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final TextEditingController searchController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();

  Map<String, dynamic>? currentSong;
  bool isPlaying = false;
  bool isLoading = false;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  StreamSubscription<PlayerState>? playerStateSubscription;
  StreamSubscription<Duration>? durationSubscription;
  StreamSubscription<Duration>? positionSubscription;
  StreamSubscription<void>? completionSubscription;

  // Pages: 0 = Home, 1 = Category, 2 = Search, 3 = Favourite
  int currentPage = 0;
  String message = '';
  String selectedCategory = 'Semua';
  String searchQuery = '';

  List songs = [];
  List FavouriteSongs = [];
  String errorMessage = '';

  final List<String> categories = [
    'Semua',
    'Garage',
    'Rock',
    'Jazz',
    'Electronic',
    'Classical',
    'Metal',
    'Country',
  ];

  @override
  void initState() {
    super.initState();

    playerStateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    durationSubscription = audioPlayer.onDurationChanged.listen((newDuration) {
      if (!mounted) return;
      setState(() {
        duration = newDuration;
      });
    });

    positionSubscription = audioPlayer.onPositionChanged.listen((newPosition) {
      if (!mounted) return;
      setState(() {
        position = newPosition;
      });
    });

    completionSubscription = audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  Future<void> cariLagu({String? keyword}) async {
    final term = (keyword ?? searchController.text).trim();

    if (term.isEmpty) {
      setState(() {
        songs = [];
        searchQuery = '';
        errorMessage = 'Masukkan judul lagu atau nama artis.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      searchQuery = term;
      message = '';
    });

    final url = Uri.https(
      'itunes.apple.com',
      '/search',
      {
        'term': term,
        'entity': 'song',
        'limit': '20',
      },
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];

        setState(() {
          songs = results.map((item) => Map<String, dynamic>.from(item)).toList();
          isLoading = false;
          errorMessage = songs.isEmpty ? 'Lagu tidak ditemukan.' : '';
        });
      } else {
        setState(() {
          songs = [];
          isLoading = false;
          errorMessage = 'Terjadi kesalahan: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        songs = [];
        isLoading = false;
        errorMessage = 'Tidak dapat terhubung ke internet.';
      });
      debugPrint('Search Error: $e');
    }
  }

  Future<void> playSong(Map<String, dynamic> song) async {
    final trackId = song['trackId'];
    final currentTrackId = currentSong?['trackId'];

    if (currentTrackId == trackId && isPlaying) {
      await audioPlayer.pause();
      return;
    }

    if (currentTrackId == trackId &&
        !isPlaying &&
        duration > Duration.zero &&
        position < duration) {
      await audioPlayer.resume();
      return;
    }

    final previewUrl = song['previewUrl'];

    if (previewUrl == null || previewUrl.toString().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preview audio tidak tersedia untuk lagu ini.'),
        ),
      );
      return;
    }

    try {
      setState(() {
        currentSong = song;
        isPlaying = false;
        position = Duration.zero;
        duration = Duration.zero;
      });

      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(previewUrl.toString()));
    } catch (e) {
      debugPrint('Music Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memutar musik. Periksa koneksi internet.'),
        ),
      );
    }
  }

  Future<void> pauseMusic() async {
    try {
      await audioPlayer.pause();
    } catch (e) {
      debugPrint('Pause Error: $e');
    }
  }

  Future<void> resumeMusic() async {
    try {
      if (currentSong != null) {
        await audioPlayer.resume();
      }
    } catch (e) {
      debugPrint('Resume Error: $e');
    }
  }

  Future<void> stopMusic() async {
    try {
      await audioPlayer.stop();
      if (!mounted) return;
      setState(() {
        isPlaying = false;
        position = Duration.zero;
        duration = Duration.zero;
        currentSong = null;
      });
    } catch (e) {
      debugPrint('Stop Error: $e');
    }
  }

  Future<void> seekMusic(double value) async {
    await audioPlayer.seek(Duration(milliseconds: value.toInt()));
  }

  bool isInFavourite(Map<String, dynamic> song) {
    final trackId = song['trackId'];
    return FavouriteSongs.any((item) => item['trackId'] == trackId);
  }

  void toggleFavourite(Map<String, dynamic> song) {
    final trackId = song['trackId'];
    setState(() {
      if (isInFavourite(song)) {
        FavouriteSongs.removeWhere((item) => item['trackId'] == trackId);
        message = '${song['trackName'] ?? 'Lagu'} dihapus dari Favourite';
      } else {
        FavouriteSongs.add(Map<String, dynamic>.from(song));
        message = '${song['trackName'] ?? 'Lagu'} ditambahkan ke Favourite';
      }
    });
  }

  void changeBottomMenu(int index) {
    setState(() {
      currentPage = index;
      message = '';
      if (index == 0) {
        selectedCategory = 'Semua';
      }
    });
  }

  void openSearch() {
    setState(() {
      currentPage = 3;
      message = '';
    });
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      currentPage = 3;
      searchController.text = category == 'Semua' ? '' : category;
      message = '';
    });

    if (category != 'Semua') {
      cariLagu(keyword: category);
    } else {
      setState(() {
        songs = [];
        searchQuery = '';
        errorMessage = '';
      });
    }
  }

  Widget _buildHeader() {
    final titles = [
      'MusicFli',
      'Kategori Musik',
      'Favourite Saya',
      'Pencarian Lagu',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      color: Colors.grey.shade700,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => changeBottomMenu(0),
            child: const Icon(
              Icons.music_note,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[currentPage],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentPage == 0
                      ? 'Temukan musik favoritmu setiap hari'
                      : 'Nikmati dan temukan musik favorit',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (currentPage != 3)
            GestureDetector(
              onTap: openSearch,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 27,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (currentPage) {
      case 0:
        return HomePage(
          songs: songs,
          categories: categories,
          selectedCategory: selectedCategory,
          currentSong: currentSong,
          isPlaying: isPlaying,
          isInFavourite: isInFavourite,
          onSelectCategory: selectCategory,
          onOpenSearch: openSearch,
          onPlaySong: playSong,
          onToggleFavourite: toggleFavourite,
        );
      case 1:
        return CategoryPage(
          categories: categories,
          selectedCategory: selectedCategory,
          onSelectCategory: selectCategory,
        );
      case 2:
        return FavouritePage(
          FavouriteSongs: FavouriteSongs,
          currentSong: currentSong,
          isPlaying: isPlaying,
          isInFavourite: isInFavourite,
          onPlaySong: playSong,
          onToggleFavourite: toggleFavourite,
        );
      case 3:
        return SearchPage(
          controller: searchController,
          isLoading: isLoading,
          searchQuery: searchQuery,
          errorMessage: errorMessage,
          songs: songs,
          currentSong: currentSong,
          isPlaying: isPlaying,
          isInFavourite: isInFavourite,
          onSearch: cariLagu,
          onPlaySong: playSong,
          onToggleFavourite: toggleFavourite,
        );
      default:
        return Container();
    }
  }

  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final List<IconData> icons = [
      Icons.home,
      Icons.grid_view,
      Icons.favorite_border,
    ];

    final List<String> labels = [
      'Beranda',
      'Kategori',
      'Favourite',
    ];

    return Container(
      padding: const EdgeInsets.only(top: 7, bottom: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < icons.length; i++)
            GestureDetector(
              onTap: () => changeBottomMenu(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        icons[i],
                        size: 22,
                        color: currentPage == i ? Colors.grey : Colors.black87,
                      ),
                      if (i == 3 && FavouriteSongs.isNotEmpty)
                        Positioned(
                          right: -7,
                          top: -7,
                          child: Container(
                            width: 15,
                            height: 15,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${FavouriteSongs.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      color: currentPage == i ? Colors.grey : Colors.black87,
                      fontWeight: currentPage == i
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    playerStateSubscription?.cancel();
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    completionSubscription?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  _buildCurrentPage(),
                  if (message.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 16,
                      right: 16,
                      child: _buildMessage(),
                    ),
                ],
              ),
            ),
            MiniPlayerWidget(
              currentSong: currentSong,
              isPlaying: isPlaying,
              duration: duration,
              position: position,
              onPause: pauseMusic,
              onResume: resumeMusic,
              onStop: stopMusic,
              onSeek: seekMusic,
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }
}