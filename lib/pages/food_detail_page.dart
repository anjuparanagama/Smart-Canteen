import 'package:flutter/material.dart';
import 'package:unibites/resources/dimension.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class FoodDetailPage extends StatelessWidget {
  final String title;
  final String price;
  final String imagePath;
  final String rating;
  final String subtitle;

  const FoodDetailPage({
    super.key,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.rating,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildHeaderImage(),
          _buildNavigationButtons(context),
          _buildDetailContent(),
        ],
      ),
    );
  }

  // Header Image
  Widget _buildHeaderImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(0),
        bottomRight: Radius.circular(0),
      ),
      child: Image.asset(
        imagePath,
        height: 350,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.image_not_supported, size: 100),
      ),
    );
  }

  // Navigation Buttons (Back and Favorite)
  Widget _buildNavigationButtons(BuildContext context) {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCircularButton(
              backgroundColor: const Color(0xFFFFD634),
              icon: Icons.arrow_back_ios_new,
              iconColor: Colors.black,
              onPressed: () => Navigator.pop(context),
            ),
            _buildCircularButton(
              backgroundColor: Colors.white,
              icon: Iconsax.heart,
              iconColor: Colors.red,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return CircleAvatar(
      backgroundColor: backgroundColor,
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }

  // Detail Content (Bottom Sheet)
  Widget _buildDetailContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 320),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleRow(),
              const SizedBox(height: 3),
              _buildSubtitle(),
              const SizedBox(height: 24),
              _buildInfoCards(),
              const SizedBox(height: 24),
              _buildDescription(),
              // Additional sections could be added here
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Color(0xFFFFD634), size: 20),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      subtitle,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
        height: 1.2,
      ),
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.attach_money_outlined,
            title: 'Rs: $price',
            subtitle: 'Per item',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Iconsax.people,
            title: '01 Serving',
            subtitle: 'Per item',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFD634),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppDimension.paddingDefault,
        horizontal: AppDimension.paddingDefault,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Delicious curries prepared with authentic spices and fresh ingredients. Perfect for a satisfying meal.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}