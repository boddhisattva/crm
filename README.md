# CRM Service

## About

API Backend for the CRM Service

## Areas of Improvement
- One can add Rate limiting capabilities
- One can add Master and Replica setup and access relevan

## Usage

### Dependencies
* Ruby 3.3.0
* Please refer to the Gemfile for the other dependencies

### Basic Setup
* Run `bundle install` from a project's root directory to install the related dependencies.

### Running the program

#### Setting up the DB schema
From the project root directory:
* Create the Database Schema with: `rake db:create` and `rake db:migrate`

#### Setting up the seeds
* In order to use the CRM API backend service one needs an OAuth application & a User with admin role
  * One can easily setup both by using the command `rake db:seed`
    * One can look at the `db/seeds.rb` file to see the code the above command runs

#### Running the rails app

* Start the rails app with: `rails s`

### Basic API setup for Getting Started with using the app

**Please note**:
1. You will need to start the rails server with `rails s` before accessing below API's
2. To access certain param values to make relevant API calls you might need to run a Rails console from the projects root directory. One can open a new rails console session in development environment with the command: `rails c`

#### User Sign up

**About**: This creates a new user in the DB and also generates an access & refresh token.

**Signup URL**: `http://localhost:3000/api/v1/users`

**HTTP Method**: POST

**POST Request Body**:

*  **Prequisities**:
  1. Client_id: This corresponds to the id generated when we first created a new Doorkeeper application with the `rake db:seed` command.

  It's value can be obtained with the command `Doorkeeper::Application.first.uid` specified in Rails console

  2. Email & Password: These values can be as per a users discretion.

**API POST Request body for User sign up**:

```
{
    "email": "test2@example.com",
    "password": "password",
    "client_id": "RTYqn8V29w57Vj31a-4qR-1dZHJSZvlFb8y0ILpb3JI"
}

```

**Sample API response**:

```
{
    "id": 9,
    "email": "test3@example.com",
    "role": "user",
    "access_token": "G57UYQsfz6Fkz3P4_nMmKTGNpSypH1q84HyKYoHlDmk",
    "token_type": "Bearer",
    "expires_in": 7200, # this means 2 hours
    "refresh_token": "db9a44944755f8d0b3e9f3eacc03ddd73be30315343248dd009323f76451105f",
    "created_at": 1724274571
}
```

We can then use the above `access_token` to call protected API's that requires user authentication.

#### User sign in

**About**: This generates an access token that can be used to access different protected API's. This functionality is provided out of the box by the doorkeeper gem.

**Signin URL**: `http://localhost:3000/oauth/token`

**HTTP Method**: POST

**POST Request Body**:

*  **Prequisities**:
  1. Client_id: This corresponds to the id generated when we first created a new Doorkeeper application with the `rake db:seed` command.
  It's value can be obtained with the command `Doorkeeper::Application.first.uid` specified in Rails console

  2. Client_secret: This corresponds to the secret generated when we first created a new Doorkeeper application with the `rake db:seed` command.
  It's value can be obtained with the command `Doorkeeper::Application.first.secret` specified in Rails console

  3. Email & Password: These values correspond to those specified as part of user sign up flow above.

  4. Grant type: As we are using password in exchange for OAuth access and refresh token, the grant_type value should be password.


**API POST Request body for User sign in**:

See how to specify the POST request params via using `form-data` in an API client like `Postman` [here](./spec/fixtures/files/sample_login_request_api_call_form_data.png)


**Sample API response**:

```
{
    "access_token": "Msm_qAlBOZGSt_T0oMp9lj5mGqglBouoDb86rFkWMXQ",
    "token_type": "Bearer",
    "expires_in": 7200,
    "refresh_token": "mo0MFV2aMdsjR7ZFF3S_WMI90WmbxfiEuu76OJ1Z3IM",
    "created_at": 1724276243
}
```

We can then use the above access_token to call protected API's that requires user authentication.

#### Example of accessing an API using the access

**Sample API URL**: GET `http://localhost:3000/api/v1/customers` (API to list customers)

*  **Prequisities**:
  1. Access token: We need to specify the access token in the Headers section using it against a field named `Authorization` as per the below format:
  `Bearer Msm_qAlBOZGSt_T0oMp9lj5mGqglBouoDb86rFkWMXQ`

See how to call the above API with the `Authorization` field filled with the Bearer token as part of the Headers section in an API client like `Postman` [here](./spec/fixtures/files/sample_api_call.png)


### How to test Image uploads are working in development

Prequisites: We need a user whose reference we could use when creating the customer.

* Open a new rails console session in development environment with: `rails c`

* Create a customer: `customer = Customer.create!(name: 't', surname: 'p', identifier: SecureRandom.uuid_v7, created_by_id: User.first.id, last_modified_by_id: User.first.id)`

* Attach a photo to the cusotmer object via: `customer.photo.attach(io: File.open("#{Rails.root}/spec/fixtures/files/faith_can_move_mountains_rachel_unsplash.jpg"), filename: 'faith_can_move_mountains_rachel_unsplash.jpg', content_type: 'image/jpg')`


### Running the tests
* One can run the specs from the project's root directory with the command `rspec`
