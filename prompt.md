You are an expert Flutter developer. Context: repository "sandwich_shop" (Flutter), two screens: OrderScreen (select sandwiches) and CartScreen (view cart + total). I want users to be able to modify cart items. Implement the features below in the app (UI, state updates, persistence if present, and tests). For each feature produce: widget changes, state-management changes (Provider/Riverpod/Bloc — pick one and be consistent), unit tests, and brief integration test steps. Be explicit about file paths and method signatures.

Features (for each: short description + exact expected behavior when the user acts):

1) Quantity stepper (increment / decrement buttons)
- Description: Provide + and − buttons inline on each cart row to increase/decrease item quantity.
- On action:
  - Tap +: if quantity < maxAllowed (use item.maxQuantity or cart max, e.g., 5) increment quantity, update item subtotal and cart total immediately (optimistic update), persist change, animate quantity change.
  - Tap −: if quantity > 1 decrement; if quantity would go to 0, remove the item (see Remove item behavior) or disable − at 1 based on UX preference.
  - If persistence fails, revert to previous quantity and show an error Snackbar.

2) Direct numeric edit (dialog or inline editable field)
- Description: Tap the quantity number to open a numeric input dialog (or inline edit) allowing arbitrary quantity within bounds.
- On action:
  - Validate input (integer, >=1, maxQuantity). If invalid, show inline error and prevent submit.
  - On submit, update quantity, recalc subtotal and cart total, persist. Show success or error feedback. Close dialog.

3) Remove item (delete)
- Description: Provide a trash icon and swipe-to-delete on cart rows.
- On action:
  - Tap trash or swipe: remove item from cart, update totals immediately, animate removal.
  - Show Undo Snackbar for 5–10s that restores the removed item to its previous position and quantity.
  - If user confirms permanent delete (if using confirmation modal), do not allow restore after undo window.

4) Edit item options (replace / customize)
- Description: Allow editing sandwich options (bread, toppings, size) from cart row (Edit button).
- On action:
  - Open an EditItem screen pre-filled with the cart item configuration.
  - When user saves changes, recalc item price (based on selected options), update the cart item and totals, persist change, and animate the update.
  - If new configuration duplicates an existing cart item, merge quantities instead of creating a duplicate (ask user or auto-merge based on setting).

5) Save for later / Move to wishlist
- Description: Allow moving an item from cart to a "Saved for later" list.
- On action:
  - Move removes item from cart, updates totals, adds entry to Saved list in profile/state.
  - Provide an action in Saved list to move back to cart (respecting stock and maxQuantity); if adding back would exceed limits, prompt user to adjust quantity.

6) Clear cart and bulk updates
- Description: Provide "Clear Cart" (confirm) and "Update all quantities" capabilities.
- On action:
  - Clear Cart: show confirm dialog; on confirm, remove all items, update totals to zero, show Undo Snackbar that restores previous state for a short window.
  - Bulk update (e.g., set all quantities to X): validate X per-item against max/stock, apply changes, update totals, persist.

Non-functional / UX requirements
- All updates must update subtotal and cart total immediately and animate changes where appropriate.
- Provide accessible touch targets and semantic labels for buttons.
- Use optimistic UI updates with rollback on failure; show Snackbars for success/error/undo.

Constraints / Edge cases to handle
- Stock limits and per-item max quantity.
- Price recalculation when options change.
- Merge logic when edited item matches existing cart item.
- Concurrency: handle two simultaneous updates cleanly.

Deliverables
- A patch or code snippets for the modified files above (widgets, provider, models).
- Unit and widget tests as listed.
- Brief manual test plan steps for QA (increment/decrement, edit, remove, undo, save for later).

