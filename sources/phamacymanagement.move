#[allow(unused_const)]
module phamacymanagement::pharmacy_management {
    use sui::sui::SUI;
    use std::string::String;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::table::{Self, Table};
    use phamacymanagement::employees;
    use phamacymanagement::customers;
    use phamacymanagement::orders;
    use phamacymanagement::inventory;

    // Errors
    const EInsufficientBalance: u64 = 1;
    const ENotAuthorized: u64 = 6;

    // Structs
    struct Pharmacy has key, store {
        id: UID,
        name: String,
        location: String,
        balance: Balance<SUI>,
        employees: Table<ID, employees::Employee>,
        customers: Table<ID, customers::Customer>,
        orders: Table<ID, orders::Order>,
        inventory: Table<ID, inventory::InventoryItem>,
        principal: address,
    }

    struct PharmacyCap has key {
        id: UID,
        for: ID,
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
            employees: table::new<ID, employees::Employee>(ctx),
            customers: table::new<ID, customers::Customer>(ctx),
            orders: table::new<ID, orders::Order>(ctx),
            inventory: table::new<ID, inventory::InventoryItem>(ctx),
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

    // Pay employee salary

    /// Pays salary to an employee from the pharmacy's balance.
    ///
    /// Takes an `amount` to be paid and transfers it from the pharmacy to the employee.
    public fun pay_employee(
        pharmacy: &mut Pharmacy,
        employee: &mut employees::Employee,
        amount: u64,
        ctx: &mut TxContext
    ) {
        assert!(balance::value(&pharmacy.balance) >= amount, EInsufficientBalance);
        let payment = coin::take(&mut pharmacy.balance, amount, ctx);
        coin::put(&mut employee.balance, payment);
    }

    // Pay pharmacy expenses

    /// Function to handle pharmacy expenses.
    ///
    /// Deducts the `amount` from the pharmacy's balance and transfers it to the `recipient`.
    public fun pay_expense(
        pharmacy: &mut Pharmacy,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        // Ensure the pharmacy has enough balance to cover the expense
        assert!(balance::value(&pharmacy.balance) >= amount, EInsufficientBalance);

        // Deduct the amount from the pharmacy's balance
        let expense = coin::take(&mut pharmacy.balance, amount, ctx);

        // Transfer the deducted amount to the recipient
        coin::transfer(expense, recipient);
    }

    // Handle pharmacy operational costs by burning tokens
    public fun handle_operational_cost(
        pharmacy: &mut Pharmacy,
        ctx: &mut TxContext
    ) {
        // Suppose the operational cost is 1000 SUI, and you want to burn it
        let burn_amount: u64 = 1000;

        // Call the pay_expense function to burn the amount
        pay_expense(pharmacy, burn_amount, @0x1, ctx);  // Burns 1000 SUI tokens by transferring to address @0x1
    }
}
