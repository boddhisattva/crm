# CRM Service

## About

API Backend for the CRM Service

## Note on some handy code related gems used
- Have made use of the `oj` gem as its fast JSON parse & serializer
- Have made use of Doorkeeper gem to provide Oauth capabilities
- Gems like `bullet` have been used to proactively look out for N+1 Queries
- Other gems like `brakeman`, `strong_migrations`, `flog`, `fasterer` and various `rubocop` gems are added for writing more secure, better quality code and for performance and consistent code formatting purposes

## Areas of Improvement
- One can add Rate limiting capabilities
- One can add Writer and Replica DB setup and access relevant API's(like those with `GET` requests) through a replica DB where appropriate for better performance

## Usage

**Please note**: Please read the **Before deploying to production** section before deploying the app to production

### Dependencies
* Ruby 3.3.0, Rails 7.1.3.4
* App is configured to use Postgres DB and has been tested with Postgres v14
  * To install Postgres
    * On Mac: https://postgresapp.com/ is a good option
    * On other Operating Systems: Please refer official Postgres guides [here](https://www.postgresql.org/download/)
* Image uploads is implemented with [Rails Active storage](https://guides.rubyonrails.org/active_storage_overview.html) and one might need to setup a relevant image processing library for image management
  * For this app we've chosen `libvips` as the image processing library. To set it up:
    * Mac: If you use homebrew, one could setup `libvips` via the command: `brew install vips`
    * On other Operating Systems: Please refer to the section [here](https://guides.rubyonrails.org/active_storage_overview.html#requirements)
* Please refer to the Gemfile for the other dependencies

### Basic App Setup
------

#### Installing app dependencies

* Run `bundle install` from a project's root directory to install the related dependencies.

#### Setting up the DB schema
From the project root directory:
* Create the Database Schema with: `rake db:create` and `rake db:migrate`

#### Setting up the DB seeds
* In order to use the CRM API backend service fully(i.e., including Admin API's access) one needs to create new Doorkeeper application & a User with `admin` role
  * One can easily setup both by using the command `rake db:seed`
    * One can look at the `db/seeds.rb` file to see how to individiually create each of these

#### Running the Rails app

* Start the rails app with: `rails s`

#### Running the tests
* The tests that are intended to also serve as a means of documentation of different API scnearios can be run from the project's root directory with the command `rspec`


### Basic API setup for Getting Started with using the app
------

**Please note**:
1. You will need to start the rails server with `rails s` before accessing below API's
2. To access certain param values to make relevant API calls you might need to run a Rails console from the projects root directory.
  a. One can open a new rails console session in development environment with the command: `rails c`

#### 1. User Sign up API

- **About**: This creates a new user in the DB and also generates an access & refresh token.

- **Signup API URL**: `http://localhost:3000/api/v1/users`

- **HTTP Method**: POST

- **Sample POST Request Body and Sample API response**:

  -  **Prequisities**:
    1. Client_id: This corresponds to the id generated when we first created a new Doorkeeper application with the `rake db:seed` command mentioned above.
      a. It's value can be obtained with the command `Doorkeeper::Application.first.uid` specified in Rails console

    2. Email & Password: These values can be as per a users discretion.

  - **Sample POST Request body for User sign up API**:

      ```
      {
          "email": "test2@example.com",
          "password": "password",
          "client_id": "RTYqn8V29w57Vj31a-4qR-1dZHJSZvlFb8y0ILpb3JI"
      }

      ```

      * One can also see how to specify the above POST request params via using `raw` option in an API client like `Postman` [here](./spec/fixtures/files/sample_user_sign_up_api_request.png)


  - **Sample API response for User sign up API**:

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

- **Accessing Protected app API's**:
  *  Upon successfully running the above API
      * The resulting `access_token` that is generated from the API call(as shown in the sample response above) can be used to call the apps protected API's

#### 2. User Login API

- **About**: This generates an access token that can be used to access different protected API's. This functionality is provided out of the box by the doorkeeper gem.

- **Signin URL**: `http://localhost:3000/oauth/token`

- **HTTP Method**: POST

- **Sample POST Request Body and Sample API response**:

  -  **Prequisities**:
    1. Client_id: This corresponds to the id generated when we first created a new Doorkeeper application with the `rake db:seed` command.
    It's value can be obtained with the command `Doorkeeper::Application.first.uid` specified in Rails console

    2. Client_secret: This corresponds to the secret generated when we first created a new Doorkeeper application with the `rake db:seed` command.
    It's value can be obtained with the command `Doorkeeper::Application.first.secret` specified in Rails console

    3. Email & Password: These values correspond to those specified as part of user sign up flow above.

    4. Grant type: As we are using password in exchange for OAuth access and refresh token, the grant_type value should be `password`.

  - **Sample API POST Request body for User Login API**:

    One can see how to specify the POST request params via using `form-data` option in an API client like `Postman` [here](./spec/fixtures/files/sample_login_request_api_call_form_data.png)

  - **Sample API response for User Login API**:

    ```
    {
        "access_token": "Msm_qAlBOZGSt_T0oMp9lj5mGqglBouoDb86rFkWMXQ",
        "token_type": "Bearer",
        "expires_in": 7200,
        "refresh_token": "mo0MFV2aMdsjR7ZFF3S_WMI90WmbxfiEuu76OJ1Z3IM",
        "created_at": 1724276243
    }
    ```

- 3. **Accessing Protected app API's**:
  *  Upon successfully running the above API
      * The resulting `access_token` that is generated from the API call(as shown in the sample response above) can be used to call the apps protected API's

#### 3. Example of accessing a Protected API using the access token generated from 1. or 2. above

  - **Sample API URL**: GET `http://localhost:3000/api/v1/customers` (API to list customers)

  -  **Prequisities**:
    1. Access token: We need to specify the access token in the Headers section using it against a field named `Authorization` as per the below format:
    `Bearer Msm_qAlBOZGSt_T0oMp9lj5mGqglBouoDb86rFkWMXQ`

  - One can see how to call the above API with the `Authorization` field filled with the Bearer token as part of the Headers section in an API client like `Postman` [here](./spec/fixtures/files/sample_api_call.png)

### How to test Image uploads are working in development

* **Prequisites**: We need a user whose reference we could use when creating the customer.

  * This user could be the one created when running the `rake db:seed` command

  * Open a new rails console session in development environment with: `rails c`

  * Create a customer with: `customer = Customer.create!(name: 'Abraham', surname: 'Rogers', identifier: SecureRandom.uuid_v7, created_by_id: User.first.id, last_modified_by_id: User.first.id)`

  * Attach a photo to the customer object via: `customer.photo.attach(io: File.open("#{Rails.root}/spec/fixtures/files/faith_can_move_mountains_rachel_unsplash.jpg"), filename: 'faith_can_move_mountains_rachel_unsplash.jpg', content_type: 'image/jpg')`

  * One can then retrieve a photo URL of the newly attached photo with the command: `customer.photo_url`
    * Sample photo URL value returned from running the above command can look like: `"http://localhost:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MiwicHVyIjoiYmxvYl9pZCJ9fQ==--2af9052e1cfe3f01780ab582fb17f12311aef9a6/faith_can_move_mountains_rachel_unsplash.jpg"`

  * One can then access the image in the web browser by:
    * Starting the rails app server with: `rails s` from the projects root directory
    * Specify the above photo URL in one's browser to access the newly attached photo

 ### Before deploying to production
 ------

- Edit the value of `PHOTO_URL_HOST` when setting up image uploads with a relevant provider for production environment

  * Please note the value of `PHOTO_URL_HOST` is used by the below code in `production.rb` below in Line 101 - 103 [here](https://github.com/boddhisattva/crm/blob/main/config/environments/production.rb#L101-L103)

    ```ruby
    Rails.application.routes.default_url_options = {
      host: ENV['PHOTO_URL_HOST']
    }

    ```
