#!/usr/bin/env coffee

test = require('tap').test

self = (method, message...)  ->
	$ = arguments.callee
	$[method].apply $, message

self.send = (msg, meta) ->

(require "../lib/Opifex.Nova.coffee").apply(self)

method_names = [
	"list.flavors",
	"list.images",
	"list.servers",
	"get.server",
	"create.server",
	"snapshot.server",
	"delete.server",
	"help"
]

check = (method) ->
	test "has method #{method}", (t) ->
		t.ok(self.hasOwnProperty(method) and self[method] instanceof Function, "#{method} exists and is a function")
		t.end()

check method for method in method_names
