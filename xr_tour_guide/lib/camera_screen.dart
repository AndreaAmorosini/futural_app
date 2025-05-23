import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

class ARCameraScreen extends StatefulWidget {
  // Landmark data passed to the screen
  final String landmarkName;
  final String landmarkDescription;
  final List<String> landmarkImages;
  final double latitude;
  final double longitude;

  const ARCameraScreen({
    Key? key,
    this.landmarkName = "Santuario di Montevergine",
    this.landmarkDescription =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.",
    this.landmarkImages = const [
      'https://picsum.photos/300/200?random=1',
      'https://picsum.photos/300/200?random=2',
      'https://picsum.photos/300/200?random=3',
    ],
    this.latitude = 40.9333,
    this.longitude = 14.7167,
  }) : super(key: key);

  @override
  State<ARCameraScreen> createState() => _ARCameraScreenState();
}

class _ARCameraScreenState extends State<ARCameraScreen> {
  // Controller for the draggable sheet
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // Initial size of the draggable sheet (30% of screen height)
  final double _initialSheetSize = 0.3;
  final double _minSheetSize = 0.2;
  final double _maxSheetSize = 0.8;

  // Flutter Map controller for the mini-map
  final MapController _mapController = MapController();

  // Current position for location tracking
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  // Get current location for the map
  void _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Navigate back to previous screen
  void _navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Build the camera background (simulated with image)
  //TODO : Replace with actual camera view
  Widget _buildCameraBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          // Using a placeholder image that represents the AR camera view
          image: AssetImage(
            'assets/montevergine.jpg',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Build the back button in top left
  Widget _buildBackButton(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 25,
      left: 15,
      child: Container(
        width: screenWidth * 0.15,
        height: screenHeight * 0.07,
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => _navigateBack(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 28,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // Build the mini map in top right using flutter_map (same as tour detail screen)
  Widget _buildMiniMap(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final mapSize = screenWidth * 0.35; // 35% of screen width

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: Container(
        width: mapSize,
        height: mapSize * 0.7, // Rectangular aspect ratio
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Center on the landmark location
              initialCenter: LatLng(widget.latitude, widget.longitude),
              // More zoomed in than the detail screen (16.0 vs 13.0)
              initialZoom: 13.0,
              // Disable interactions for mini-map
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none, // Disable all interactions
              ),
            ),
            children: [
              // Base map layer (same as tour detail screen)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),

              // Current location marker (if available)
              if (_currentPosition != null)
                CurrentLocationLayer(
                  style: LocationMarkerStyle(
                    marker: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Center(
                        child: Icon(
                          Icons.person_pin_circle,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                    markerSize: const Size.square(24), // Smaller for mini-map
                    accuracyCircleColor: AppColors.primary.withOpacity(0.2),
                    headingSectorColor: AppColors.primary.withOpacity(0.6),
                  ),
                ),

              // Landmark marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(widget.latitude, widget.longitude),
                    width: 30, // Smaller marker for mini-map
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the draggable bottom sheet with landmark information
  Widget _buildDraggableSheet(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _initialSheetSize,
      minChildSize: _minSheetSize,
      maxChildSize: _maxSheetSize,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Landmark name/title
                      Text(
                        widget.landmarkName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description section header
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Description text
                      Text(
                        widget.landmarkDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Photos section
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Photo grid
                      _buildPhotoGrid(),

                      // Add some bottom padding for better scrolling experience
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build a grid of photos
  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: widget.landmarkImages.length,
      itemBuilder: (context, index) {
        return _buildPhotoCard(widget.landmarkImages[index], index);
      },
    );
  }

  // Build individual photo card
  Widget _buildPhotoCard(String imageUrl, int index) {
    return GestureDetector(
      onTap: () {
        // Show full-screen image viewer
        _showImageViewer(imageUrl, index);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColors.lightGrey,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.lightGrey,
                child: const Icon(
                  Icons.image_not_supported,
                  color: AppColors.textSecondary,
                  size: 40,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Show full-screen image viewer
  void _showImageViewer(String imageUrl, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => _FullScreenImageViewer(
              images: widget.landmarkImages,
              initialIndex: initialIndex,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background for camera feel
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Camera background (full screen)
          _buildCameraBackground(),

          // Back button (top left)
          _buildBackButton(context),

          // Mini map (top right)
          _buildMiniMap(context),

          // Draggable bottom sheet with landmark info
          _buildDraggableSheet(context),
        ],
      ),
    );
  }
}

// Full-screen image viewer widget
class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 60,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
