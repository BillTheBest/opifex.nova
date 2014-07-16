Opifex.Nova
=============

Opifex.Nova is a provisioner interface for OpenStack Nova API

Installation
------------

	npm install opifex
	npm install opifex.nova

Usage
-----

Create a `${HOME}/.nova.coffee` config file:

	module.exports = {
		username: 'your-username'
		apikey: 'your-api-key'
	}

The file may not live in _your_ home directory, but the home directory of
the process user. Optionally, `url` and `region` can be defined to override
the defaults of `https://identity.api.rackspacecloud.com` and `ORD`
respectively.

The username and api key can be retrieved from the Rackspace Account Settings
page.

Run opifex.nova:

	$ /node_modules/.bin/opifex 'amqp://wot:wotsallthisthen!@bus04.wot.io:5672/wot/agy/#/agy/agy/agy' nova
