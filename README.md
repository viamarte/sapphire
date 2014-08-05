Sapphire ![Version](http://img.shields.io/badge/Version-1.0.0-blue.svg) ![Coverage](http://img.shields.io/badge/Coverage-100%25-brightgreen.svg)
========

## What?

Do you want a library that helps you work with Microsoft SQL Server stored procedures in Node.JS? That library needs to be fast, secure and easy to use?
So here is Sapphire, a library that does that and more!

Sapphire is a library crafted to work just with stored procedures, so we keep things simple. You call a procedure with your parameters and listen to the result or possible errors. And that's it. Sapphire handles all that database pool management, data type validation and sql injection stuff for you automatically. All you have to do is query your database!

You can even let Sapphire manage multiple SQL Server databases, like we do here on Via Marte.

## Sweet! How do I get started?

* First you need to create your Node.JS project, if you already did that skip this step.

* Now head to the root of your project's folder.

* You'll now install Sapphire in your project, to do this type on your terminal: `npm install node-sapphire`

* Notice that Sapphire doesn't know your database details. You must provide this to Sapphire.

* To do so create a sconfig.json file on the root of your project containg the following keys (without the comments):

	```
	{
		"maxConnections" : 50, //The maximum number of connections you want Sapphire to open per database
		"serverList": {
			"myserver": { //Server alias, the name you'll use to refer your server
			  "server": "0.0.0.0", //Server IP address, Sapphire needs the server to be TCP/IP enabled.
			  "userName": "user", //Connection user name
			  "password": "pass", //Connection password
			  "options": { //Optional key to define timeouts, different instance name, etc.
			    "connectionTimeout": 1500, //Connection timeout in milisseconds
			    "instanceName": "INSTANCENAME" //Instance name, if applicable
			  }
			}
		},
		"testingServer": "myserver" //Server in which you wish to run automated tests.
	}
	```

	You can use the `sconfig_sample.json` as a boilerplate, make you changes and rename to `sconfig.json` when you're ready.

* Now you must request Sapphire in your Node.JS project as you would do with any other module, see the examples folder in case of doubt.

* You are all set, have fun!

## What Sapphire can do for me?

Check out our [wiki](https://github.com/viamarte/sapphire/wiki), there is all the information you may need about Sapphire.

Also check the [Usage examples](https://github.com/viamarte/sapphire/wiki/Usage-examples) page in the wiki, that shows some code examples of Sapphire's usage.

## Developing Sapphire

If you are interested in taking a look at Sapphire's source and work mechanisms, or even contribute to the project please continue reading. If you are just a user of the library what you read so far should be fine.

## Testing Sapphire

If you want to test Sapphire in your environment you'll need to add the testing stored procedures to one of your databases. Then Sapphire will make various requests to those SPs testing the library features.

This will ensure Sapphire works well on your environment, if you are interested in testing Sapphire in your environment do the following:

1. Sapphire uses grunt to build itself and perform tests, so install grunt with `npm install grunt-cli -g`. You may need administrator rights to do that.

2. Clone this repo in your server that connects with the database.

3. Move your terminal to the root directory of the cloned Sapphire.

4. Run `npm install` to install all Sapphire needs.

5. Go to the sql folder and grab the `sp_for_tests.sql` file, run that on your database to create the test SPs.

6. In the root folder of Sapphire's cloned project, create your `sconfig.json` file, with the testingServer pointing to the server you created the testing SPs.

7. Back on Sapphire's root folder run `grunt test`

8. If everything passes you are good to go.

## I would like to contribute!

If you want to contribute to Sapphire's project, please follow [this guide](https://github.com/viamarte/sapphire/CONTRIBUTING.md).

## Future releases

Sapphire has just been born, we are now at version 1.0.0. Many improvements and new features are queued to launch.

As Sapphire is always in development, [here](https://github.com/viamarte/sapphire/issues/) are some things we have in mind for the next version!

You can help too! If you have a great idea you would like to implement in Sapphire create a new issue to let us know. You can also implement it yourself using the contribution guide.

## Authors

* [Ivair Kautzmann](https://github.com/ivair/)
* [Matheus Kautzmann](https://github.com/mkautzmann/)

## License

The project is under MIT license, check the file [here](https://github.com/viamarte/sapphire/LICENSE.md).
