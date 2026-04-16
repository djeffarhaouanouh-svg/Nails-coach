import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/daily_photo.dart';
import '../../data/repositories/photo_repository.dart';
import '../../theme/app_theme.dart';

class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal photo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Galerie'),
            Tab(text: 'Comparer'),
          ],
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GalleryTab(),
          _CompareTab(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (_, __) {
          final onGallery = _tabController.animation!.value < 0.5;
          return onGallery ? _AddPhotoFab() : const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AddPhotoFab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(photoRepositoryProvider);
    final hasToday = repo.hasPhotoToday();

    return FloatingActionButton.extended(
      onPressed: hasToday
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      const Text('Une photo par jour ! Revenez demain. 📸'),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          : () => _showPhotoOptions(context, ref),
      backgroundColor: hasToday ? AppTheme.textSecondary : AppTheme.primary,
      icon: Icon(hasToday ? Icons.check : Icons.camera_alt),
      label: Text(hasToday ? 'Fait aujourd\'hui' : 'Prendre une photo'),
    );
  }

  void _showPhotoOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ajouter la photo du jour',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Prenez une photo quotidienne pour suivre la progression de la santé de vos ongles',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final repo = ref.read(photoRepositoryProvider);
                  final photo = await repo.capturePhoto();
                  if (photo == null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Impossible d\'accéder à l\'appareil photo. Vérifiez les permissions dans Réglages.'),
                        backgroundColor: AppTheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Prendre avec l\'appareil photo'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final repo = ref.read(photoRepositoryProvider);
                  final photo = await repo.pickFromGallery();
                  if (photo == null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Impossible d\'accéder à la galerie. Vérifiez les permissions dans Réglages.'),
                        backgroundColor: AppTheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Choisir depuis la galerie'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: AppTheme.primary),
                  foregroundColor: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryTab extends ConsumerWidget {
  const _GalleryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photosListProvider);
    final photos = photosAsync.valueOrNull ?? ref.read(photoRepositoryProvider).getAllPhotos();

    if (photos.isEmpty) {
      return _EmptyGallery();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) => _PhotoTile(photo: photos[i]),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_camera_outlined,
              size: 48,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune photo pour l\'instant',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Prenez une photo quotidienne de vos ongles pour suivre visuellement votre progression.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends ConsumerWidget {
  final DailyPhoto photo;
  const _PhotoTile({required this.photo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showFullPhoto(context, ref),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(photo.localPath), fit: BoxFit.cover),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  DateFormat('MMM d').format(photo.date),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullPhoto(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.file(File(photo.localPath)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                DateFormat('EEEE, MMMM d, yyyy').format(photo.date),
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: TextButton.icon(
                onPressed: () => _confirmDelete(ctx, ref),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Supprimer cette photo',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer la photo ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(photoRepositoryProvider).deletePhoto(photo.id);
              if (ctx.mounted) Navigator.pop(ctx); // ferme confirmation
              if (context.mounted) Navigator.pop(context); // ferme plein écran
            },
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CompareTab extends ConsumerStatefulWidget {
  const _CompareTab();

  @override
  ConsumerState<_CompareTab> createState() => _CompareTabState();
}

class _CompareTabState extends ConsumerState<_CompareTab> {
  DailyPhoto? _before;
  DailyPhoto? _after;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(photoRepositoryProvider);
    final photos = repo.getAllPhotos();

    if (photos.length < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Vous avez besoin d\'au moins 2 photos pour comparer. Continuez à enregistrer chaque jour ! 📸',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Selectors
          Row(
            children: [
              Expanded(
                child: _PhotoSelector(
                  label: 'Avant',
                  selected: _before,
                  photos: photos,
                  onSelected: (p) => setState(() => _before = p),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PhotoSelector(
                  label: 'Après',
                  selected: _after,
                  photos: photos,
                  onSelected: (p) => setState(() => _after = p),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_before != null && _after != null)
            Expanded(
              child: _SliderComparison(
                before: _before!,
                after: _after!,
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text(
                  'Sélectionnez une photo "avant" et "après" ci-dessus pour comparer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SliderComparison extends StatefulWidget {
  final DailyPhoto before;
  final DailyPhoto after;

  const _SliderComparison({required this.before, required this.after});

  @override
  State<_SliderComparison> createState() => _SliderComparisonState();
}

class _SliderComparisonState extends State<_SliderComparison> {
  double _sliderPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final dividerX = width * _sliderPosition;

          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _sliderPosition =
                    (_sliderPosition + details.delta.dx / width).clamp(0.02, 0.98);
              });
            },
            onTapDown: (details) {
              setState(() {
                _sliderPosition = (details.localPosition.dx / width).clamp(0.02, 0.98);
              });
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Photo "Après" (full, en dessous)
                Image.file(
                  File(widget.after.localPath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                // Photo "Avant" (clippée à gauche du slider)
                ClipRect(
                  clipper: _LeftClipper(_sliderPosition),
                  child: Image.file(
                    File(widget.before.localPath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                // Label "Avant"
                Positioned(
                  top: 12,
                  left: 12,
                  child: _PhotoLabel(
                    text: 'Avant',
                    date: widget.before.date,
                  ),
                ),
                // Label "Après"
                Positioned(
                  top: 12,
                  right: 12,
                  child: _PhotoLabel(
                    text: 'Après',
                    date: widget.after.date,
                  ),
                ),
                // Ligne de séparation
                Positioned(
                  left: dividerX - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Colors.white,
                  ),
                ),
                // Handle (bouton central)
                Positioned(
                  left: dividerX - 22,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.compare_arrows,
                        color: Colors.black87,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LeftClipper extends CustomClipper<Rect> {
  final double fraction;
  const _LeftClipper(this.fraction);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_LeftClipper old) => old.fraction != fraction;
}

class _PhotoLabel extends StatelessWidget {
  final String text;
  final DateTime date;

  const _PhotoLabel({required this.text, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
          ),
          Text(
            DateFormat('MMM d').format(date),
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _PhotoSelector extends StatelessWidget {
  final String label;
  final DailyPhoto? selected;
  final List<DailyPhoto> photos;
  final ValueChanged<DailyPhoto> onSelected;

  const _PhotoSelector({
    required this.label,
    required this.selected,
    required this.photos,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: selected == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_outlined,
                        color: AppTheme.textSecondary),
                    const SizedBox(height: 4),
                    Text(
                      'Sélectionner $label',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(selected!.localPath), fit: BoxFit.cover),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Sélectionner une photo $label',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  final p = photos[i];
                  return GestureDetector(
                    onTap: () {
                      onSelected(p);
                      Navigator.pop(ctx);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.file(File(p.localPath),
                              width: 90, height: 90, fit: BoxFit.cover),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                DateFormat('MMM d').format(p.date),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
