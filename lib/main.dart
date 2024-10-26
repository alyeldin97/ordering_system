import 'package:flutter/material.dart';

void main() {
  runApp(MealOrderApp());
}

class MealOrderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: MealOrderPage(),
      ),
    );
  }
}

class MealOrderPage extends StatefulWidget {
  @override
  _MealOrderPageState createState() => _MealOrderPageState();
}

class _MealOrderPageState extends State<MealOrderPage>
    with TickerProviderStateMixin {
  List<Meal> meals = [];
  final ValueNotifier<int> totalOrderPrice = ValueNotifier<int>(0);
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  void _addMeal() {
    setState(() {
      final newMeal =
          Meal(name: '', price: 0, onMealUpdated: _updateTotalPrice);
      meals.add(newMeal);
      _controller.forward(from: 0);
    });
    _updateTotalPrice();
  }

  void _removeMeal(int index) {
    setState(() {
      meals.removeAt(index);
    });
    _updateTotalPrice();
  }

  void _updateTotalPrice() {
    int total = meals.fold(0, (sum, meal) => sum + meal.totalMealPrice);
    totalOrderPrice.value = total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("طلبات  الاكل",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  return ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInOut,
                    ),
                    child: MealWidget(
                      meal: meals[index],
                      onRemove: () => _removeMeal(index),
                      onMealUpdated: _updateTotalPrice,
                    ),
                  );
                },
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: totalOrderPrice,
              builder: (context, value, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'إجمالي الطلب: $value جنيه',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                );
              },
            ),
            FloatingActionButton.extended(
              onPressed: _addMeal,
              label: Text('إضافة وجبة', style: TextStyle(color: Colors.white)),
              icon: Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}

class Meal {
  String name;
  int quantity;
  int price;
  List<Order> orders;
  final VoidCallback onMealUpdated;

  Meal(
      {required this.name,
      this.quantity = 0,
      required this.price,
      required this.onMealUpdated})
      : orders = [];

  int get totalMealPrice {
    return orders.fold(0, (sum, order) => sum + order.totalOrderPrice(price));
  }

  void updateMeal() {
    onMealUpdated();
  }
}

class Order {
  String personName;
  int quantity;
  bool isSelected;

  Order({required this.personName, this.quantity = 0, this.isSelected = false});

  int totalOrderPrice(int mealPrice) {
    return quantity * mealPrice;
  }
}

class MealWidget extends StatefulWidget {
  final Meal meal;
  final VoidCallback onRemove;
  final VoidCallback onMealUpdated;

  MealWidget(
      {required this.meal,
      required this.onRemove,
      required this.onMealUpdated});

  @override
  _MealWidgetState createState() => _MealWidgetState();
}

class _MealWidgetState extends State<MealWidget> with TickerProviderStateMixin {
  late TextEditingController _personNameController;
  late TextEditingController _mealPriceController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _personNameController = TextEditingController();
    _mealPriceController =
        TextEditingController(text: widget.meal.price.toString());
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeController.forward();
  }

  void _addOrder() {
    if (_personNameController.text.isNotEmpty && widget.meal.quantity > 0) {
      setState(() {
        widget.meal.orders.add(Order(
            personName: _personNameController.text,
            quantity: widget.meal.quantity));
        _personNameController.clear();
        widget.meal.quantity = 0;
      });
      widget.onMealUpdated();
    }
  }

  void _incrementQuantity() {
    setState(() {
      widget.meal.quantity++;
    });
    widget.onMealUpdated();
  }

  void _decrementQuantity() {
    if (widget.meal.quantity > 0) {
      setState(() {
        widget.meal.quantity--;
      });
      widget.onMealUpdated();
    }
  }

  void _removeOrder(int index) {
    setState(() {
      widget.meal.orders.removeAt(index);
    });
    widget.onMealUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
      child: Card(
        color: Colors.teal[50],
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اسم الوجبة',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 4),
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (value) {
                            widget.meal.name = value;
                          },
                          controller:
                              TextEditingController(text: widget.meal.name),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'السعر',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 4),
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              widget.meal.price = int.tryParse(value) ?? 0;
                            });
                            widget.onMealUpdated();
                          },
                          controller: _mealPriceController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: Colors.teal),
                        onPressed: _decrementQuantity,
                      ),
                      Text('${widget.meal.quantity}',
                          style: TextStyle(fontSize: 20)),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.teal),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: widget.onRemove,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'اسم الزبون',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              TextField(
                controller: _personNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _addOrder,
                icon: Icon(Icons.person_add),
                label: Text('إضافة طلب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.meal.orders.asMap().entries.map((entry) {
                  int index = entry.key;
                  Order order = entry.value;
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: order.isSelected,
                              onChanged: (value) {
                                setState(() {
                                  order.isSelected = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                order.personName,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'إجمالي: ',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text:
                                        '${order.totalOrderPrice(widget.meal.price)} ',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: ' جنيه       ',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'الكمية: ',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: '${order.quantity}   ',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeOrder(index),
                              icon: Icon(Icons.close, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              if (widget.meal.orders.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'إجمالي الوجبة: ${widget.meal.totalMealPrice} جنيه',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
