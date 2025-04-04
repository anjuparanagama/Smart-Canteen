import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unibites/resources/dimension.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodDetailPageEdit extends StatefulWidget {
  final String title;
  final String price;
  final String imagePath;
  final String rating;
  final String subtitle;
  // Add documentId to identify which document to update
  final String collectionName;
  final String documentId;

  const FoodDetailPageEdit({
    super.key,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.rating,
    required this.subtitle,
    required this.collectionName,
    required this.documentId,
  });

  @override
  State<FoodDetailPageEdit> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPageEdit> {
  // Text editing controllers
  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController ratingController;
  late TextEditingController subtitleController;
  late TextEditingController servingController;
  late TextEditingController perItemController;
  late TextEditingController descriptionTitleController;
  late TextEditingController descriptionController;

  // Track if any changes were made
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the provided values
    titleController = TextEditingController(text: widget.title);
    priceController = TextEditingController(text: widget.price);
    ratingController = TextEditingController(text: widget.rating);
    subtitleController = TextEditingController(text: widget.subtitle);
    servingController = TextEditingController(text: '01 Serving');
    perItemController = TextEditingController(text: 'Per item');
    descriptionTitleController = TextEditingController(text: 'Description');
    descriptionController = TextEditingController(
      text: 'Delicious curries prepared with authentic spices and fresh ingredients. Perfect for a satisfying meal.',
    );

    // Add listeners to detect changes
    titleController.addListener(_onTextChanged);
    priceController.addListener(_onTextChanged);
    ratingController.addListener(_onTextChanged);
    subtitleController.addListener(_onTextChanged);
    servingController.addListener(_onTextChanged);
    perItemController.addListener(_onTextChanged);
    descriptionTitleController.addListener(_onTextChanged);
    descriptionController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    titleController.removeListener(_onTextChanged);
    priceController.removeListener(_onTextChanged);
    ratingController.removeListener(_onTextChanged);
    subtitleController.removeListener(_onTextChanged);
    servingController.removeListener(_onTextChanged);
    perItemController.removeListener(_onTextChanged);
    descriptionTitleController.removeListener(_onTextChanged);
    descriptionController.removeListener(_onTextChanged);

    // Dispose controllers to prevent memory leaks
    titleController.dispose();
    priceController.dispose();
    ratingController.dispose();
    subtitleController.dispose();
    servingController.dispose();
    perItemController.dispose();
    descriptionTitleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Save changes to Firestore
  Future<void> _saveChangesToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.documentId)
          .update({
        'item_name': titleController.text,
        'item_price': priceController.text,
        'item_rating': ratingController.text,
        'item_description': subtitleController.text,
        'description': descriptionController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully!'),
          backgroundColor: Colors.green,),
      );
      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving changes: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  // Show confirmation dialog if changes were made
  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Save Changes'),
        content: const Text('Do you want to save your changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await _saveChangesToFirestore();
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            _buildHeaderImage(),
            _buildNavigationButtons(context),
            _buildDetailContent(),
          ],
        ),
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
        widget.imagePath,
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
              onPressed: () async {
                if (await _onWillPop()) {
                  Navigator.pop(context);
                }
              },
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
          child: SingleChildScrollView(
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
                const SizedBox(height: 30),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _hasChanges ? () {
          showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Save Changes'),
              content: const Text('Are you sure you want to save these changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _saveChangesToFirestore();
                  },
                  child: const Text('Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ],
            ),
          );
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD634),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: TextField(
              controller: titleController,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Food Title',
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Color(0xFFFFD634), size: 20),
              const SizedBox(width: 4),
              SizedBox(
                width: 30,
                child: TextField(
                  controller: ratingController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextField(
        controller: subtitleController,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
          height: 1.2,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: 'Enter subtitle',
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.attach_money_outlined,
            titleController: priceController,
            subtitleController: perItemController,
            isPriceField: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Iconsax.people,
            titleController: servingController,
            subtitleController: perItemController,
            isPriceField: false,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required TextEditingController titleController,
    required TextEditingController subtitleController,
    required bool isPriceField,
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: TextField(
                    controller: titleController,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      prefixText: isPriceField ? 'Rs: ' : '',
                      prefixStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    keyboardType: isPriceField ? TextInputType.number : TextInputType.text,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: TextField(
                    controller: subtitleController,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: TextField(
            controller: descriptionTitleController,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'Section Title',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: TextField(
            controller: descriptionController,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            maxLines: 5,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'Enter description here',
            ),
          ),
        ),
      ],
    );
  }
}