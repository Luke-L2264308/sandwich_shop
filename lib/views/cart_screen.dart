import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/checkout_screen.dart';
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

  // New helper to remove an item and offer undo via Snackbar.
  void _removeItemWithUndo(BuildContext context, Sandwich sandwich) {
    final int previousQty = widget.cart.getQuantity(sandwich);
    if (previousQty == 0) return;

    setState(() {
      widget.cart.updateQuantity(sandwich, 0);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${sandwich.name} removed'),
        duration: const Duration(seconds: 7),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              widget.cart.updateQuantity(sandwich, previousQty);
            });
          },
        ),
      ),
    );
  }

  // New: cached snapshot used for undo operations
  Map<Sandwich, int>? _undoSnapshot;

  // New: Confirmation before clearing cart
  Future<void> _confirmClearCart(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cart'),
        content: const Text('Are you sure you want to clear your entire cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true) {
      _clearCartWithUndo(context);
    }
  }

  // New: clear cart and show undo snackbar
  void _clearCartWithUndo(BuildContext context) {
    // cache snapshot
    _undoSnapshot = Map<Sandwich, int>.from(widget.cart.items);
    setState(() {
      widget.cart.clear();
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cart cleared'),
        duration: const Duration(seconds: 7),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            if (_undoSnapshot != null) {
              setState(() {
                widget.cart.clear();
                _undoSnapshot!.forEach((sandwich, qty) {
                  widget.cart.updateQuantity(sandwich, qty);
                });
                _undoSnapshot = null;
              });
            }
          },
        ),
      ),
    );
  }

  // New: Bulk update dialog and apply logic
  Future<void> _showBulkUpdateDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController(text: '1');
    String? errorText;
    final int globalMin = 1;
    final int globalMax = 99;

    final int? result = await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          void submit() {
            final text = controller.text.trim();
            final parsed = int.tryParse(text);
            if (parsed == null) {
              setStateDialog(() => errorText = 'Enter a valid integer');
              return;
            }
            if (parsed < globalMin || parsed > globalMax) {
              setStateDialog(() => errorText =
                  'Enter a value between $globalMin and $globalMax');
              return;
            }
            Navigator.of(ctx).pop(parsed);
          }

          return AlertDialog(
            title: const Text('Bulk update quantities'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Set quantity for all items',
                      errorText: errorText),
                  onSubmitted: (_) => submit(),
                ),
                const SizedBox(height: 8),
                Text('Values will be clamped between $globalMin and $globalMax',
                    style: Theme.of(ctx).textTheme.bodySmall),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: const Text('Cancel')),
              ElevatedButton(onPressed: submit, child: const Text('Apply')),
            ],
          );
        });
      },
    );

    if (result != null) {
      // apply bulk update with undo snapshot
      _undoSnapshot = Map<Sandwich, int>.from(widget.cart.items);
      setState(() {
        widget.cart.items.forEach((sandwich, _) {
          final int clamped = result.clamp(globalMin, globalMax);
          widget.cart.updateQuantity(sandwich, clamped);
        });
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All items set to $result'),
          duration: const Duration(seconds: 7),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (_undoSnapshot != null) {
                setState(() {
                  widget.cart.clear();
                  _undoSnapshot!.forEach((sandwich, qty) {
                    widget.cart.updateQuantity(sandwich, qty);
                  });
                  _undoSnapshot = null;
                });
              }
            },
          ),
        ),
      );
    }
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
                // Wrap each cart row in a Dismissible to enable swipe-to-delete.
                Dismissible(
                  key: ValueKey(entry.key),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    _removeItemWithUndo(context, entry.key);
                  },
                  child: Column(
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
                          // show stepper + trash button
                          Row(
                            children: [
                              QuantityStepper(
                                quantity: entry.value,
                                min: 1,
                                max: 99,
                                onChanged: (newQuantity) async {
                                  setState(() {
                                    widget.cart.updateItemQuantity(
                                        entry.key, newQuantity);
                                  });
                                },
                                onEdit: (current) async {
                                  final int? edited =
                                      await showEditQuantityDialog(
                                    context,
                                    current: current,
                                    min: 1,
                                    max: 99,
                                  );
                                  return edited;
                                },
                              ),
                              const SizedBox(width: 8),
                              Semantics(
                                label: 'Remove ${entry.key.name}',
                                button: true,
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Remove item',
                                  onPressed: () =>
                                      _removeItemWithUndo(context, entry.key),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              Text(
                'Total: £${widget.cart.totalPrice.toStringAsFixed(2)}',
                style: heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // New: Clear Cart and Bulk Update controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.cart.isEmpty
                            ? null
                            : () => _confirmClearCart(context),
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Clear Cart'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.cart.isEmpty
                            ? null
                            : () => _showBulkUpdateDialog(context),
                        icon: const Icon(Icons.format_list_numbered),
                        label: const Text('Bulk Update'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const SizedBox(height: 20),
              Builder(
                builder: (BuildContext context) {
                  final bool cartHasItems = widget.cart.items.isNotEmpty;
                  if (cartHasItems) {
                    return StyledButton(
                      onPressed: _navigateToCheckout,
                      icon: Icons.payment,
                      label: 'Checkout',
                      backgroundColor: Colors.orange,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
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

  Future<void> _navigateToCheckout() async {
    if (widget.cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cart: widget.cart),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        widget.cart.clear();
      });

      final String orderId = result['orderId'] as String;
      final String estimatedTime = result['estimatedTime'] as String;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Order $orderId confirmed! Estimated time: $estimatedTime'),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
