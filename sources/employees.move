module phamacymanagement::employees {
    use sui::sui::SUI;
    use std::string::String;
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    // Errors
    const ENotAuthorized: u64 = 6;

    // Structs
    struct Employee has key, store {
        id: UID,
        name: String,
        role: String,
        principal: address,
        balance: Balance<SUI>,
        department: String,
        hireDate: String,
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
}