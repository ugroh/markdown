.PHONY: all

# This is the default pseudo-target. It runs all the tests.
all:
	./test.sh testfiles/Markdown_1.0.3/auto-links.test  # Populate cache before running parallel
	find testfiles/ -type f -name '*.test' | parallel --halt 2 ./test.sh
