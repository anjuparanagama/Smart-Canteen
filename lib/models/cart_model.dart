import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final List<List<String>> _foodItems = [
    ['Rice & Curry (Chicken)', '250.00', 'assets/images/foods/rice_with_chicken.jpg', '4.5', 'Rice with Chicken Curry'],
    ['Rice & Curry (Egg)', '350.00', 'assets/images/foods/rice_with_egg.jpg', '4.8', 'Rice with Boiled Egg'],
    ['Rice & Curry (Fish)', '250.00', 'assets/images/foods/rice_with_fish.jpg', '4.5', 'Rice with Fish Curry'],
    ['Parata', '250.00', 'assets/images/foods/dosa.jpg', '4.5', 'Steaming Fresh Parata'],
    ['Roll (Fish)', '250.00', 'assets/images/foods/fish_roll.webp', '4.5', 'Fresh Fish Rolls'],
    ['Kottu (Chicken)', '250.00', 'assets/images/foods/kottu.jpg', '4.5', 'Hot Kottu with Chicken'],

  ];

  List<List<String>> get foodItems => _foodItems;
}
