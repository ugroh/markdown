.PHONY: all

# This is the default pseudo-target. It runs all the tests.
all:
	find testfiles/ -type f -name '*.test' | parallel --jobs 1 --halt 2 ./test.sh
