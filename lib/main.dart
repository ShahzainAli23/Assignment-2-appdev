import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: Colors.purple[50]),
        home: ProductListScreen(),
      ),
    );
  }
}

class ProductProvider extends ChangeNotifier {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String _selectedCategory = "All";
  String _searchQuery = "";
  List<String> _categories = [
    "All",
    "electronics",
    "jewelery",
    "men's clothing",
    "women's clothing",
  ];

  List<dynamic> get products =>
      _products
          .where(
            (p) =>
                (_selectedCategory == "All" ||
                    p['category'] == _selectedCategory) &&
                (p['title'].toLowerCase().contains(_searchQuery.toLowerCase())),
          )
          .toList();

  bool get isLoading => _isLoading;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;

  ProductProvider() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    final response = await http.get(
      Uri.parse("https://fakestoreapi.com/products"),
    );
    if (response.statusCode == 200) {
      _products = json.decode(response.body);
    }
    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _isSearchVisible = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
        backgroundColor: Colors.purple[50],
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchVisible)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search products...",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: provider.setSearchQuery,
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  provider.categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: provider.selectedCategory == cat,
                        onSelected: (_) => provider.setCategory(cat),
                        selectedColor: const Color.fromARGB(
                          255,
                          215,
                          182,
                          222,
                        ), // Selected color
                        backgroundColor:
                            Colors
                                .purple[50], // Matches background when unchecked
                      ),
                    );
                  }).toList(),
            ),
          ),
          Expanded(
            child:
                provider.isLoading
                    ? Shimmer.fromColors(
                      baseColor: const Color.fromARGB(255, 152, 152, 152)!,
                      highlightColor: const Color.fromARGB(255, 227, 227, 227)!,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: 6,
                        itemBuilder:
                            (_, __) => Card(
                              color: const Color.fromARGB(255, 227, 227, 227),
                            ),
                      ),
                    )
                    : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: provider.products.length,
                      itemBuilder: (context, index) {
                        final product = provider.products[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    0.4,
                                  ), // Shadow color
                                  blurRadius: 10, // How soft the shadow is
                                  spreadRadius:
                                      1, // How much the shadow spreads
                                  offset: Offset(
                                    0,
                                    2,
                                  ), // The position of the shadow
                                ),
                              ],
                            ),
                            margin: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex:
                                      product['title'].length > 30
                                          ? 5
                                          : 6, // Adjust image height
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: Image.network(
                                      product['image'],
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['title'],
                                        maxLines:
                                            product['title'].length > 30
                                                ? 2
                                                : 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "\$${product['price']}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          buildStarRating(
                                            (product['rating']['rate'] as num)
                                                .toDouble(),
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
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final dynamic product;
  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    double screenHeight =
        MediaQuery.of(context).size.height; // Get screen height

    return Scaffold(
      backgroundColor: Colors.purple[50], // Background color
      appBar: AppBar(
        backgroundColor: Colors.purple[50], // Same color as background
        elevation: 0, // Remove shadow
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image at top, covering full width, taking 30% of screen height
            Container(
              height: screenHeight * 0.3, // 30% of screen height
              width: double.infinity, // Full width
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(product['image']),
                  fit: BoxFit.cover, // Ensures full coverage
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "\$${product['price']}",
                    style: TextStyle(fontSize: 22, color: Colors.green),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      buildStarRating(
                        (product['rating']['rate'] as num).toDouble(),
                      ), // Star rating
                      SizedBox(width: 10),
                      Text(
                        "(${product['rating']['count']})",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(product['description'], style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildStarRating(double rating) {
  int fullStars = rating.floor();
  bool hasHalfStar = (rating - fullStars) >= 0.5;
  int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

  return Row(
    children: [
      for (int i = 0; i < fullStars; i++)
        Icon(Icons.star, color: Colors.amber, size: 18),
      if (hasHalfStar) Icon(Icons.star_half, color: Colors.amber, size: 18),
      for (int i = 0; i < emptyStars; i++)
        Icon(Icons.star_border, color: Colors.grey, size: 18),
    ],
  );
}
