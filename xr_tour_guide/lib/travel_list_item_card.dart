import 'package:flutter/material.dart';
import 'app_colors.dart';

class TravelListItemCard extends StatelessWidget {
  final String imagePath; // Path to the image asset
  final String title; // The title of the item
  final String description; // A short description of the item
  final double cardWidth; // The width of the card
  final VoidCallback? onTap; // Optional callback for when the card is tapped

  const TravelListItemCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.cardWidth,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // Short description of the list item.
                    Text(
                      description, // Use the description parameter
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
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
      ),
    );
  }
}
