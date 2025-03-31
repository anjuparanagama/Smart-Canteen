import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unibites/resources/color.dart';
import 'package:unibites/resources/dimension.dart';
import 'package:unibites/resources/drawable.dart';
import 'package:unibites/resources/font.dart';

class InteractiveHorizontalCategoriesMenu extends StatefulWidget {
  final Map<int, VoidCallback>? categoryActions;
  final ValueChanged<String>? onCategorySelected; // Callback for category selection

  const InteractiveHorizontalCategoriesMenu({
    super.key,
    this.categoryActions,
    this.onCategorySelected,
  });

  @override
  _InteractiveHorizontalCategoriesMenuState createState() =>
      _InteractiveHorizontalCategoriesMenuState();
}

class _InteractiveHorizontalCategoriesMenuState
    extends State<InteractiveHorizontalCategoriesMenu> {
  // List of categories with icons and labels
  final List<CategoryItem> categories = [
    CategoryItem(
        icon: AppImages.popularIcon,
        label: 'Popular',
        action: () => print('Popular category selected')),
    CategoryItem(
        icon: AppImages.breakfastIcon,
        label: 'Breakfast',
        action: () => print('Breakfast category selected')),
    CategoryItem(
        icon: AppImages.lunchIcon,
        label: 'Lunch',
        action: () => print('Lunch category selected')),
    CategoryItem(
        icon: AppImages.drinksIcon,
        label: 'Drinks',
        action: () => print('Drinks category selected')),
    CategoryItem(
        icon: AppImages.dessertIcon,
        label: 'Dessert',
        action: () => print('Dessert category selected')),
    CategoryItem(
        icon: AppImages.snacksIcon,
        label: 'Snacks',
        action: () => print('Snacks category selected')),
    CategoryItem(
        icon: AppImages.cookiesIcon,
        label: 'Biscuits',
        action: () => print('Biscuits category selected')),
    CategoryItem(
        icon: AppImages.dairyIcon,
        label: 'Dairy',
        action: () => print('Dairy category selected')),
  ];

  // Track the currently selected category index
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });

              // Notify the parent widget of the selected category
              if (widget.onCategorySelected != null) {
                widget.onCategorySelected!(categories[index].label);
              }

              // Priority 1: Use custom action from widget parameter if provided
              if (widget.categoryActions != null &&
                  widget.categoryActions!.containsKey(index)) {
                widget.categoryActions![index]!();
              }
              // Priority 2: Use default action from CategoryItem
              else {
                categories[index].action?.call();
              }
            },
            child: CategoryItemWidget(
              category: categories[index],
              isActive: _selectedIndex == index,
            ),
          );
        },
      ),
    );
  }
}

// CategoryItem class to hold icon, label, and action
class CategoryItem {
  final String icon;
  final String label;
  final VoidCallback? action;

  CategoryItem({
    required this.icon,
    required this.label,
    this.action,
  });
}

// Widget for displaying category items
class CategoryItemWidget extends StatelessWidget {
  final CategoryItem category;
  final bool isActive;

  const CategoryItemWidget({
    super.key,
    required this.category,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isActive ? Color(0xFFFFD634) : Colors.grey[300],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimension.paddingDefault * 2,
                  horizontal: AppDimension.paddingDefault * 1.5),
              child: SvgPicture.asset(
                category.icon,
                width: 24,
                height: 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.label,
            style: TextStyle(
                color: isActive ? Colors.black : AppColors.textDarkGrey,
                fontSize: 13,
                fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
