import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audio_fit/models/food.dart';
import 'package:provider/provider.dart';
import 'package:audio_fit/screens/food_diary_screen/food_tile.dart';

class FoodList extends StatefulWidget {
  @override
  _FoodListState createState() => _FoodListState();
}

class _FoodListState extends State<FoodList> {
  @override
  Widget build(BuildContext context) {
    bool foodsNull = false;
    final foods = Provider.of<List<Food>>(context) ?? [];

    if (foods.isNotEmpty) {
      return ListView.builder(
        itemCount: foods.length,
        itemBuilder: (context, index) {
          return FoodTile(food: foods[index]);
        },
      );
    } else {
      return Container(
        height: 80,
        width: 300,
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 15),
        child: Text(
          'Click to log a food',
          textAlign: TextAlign.center,
          style: new TextStyle(color: Colors.grey, fontSize: 15.0),
        ),
      );
    }
  }
}
