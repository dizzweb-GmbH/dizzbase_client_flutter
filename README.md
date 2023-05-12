# dizzbase Flutter client

dizzbase is a realtime postgreSQL backend-as-a-service for node.js express servers.
Clients (flutter/dart or JavaScript/React) can send query that are automatically updated in realtime.

dizzbase can be an alternative to self-hosting supabase if a lightweight and easy to install solution is needed.
Also, it can be used instead of firebase if you need a relational rather than document database. 

This package is the dart/flutter client for dizzbase - see https://www.npmjs.com/package/dizzbase for instruction on how to install/run the node.js backend with PostgreSQL.

## Features

Provides a real-time feed to database queries via a dart Stream. Using a flutter StreamBuilder the widget content is automatically updated whenever the data in the database changes. The flutter/dart client also provides interface to update/insert/delete postgresql data and to directly send SQL statments. 

## Getting started

The client works with the dizzbase backend-as-a-services. Install and configure dizzbase on your backend server: https://www.npmjs.com/package/dizzbase

Install the client: ```flutter pub add dizzbase_client``` 

Import the package to your flutter app: ```import 'package:dizzbase_client/dizzbase_client.dart';```

In the flutter apps main() function, call DizzbaseConnection.configureConnection(...) to configure your backend services URL and access token.

To understand how the dart/flutter dizzbase client works, please review the flutter demo client:

https://github.com/dizzweb-GmbH/dizzbase_flutter_demo

The README.md file of the demo client provides pointers on how to use the dizzbase_client API.

Note the initState() and dispose() overrides of the StatefulWidgets to see how to create and clean up the dizzbase connection and therefore to avoid backend memory leaks with long-running clients.

## Usage

Please refer to the demo widgets for details on how to use the client.

## Additional information

A JavaScript/React client might be available in the future.

## TO DO 

Backend security (access token) is not yet implemented.
