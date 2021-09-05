.PHONY: all implode

TINYYAML=markdown-tinyyaml.lua
OUTPUT=$(TINYYAML)

# This is the default pseudo-target.
all: $(OUTPUT)

# This target produces the lua-tinyyaml external library.
$(TINYYAML): lua-tinyyaml
	git submodule update --init --recursive $<
	(sed 's/^/-- /' $</LICENSE && echo && cat $</tinyyaml.lua) > $@

# This pseudo-target removes any makeable files.
implode:
	rm -f $(OUTPUT)
