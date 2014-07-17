MOCHA = ./node_modules/.bin/mocha
REPORTER = spec # try nyan ;-)
COMPILERS = coffee:coffee-script/register
TESTS = test/*.coffee

test:
	@NODE_ENV=test $(MOCHA) \
		--reporter $(REPORTER) \
		--compilers $(COMPILERS) \
		$(TESTS)

.PHONY: test
