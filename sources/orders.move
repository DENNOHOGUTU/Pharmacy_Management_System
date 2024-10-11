module pharmacymanagement::order{
    use sui::sui::SUI;
    use std::string::String;
    use sui::object::{self, UID, ID};
    use sui::tx_context::{self, TxContext};
    use sui::table::{self, Table};

    // stract 
    stract Order has key, store{
        id: UID,
        customer: address,
        pharmacist: address,
        date: u64,
        time: u64,
        description: String,
    }
    // order methods

    /// Adds information about a new order.
    ///

    public fun add_order_info(
        pharmacy: $mut Table<ID, Pharmacy>,
        customer: address,
        pharmacist: address,
        date: u64,
        time: u64,
        description: String,
        ctx: &mut TxContext
    ){
        let id = object::new(ctx);
        let order = Order{
            id,
            customer,
            pharmacist,
            date,
            time,
            description,
        };

        table::add<ID, Order>(pharmacy, object::uid_to_inner(&order.id), order);

    }

    // remove the orfer information from the pharmacys records and delete associated data.

    public fun cancel_order(
        pharmacy: $mut Table<ID, Pharmacy>,
        order_id: ID,
        ctx: &mut TxContext
    ){
        let order = table::get<ID, Order>(pharmacy, order_id);
        let order {
            id,
            customer,
            pharmacist,
            date,
            time,
            description,
        } = order;
        object::delete(id)

    }

}