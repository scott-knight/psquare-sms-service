# PSquare SMS Service Example

This is a Rails 6 api service application which submits SMS text messages to external SMS services. [Postgres 12](https://postgresapp.com/downloads.html) is used for record storage, specifically to take advantage of TSVECTOR type fields. The app also requires that Redis and Sidekiq instances are running in parallel with the app. Instructions for running all the required services are outlined below.

While there are some complex parts to this app, it was developed using [K.I.S.S. principals](https://medium.com/@devisha.singh/the-kiss-principle-in-software-development-everything-you-need-to-know-dd8ea6e46bcd). No one likes a bloated, hard to read, useless, code base. If you find code that can use improvement feel free to reach out to me.



<br/>

## RBENV, RBENV Libraries, and Gems

[RBENV](https://github.com/sstephenson/rbenv) and [RBENV-GEMSET](https://github.com/jf/rbenv-gemset) are used to manange Ruby and install ruby gems. BREW was used to install [RBENV](https://github.com/sstephenson/rbenv) and the supportive RBENV libraries using: `brew install rbenv rbenv-gemset rbenv-use rbenv-aliases`. 

`rbenv-gemset` will automatically manage gems for the current Ruby version (set in memory by RBENV), in gemsets, if there is a `.ruby-gemset` file in the project directory. If `.ruby-gemset` isn't found, it will install the gems in the `global` scope of the current Ruby version.

### Installing a Ruby with RBENV

To install a Ruby version with RBENV you simply pass the version you want to install to RBENV, like so:

```sh
$ rbenv install 2.7.2
```

Once installed, run the `rehash` function to update RBENVs inventory for your current console session:

```sh
rbenv rehash
```

All newly instantiated console sessions will automatically have access to the installed Ruby.

### Installing the Gems

Once you have the appropriate Ruby installed, you can run `Bundler` to install the gems for the app. Run the following:

```sh
$ bundle install
```

Once installed, if you would like to update the installed gems, run the following:

```sh
$ bundle update
```

To see the list of gems that will be installed, review the `Gemfile` found in the project root.

<br/>

## Running this content locally

This application will contact exteral apis which will send a responses when they have compeleted their tasks. You will need to setup your computer to accept the responses from the external source.

<br/>

### Setup to receive external requests using NGROK

For this app to work locally you have to have a way for the external service to send messages back to your setup, without it, you can send messages but you wont be able to receive them. The easiest way to make your `localhost:3000` server instance accessable publically would be to use [ngrok](https://ngrok.com). When you go to the ngrok site, you will need to create an account if you don't have one. Login to see the dashboard information, download the ngrok executable, unzip the executable, set the authorization, then run the executable.

  1. Create a free account (if you don't already have one) and login.
  2. Download ngrok (if you haven't already). At the console, unzip the downlaoded file: `unzip /path/to/ngrok.zip`.
  3. In the [setup documentation dashboard](https://dashboard.ngrok.com/get-started/setup) there is a section named `Connect your account` which contains a command to set your authtoken. Copy the command, paste it into the console, run the command. It should look something like this: `./ngrok authtoken eu7thsalhsadhytr98i76hy66563hd65sh2`
  4. Fire up ngrok by running `./ngrok http 3000` in the console

<br/>

### The `master.key` and `credentials.yml.enc`

Normally, you wouldn't expose the `master.key` file in the code. However, as this is an example Rails app, I have added `master.key` to be tracked by git. To view or edit `credentials.yml.enc` you will need to runthe following:

```
EDITOR="vim --wait" bin/rails credentials:edit
```

When you save and close the file, `credentials.yml.enc` will automatically re-encrypt with the new changes.

<br/>

## Running Rails, Redis, and Sidekiq

You can run each of the services in one of two ways. You can run each service indivisually in their own console, or you can run Foreman which starts all the services automatically.

### Running Services Individually

There are advantages to running services individually. Mainly, when you add `binding.pry` break-points in the code, the correlating console (Rails or Sidekiq) will be available for you to work in.

To start each service individually, open 4 terminal sessions and run one line in each of the sessions. The lines are as follows:

Terminal 1
```sh
redis-server
```

Terminal 2
```sh
bundle exec puma -p 3000 -C config/puma.rb
```

Terminal 3
```sh
bundle exec sidekiq
```

Terminal 4
```sh
ngrok http 3000
```

### Running Services with Foreman

To run all services with `Foreman`, you only need one terminal session. Simply run the following:

```sh
foreman start
```

<br/>


## API Details

This app was created to send fake sms text content to 2 separate dummy apis, hosted on AWS. The dummy apis randomly fail on connection attempts. They also randomly return success or failure responses.

This app was also created to send the messages in a load balance of 30% to server 1 and 70% to server 2. After it sends around 10 messages you should be able to query the sms_messages index endpoint and view a paginated list of SmsMessages. The `meta` in the returned JSON contains the `load_balance_ratio` which should indicate an estimated 3/7 split on the load.

After it submits a message to the external api, the external api will respond with a failure or success response. The background worker that started the job of sending the message will attempt to send the message again, for a maximum of 3 times. If the 3 times are exceeded, it will attempt to contact the alternate server, for a maximum of 3 times. The total attemps count is saved to the sms_message object.

<br/>

## API Endpoints

Below are the defined api endpoints that allow you to create, view, and even resend messages.

#### Index

The endpoint for the index view is:

```sh
GET http://localhost:3000/v1/sms_messages
```

The index endpoint accepts params for searching sms_messages. Please review [sms_messages_controller.rb#index](https://github.com/scott-knight/psquare-sms-service/blob/master/app/controllers/v1/sms_messages_controller.rb#L6) for the list of params.

The index view returns a collection of serialzed JSON sms_messages. For example:

```json
{
  "data": [
    {
      "id": "e1bcdbb7-0511-4868-be31-02bfd21c1037",
      "type": "sms_message",
      "attributes": {
        "phone_number": "9139988888",
        "message_txt": "This is for my rails sms message service",
        "message_uuid": "87450964-0040-4126-93c9-ad07a33e9f69",
        "status": "delivered",
        "total_tries": 3,
        "url_domain": "https://jo3kcwlvke.execute-api.us-west-2.amazonaws.com",
        "url_path": "/dev/provider1",
        "created_at": "2020-10-08T03:32:13.924Z",
        "updated_at": "2020-10-08T03:32:20.207Z",
        "discarded_at": null
      },
      "links": {
        "self": {
          "url": "/v1/sms_messages/e1bcdbb7-0511-4868-be31-02bfd21c1037"
        }
      }
    },
    { ... }
  ],
  "meta": {
    "pagination": {
      "count": 8,
      "page": 1,
      "prev": null,
      "next": null,
      "last": 1
    },
    "load_balance_ratio": 0.4419
  }
}
```

As you can see in the example, the data returns a paginated array, pagination meta data and the current `load_balance_ratio`.

The `Pagy` gem is used to build and delivery the paginated content. The `jsonapi-serializer` gem is used to build the serialzed JSON.

<br/>

### Create

To create and send an sms message to the external api, use the following endpoint:

```sh
POST http://localhost:3000/v1/sms_messages
```

You will need to send the following payload:

```json
{
  "sms_message": {
    "phone_number": <your number>,
    "message_txt": <your message>
  }
}
```

This exact structure is expected. If you leave out a field, you should receive and error.

Once a message is POST'ed, the app will queue it for delivery via Sidekiq and Redis. The response you'll receive will be a serialzed object that looks like this:

```json
{
  "data": {
    "id": "e1bcdbb7-0511-4868-be31-02bfd21c1037",
    "type": "sms_message",
    "attributes": {
      "phone_number": "9139988888",
      "message_txt": "This is for my rails sms message service",
      "message_uuid": null,
      "status": null,
      "total_tries": null,
      "url_domain": null,
      "url_path": null,
      "created_at": "2020-10-08T03:32:13.924Z",
      "updated_at": "2020-10-08T03:32:13.924Z",
      "discarded_at": null
    },
    "links": {
      "self": {
        "url": "/v1/sms_messages/e1bcdbb7-0511-4868-be31-02bfd21c1037"
        }
      }
  },
  "meta": {
    "server_message": "sms_message was sent to the queue"
  }
}
```

If you visit the self URL you will be able to see the status of the message.

<br/>

### The SmsMessage Object

Looking at the returned object above, you see the following fields:

* phone_number (STRING) **required** - Sent with your POST.
* message_txt  (TEXT) **required** - Sent with your POST.
* message_uuid (TEXT) - This is the UUID sent by the external API with a 200 response.
* status (STRING)- This is the status message sent by the external api or by this apps messaging service if ther are 6 failed attempts.
* total_tries (INTEGER)- This records the total number of tries the worker attempted to send the message.
* url_domain (STRING) - This records the domain the message was sent to. I realize it's overkill to record this, but it's nice historical data.
* url_path (STRING) - This is the succesful path that was contacted.
* create_at (DateTime) - stamp when the record was created.
* updated_at (DateTime) - stamp when the record gets update, initially the same as created_at.
* discarded_at (DateTime) - stamp for a softdelete of the record.

The `meta > server_message` is the message added by the controller to let you know what happened.

In addition to the described fields above, there is also a field `tsv` which stores indexed TSVECTOR data on the message_text field. This makes searching for information by text fast and efficient. Other efficient indexes have been created for other fields as well. Details can be found in the migrations and `schema.sql` file.

<br/>

### Show

To view the status of an sms_message, you can call the following:

```sh
GET http://localhost:3000/v1/sms_messages/:id
```

Example:

```sh
localhost:3000/v1/sms_messages/f502f29e-6e34-4502-b011-41b5a5f161aa
```

This will return a JSON representation of the state of the data as demonstrated above.


### Delivery Status

This endpoint is used by the external api to submit the delievery status of a sent message. This updates the status of an sms_message object which found by passing the `message_uuid` as a param. Here is the url:

```sh
POST localhost:3000/v1/sms_messages/delivery_status?message_id=:message_uuid
```

Example:

```sh
localhost:3000/v1/sms_messages/delivery_status?message_id=a955fa62-ec72-4662-9ad5-3f622e00f1ca
```

The following payload is required:

```sh
{
  "status": "delivered"
}
```

In this example, the JSON contains the word `status`. `status` is the only expected key in the payload.


### Resend

This allows you to resend a message that may not have successfully been sent. When you view an sms_message object from the `index` or `show` endpoints, if that object doesn't have a `message_uuid`, you can use the following endpoint to resend to the external api.

```sh
POST http://localhost:3000/v1/sms_messages/:id/resend
```

Example:

```sh
localhost:3000/v1/sms_messages/f502f29e-6e34-4502-b011-41b5a5f161aa/resend
```

Additionally, if the sms_message has already been sent, you can force send the message again using the `force` param:

```sh
localhost:3000/v1/sms_messages/f502f29e-6e34-4502-b011-41b5a5f161aa/resend?force=true
```

<br/>

## Testing

Rspec was for the testing framework. The app currently has 99.6% coverage. To run the test, run the following:

```sh
$ rspec
```

To run a specific test file, run the following:

```sh
$ rspec spec/path/to_the_test_file_spec.rb
```
