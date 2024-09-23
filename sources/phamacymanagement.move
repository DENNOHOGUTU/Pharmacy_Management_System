#[allow(unused_const)]
module phamacymanagement::pharmacy_management {
    use sui::sui::SUI;
    use std::string::String;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::table::{Self, Table};

    // Errors
    const EInsufficientBalance: u64 = 1;
    const ENotPharmacy: u64 = 2;
    const ENotEmployee: u64 = 3;
    const ENotCustomer: u64 = 4;
    const ENotOrder: u64 = 5;
    const ENotAuthorized: u64 = 6;

    // Structs
    struct Pharmacy has key, store {
        id: UID,
        name: String,
        location: String,
        balance: Balance<SUI>,
        employees: Table<ID, Employee>,
        customers: Table<ID, Customer>,
        orders: Table<ID, Order>,
        inventory: Table<ID, InventoryItem>,
        principal: address,
    }

    struct PharmacyCap has key {
        id: UID,
        for: ID,
    }

    struct Employee has key, store {
        id: UID,
        name: String,
        role: String,
        principal: address,
        balance: Balance<SUI>,
        department: String,
        hireDate: String,
    }

    struct Customer has key, store {
        id: UID,
        name: String,
        age: u64,
        address: String,
        principal: address,
        prescriptionHistory: String,
    }

    struct Order has key, store {
        id: UID,
        customer: address,
        pharmacist: address,
        date: String,
        time: String,
        description: String,
    }

    struct InventoryItem has key, store {
        id: UID,
        name: String,
        quantity: u64,
        unit_price: u64,
    }

    // Pharmacy methods

    /// Adds information about a new pharmacy.
    ///
    /// Returns a `PharmacyCap` object representing the capability to manage the pharmacy.
public fun add_pharmacy_info(
    name: String,
    location: String,
    ctx: &mut TxContext
) : (Pharmacy, PharmacyCap) {
    let id = object::new(ctx);
    let pharmacy = Pharmacy {
        id,
        name,
        location,
        balance: balance::zero<SUI>(),
        principal: tx_context::sender(ctx),
        employees: table::new<ID, Employee>(ctx),
        customers: table::new<ID, Customer>(ctx),
        orders: table::new<ID, Order>(ctx),
        inventory: table::new<ID, InventoryItem>(ctx),
    };


    let cap = PharmacyCap {
        id: object::new(ctx),
        for: object::uid_to_inner(&id),
    };

    // We now directly return the pharmacy and the capability object to the caller
    (pharmacy, cap)
}


    /// Deposits funds into the pharmacy's balance.
    ///
    /// Takes a `Coin<SUI>` amount and adds it to the pharmacy's balance.
    public fun deposit(
        pharmacy: &mut Pharmacy,
        amount: Coin<SUI>,
    ) {
        let coin = coin::into_balance(amount);
        balance::join(&mut pharmacy.balance, coin);
    }

    // Employee methods

    /// Adds information about a new employee.
    ///
    /// Returns an `Employee` object representing the newly added employee.
    public fun add_employee_info(
    name: String,
    role: String,
    department: String,
    hireDate: String,
    ctx: &mut TxContext
) : Employee {
    let id = object::new(ctx);
    let employee = Employee {
        id,
        name,
        role,
        principal: tx_context::sender(ctx),
        balance: balance::zero<SUI>(),
        department,
        hireDate,
    };

    // Directly return the employee object without using transfer::transfer
    employee
}


    /// Updates information about an existing employee.
    ///
    /// Requires authorization from the employee themselves.
    public fun update_employee_info(
        employee: &mut Employee,
        name: String,
        role: String,
        department: String,
        hireDate: String,
        ctx: &mut TxContext
    ) {
        assert!(employee.principal == tx_context::sender(ctx), ENotAuthorized);
        employee.name = name;
        employee.role = role;
        employee.department = department;
        employee.hireDate = hireDate;
    }

    // Pay employee salary

