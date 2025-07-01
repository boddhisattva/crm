# CRM Service (problem statement markdown converted to PDF version of the project)

You need to build a synthetic API project. The objective is to create a REST API to manage customer data for a small shop. It will work as the backend side for a CRM interface that is being developed by a different team. You’re in charge of the API design and implementation. Here are the requirements for the API:

- The API should be only accessible by a registered user by providing an
authentication mechanism. Follow OAuth 2 protocol for authentication (You can use a third party public OAuth provider)
- A user can only:
• List all customers in the database.
• Get full customer information, including a photo URL.
• Create a new customer:
    - A customer should have at least name, surname, id and a photo field.
    • Name, surname and id are required fields.
    • Image uploads should be able to be managed.
    • The customer should have a reference to the user who created it.
    - Update an existing customer.
    • The customer should hold a reference to the last user who modified it.
    - Delete an existing customer.
- An admin can also:
    - Manage users:
        - Create users
        - Delete users
        - Update users
        - List users
        - Change admin status