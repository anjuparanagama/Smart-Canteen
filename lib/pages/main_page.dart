import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unibites/models/cart_model.dart';
import 'package:unibites/pages/food_detail_page.dart';
import 'package:unibites/resources/color.dart';
import 'package:unibites/resources/dimension.dart';
import 'package:unibites/resources/drawable.dart';
import 'package:unibites/resources/font.dart';
import 'package:unibites/widgets/category_bar.dart';
import '../components/food_tile.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String selectedCategory = "Popular"; // Default category
  int _selectedIndex = 0;

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

  void navigateFoodDetailPage(Map<String, dynamic> foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailPage(
          title: foodItem['title'],
          price: foodItem['price'],
          imagePath: foodItem['imagePath'],
          rating: foodItem['rating'],
          subtitle: foodItem['subtitle'],
        ),
      ),
    );
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
              color: Colors.black.withValues(alpha: 0.1), // Subtle shadow effect
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, -3), // Shadow at the top of the BottomNavigationBar
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), // Rounded top-left corner
            topRight: Radius.circular(20), // Rounded top-right corner
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), // Ensuring the clipping matches decoration
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _selectedIndex == 0 ? Color(0xFFFFD634) : Colors.transparent,
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
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _selectedIndex == 1 ? Color(0xFFFFD634) : Colors.transparent,
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
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _selectedIndex == 2 ? Color(0xFFFFD634) : Colors.transparent,
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

            const SizedBox(height: 16),

            // Food Grid
            Expanded(
              child: Consumer<CartModel>(
                builder: (context, value, child) {
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: value.foodItems.length,
                    itemBuilder: (context, index) {
                      final foodItem = {
                        'title': value.foodItems[index][0],
                        'price': value.foodItems[index][1],
                        'imagePath': value.foodItems[index][2],
                        'rating': value.foodItems[index][3],
                        'subtitle': value.foodItems[index][4],
                      };
                      return FoodTile(
                        title: foodItem['title'] as String,
                        price: foodItem['price'] as String,
                        imagePath: foodItem['imagePath'] as String,
                        rating: foodItem['rating'] as String,
                        subtitle: foodItem['subtitle'] as String,
                        onTap: () => navigateFoodDetailPage(foodItem),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}