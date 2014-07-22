# Opifex.Nova.coffee
#
#	© 2013 Dave Goehrig <dave@dloh.org>
#	© 2014 wot.io LLC
#

cloud = require 'pkgcloud'
try
       config = require "#{process.env.HOME}/.nova.coffee"
catch
       config = {}
config[key.toLowerCase()] = "#{process.env[key]}" for key in ['USERNAME', 'APIKEY', 'URL', 'REGION']

Nova = () ->
	self = this
	self.servers = []
	self.client = cloud.providers.rackspace.compute.createClient {
		username: config.username
		apiKey: config.apikey
		authUrl: config.url or 'https://identity.api.rackspacecloud.com'
		region: config.region or 'ORD'
	}
	self["list.flavors"] = () ->
		self.client.getFlavors (error, flavors) ->
			if error
				console.log "Failed to fetch flavors #{error}"
				return self.send [ 'nova', 'error', error ]
			self.flavors = flavors.map (x) ->
				id: x.id
				name: x.name
				ram: x.ram
				vcpus: x.vcpus
				disk: x.disk
				swap: x.swap
			self.send  [ 'nova', 'list.flavors', self.flavors ]
	self["list.images"] = () ->
		self.client.getImages (error, images) ->
			if error
				console.log "Failed to fetch images #{error}"
				return self.send [ 'nova', 'error', error ]
			self.images = images.map (x) ->
				id: x.id
				name: x.name
				created: x.created
				updated: x.updated
				status: x.status
				progress: x.progress
			self.send  [ 'nova', 'list.images', self.images ]
	self["list.servers"] = () ->
		self.client.getServers (error, servers) ->
			if error
				console.log "Failed to fetch servers #{error}"
				return self.send [ 'nova', 'error', error ]
			self.servers = servers.map (x) ->
				id: x.id
				name: x.name
				status: x.status
				progress: x.progress
				image: x.imageId
				flavor: x.flavorId
				host: x.hostId
				public:  (x.addresses.public.filter (y) -> y.version == 4)[0].addr
				private:  (x.addresses.private.filter (y) -> y.version == 4)[0].addr
			self.send [ 'nova', 'list.servers', self.servers ]
	self["create.server"] = (name,image,flavor,metadata={}) ->
		self.client.createServer {
			name: name,
			image: image,
			flavor: flavor,
			metadata: metadata,
			}, (error, server) ->
				if error
					console.log "Failed to create server #{error}"
					return self.send [ 'nova', 'error', error ]
				console.log(server)
				self.send ['nova', "create.server", server.name, server.id, server.adminPass ]
				self.servers.push server
	self["snapshot.server"] = (name,id) ->
		self.client.createImage { name: name, server: id }, (error, image) ->
			if error
				console.log "Failed to snapshot server #{error}"
				return self.send [ 'nova', 'error', error ]
			console.log(image)
			self.send [ 'nova', 'snapshot.server', image.name, image.id ]
			self.images.push(image)
	self["delete.server"] = (id) ->
		self.client.destroyServer (id), (error, serverId) ->
			if error
				console.log "Failed to delete server #{error}"
				return self.send [ 'nova', 'error', error ]
			console.log(server)
			self.send [ 'nova', 'delete.server', server ]
			self.servers = server for server in servers when server.id != id
	self["help"] = () ->
		self.send [ 'nova', 'help', [ 'list.servers'], ['list.flavors'], ['list.images'], ['create.server', 'name','image','flavor'],['snapshot.server','name','image' ] ]
	self["*"] = (message...) ->
		console.log "Unknown message #{ JSON.stringify(message) }"

module.exports = Nova
