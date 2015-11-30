# Opifex.Nova.coffee
#
#	© 2013 Dave Goehrig <dave@dloh.org>
#	© 2015 wot.io LLC
#

cloud = require 'pkgcloud'
try
       config = require "#{process.env.HOME}/.nova.coffee"
catch
       config = {}
config[key.toLowerCase()] = "#{process.env[key]}" for key in ['USERNAME', 'APIKEY', 'URL', 'REGION', 'CLUSTER']

Nova = () ->
	self = this
	self.servers = []
	self.client = cloud.providers.rackspace.compute.createClient {
		username: config.username
		apiKey: config.apikey
		authUrl: config.url or 'https://identity.api.rackspacecloud.com'
		region: config.region or 'ORD'
		useInternal: true
	}
	self["list.flavors"] = () ->
		self.client.getFlavors (error, flavors) ->
			if error
				self?.log?.error "Failed to fetch flavors #{error}"
				return self.send [ 'nova', 'error', error ]
			self.flavors = flavors.map (x) ->
				id: x.id
				name: x.name
				ram: x.ram
				vcpus: x.vcpus
				disk: x.disk
				swap: x.swap
			self.send [ 'nova', 'list.flavors' ].concat(self.flavors)
	self["list.images"] = () ->
		self.client.getImages (error, images) ->
			if error
				self?.log?.error "Failed to fetch images #{error}"
				return self.send [ 'nova', 'error', error ]
			self.images = images.map (x) ->
				id: x.id
				name: x.name
				created: x.created
				updated: x.updated
				status: x.status
				progress: x.progress
			self.send [ 'nova', 'list.images' ].concat(self.images)
	self["list.servers"] = () ->
		self.client.getServers (error, servers) ->
			if error
				self?.log?.error "Failed to fetch servers #{error}"
				return self.send [ 'nova', 'error', error ]
			re = new RegExp(config.cluster)
			self.servers = servers.filter (srv) ->
				return re.test srv.name
			.map (x) ->
				id: x.id
				name: x.name
				status: x.status
				progress: x.progress
				image: x.imageId
				flavor: x.flavorId
				host: x.hostId
				public:  (x.addresses.public.filter (y) -> y.version == 4)[0].addr
				private:  (x.addresses.private.filter (y) -> y.version == 4)[0].addr
			self.send [ 'nova', 'list.servers' ].concat(self.servers)
	self["get.server"] = (server_id) ->
        self.client.getServer server_id, (error, server) ->
            if error
                self?.log?.error "Failed to get server #{error}"
                return self.send [ 'nova', 'error', error ]
            self.server = {
                id: server.id
                name: server.name
                created: server.created
                updated: server.updated
                status: server.status
                progress: server.progress
                }
            self.send [ 'nova', 'get.server', self.server ]
	self["create.server"] = (name,image,flavor,metadata={},userdata='') ->
		# If we were passed metadata or userdata, then we need to use a cfgdrive.
		self?.log?.debug(metadata)
		
		if (i for own i of metadata).length != 0 or userdata?
			cfgdrive = true
		else
			cfgdrive = false
		self.client.createServer {
			name: name,
			image: image,
			flavor: flavor,
			metadata: metadata,
			cfgdrive: cfgdrive,
			userdata: userdata,
			}, (error, server) ->
				if error
					self?.log?.error "Failed to create server #{error}"
					return self.send [ 'nova', 'error', error ]
				self?.log?.debug(server)
				self.send ['nova', "create.server", server.name, server.id, server.adminPass ]
				self.servers.push server
	self["snapshot.server"] = (name,id) ->
		self.client.createImage { name: name, server: id }, (error, image) ->
			if error
				self?.log?.error "Failed to snapshot server #{error}"
				return self.send [ 'nova', 'error', error ]
			self?.log?.debug(image)
			self.send [ 'nova', 'snapshot.server', image.name, image.id ]
			self.images.push(image)
	self["delete.server"] = (id) ->
		self.client.destroyServer (id), (error, serverId) ->
			if error
				self?.log?.error "Failed to delete server #{error}"
				return self.send [ 'nova', 'error', error ]
			self?.log?.debug(server)
			self.send [ 'nova', 'delete.server', id ]
			self.servers = server for server in self.servers when server.id != id
	self["help"] = () ->
		self.send [ 'nova', 'help', [ 'list.servers' ], [ 'list.flavors' ], [ 'list.images' ], [ 'create.server', 'name','image.id','flavor' ],[ 'snapshot.server','name','image.id' ],[ 'delete.server','image.id' ] ]
	
module.exports = Nova
