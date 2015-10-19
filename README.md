# Start.it

**Work in progress!**

Start.it is a JSON API for organizing *public* and *free* fitness events. User can either start an event or join to events started by other users. At the moment there are two type of events: *run* and *bike ride*. Every event is determined by:
 - Starting position (latitude & longitude)
 - Start time (timezone depends on the position. For example if starting position is in Paris then start time is in CET)
 - Title (optional)
 - Description

Frontend example can be found [here](https://github.com/Rodic/startit-frontend).

## Accounts and sessions

Users can login either through *Facebook* or *Google*.

To login:
  - Frontend must be registered with a provider.
  - User must obtain authorization code from a provider.
  - Must make POST request to Start.it with necessary credentials.

__Example__

1) Go to https://developers.facebook.com/ and create new app. Once you obtain `clientId` and `clientSecret` send user to https://www.facebook.com/v2.3/dialog/oauth where she will get the authorization `code`.

2) Make POST request to the API
```sh
$ curl --data "code=AAA&clientId=BBB&clientSecret=CCCprovider=facebook&redirectUri=DDD" http://localhost:3000/v1/auth/facebook/callback
```
3) API will then excange the code for the access token, read *username* and *email* from user's facebook profile and create new account (in case of the first visit). If process is successful, API will respond with JSON Web Token:
```javascript
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdGFydC5pdCIsImlkIjozMn0.M9MzYJMPZNuhacq_kuVA_9yDKC6ftPTqoKlVwS_Wm54"
}
```
4) In order to identify user on subsequent requests, JWT has to be included in request's Authorization header.
```sh
$ curl -H "Authorization:Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdGFydC5pdCIsImlkIjozMn0.M9MzYJMPZNuhacq_kuVA_9yDKC6ftPTqoKlVwS_Wm54" --data "event={}" http://localhost:3000/v1/events
```

## Users

### Profiles

Any user (guest or registered) can query users by their `id`. However, in order to protect privacy only `username` is exposed.

__Example__

```sh
$ curl -X GET http://localhost:3000/v1/users/32
```
```javascript
{
  "id":16,
  "username":"lori"
}
```

### Own profile

Registered user can get much more information from his own profile.

__Example__

```sh
$ curl -H "Authorization:Bearer _token_" -X GET http://localhost:3000/v1/users/me
```

```javascript
{
  "id":16,
  "username":"lori",
  "email":lori@example.com,
  "latitude":null,
  "longitude":null,
  "joined_events":[],
  "started_events":[]
}
```

if token is invalid or not present, status code is `401` and output:
```javascript
{
  "error": "you're not signed in"
}
```

## Events

### Get single event

Any user (guest or registered) can query API for a single event by its **id**.

__Example__
```sh
$ curl -X GET http://localhost:3000/v1/events/3
```
```javascript
{
  "id": 3,
  "title": "Hyde Park Run",
  "description": "Evening run through Hyde Park. About 7 km in 40 minutes!",
  "start_latitude": "44.7930648",
  "start_longitude": "20.4480145",
  "start_time": "2025 Oct 10 23:00:00",
  "type": "Run",
  "creator": {
    "id": 22,
    "username": "verdie"
  },
  "participants": [
    {
      "id": 16,
      "username": "lori"
    },
    {
      "id": 22,
      "username": "verdie"
    }
  ]
}
```

### Get list of events

Any user can also qurey API for a list of all **upcoming** events.
```sh
$ curl -X GET http://localhost:3000/v1/events`
```
Unforunately, at the moment no aditional params are supported. So you cannot query let's say all events in range of 50 kms from some point (given by its lattitude & longitude).

### Create event

In order to create an event user has to be registered.

__Example__

```sh
$ curl -H "Authorization:Bearer _token_" --data "event={description=Run on Danube riverbank.&start_latitude=44.82999505242894&start_longitude=20.464193619018488&start_time=22/10/2015 12:00&type=Run}" http://localhost:3000/v1/events
```

If successful, API respond with status code `201` and event in JSON

```javascript
{
  "id":15,
  "start_latitude":"44.82999505242894",
  "start_longitude":"20.464193619018488",
  "start_time":"2015-10-22T12:00:00.000Z",
  "start_time_utc":"2015-10-22T10:00:00.000Z",
  "description":"Run on Danube riverbank.",
  "title":null,
  "created_at":"2015-10-19T15:59:25.784Z",
  "updated_at":"2015-10-19T15:59:25.784Z",
  "creator_id":32
}
```

If token is invalid, status code is `401` and output:
```javascript
{
  "error": "you're not signed in"
}
```

If event's data are invalid, status code is `422` and validation errors are sent back.
```javascript
{
  "start_latitude":["can't be blank","is not a number"],
  "start_longitude":["can't be blank","is not a number"],
  "start_time":["can't be blank","can't determine timezone without latitude and longitude"],
  "description":["can't be blank"],
  "type":["can't be blank","must be 'Run' or 'BikeRide'"]
}
```
Just note that there could be more validation errors. For example, `start_time` can't be in the past, `latitude` must be between -90 and 90, `longitude` must be between -180 and 180, `description` must be 500 chars max...

### Update event

Only creator of the event can update it.

__Example__

```sh
$ curl -H "Authorization:Bearer _token_" --data "event[title]=Danube run" -X PUT http://localhost:3000/v1/events/16
```

Upon sucessful update, API respond with status code `200` and updated event.
```javascript
{
  "id":16,
  "start_latitude":"44.8299951",
  "start_longitude":"20.4641936",
  "start_time":"2015-10-22T12:00:00.000Z",
  "start_time_utc":"2015-10-22T10:00:00.000Z",
  "description":"Run on Danube riverbank.",
  "title":"Danube run",
  "created_at":"2015-10-19T16:23:16.526Z",
  "updated_at":"2015-10-19T16:25:08.425Z",
  "creator_id":32
}
```
If data are invalid, status code is `422` and validation errors are presented.

For invalid token, status code is `401` and resonse:
```javascript
{
  "error": "you're not signed in"
}
```

### Destroy event

Only creator of the event can destroy it.

__Example__

```sh
$ curl -H "Authorization:Bearer _token_" -X DELETE http://localhost:3000/v1/events/15
```

If successful API respond with `204`.

If token is invalid, status code is `401` and output:
```javascript
{
  "error": "you're not signed in"
}
```

If event's `id` is invalid response is `404`

## Joingin events

Only registered user can join.

__Example__

```javascript
$ curl -H "Authorization:Bearer _token_" --data "participation[event_id]=12" http://localhost:3000/v1/participations
```

If successful, API respond with `201`.

For invalid `event_id`, status code is `422` and JSON output:

```javascript
{
  "event_id":["is not present in table \"events\""]
}
```

If user is already participant, code is `422` and output:
```javascript
{
  "user_id":["has already been registered as a participant"]
}
```

For invalid token, status code is `401` and output:

```javascript
{
  "error":"must be signed in"
}
```
