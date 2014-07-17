MOCHA = ./node_modules/.bin/mocha
REPORTER = spec # try nyan ;-)
COMPILERS = coffee:coffee-script/register
LIBS = lib/*.coffee
TESTS = test/*.coffee

lint:
	@coffee -p $(LIBS) > /dev/null

test:
	@NODE_ENV=test $(MOCHA) \
		--reporter $(REPORTER) \
		--compilers $(COMPILERS) \
		$(TESTS)

.PHONY: test lint
