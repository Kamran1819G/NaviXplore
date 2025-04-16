import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Updated categories based on the JSON data
  final List<String> _categories = const [
    'All',
    'Mall',
    'Religious Place',
    'Park',
    'Hospital',
    'Market',
    'Restaurant',
    'Library',
    'Electronics Store',
    'Grocery Store',
    'Fast Food Restaurant',
    'Road',
    'Furniture Store',
    'Landmark',
    'Garden',
    'Stadium'
  ];

  @override
  void initState() {
    super.initState();
    // initState logic if needed
  }

  @override
  void dispose() {
    super.dispose();
    // dispose logic if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Light background color for modern look
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Xplore - Navi Mumbai",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontFamily: "Fredoka",
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),

              const SizedBox(height: 16),

              // Modern search bar with shadow
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for grocery shop, gardens, restaurants',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Categories with improved spacing
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(_categories[index],
                            style: TextStyle(
                              color: _selectedCategory == _categories[index]
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight:
                              _selectedCategory == _categories[index]
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            )),
                        selected: _selectedCategory == _categories[index],
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedCategory =
                            selected ? _categories[index] : 'All';
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.deepOrange.shade400,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(color: Colors.grey[300]!)),
                        elevation: 0,
                        pressElevation: 2,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Results count text
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                child: RichText(
                  text: TextSpan(
                    text: 'See what ',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18),
                    children: [
                      TextSpan(
                        text: 'Navi Mumbai ',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const TextSpan(
                        text: 'locals have uncovered',
                      ),
                    ],
                  ),
                ),
              ),

              // Grid layout for places
              Expanded(
                child: _buildPlaceGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('NM-Places').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print('StreamBuilder Error: ${snapshot.error}');
          return Center(child: Text('Something went wrong: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('No places found',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          );
        }

        List<DocumentSnapshot> placesDocs = snapshot.data!.docs;

        List<DocumentSnapshot> filteredPlaces = placesDocs.where((doc) {
          if (_selectedCategory == 'All') return true;
          return (doc['category'] as String?)?.toLowerCase() ==
              _selectedCategory.toLowerCase();
        }).toList();

        filteredPlaces = filteredPlaces.where((doc) {
          final name = (doc['name'] as String?)?.toLowerCase() ?? '';
          return name.contains(_searchQuery.toLowerCase());
        }).toList();

        // Grid layout with 2 columns
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.738, // Adjust for card height
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filteredPlaces.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = filteredPlaces[index];
            Map<String, dynamic> placeData =
            document.data() as Map<String, dynamic>;

            return PlaceCard(placeData: placeData, documentId: document.id);
          },
          // Add this line to improve scrolling physics
          physics: const BouncingScrollPhysics(),
        );
      },
    );
  }
}

class PlaceCard extends StatelessWidget {
  final Map<String, dynamic> placeData;
  final String documentId;

  const PlaceCard({super.key, required this.placeData, required this.documentId});

  @override
  Widget build(BuildContext context) {
    String distanceText = '';
    if (placeData['distance'] != null) {
      String distance = placeData['distance'].toString();
      if (distance.contains('min')) {
        distanceText = distance;
      } else if (distance.contains('hr')) {
        distanceText = distance;
      } else {
        distanceText = '${distance} walk';
      }
    } else {
      distanceText = 'Unknown';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias, // Added for smoother corners
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with bookmark overlay
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Image.network(
                    placeData['imageUrl'] ?? 'https://via.placeholder.com/200',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey[500]),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.bookmark_border,
                            size: 18, color: Colors.deepOrange),
                        onPressed: () {
                          // Add/remove from favorites logic
                        },
                      ),
                    ),
                  ),
                ),
                // Category tag at bottom left
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      placeData['category'] ?? 'Place',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content area
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name with ellipsis for long text
                  Text(
                    placeData['name'] ?? 'Place Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Rating and distance row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating with star
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '${placeData['rating'] ?? 0.0}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Distance with walk icon
                      Row(
                        children: [
                          Icon(Icons.directions_walk,
                              size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(
                            distanceText,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
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