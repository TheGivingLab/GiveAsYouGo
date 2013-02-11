# Give As You Go

Mobile app skeleton built on [spine.mobile](http://spinejs.com/mobile/) using
the API from [TheGivingLab](http://www.thegivinglab.org/). The app comes with
authentication, sign up and sign in out of the box and is intended to serve as
a starting point for anyone building mobile apps using TheGivingLab API.

## Features

* Sign up with name, email and password
* Sign up via facebook
* Sign in with email and password
* Sign in via facebook
* Show the users profile
* HTML5 local storage for persistent sessions across app restart

## Requirements

Spine.mobile uses [hem](https://github.com/maccman/hem) to build and package
the app, which requires `nodejs` and `npm` to be installed.

Other than that you need an [API key from
TheGivingLab](http://www.thegivinglab.org/users/signup?developer=1) and you
need to create a [Facebook app](https://developers.facebook.com/apps). For a
very easy way of deploying your app, tick the box *Yes, I would like free web
hosting provided by Heroku* and choose *Node.js* as the environment when
registering the Facebook app.

## Configuration

The only configuration required is setting up your TheGivingLab API key and
facebook app id. `hem` will read them either from `app/environment.env` or from
the `FACEBOOK_APP_ID` and `GIVINGLAB_API_KEY` environment variables, which take
precedence.

### Using foreman (recommended)

Create a (non-versioned) file `.env` in the root directory of your app with the
following content (replace with your API keys):
```
FACEBOOK_APP_ID="YOUR-FACEBOOK-APP-ID"
GIVINGLAB_API_KEY="YOUR-GIVINGLAB-API-KEY"
```
`foreman` will automatically pick up this `.env` file and `hem` will use these
these values when building the static app.

### Without foreman (not recommended)

This will require you to manually export the `FACEBOOK_APP_ID` and
`GIVINGLAB_API_KEY` environment variables or edit `app/environment.env`.

## Running locally

Install `hem` (if you don't have it already):
```
npm install -g hem
```
Install dependencies:
```
npm install
```

### Using foreman (recommended)

Install `foreman` (if you don't have it already):
```
gem install foreman
```
Run the development server:
```
foreman start dev
```
Build the (static) app:
```
foreman run hem build
```
Serve up the static app:
```
foreman start web
```

### Without foreman (not recommended)

Run the development server:
```
hem server
```
Build the (static) app:
```
hem build
```
Serve up the static app:
```
serveup ./public
```

## Deploy to heroku

Heroku requires the static app to be built - which is recommended anyway for
performance reasons. Do *not* commit and push `public/application.js` and
`application.css` to a public repository, since they will contain your API
keys. Instead use a separate branch (we'll call it *heroku*) that you only
push to heroku.

Build the app:
```
foreman run hem build
```
Switch to your `heroku` branch:
```
git checkout heroku
```
Commit that static app:
```
git add public/application.{css,js}
git commit -m "Build static app"
```
Deploy to heroku:
```
git push -f heroku heroku:master
```
Your app is live on the web!
