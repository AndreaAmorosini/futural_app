// lib/screens/tour_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'dart:math' as math;
import 'app_colors.dart';

// Define a class for your waypoints
class Waypoint {
  final String title;
  final String subtitle;
  final String description;
  final LatLng location;
  final List<String> images;
  final String category; // Added category field

  Waypoint({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.images,
    this.category = '', // Default empty category
  });
}

class TourDetailScreen extends StatefulWidget {
  final String tourId;
  final String tourName;
  final String location;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final String category;
  final String description;
  final double latitude;
  final double longitude;

  const TourDetailScreen({
    Key? key,
    required this.tourId,
    required this.tourName,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.category,
    required this.description,
    this.latitude = 48.8566,
    this.longitude = 2.3522,
  }) : super(key: key);

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen>
    with TickerProviderStateMixin {
  String _selectedTab = 'About';
  late List<bool> _expandedWaypoints;
  int _currentImageIndex = 0;
  late PageController _pageController;
  final MapController _mapController = MapController();

  // Selected waypoint for the itinerary view
  int _selectedWaypointIndex = 0;

  // Animation controllers
  late AnimationController _mapAnimationController;
  late Animation<double> _mapAnimation;

  // Bottom sheet controller for itinerary view
  late DraggableScrollableController _sheetController;
  double _sheetMinSize = 0.15; // Initial height ratio
  double _sheetMaxSize = 0.4; // Maximum height ratio

  // Define your waypoints with coordinates
  final List<Waypoint> _waypoints = [
    Waypoint(
      title: 'Tappa 1',
      subtitle: 'Eiffel Tower',
      description:
          'The Eiffel Tower is a wrought-iron lattice tower on the Champ de Mars in Paris, France. It is named after the engineer Gustave Eiffel, whose company designed and built the tower.',
      location: LatLng(48.8584, 2.2945),
      images: ['assets/montevergine.jpg', 'assets/montevergine.jpg'],
      category: 'Cultural',
    ),
    Waypoint(
      title: 'Tappa 2',
      subtitle: 'Louvre Museum',
      description:
          'The Louvre, or the Louvre Museum, is the world\'s most-visited museum and a historic monument in Paris, France.',
      location: LatLng(48.8606, 2.3376),
      images: [],
      category: 'Cultural',
    ),
    Waypoint(
      title: 'Tappa 3',
      subtitle: 'Notre-Dame Cathedral',
      description:
          'Notre-Dame de Paris, referred to simply as Notre-Dame, is a medieval Catholic cathedral on the Île de la Cité in the 4th arrondissement of Paris.',
      location: LatLng(48.8530, 2.3499),
      images: [],
      category: 'Historical',
    ),
    Waypoint(
      title: 'Tappa 4',
      subtitle: 'Arc de Triomphe',
      description:
          'The Arc de Triomphe de l\'Étoile is one of the most famous monuments in Paris, France, standing at the western end of the Champs-Élysées.',
      location: LatLng(48.8738, 2.2950),
      images: [],
      category: 'Historical',
    ),
    Waypoint(
      title: 'Tappa 5',
      subtitle: 'Sacré-Cœur',
      description:
          'The Basilica of the Sacred Heart of Paris, commonly known as Sacré-Cœur Basilica, is a Roman Catholic church and minor basilica in Paris, France.',
      location: LatLng(48.8867, 2.3431),
      images: [],
      category: 'Religious',
    ),
  ];

  late LocationPermission _permission;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _expandedWaypoints = List.generate(
      _waypoints.length,
      (index) => index == 0,
    );
    _checkLocationPermission();
    _pageController = PageController();

    // Initialize animation controllers
    _mapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _mapAnimation = CurvedAnimation(
      parent: _mapAnimationController,
      curve: Curves.easeInOut,
    );

    // Initialize bottom sheet controller
    _sheetController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapAnimationController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    _permission = await Geolocator.checkPermission();
    if (_permission == LocationPermission.denied) {
      _permission = await Geolocator.requestPermission();
      if (_permission == LocationPermission.denied) {
        print('Location permissions are denied.');
        return;
      }
    }

    if (_permission == LocationPermission.deniedForever) {
      print(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
      return;
    }

    _getCurrentLocation();
  }

  void _getCurrentLocation() {
    Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  void _centerMap(LatLng latLng) {
    _mapController.move(latLng, _mapController.camera.zoom);
  }

  // Method to build a waypoint marker for the map view
  Marker _buildWaypointMarker(
    int index,
    Waypoint waypoint, {
    bool isItineraryView = false,
  }) {
    final bool isSelected = _selectedWaypointIndex == index && isItineraryView;

    return Marker(
      point: waypoint.location,
      width: 60, // Increased size for better tapping
      height: 60, // Increased size for better tapping
      child: GestureDetector(
        onTap: () {
          print('Tapped on Waypoint ${index + 1}');
          _centerMap(waypoint.location);

          if (isItineraryView) {
            setState(() {
              _selectedWaypointIndex = index;
            });

            // Animate the bottom sheet to show more details
            _sheetController.animateTo(
              _sheetMinSize + 0.05,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            setState(() {
              for (int i = 0; i < _expandedWaypoints.length; i++) {
                _expandedWaypoints[i] = (i == index);
              }
            });
          }
        },
        child: Stack(
          children: [
            // Shadow for depth
            if (isItineraryView)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),

            // Marker container
            Container(
              width: isItineraryView ? 40 : 32,
              height: isItineraryView ? 40 : 32,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isItineraryView ? 16 : 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build image gallery indicator dots
  Widget _buildImageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.images.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                _currentImageIndex == index
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            physics:
                _selectedTab == 'Itinerario'
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image gallery with pagination
                Stack(
                  children: [
                    // Image gallery
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.asset(
                            widget.images[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),

                    // Status bar area
                    Container(
                      height: MediaQuery.of(context).padding.top,
                      color: Colors.transparent,
                    ),

                    // Back button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    // Image counter
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${widget.images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Image indicator dots
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: _buildImageIndicator(),
                    ),
                  ],
                ),

                // Category, title, and rating
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            if (index < widget.rating.floor()) {
                              return const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              );
                            } else if (index < widget.rating) {
                              return const Icon(
                                Icons.star_half,
                                color: Colors.amber,
                                size: 18,
                              );
                            } else {
                              return const Icon(
                                Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              );
                            }
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.rating} (${widget.reviewCount.toString()})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.tourName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Navigation tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildNavTab(
                        icon: Icons.info_outline,
                        label: 'About',
                        isSelected: _selectedTab == 'About',
                        onTap: () {
                          setState(() {
                            _selectedTab = 'About';
                          });
                        },
                      ),
                      _buildNavTab(
                        icon: Icons.map_outlined,
                        label: 'Mappa',
                        isSelected: _selectedTab == 'Mappa',
                        onTap: () {
                          setState(() {
                            _selectedTab = 'Mappa';
                          });
                        },
                      ),
                      _buildNavTab(
                        icon: Icons.route_outlined,
                        label: 'Itinerario',
                        isSelected: _selectedTab == 'Itinerario',
                        onTap: () {
                          setState(() {
                            _selectedTab = 'Itinerario';
                          });

                          // Start the animation when switching to Itinerario
                          _mapAnimationController.forward();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Content based on selected tab
                if (_selectedTab == 'About') ...[
                  // Tour highlights
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tour Highlights:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Verified reviews section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Verified Reviews',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${widget.reviewCount})',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.rating.toString(),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const Icon(
                                        Icons.star_half,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Based on ${widget.reviewCount} Reviews',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildReviewItem(
                          name: 'Gorgia',
                          date: 'Oct 24, 2024',
                          rating: 4.2,
                          comment:
                              'The tour schedule was nicely arranged, yet we felt rushed and couldn\'t fully savor our time at Disneyland. It would have been...',
                          imageUrl: "",
                        ),
                        const SizedBox(height: 16),
                        _buildReviewItem(
                          name: 'John',
                          date: 'Oct 24, 2024',
                          rating: 4.8,
                          comment:
                              'The historical sites were breathtaking, but the queues were long and it was...',
                          imageUrl: "",
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'More',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_selectedTab == 'Mappa') ...[
                  // Interactive Map view using flutter_map
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(
                              _currentPosition?.latitude ?? widget.latitude,
                              _currentPosition?.longitude ?? widget.longitude,
                            ),
                            initialZoom: 13.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            // Base map layer
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),

                            // Current location marker
                            if (_currentPosition != null)
                              CurrentLocationLayer(
                                style: LocationMarkerStyle(
                                  marker: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Center(
                                      child: Icon(
                                        Icons.person_pin_circle,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  markerSize: const Size.square(40),
                                  accuracyCircleColor: AppColors.primary
                                      .withOpacity(0.3),
                                  headingSectorColor: AppColors.primary
                                      .withOpacity(0.8),
                                ),
                              ),

                            // Waypoints markers
                            MarkerLayer(
                              markers:
                                  _waypoints.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    Waypoint waypoint = entry.value;
                                    return _buildWaypointMarker(
                                      index,
                                      waypoint,
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Waypoints list
                  ..._waypoints.asMap().entries.map((entry) {
                    int index = entry.key;
                    Waypoint waypoint = entry.value;
                    return _buildWaypointItem(
                      index: index,
                      title: waypoint.title,
                      subtitle: waypoint.subtitle,
                      description: waypoint.description,
                      images: waypoint.images,
                    );
                  }).toList(),
                ],

                // Add space at the bottom for non-Itinerario tabs
                if (_selectedTab != 'Itinerario') const SizedBox(height: 40),
              ],
            ),
          ),

          // Itinerario full-screen map view with animation
          if (_selectedTab == 'Itinerario')
            AnimatedBuilder(
              animation: _mapAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: FadeTransition(opacity: _mapAnimation, child: child),
                );
              },
              child: Stack(
                children: [
                  // Full-screen map
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter:
                          _waypoints[0].location, // Start with first waypoint
                      initialZoom: 13.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      // Base map layer
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),

                      // Waypoint markers
                      MarkerLayer(
                        markers:
                            _waypoints.asMap().entries.map((entry) {
                              int index = entry.key;
                              Waypoint waypoint = entry.value;
                              return _buildWaypointMarker(
                                index,
                                waypoint,
                                isItineraryView: true,
                              );
                            }).toList(),
                      ),

                      // Current location marker
                      if (_currentPosition != null)
                        CurrentLocationLayer(
                          style: LocationMarkerStyle(
                            marker: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Center(
                                child: Icon(
                                  Icons.person_pin_circle,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            markerSize: const Size.square(40),
                            accuracyCircleColor: Colors.blue.withOpacity(0.3),
                            headingSectorColor: Colors.blue.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),

                  // Back button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          // Go back to previous screen or tab
                          setState(() {
                            _selectedTab = 'About';
                          });
                          _mapAnimationController.reverse();
                        },
                      ),
                    ),
                  ),

                  // Bottom sheet with waypoint info
                  DraggableScrollableSheet(
                    initialChildSize: _sheetMinSize,
                    minChildSize: _sheetMinSize,
                    maxChildSize: _sheetMaxSize,
                    controller: _sheetController,
                    builder: (context, scrollController) {
                      final selectedWaypoint =
                          _waypoints[_selectedWaypointIndex];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Handle indicator
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 12,
                                    bottom: 8,
                                  ),
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),

                              // Waypoint card
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    // Waypoint image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        selectedWaypoint.images.isNotEmpty
                                            ? selectedWaypoint.images[0]
                                            : 'assets/montevergine.jpg', // Fallback image
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Waypoint info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedWaypoint.category,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          Text(
                                            selectedWaypoint.subtitle,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Camera button
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade700,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          // Camera functionality
                                          print(
                                            'Open camera for AR at waypoint ${_selectedWaypointIndex + 1}',
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Tour info
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tour Name',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '1 City · ${_waypoints.length} Places',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Progress indicator
                                    Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                (_selectedWaypointIndex + 1) /
                                                _waypoints.length *
                                                0.9,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Description (visible when expanded)
                                    const SizedBox(height: 16),
                                    Text(
                                      selectedWaypoint.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaypointItem({
    required int index,
    required String title,
    required String subtitle,
    required String description,
    required List<String> images,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          // Waypoint header with 3D effect
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _expandedWaypoints[index] = !_expandedWaypoints[index];
                    if (_selectedTab == 'Mappa') {
                      // Center map on waypoint when expanded in Mappa tab
                      _centerMap(_waypoints[index].location);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    children: [
                      // Waypoint number with primary color
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Waypoint name with secondary color
                      Expanded(
                        child: Text(
                          subtitle, // Using subtitle for waypoint name
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                      // Expand/collapse icon
                      Icon(
                        _expandedWaypoints[index]
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Waypoint content (expanded) with 3D effect
          if (_expandedWaypoints[index])
            Container(
              margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    // Images (if any)
                    if (images.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, imageIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    images[imageIndex],
                                    height: 100,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // AR Guide button (only for the first waypoint in this example)
                    if (index == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // AR Guide functionality
                              print(
                                'Activate AR Guide for Waypoint ${index + 1}',
                              );
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Attiva Guida AR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required String name,
    required String date,
    required double rating,
    required String comment,
    String imageUrl = "",
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    imageUrl.isNotEmpty ? AssetImage(imageUrl) : null,
                child:
                    imageUrl.isEmpty
                        ? const Icon(
                          Icons.person,
                          size: 24,
                          color: AppColors.textSecondary,
                        )
                        : null,
              ),
              const SizedBox(width: 12),

              // User name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Review comment
          Text(
            comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 8),

          // Read more button
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Read more',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
