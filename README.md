# PSquare SMS Service Example

This is a Rails 6 api service application which submits SMS text messages to external SMS services. [Postgres 12](https://postgresapp.com/downloads.html) is used for record storage, specifically to take advantage of TSVECTOR type fields. The app also requires that Redis and Sidekiq instances are running in parallel with the app. Instructions for running all the required services are outlined below.

While there are some complex parts to this app, it was developed using [K.I.S.S. principals](https://medium.com/@devisha.singh/the-kiss-principle-in-software-development-everything-you-need-to-know-dd8ea6e46bcd). No one likes a bloated, hard to read, useless, code base. If you find code that can use improvement feel free to reach out to me.



<br/>

## RBENV, RBENV Libraries, and Gems

[RBENV](https://github.com/sstephenson/rbenv) and [RBENV-GEMSET](https://github.com/jf/rbenv-gemset) are used to manange Ruby and install ruby gems. BREW was used to install [RBENV](https://github.com/sstephenson/rbenv) and the supportive RBENV libraries using: `brew install rbenv rbenv-gemset rbenv-use rbenv-aliases`.

`Rbenv-gemset` will automatically manage gems for the current Ruby version (set in memory by RBENV), in gemsets, if there is a `.ruby-gemset` file in the project directory. If `.ruby-gemset` isn't found, it will install the gems in the `global` scope of the current Ruby version.

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

The easiest way to make your `localhost:3000` server instance accessable publically would be to use [ngrok](https://ngrok.com). When you go to the ngrok site, you will need to create an account if you don't have one. Login to see the dashboard information, download the ngrok executable, unzip the executable, set the authorization, then run the executable.

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

When you save and close the file, `credentials.yml.enc` will automatically reencrypt with the new changes.

<br/>

## Running Rails, Redis, and Sidekiq

You can run each of the services in one of two ways. You can run each service indivisually in their own console, or you can run Foreman which starts all the services automatically.

### Running Services Individually

There are advantages to running services individually. Mainly, when you add `binding.pry` break-points in the code, the correlating console (Rails or Sidekiq) will be available for you to work in.

To start each service individually, open 3 terminal sessions and run one line in each of the sessions. The lines are as follows:

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

### Running Services with Foreman

To run all services with `Foreman`, you only need one terminal session. Simply run the following:

```sh
foreman start
```

<br/>

##
