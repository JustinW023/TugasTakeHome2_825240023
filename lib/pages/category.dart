import 'package:flutter/material.dart';
import '../widgets/sectiontitle.dart';

class CategoryPage extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onSelectCategory;

  const CategoryPage({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final categoryIcons = <String, IconData>{
      'Semua': Icons.apps,
      'Garage': Icons.music_note,
      'Rock': Icons.music_note,
      'Jazz': Icons.album,
      'Electronic': Icons.graphic_eq,
      'Classical': Icons.album,
      'Metal': Icons.queue_music,
      'Country': Icons.audiotrack,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitleWidget(
            title: 'Pilih Kategori Musik',
            subtitle: 'Tekan kategori untuk mencari lagu berdasarkan genre',
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.25,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];

              return GestureDetector(
                onTap: () => onSelectCategory(category),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedCategory == category
                          ? Colors.grey
                          : Colors.white,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        categoryIcons[category] ?? Icons.music_note,
                        color: Colors.grey,
                        size: 26,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}