.PHONY: all implode force

TINYYAML=markdown-tinyyaml.lua
OUTPUT=$(TINYYAML)

# This is the default pseudo-target.
all: $(OUTPUT)

# These targets produce the lua-tinyyaml external library.
lua-tinyyaml: force
	git submodule update --init --recursive -- $@
	git submodule sync -- $@

$(TINYYAML): lua-tinyyaml
	(sed 's/^/-- /' $</LICENSE && echo && cat $</tinyyaml.lua) > $@

# This pseudo-target removes any makeable files.
implode:
	rm -f $(OUTPUT)
