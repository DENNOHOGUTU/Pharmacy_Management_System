module phamacymanagement::customers {
    use sui::sui::SUI;
    use std::string::String;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    // Errors
    const ENotAuthorized: u64 = 6;

    // Structs
    struct Customer has key, store {
        id: UID,
        name: String,
        age: u64,
        address: String,
        principal: address,
        prescriptionHistory: String,
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
}
