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

To create a server, you can then run something like:

	$ wscat --connect ws://localhost:8080/wot/agy/%23/agy/agy/agy/
	> ["create.server", "agy.test00", "abd98481-6e82-4410-a01d-8360cb3d1f65", 2]

	OR

	$ wscat --connect ws://localhost:8080/wot/agy/%23/agy/agy/agy/
	> ["create.server", "agy.test01", "abd98481-6e82-4410-a01d-8360cb3d1f65", 2, {"dns_server": "10.209.64.127"}]

Starting a machine with meta-data can also be done "manually" from the command line:

	$ source ~/.novarc
	$ nova boot --flavor performance1-1 --image abd98481-6e82-4410-a01d-8360cb3d1f65 \
		--meta local-hostname=agy.test01.wot.io \
		--meta dns_server=10.209.64.127 \
		--config-drive true \
		agy.test01
