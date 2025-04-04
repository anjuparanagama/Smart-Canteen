import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unibites/models/cart_model.dart';
import 'package:unibites/pages/food_detail_page_edit.dart';
import 'package:unibites/resources/color.dart';
import 'package:unibites/resources/dimension.dart';
import 'package:unibites/resources/drawable.dart';
import 'package:unibites/resources/font.dart';
import 'package:unibites/widgets/category_bar.dart';
import '../components/food_tile.dart';
import '../widgets/shimmer_loading.dart';
import 'food_detail_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String selectedCategory = "Popular"; // Default category
  int _selectedIndex = 0;
  String userEmail = "user@itum.mrt.ac.lk";
  // Add a constant for admin email to avoid hardcoding it multiple times
  final String adminEmail = "22it0495@itum.mrt.ac.lk";

  @override
  void initState() {
    super.initState();
    // Load user email when the page initializes
    _loadUserEmail();
  }

  void updateCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('userEmail');

      if (email != null) {
        setState(() {
          userEmail = email;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading user email: $e");
      }
    }
  }

  // Modified to ensure proper navigation and debug print
  void navigateFoodDetailPageEdit(String title, String price, String imagePath, String rating, String subtitle, String documentId) {
    try {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FoodDetailPageEdit(
              title: title,
              price: price,
              imagePath: imagePath,
              rating: rating,
              subtitle: subtitle,
              collectionName: selectedCategory.toLowerCase(), // Use the appropriate collection name
              documentId: documentId, // Pass the document ID
            ),
          ),
        );

        if (kDebugMode) {
          print("Navigation push completed");
        }
      } else {
        if (kDebugMode) {
          print("Context is null or not mounted!");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error navigating to food detail: $e");
      }
    }
  }

  void navigateFoodDetailPage(String title, String price, String imagePath, String rating, String subtitle) {
    try {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FoodDetailPage(
              title: title,
              price: price,
              imagePath: imagePath,
              rating: rating,
              subtitle: subtitle,
            ),
          ),
        );

        if (kDebugMode) {
          print("Navigation push completed");
        }
      } else {
        if (kDebugMode) {
          print("Context is null or not mounted!");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error navigating to food detail: $e");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD634),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu_sharp, color: Colors.black),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), // Fixed: replaced withValues with withOpacity
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _selectedIndex == 0 ? const Color(0xFFFFD634) : Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                    child: Icon(Iconsax.home_1, color: _selectedIndex == 0 ? Colors.black : Colors.grey),
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _selectedIndex == 1 ? const Color(0xFFFFD634) : Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                    child: Icon(Iconsax.shopping_cart, color: _selectedIndex == 1 ? Colors.black : Colors.grey),
                  ),
                ),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _selectedIndex == 2 ? const Color(0xFFFFD634) : Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                    child: Icon(Iconsax.profile_2user, color: _selectedIndex == 2 ? Colors.black : Colors.grey),
                  ),
                ),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimension.paddingDefault * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                  bottom: AppDimension.paddingDefault * 2,
                  top: AppDimension.paddingDefault * 2),
              child: Row(
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.only(right: AppDimension.paddingDefault),
                    child: SvgPicture.asset(
                      AppImages.splashLogo,
                      height: 32,
                      width: 32,
                    ),
                  ),
                  const Text(
                    '👋 Hello,\nAppStaticsX!',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1,
                      color: AppColors.textDarkGrey,
                    ),
                  ),
                ],
              ),
            ),

            // Title
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Taste the Food You',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: AppFonts.outfitBold,
                      fontSize: 24,
                    ),
                  ),
                  TextSpan(
                    text: '\nFavour!',
                    style: TextStyle(
                      color: Color(0xFFFFD634),
                      fontFamily: AppFonts.outfitBold,
                      fontSize: 28,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar
            TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search Foods",
                hintStyle: const TextStyle(
                  color: AppColors.textDarkGrey,
                ),
                prefixIcon: const Icon(Iconsax.search_normal_1_copy,
                  color: AppColors.textDarkGrey,),
                suffixIcon: IconButton(
                  icon: const Icon(Iconsax.setting_5),
                  color: AppColors.textDarkGrey,
                  onPressed: () {
                    if (kDebugMode) {
                      print("Filter button pressed");
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[300],
              ),
            ),

            const SizedBox(height: 16),

            // Category Menu
            InteractiveHorizontalCategoriesMenu(
              onCategorySelected: updateCategory,
            ),

            const SizedBox(height: 16),

            // Selected Category Label
            Text(
              '$selectedCategory Items',
              style: const TextStyle(
                fontFamily: AppFonts.outfitBold,
                color: Colors.black,
                fontSize: 24,
              ),
            ),

            // Fixed: Added proper initialization for SizedBox
            const SizedBox(height: 5),

            Expanded(
              child: Consumer<CartModel>(
                builder: (context, value, child) {
                  // Check if data is loading
                  if (value.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Grid-based shimmer loading effect
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.symmetric(vertical: AppDimension.paddingDefault),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10, // Added for better spacing
                              ),
                              itemCount: 4, // Reduced count for better performance
                              itemBuilder: (context, index) {
                                return ShimmerLoading(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Top rectangle (image placeholder)
                                        Container(
                                          width: double.infinity,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Middle rectangle (title placeholder)
                                        Container(
                                          width: double.infinity,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Bottom rectangle (subtitle/price placeholder)
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.3, // Make it shorter
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4.0),
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

                  // Check if the list is empty after loading (potential error or no data)
                  else if (value.foodItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.no_meals, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No food items available'),
                        ],
                      ),
                    );
                  }
                  // Data loaded successfully - show grid with optimized animations
                  else {
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(vertical: AppDimension.paddingDefault),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10, // Added for better spacing
                      ),
                      itemCount: value.foodItems.length,
                      itemBuilder: (context, index) {
                        final item = value.foodItems[index];

                        // Extract values from the list
                        final title = item[0];
                        final price = item[1];
                        final imagePath = item[2];
                        final rating = item[3];
                        final subtitle = item[4];
                        final documentId = item.length > 5 ? item[5] : "";

                        // Fixed: Simplified animation for better performance
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 300 + (index * 50)),
                            builder: (context, val, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * val),
                                child: child,
                              );
                            },
                            child: FoodTile(
                              title: title,
                              price: price,
                              imagePath: imagePath,
                              rating: rating,
                              subtitle: subtitle,
                              onTap: () {
                                // Check if the user is an admin using the constant
                                if (userEmail == adminEmail) {
                                  navigateFoodDetailPageEdit(title, price, imagePath, rating, subtitle, documentId);
                                } else {
                                  navigateFoodDetailPage(title, price, imagePath, rating, subtitle);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}