    /// Pays salary to an employee from the pharmacy's balance.
    ///
    /// Takes an `amount` to be paid and transfers it from the pharmacy to the employee.
    public fun pay_employee(
        pharmacy: &mut Pharmacy,
        employee: &mut Employee,
        amount: u64,
        ctx: &mut TxContext
    ) {
        assert!(balance::value(&pharmacy.balance) >= amount, EInsufficientBalance);
        let payment = coin::take(&mut pharmacy.balance, amount, ctx);
        coin::put(&mut employee.balance, payment);
    }

    // Customer methods

    /// Adds information about a new customer.
    ///
    /// Returns a `Customer` object representing the newly added customer.
    public fun add_customer_info(
    name: String,
    age: u64,
    address: String,
    prescriptionHistory: String,
    ctx: &mut TxContext
) : Customer {
    let id = object::new(ctx);
    let customer = Customer {
        id,
        name,
        age,
        address,
        principal: tx_context::sender(ctx),
        prescriptionHistory,
    };

    // Directly return the customer object to the caller
    customer
}


    /// Updates information about an existing customer.
    ///
    /// Requires authorization from the customer themselves.
    public fun update_customer_info(
        customer: &mut Customer,
        name: String,
        age: u64,
        address: String,
        prescriptionHistory: String,
        ctx: &mut TxContext
    ) {
        assert!(customer.principal == tx_context::sender(ctx), ENotAuthorized);
        customer.name = name;
        customer.age = age;
        customer.address = address;
        customer.prescriptionHistory = prescriptionHistory;
    }

    // Order methods

    /// Adds information about a new order.
    ///
    /// Returns an `Order` object representing the newly added order.
    public fun add_order_info(
        pharmacy: &mut Pharmacy,
        customer: &mut Customer,
        pharmacist: &mut Employee,
        date: String,
        time: String,
        description: String,
        ctx: &mut TxContext
    ) {
        let id = object::new(ctx);
        let order = Order {
            id,
            customer: customer.principal,
            pharmacist: pharmacist.principal,
            date,
            time,
            description,
        };

        table::add<ID, Order>(&mut pharmacy.orders, object::uid_to_inner(&order.id), order);
    }

    /// Cancels an existing order.
    ///
    /// Removes the order from the pharmacy's records and deletes associated data.
    public fun cancel_order(
        pharmacy: &mut Pharmacy,
        order_id: ID,
    ) {
        let order = table::remove(&mut pharmacy.orders, order_id);
        let Order {
            id,
            customer: _,
            pharmacist: _,
            date: _,
            time: _,
            description: _,
        } = order;
        object::delete(id);
    }

    // Inventory methods

    /// Adds a new item to the pharmacy's inventory.
    ///
    /// Returns nothing.
    public fun add_inventory_item(
        pharmacy: &mut Pharmacy,
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

        table::add<ID, InventoryItem>(&mut pharmacy.inventory, object::uid_to_inner(&item.id), item);
    }

    /// Updates an existing inventory item.
    ///
    /// Takes `item_id`, `name`, `quantity`, `unit_price` and updates corresponding item in inventory.
    public fun update_inventory_item(
        pharmacy: &mut Pharmacy,
        item_id: ID,
        name: String,
        quantity: u64,
        unit_price: u64,
    ) {
        let item = table::borrow_mut(&mut pharmacy.inventory, item_id);
        item.name = name;
        item.quantity = quantity;
        item.unit_price = unit_price;
    }

    /// Removes an item from the pharmacy's inventory.
    ///
    /// Deletes the item from inventory table and associated data.
    public fun remove_inventory_item(
        pharmacy: &mut Pharmacy,
        item_id: ID,
    ) {
        let item = table::remove(&mut pharmacy.inventory, item_id);
        let InventoryItem { id, name: _, quantity: _, unit_price: _ } = item;
        object::delete(id);
    }

    // Handle pharmacy expenses

    /// Pays an expense from the pharmacy's balance.
    ///
    /// Takes `amount` and transfers it out from the pharmacy's balance.
    public fun pay_expense(
        pharmacy: &mut Pharmacy,
        amount: u64,
        ctx: &mut TxContext
    ) {
        assert!(balance::value(&pharmacy.balance) >= amount, EInsufficientBalance);
        let payment = coin::take(&mut pharmacy.balance, amount, ctx);
        coin::destroy(payment);
    }
}
