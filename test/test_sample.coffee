assert = require 'assert'

describe 'Array', ->
	describe '#indexOf()', ->
		it 'should return -1 when not present', ->
			assert.equal [1,2,3].indexOf(5), -1
			assert.equal [1,2,3].indexOf(0), -1
