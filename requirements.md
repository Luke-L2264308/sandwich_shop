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

## Profile Screen — Requirements & AI Prompt

### Feature Purpose
Add a Profile screen where users can view and edit simple account details (display name, email, phone, shipping address). This is a lightweight local UI only (no real auth or backend required yet) and must be reachable from the bottom of the Order/Cart screen. Include validation, accessible controls, immediate UI feedback, and widget tests. Persisting data may be mocked (in-memory or simple local mock) to enable UI tests.

### Subtasks
- Subtask 1 — Profile Screen UI
  - Fields: Display name (required), Email (required, validate format), Phone (optional, validate digits), Address (multiline, optional).
  - Actions: Save (applies changes to local profile model / mock provider and shows success Snackbar), Cancel (revert edits), Edit mode toggle (view vs edit).
  - Accessibility: semantic labels for all inputs and buttons; minimum touch sizes.
  - File: lib/views/profile_screen.dart

- Subtask 2 — Navigation Link
  - Add a small link/button at the bottom of the order/cart screen labeled "Profile" that pushes the Profile screen.
  - File change: lib/views/cart_screen.dart — append link/button to the bottom area.

- Subtask 3 — Local Mock Persistence & Provider
  - Implement simple profile provider (lib/providers/profile_provider.dart) or extend existing provider pattern to store profile in memory with Future.delayed to simulate async save/load.
  - Methods: Future<Profile> loadProfile(), Future<void> saveProfile(Profile).
  - Optimistic UI not required but keep API consistent with cart provider style for future integration.

- Subtask 4 — Tests
  - Widget tests: test/widget/profile_screen_test.dart
    - Verify initial view mode displays profile fields.
    - Tap Edit -> update fields -> Tap Save -> shows success Snackbar and persists to mock provider.
    - Validation tests: invalid email shows inline error and prevents save.
    - Accessibility: inputs have semantic labels; buttons tappable.
  - Unit tests for provider: test/provider/profile_provider_test.dart (load/save behavior, simulated delay).

### Acceptance Criteria
- Profile screen reachable from Cart/Order screen bottom link.
- Fields validate (email format, required name/email).
- Save shows success Snackbar; mock provider receives updated Profile.
- Widget tests present and passing.
- All interactive controls include semantic labels and minimum touch sizes.

### Manual QA Checklist (brief)
- Open Cart -> tap Profile link -> Profile screen opens.
- Edit name/email/phone/address; invalid email blocks save and shows error.
- Save shows Snackbar and returns to view mode showing updated values.
- Re-open screen loads persisted mock values.

### AI Assistant Prompt (for implementation)
```text
You are building a Flutter Profile screen for the Sandwich Shop app (no real auth needed). Implement a new screen at lib/views/profile_screen.dart that allows viewing and editing a simple user profile with these fields: displayName (required), email (required, valid email), phone (optional, digits only), address (optional, multiline). Provide an Edit toggle that switches between view and edit modes, a Save button that validates input and calls a local mock provider to persist changes asynchronously (simulate with Future.delayed), and a Cancel button that discards edits.

Also:
- Add a navigation link/button labeled "Profile" at the bottom of lib/views/cart_screen.dart to push this screen.
- Create a simple provider at lib/providers/profile_provider.dart with: Future<Profile> loadProfile(), Future<void> saveProfile(Profile). The provider may hold state in memory for now.
- Ensure accessibility: semantic labels for all inputs and buttons; minimum recommended touch sizes.
- Write widget tests at test/widget/profile_screen_test.dart that cover: view mode display, transition to edit mode, validation (invalid email), successful save calling provider, and Snackbar on save.
- Keep UI simple and consistent with app styling. Do not implement backend authentication.

Return the code changes (new files and modified cart_screen link) and the tests.
```

---

## New task: App-wide Drawer + Responsive Navigation

Short description
- Provide a single, accessible app-wide navigation shell that exposes a Drawer on small screens, a NavigationRail on medium screens, and a permanent side navigation on large screens. Make the drawer (or rail/panel) available from all app screens via a shared scaffold/shell.

Exact expected behavior when user acts
- On narrow screens (mobile):
  - AppBar shows hamburger icon.
  - Tap hamburger opens modal Drawer with navigation items and account actions.
  - Drawer items navigate to screens; Drawer closes automatically after navigation.
  - Drawer accessible via keyboard (semanticLabel on the button) and swipe.
- On medium screens (tablet):
  - A persistent, collapsible NavigationRail appears on the left.
  - Selecting an item navigates without opening a modal Drawer.
  - Rail has icons and optional labels when expanded.
- On wide screens (desktop):
  - A permanent side navigation panel is visible with icons + text.
  - The AppBar does not show a hamburger icon for navigation.
- All navigation items share a single source of truth and update selection state consistently.
- All navigation UIs have semantic labels, accessible touch targets, and keyboard focus behavior.

Implementation notes / constraints
- Create a single AppShell widget (lib/widgets/app_shell.dart) that accepts a Widget body and handles drawer/rail/panel rendering based on screen width.
- Replace per-screen Scaffold usage with AppShell(body: MyScreen()) for all top-level screens.
- Use LayoutBuilder or MediaQuery to determine layout breakpoints and AnimatedSwitcher for smooth transitions.
- Centralize navigation items in lib/navigation/navigation_items.dart and use a NavigationProvider (Provider or Riverpod) to manage selection and open/close state.
- Preserve existing routes and ensure deep linking works.

Deliverables
- Widget: lib/widgets/app_shell.dart (BaseScaffold implementation).
- Navigation config: lib/navigation/navigation_items.dart.
- Provider/state: lib/state/navigation_provider.dart (selection, open/close).
- Updates to top-level screens to use AppShell.
- Unit/widget tests:
  - Widget test: AppShell renders Drawer on narrow width and NavigationRail on medium width and side panel on large width.
  - Interaction test: tap hamburger opens drawer; selecting item navigates and closes drawer.
  - Accessibility test: semantic labels exist for open/close actions.
- Brief manual QA steps (incremental): open Drawer, navigate, resize window and confirm UI switches, keyboard open/close, verify deep link navigation.

Reference
- Revisit Worksheet 2, Exercise 6 for adaptive layout hints.