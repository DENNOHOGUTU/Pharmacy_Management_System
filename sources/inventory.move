module phamacymanagement::inventory {
    use sui::sui::SUI;
    use std::string::String;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::table::{Self, Table};

    // Structs
    struct InventoryItem has key, store {
        id: UID,
        name: String,
        quantity: u64,
        unit_price: u64,
    }

    // Inventory methods

    /// Adds a new item to the pharmacy's inventory.
    ///
    /// Returns nothing.
    public fun add_inventory_item(
        pharmacy: &mut Table<ID, InventoryItem>,
        name: String,
        quantity: u64,
        unit_price: u64,
        ctx: &mut TxContext
    ) {
        let id = object::new(ctx);
        let item = InventoryItem {
            id,
            name,
            quantity,
            unit_price,
        };

        table::add<ID, InventoryItem>(pharmacy, object::uid_to_inner(&item.id), item);
    }

    /// Updates an existing inventory item.
    /// Takes `item_id`, `name`, `quantity`, `unit_price` and updates corresponding item in inventory.
    public fun update_inventory_item(
        pharmacy: &mut Table<ID, InventoryItem>,
        item_id: ID,
        name: String,
        quantity: u64,
        unit_price: u64,
    ) {
        let item = table::borrow_mut(pharmacy, item_id);
        item.name = name;
        item.quantity = quantity;
        item.unit_price = unit_price;
    }

    /// Removes an item from the pharmacy's inventory.
    ///
    /// Deletes the item from inventory table and associated data.
    public fun remove_inventory_item(
        pharmacy: &mut Table<ID, InventoryItem>,
        item_id: ID,
    ) {
        let item = table::remove(pharmacy, item_id);
        let InventoryItem { id, name: _, quantity: _, unit_price: _ } = item;
        object::delete(id);
    }
}