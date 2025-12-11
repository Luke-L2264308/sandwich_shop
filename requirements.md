# Cart Item Modification — Requirements Document

## Feature Purpose
Allow users to modify items in their cart (quantity, options, remove, save for later, bulk operations) so they can correct orders, customize sandwiches, and manage cart contents before checkout. All changes must update UI immediately (optimistic), persist to the app’s cart layer, and provide undo/error feedback.

---

## Subtasks

### Subtask 1 — Quantity Stepper (Increment / Decrement)
- Description
  - Inline + and − controls on each cart row to change quantity.
- User stories
  - As a shopper, I can tap + to increase quantity up to item or cart max so I can order multiples.
  - As a shopper, I can tap − to decrease quantity; if quantity becomes zero the item is removed (with undo).
  - As a shopper, if persistence fails, I see an error and my previous quantity is restored.
- Acceptance criteria
  - + increments quantity while quantity < item.maxQuantity (or global cart max); UI subtotal and cart total update immediately.
  - − decrements quantity while quantity > 1; when decrementing to 0, item removal flow triggers and shows Undo Snackbar.
  - UI change is animated; touch targets have semantic labels.
  - Cart provider method updateItemQuantity(cartItemId, newQuantity) is called; on failure, UI rolls back and an error Snackbar appears.
  - Unit tests cover increment, decrement, max-limit enforcement, and rollback on persistence failure.
- Tasks
  - Add stepper widget to lib/views/cart_screen.dart.
  - Add provider method: Future<void> updateItemQuantity(String cartItemId, int quantity).

---

### Subtask 2 — Direct Numeric Edit (Dialog / Inline)
- Description
  - Tap the quantity number to open a numeric input allowing arbitrary integer within bounds.
- User stories
  - As a shopper, I tap the quantity number and enter an exact value (e.g., 10) to set the quantity quickly.
  - As a shopper, I receive validation errors for non-integers, <1, or >maxQuantity.
- Acceptance criteria
  - Tapping opens modal dialog with numeric input pre-filled with current quantity.
  - Input validated: integer, >=1, <= item.maxQuantity/stock; invalid submit shows inline error.
  - On valid submit: UI updates immediately, persists via updateItemQuantity, dialog closes, success or error Snackbar shown.
  - Widget tests validate dialog validation and persistence behavior.
- Tasks
  - Implement edit dialog widget (lib/views/edit_quantity_dialog.dart or inside cart_screen).
  - Wire dialog to provider updateItemQuantity.

---

### Subtask 3 — Remove Item (Trash + Swipe-to-Delete)
- Description
  - Trash icon and swipe-to-delete on cart rows; removal supports Undo.
- User stories
  - As a shopper, I can delete an item via trash icon or swipe.
  - As a shopper, I can undo a deletion from a Snackbar within 5–10s.
- Acceptance criteria
  - Deleting removes item immediately from UI and updates totals; removeItem(cartItemId) called.
  - Removal animates; Snackbar appears with Undo action for configurable duration (default 7s).
  - Undo restores item position and quantity; if persistence confirmed permanent (after undo window or confirmation dialog), item remains removed.
  - Tests cover delete, undo restore, and persistence failure handling.
- Tasks
  - Implement swipe-to-delete and trash button in lib/views/cart_screen.dart.
  - Add provider method: Future<void> removeItem(String cartItemId).
  - Implement undo logic (temporary cache of removed item state).

---


### Subtask 4 — Clear Cart and Bulk Updates
- Description
  - Provide Clear Cart (with confirmation + undo) and Bulk Update quantities.
- User stories
  - As a shopper, I can clear my entire cart with confirmation and undo.
  - As a shopper, I can apply a bulk quantity update to all items (e.g., set all to 2) subject to per-item limits.
- Acceptance criteria
  - Clear Cart shows confirm dialog; on confirm, cart is emptied, totals zeroed, and Undo Snackbar restores previous cart state for a short window.
  - Bulk update dialog validates quantity against each item’s max/stock; applies permissible updates, updates totals, and persists.
  - Provider method clearCart() exists and supports undo via cached snapshot.
  - Tests for clear+undo and bulk update validation and persistence.
- Tasks
  - Add Clear Cart and Bulk Update UI controls (lib/views/cart_screen.dart).
  - Add provider method: Future<void> clearCart() and bulk update helpers.

---

## Cross-cutting Requirements
- State management
  - Use a single consistent approach (choose Provider or Riverpod). Implement lib/providers/cart_provider.dart with methods:
    - Future<void> updateItemQuantity(String cartItemId, int quantity)
    - Future<void> removeItem(String cartItemId)
    - Future<void> editItemOptions(String cartItemId, CartItemOptions options)
    - Future<void> moveToSaved(String cartItemId)
    - Future<void> clearCart()
  - Provider must support optimistic updates with rollback on failure and concurrency safeguards (queued updates, last-write-wins or merge strategy).
- Models
  - lib/models/cart_item.dart: include id, productId, options, unitPrice, quantity, maxQuantity, stock, subtotal getter.
  - CartItemOptions model for options comparison and price calc.
- UX / Accessibility
  - All interactive controls must have semantic labels and minimum touch sizes.
  - Animate quantity/subtotal/row insert/remove.
  - Use Snackbars for success/error/undo with clear messages.
- Persistence
  - Integrate with existing persistence (local DB, prefs or remote). If none, create a simple local persistence mock with Future.delayed to simulate network and enable unit tests.
- Tests
  - Unit tests: test/provider/cart_provider_test.dart — cover updateItemQuantity, removeItem, editItemOptions, moveToSaved, clearCart, merge logic, error rollback.
  - Widget tests: test/widget/cart_screen_test.dart — interaction tests for stepper, edit-dialog, delete+undo, edit options flow, save for later, clear cart.
- Edge cases
  - Stock limit enforcement and messaging.
  - Merge on edited item matching another cart item.
  - Simultaneous updates: handle concurrency and provide user-visible resolution (e.g., show conflict Snackbar).
  - Offline/failed persistence rollback and retry options.

---

## Acceptance Criteria — Overall Feature Complete
- All subtasks implemented and wired into lib/views/cart_screen.dart and provider in lib/providers/cart_provider.dart.
- Unit and widget tests added and passing.
- All interactive flows update UI immediately, persist via provider, and handle failures with rollback and user feedback.
- Animations and accessibility semantics included.
- Manual QA checklist added (see below).

---

## Manual QA Checklist (brief)
- Increment/decrement quantity under/at/over limit.
- Tap quantity and enter valid/invalid values; verify validation and persistence.
- Delete via trash and swipe; test Undo restores item.
- Edit item options and confirm price recalculation and merge behavior.
- Save item for later and restore to cart, including quantity limit prompts.
- Clear cart and Undo restores previous cart.
- Bulk update applies limits per item and persists changes.

--- 

If you want, I can convert this into issue templates and generate example provider and widget scaffolds (file paths and method signatures) next.