import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:sandwich_shop/views/app_styles.dart';
import 'package:sandwich_shop/views/order_screen.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';
import 'package:sandwich_shop/views/edit_quantity_dialog.dart'; // new import

typedef QuantityChanged = Future<void> Function(int newQuantity);

class QuantityStepper extends StatefulWidget {
  final int quantity;
  final int min;
  final int max;
  final QuantityChanged onChanged;
  final String semanticPrefix;
  // New: optional edit callback that should open an editor and return new value or null.
  final Future<int?> Function(int current)? onEdit;

  const QuantityStepper({
    Key? key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.semanticPrefix = 'Quantity',
    this.onEdit,
  }) : super(key: key);

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper>
    with SingleTickerProviderStateMixin {
  late int _quantity;
  bool _inFlight = false;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void didUpdateWidget(covariant QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity && !_inFlight) {
      setState(() => _quantity = widget.quantity);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _setQuantity(int newQty) async {
    if (newQty < widget.min || newQty > widget.max || _inFlight) return;
    setState(() {
      _quantity = newQty;
      _inFlight = true;
      _animController.forward(from: 0);
    });

    try {
      await widget.onChanged(newQty);
    } catch (_) {
      // on failure, rollback to previous widget.quantity (caller/provider should handle)
      setState(() {
        _quantity = widget.quantity;
      });
    } finally {
      if (mounted) {
        setState(() => _inFlight = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // minimum touch size
    const double buttonSize = 40.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '${widget.semanticPrefix} decrease',
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _quantity > widget.min && !_inFlight
                ? () => _setQuantity(_quantity - 1)
                : null,
            child: SizedBox(
              height: buttonSize,
              width: buttonSize,
              child: Icon(Icons.remove, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.08).animate(
              CurvedAnimation(parent: _animController, curve: Curves.easeOut)),
          child: Semantics(
            label: '${widget.semanticPrefix} value',
            value: '$_quantity',
            liveRegion: true,
            child: GestureDetector(
              onTap: () async {
                // If an edit callback is provided, call it and apply returned value.
                if (widget.onEdit != null) {
                  final int? edited = await widget.onEdit!(_quantity);
                  if (edited != null && edited != _quantity) {
                    await _setQuantity(edited);
                  }
                }
                // Optional: otherwise do nothing (tap-to-edit not enabled)
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: Text('$_quantity', textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: '${widget.semanticPrefix} increase',
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _quantity < widget.max && !_inFlight
                ? () => _setQuantity(_quantity + 1)
                : null,
            child: SizedBox(
              height: buttonSize,
              width: buttonSize,
              child: Icon(Icons.add, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class CartScreen extends StatefulWidget {
  final Cart cart;

  const CartScreen({super.key, required this.cart});

  @override
  State<CartScreen> createState() {
    return _CartScreenState();
  }
}

class _CartScreenState extends State<CartScreen> {
  void _goBack() {
    Navigator.pop(context);
  }

  String _getSizeText(bool isFootlong) {
    if (isFootlong) {
      return 'Footlong';
    } else {
      return 'Six-inch';
    }
  }

  double _getItemPrice(Sandwich sandwich, int quantity) {
    final PricingRepository pricingRepository = PricingRepository();
    return pricingRepository.calculatePrice(
      quantity: quantity,
      isFootlong: sandwich.isFootlong,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 100,
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
        title: const Text(
          'Cart View',
          style: heading1,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              for (MapEntry<Sandwich, int> entry in widget.cart.items.entries)
                Column(
                  children: [
                    Text(entry.key.name, style: heading2),
                    Text(
                      '${_getSizeText(entry.key.isFootlong)} on ${entry.key.breadType.name} bread',
                      style: normalText,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Qty: ${entry.value} - £${_getItemPrice(entry.key, entry.value).toStringAsFixed(2)}',
                          style: normalText,
                        ),
                        QuantityStepper(
                          quantity: entry.value,
                          min: 1,
                          max: 99,
                          onChanged: (newQuantity) async {
                            setState(() {
                              widget.cart
                                  .updateItemQuantity(entry.key, newQuantity);
                            });
                          },
                          // wire tap-to-edit to open modal dialog
                          onEdit: (current) async {
                            final int? edited = await showEditQuantityDialog(
                              context,
                              current: current,
                              min: 1,
                              max: 99,
                            );
                            return edited;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              Text(
                'Total: £${widget.cart.totalPrice.toStringAsFixed(2)}',
                style: heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              StyledButton(
                onPressed: _goBack,
                icon: Icons.arrow_back,
                label: 'Back to Order',
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
