import 'package:xr_tour_guide/models/tour.dart';
import 'package:xr_tour_guide/models/category.dart';

class TourService {
  // Simulate API call to get nearby tours
  Future<List<Tour>> getNearbyTours() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    return [
      Tour(
        id: 'tour_1',
        title: 'Montevergine',
        description: 'Il Santuario di Montevergine è un importante complesso monastico mariano situato a circa 1.270 metri sul livello del mare, nel massiccio del Partenio, nel comune di Mercogliano (Avellino). Fondato nel 1124 da San Guglielmo da Vercelli, il santuario è oggi uno dei principali luoghi di pellegrinaggio del Sud Italia, con oltre un milione di visitatori ogni anno.',
        imagePath: 'assets/montevergine.jpg',
        category: 'Natura',
        subcategory: 'Montagna',
        rating: 4.5,
        reviewCount: 675,
        images: ['assets/montevergine.jpg', 'assets/acquedotto.jpg', 'assets/cibo_example.jpg'],
        location: 'Avellino, Campania',
        latitude: 40.9333,
        longitude: 14.7167,
      ),
      Tour(
        id: 'tour_2',
        title: 'Acquedotto Romano',
        description: 'Discover the beauty of this amazing destination.',
        imagePath: 'assets/acquedotto.jpg',
        category: 'Storia',
        subcategory: 'Archeologia',
        rating: 4.3,
        reviewCount: 425,
        images: ['assets/acquedotto.jpg', 'assets/montevergine.jpg', 'assets/cibo_example.jpg'],
        location: 'Avellino, Campania',
        latitude: 40.9147,
        longitude: 14.7927,
      ),
    ];
  }

  // Simulate API call to get cooking tours
  Future<List<Tour>> getCookingTours() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    return [
      Tour(
        id: 'tour_3',
        title: 'Cucina Tipica Irpina',
        description: 'Experience traditional Irpinian cuisine.',
        imagePath: 'assets/cibo_example.jpg',
        category: 'Cibo',
        subcategory: 'Tradizionale',
        rating: 4.8,
        reviewCount: 312,
        images: ['assets/cibo_example.jpg', 'assets/montevergine.jpg', 'assets/acquedotto.jpg'],
        location: 'Avellino, Campania',
        latitude: 40.9147,
        longitude: 14.7927,
      ),
    ];
  }

  // Simulate API call to get categories
  Future<List<Category>> getCategories() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data
    return [
      Category(name: 'Natura', image: 'assets/natura_categoria.jpg'),
      Category(name: 'Città', image: 'assets/citta_categoria.jpg'),
      Category(name: 'Cultura', image: 'assets/wine_category.jpg'),
      Category(name: 'Cibo', image: 'assets/cibo_example.jpg'),
    ];
  }
}