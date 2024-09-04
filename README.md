The project is a Pharmacy Management System created with the Move programming language on the Sui blockchain as a smart contract. It is intended to manage important entities including pharmacies, staff, clients, orders, and inventory items in order to simplify and safeguard a pharmacy's operations.

Important Elements: Pharmacy Administration

Pharmacy: Holds data about the pharmacy, such as name, address, staff, clients, orders, inventory, and balance (in SUI tokens). A PharmacyCap struct, which serves as a capacity token for controlling the pharmacy, is also included.
Balance Handling: The pharmacy's financial operations are managed by the system, which enables money to be transferred into the pharmacy's balance and utilized for staff wages or expenditure reimbursement.

Management of Workers:

Employee: Manages employee data, such as department, job, and remaining compensation. Employees may be employed, updated, and paid through the contract, which ensures that only those with the required authority may make changes to their personal information.
Customer Management:

customer: Preserves customer information, including address, age, and previous prescription history. The system permits the secure addition of new customers and the updating of existing data, with authorized checks ensuring data integrity.
Administration of Orders:

Order: Manages the creation and cancellation of customer orders, including details on the order's particulars and the prescribing pharmacist. Orders are linked to specific employees and clients.

Inventory Control:

Inventory Item: Lists the brands, prices, and amounts of the products that are currently in stock at the pharmacy. The technology makes it easier to add, update, and remove inventory items, enabling accurate inventory control.
Security features include:
Verifications of Authorization: make sure that only individuals who have been given authorization, such the owner or employees, are allowed to alter personal information or perform certain duties.
Error Handling: Uses distinct error codes to address problems such as inadequate balance or unauthorized access.


