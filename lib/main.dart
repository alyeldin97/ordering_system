import 'package:flutter/material.dart';

void main() {
  runApp(MealOrderApp());
}

class MealOrderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MealOrderPage(),
    );
  }
}

class MealOrderPage extends StatefulWidget {
  @override
  _MealOrderPageState createState() => _MealOrderPageState();
}

class _MealOrderPageState extends State<MealOrderPage> {
  List<Meal> meals = []; // List of meals

  void _addMeal() {
    setState(() {
      meals.add(Meal(name: 'New Meal')); // Add a new meal with default name
    });
  }

  void _removeMeal(int index) {
    setState(() {
      meals.removeAt(index); // Remove the meal at the specified index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meal Order App')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                return MealWidget(
                  meal: meals[index],
                  onRemove: () => _removeMeal(index),
                );
              },
            ),
          ),
          FloatingActionButton(
            onPressed: _addMeal,
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class Meal {
  String name;
  int quantity;
  List<Order> orders;

  Meal({required this.name, this.quantity = 0}) : orders = [];
}

class Order {
  String personName;
  int quantity;

  Order({required this.personName, this.quantity = 0});
}

class MealWidget extends StatefulWidget {
  final Meal meal;
  final VoidCallback onRemove;

  MealWidget({required this.meal, required this.onRemove});

  @override
  _MealWidgetState createState() => _MealWidgetState();
}

class _MealWidgetState extends State<MealWidget> {
  late TextEditingController _personNameController;

  @override
  void initState() {
    super.initState();
    _personNameController = TextEditingController();
  }

  void _addOrder() {
    if (_personNameController.text.isNotEmpty && widget.meal.quantity > 0) {
      setState(() {
        widget.meal.orders.add(Order(
            personName: _personNameController.text,
            quantity: widget.meal.quantity));
        // Resetting the fields
        _personNameController.clear();
        widget.meal.quantity = 0; // Reset quantity after submission
      });
    }
  }

  void _incrementQuantity() {
    setState(() {
      widget.meal.quantity++;
    });
  }

  void _decrementQuantity() {
    if (widget.meal.quantity > 0) {
      setState(() {
        widget.meal.quantity--;
      });
    }
  }

  void _removeOrder(int index) {
    setState(() {
      widget.meal.orders
          .removeAt(index); // Remove the order at the specified index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                widget.meal.name = value; // Update the meal name
              },
              controller: TextEditingController(text: widget.meal.name),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: _decrementQuantity),
                    Text('${widget.meal.quantity}',
                        style: TextStyle(fontSize: 20)),
                    IconButton(
                        icon: Icon(Icons.add), onPressed: _incrementQuantity),
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.delete), onPressed: widget.onRemove),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _personNameController,
              decoration: InputDecoration(
                hintText: 'Person\'s Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOrder,
              child: Text('Submit Order'),
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.meal.orders.asMap().entries.map((entry) {
                int index = entry.key;
                Order order = entry.value;
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Text('${order.personName} - x ${order.quantity}'),
                      Spacer(),
                      IconButton(
                        onPressed: () =>
                            _removeOrder(index), // Remove order on tap

                        icon: Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
