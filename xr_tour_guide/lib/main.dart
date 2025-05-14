import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Import for debugPaintSizeEnabled
import 'package:flutter/services.dart'; // Import for SystemChrome
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  // Ensure the status bar is transparent and the UI can extend behind it
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar transparent
      statusBarIconBrightness:
          Brightness.dark, // Set icons to dark for light backgrounds
      statusBarBrightness:
          Brightness.light, // Set brightness for iOS status bar
    ),
  );

  runApp(const MyApp());
}

// The root of your application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application title, shown in the task switcher.
      title: 'Travel Explorer UI',
      // Hide the debug banner in the corner.
      debugShowCheckedModeBanner: false,
      // Define the application's theme.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Primary color for the app
        // Adaptive visual density helps widgets look good on different platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // The home screen of the application.
      home: const TravelExplorerScreen(),
    );
  }
}

// A reusable widget for the card elements in the horizontal lists.
class TravelListItemCard extends StatelessWidget {
  final String imagePath; // Path to the image asset
  final String title; // The title of the item
  final String description; // A short description of the item
  final double cardWidth; // The width of the card

  const TravelListItemCard({
    Key? key,
    required this.imagePath, // Make imagePath required
    required this.title, // Make title required
    required this.description, // Make description required
    required this.cardWidth, // Make cardWidth required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Use SizedBox to control the width of the card
      width: cardWidth,
      child: Card(
        elevation: 3.0, // Shadow depth for the card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.0,
          ), // Rounded corners for the card
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded makes the image take up the remaining vertical space
            // within the card after the text content.
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10.0),
                ), // Rounded top corners for the image
                child: Image.asset(
                  imagePath, // Use the imagePath parameter
                  fit:
                      BoxFit
                          .cover, // Cover the available space, potentially cropping
                  width:
                      double
                          .infinity, // Make the image take the full width of the card
                ),
              ),
            ),
            // Padding around the text content.
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title of the list item.
                  Text(
                    title, // Use the title parameter
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Short description of the list item.
                  Text(
                    description, // Use the description parameter
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1, // Limit the description to one line
                    overflow:
                        TextOverflow.ellipsis, // Add "..." if text overflows
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// The main screen widget, a StatelessWidget as the content is static for this example.
class TravelExplorerScreen extends StatelessWidget {
  const TravelExplorerScreen({Key? key}) : super(key: key);

  // Extracted method for creating a category item with customizable name and image
  Widget buildCategoryItem({
    required BuildContext context,
    required int index,
    required double width,
    required String categoryName,
    required String imagePath,
    EdgeInsets? margin,
  }) {
    return Container(
      // Responsive width for each category item.
      width: width,
      // Add left margin to the first item and right margin to all items.
      margin:
          margin ?? EdgeInsets.only(left: index == 0 ? 20.0 : 0.0, right: 10.0),
      decoration: BoxDecoration(
        // Rounded corners for the container.
        borderRadius: BorderRadius.circular(10.0),
        // Use the provided image path for the background
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      // Use a Stack to place text on top of the background.
      child: Stack(
        children: [
          // Add a dark overlay to make text more readable on top of images.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.black.withOpacity(
                  0.3,
                ), // Semi-transparent overlay
              ),
            ),
          ),
          // Center the category name text.
          Center(
            child: Text(
              categoryName, // Use the provided category name
              style: const TextStyle(
                color:
                    Colors.white, // Text color for readability on dark overlay
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery provides information about the device's screen size and other properties.
    // We use this to make the layout responsive.
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<Map<String, String>> categories = [
      {'name': 'Natura', 'image': 'assets/natura_categoria.jpg'},
      {'name': 'Città', 'image': 'assets/citta_categoria.jpg'},
      {'name': 'Cultura', 'image': 'assets/wine_category.jpg'},
      {'name': 'Cibo', 'image': 'assets/cibo_example.jpg'},
    ];


    return Scaffold(
      // Extends the body to be behind the app bar. This is crucial for the
      // image to go all the way to the top of the screen, under the status bar.
      extendBodyBehindAppBar: true,
      // Remove the app bar since we want the top bar to scroll with content
      appBar: null,
      // The main content of the screen. Wrapped in SingleChildScrollView to make it scrollable.
      body: SingleChildScrollView(
        // Arrange children vertically.
        child: Column(
          // Align children to the start (left) of the column.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Area for the background image at the top with the title bar
            Stack(
              children: [
                // Background image container
                Container(
                  // Set height as a fraction of the screen height for responsiveness.
                  height: screenHeight * 0.3, // Takes up 30% of screen height
                  // Set width to the full screen width.
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/background_app.jpg',
                      ), // Placeholder asset path
                      fit: BoxFit.cover, // Cover the entire container area
                    ),
                  ),
                  child: Stack(
                    // Stack allows placing widgets on top of each other.
                    children: [
                      // Optional: Add a gradient overlay to blend the image with the content below.
                      Positioned.fill(
                        // Positioned.fill makes this container fill the parent Stack.
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent, // Start with transparent
                                Colors.white.withOpacity(
                                  0.8,
                                ), // Transition to semi-transparent white
                                Colors.white, // End with opaque white
                              ],
                              // Stops define where each color in the gradient is at.
                              stops: const [
                                0.6,
                                0.8,
                                1.0,
                              ], // Gradient effect starts at 60%, ends at 100%
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title bar that scrolls with content
                Positioned(
                  top:
                      MediaQuery.of(context).padding.top +
                      20, // Add padding for status bar
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      // Wrap the Row in a Container for the semi-transparent panel
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                        // child: Row(
                        //   children: [
                        //   SizedBox(
                        //     width: screenWidth * 0.3, // Set the desired width
                        //     height: screenHeight * 0.3, // Set the desired height
                        //     child: Image(image: AssetImage('assets/logo_app.png')),
                        //   ),
                        //   const Spacer(), // Push other content to the right
                        //   ],
                        // ),
                        child:                           
                          SizedBox(
                            width: screenWidth * 0.17, // Set the desired width
                            height: screenHeight * 0.17, // Set the desired height
                            child: Image(image: AssetImage('assets/logo_app.png')),
                          ),
                    ),
                  ),
                ),
              ],
            ),

            // Search Bar Section.
            Padding(
              // Add horizontal and vertical padding around the search bar.
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Dove vuoi andare?', // Placeholder text
                  prefixIcon: const Icon(
                    Icons.search,
                  ), // Search icon at the beginning
                  // Define the border style. OutlineInputBorder creates a border around the field.
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      30.0,
                    ), // Rounded corners
                    borderSide: BorderSide.none, // No visible border line
                  ),
                  filled: true, // Fill the background with a color
                  fillColor: Colors.grey[200], // Light grey background color
                  // Adjust content padding inside the TextField.
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 20,
                  ),
                ),
              ),
            ),

            // Horizontal Category/Filter Section 1.
            Padding(
              // Add vertical and horizontal padding around the filter chips.
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              child: Row(
                // Distribute space evenly between the filter chips.
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // FilterChip is a Material Design widget for filter options.
                  FilterChip(
                    label: const Text('Natura'),
                    onSelected: (bool selected) {
                      // TODO: Implement filter logic based on selection.
                      print('Natura selected: $selected');
                    },
                  ),
                  FilterChip(
                    label: const Text('Cibo'),
                    onSelected: (bool selected) {
                      // TODO: Implement filter logic based on selection.
                      print('Cibo selected: $selected');
                    },
                  ),
                  FilterChip(
                    label: const Text('Cultura'),
                    onSelected: (bool selected) {
                      // TODO: Implement filter logic based on selection.
                      print('Cultura selected: $selected');
                    },
                  ),
                  // Add more FilterChip widgets for other categories as needed.
                ],
              ),
            ),

            // Horizontal List 1: Exploring the Wonders of Sri Lanka.
            Padding(
              // Add vertical padding to separate this section.
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                // Align children to the start (left).
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title.
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      'Luoghi Intorno a te',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // SizedBox with a fixed height for the horizontal ListView.
                  // Setting a height is necessary for a horizontal ListView within a Column.
                  SizedBox(
                    // Responsive height for the horizontal list using a fraction of screenHeight.
                    height:
                        screenHeight * 0.25, // Takes up 25% of screen height
                    // ListView.builder is used for efficient rendering of a potentially large list.
                    child: ListView.builder(
                      // Set the scroll direction to horizontal.
                      scrollDirection: Axis.horizontal,
                      // The number of items in the list. Replace with your actual data count.
                      itemCount: 5, // Example: 5 items
                      // itemBuilder creates each item in the list.
                      itemBuilder: (context, index) {
                        // Use the reusable TravelListItemCard widget.
                        return Padding(
                          // Add left padding to the first item and right padding to all items
                          // for spacing between cards.
                          padding: EdgeInsets.only(
                            left: index == 0 ? 20.0 : 0.0,
                            right: 15.0,
                          ),
                          child: TravelListItemCard(
                            // Pass dummy data or data from your model here.
                            imagePath:
                                'assets/acquedotto.jpg', // Placeholder asset path
                            title:
                                'Destination ${index + 1}', // Placeholder title
                            description:
                                'Discover the beauty of this place.', // Placeholder description
                            cardWidth:
                                screenWidth *
                                0.6, // Responsive width for the card
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Category Section (Resembling the image more closely).
            Padding(
              // Add vertical and horizontal padding.
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              child: Row(
                // Space out the title and the "See More" button.
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categorie',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Button to see more categories.
                  TextButton(
                    onPressed: () {
                      // TODO: Implement action to navigate to a categories screen.
                      print('See More Categories tapped');
                    },
                    child: const Text('See More'),
                  ),
                ],
              ),
            ),
            // SizedBox with a fixed height for the horizontal list of categories.
            SizedBox(
              // Responsive height for the category list.
              height:
                  screenHeight *
                  0.12, // Adjust height as needed to fit the design
              child: ListView.builder(
                // Set scroll direction to horizontal.
                scrollDirection: Axis.horizontal,
                // Number of category items.
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  // Use the extracted method to create category items with the data from our list
                  return buildCategoryItem(
                    context: context,
                    index: index,
                    width: screenWidth * 0.4,
                    categoryName: categories[index]['name']!,
                    imagePath: categories[index]['image']!,
                  );
                },
              ),
            ),

            // Horizontal List 2: A modern culinary Journey.
            Padding(
              // Add vertical padding.
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                // Align children to the start (left).
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title.
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      'Eventi Culinari intorno a te',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // SizedBox with a fixed height for the horizontal ListView.
                  SizedBox(
                    // Responsive height for the horizontal list.
                    height: screenHeight * 0.3, // Takes up 30% of screen height
                    child: ListView.builder(
                      // Set scroll direction to horizontal.
                      scrollDirection: Axis.horizontal,
                      // Number of items in the list. Replace with your actual data count.
                      itemCount: 4, // Example: 4 items
                      itemBuilder: (context, index) {
                        // Use the reusable TravelListItemCard widget.
                        return Padding(
                          // Add left padding to the first item and right padding to all items
                          // for spacing between cards.
                          padding: EdgeInsets.only(
                            left: index == 0 ? 20.0 : 0.0,
                            right: 15.0,
                          ),
                          child: TravelListItemCard(
                            // Pass dummy data or data from your model here.
                            imagePath:
                                'assets/cibo_example.jpg', // Placeholder asset path
                            title: 'Dish ${index + 1}', // Placeholder title
                            description:
                                'A delightful culinary experience.', // Placeholder description
                            cardWidth:
                                screenWidth *
                                0.7, // Responsive width for the card
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // You can add more sections here following the same patterns.
            // Example: Another horizontal list, a vertical list, etc.
            SizedBox(height: 20), // Add some space at the bottom
          ],
        ),
      ),
      // Bottom navigation bar.
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // Define each item in the bottom navigation bar.
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: 0, // Index of the currently selected item (Explore).
        selectedItemColor:
            Colors.blue, // Color of the selected item icon and label.
        unselectedItemColor:
            Colors.grey, // Color of unselected item icons and labels.
        showUnselectedLabels:
            true, // Show labels for items that are not selected.
        onTap: (int index) {
          // TODO: Implement navigation logic based on the tapped item index.
          print('Bottom navigation item tapped: $index');
        },
      ),
    );
  }
}
