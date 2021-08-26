.PHONY: all base clean implode dist test examples docker-image

AUXFILES=markdown.bbl markdown.cb markdown.cb2 markdown.glo markdown.bbl \
  markdown.run.xml markdown.bib markdown.markdown.in markdown.markdown.lua \
  markdown.markdown.out markdown-interfaces.md markdown-miscellanea.md \
	markdown-options.md markdown-tokens.md
AUXDIRS=_minted-markdown _markdown_markdown
TDSARCHIVE=markdown.tds.zip
CTANARCHIVE=markdown.ctan.zip
DISTARCHIVE=markdown.zip
ARCHIVES=$(TDSARCHIVE) $(CTANARCHIVE) $(DISTARCHIVE)
EXAMPLES_RESOURCES=examples/example.md examples/scientists.csv
EXAMPLES_SOURCES=examples/context.tex examples/latex.tex
EXAMPLES=examples/context-mkii.pdf examples/context-mkiv.pdf \
  examples/latex-pdftex.pdf examples/latex-luatex.pdf examples/latex-xetex.pdf
TESTS=tests/test.sh tests/support/*.tex tests/templates/*/*.tex.m4 \
  tests/templates/*/COMMANDS.m4 tests/testfiles/*/*.test
MAKES=Makefile $(addsuffix /Makefile, $(SUBDIRECTORIES)) latexmkrc
ROOT_README=README.md banner.png
READMES=$(ROOT_README) LICENSE examples/README.md tests/README.md \
  tests/support/README.md tests/templates/README.md tests/testfiles/README.md \
  tests/templates/*/README.md tests/testfiles/*/README.md
DTXARCHIVE=markdown.dtx
VERSION=$(shell sed -rn '/^\\def\\markdownVersion\{/s/[^{]*\{(.*)\}.*/\1/p' <$(DTXARCHIVE))
LASTMODIFIED=$(shell sed -rn '/^\\def\\markdownLastModified\{/s/[^{]*\{(.*)\}.*/\1/p' <$(DTXARCHIVE))
INSTALLER=markdown.ins docstrip.cfg
TECHNICAL_DOCUMENTATION=markdown.pdf
MARKDOWN_USER_MANUAL=markdown.md markdown.css
HTML_USER_MANUAL=markdown.html markdown.css
USER_MANUAL=$(MARKDOWN_USER_MANUAL) $(HTML_USER_MANUAL)
DOCUMENTATION=$(TECHNICAL_DOCUMENTATION) $(USER_MANUAL) $(ROOT_README)
INSTALLABLES=markdown.lua markdown-cli.lua markdown.tex markdown.sty t-markdown.tex \
	markdownthemewitiko_dot.sty markdownthemewitiko_graphicx_http.sty \
	markdownthemewitiko_tilde.sty
MAKEABLES=$(TECHNICAL_DOCUMENTATION) $(USER_MANUAL) $(INSTALLABLES) $(EXAMPLES)
RESOURCES=$(DOCUMENTATION) $(EXAMPLES_RESOURCES) $(EXAMPLES_SOURCES) $(EXAMPLES) \
  $(MAKES) $(READMES) $(INSTALLER) $(DTXARCHIVE) $(TESTS)
EVERYTHING=$(RESOURCES) $(INSTALLABLES)

DOCKER_IMAGE_TAG=$(shell git describe --tags --always --long --exclude latest)

# This is the default pseudo-target. It typesets the manual,
# the examples, and extracts the package files.
all: $(MAKEABLES)
	$(MAKE) clean

# This pseudo-target extracts the source files out of the DTX archive.
base: $(INSTALLABLES)
	$(MAKE) clean

# This pseudo-target builds a witiko/markdown Docker image.
docker-image:
	docker build -t witiko/markdown:latest .
	docker tag witiko/markdown:latest witiko/markdown:$(DOCKER_IMAGE_TAG)

# This target extracts the source files out of the DTX archive.
$(INSTALLABLES) $(MARKDOWN_USER_MANUAL): $(INSTALLER) $(DTXARCHIVE)
	xetex $<

# This target typesets the manual.
$(TECHNICAL_DOCUMENTATION): $(DTXARCHIVE) $(INSTALLABLES)
	latexmk -interaction=nonstopmode $<
	test `tail $(basename $<).log | sed -rn 's/.*\(([0-9]*) pages.*/\1/p'` -gt 150

# These targets typeset the examples.
$(EXAMPLES): $(EXAMPLE_SOURCES) examples/example.tex $(INSTALLABLES)
	$(MAKE) -C examples $(notdir $@)

examples/example.tex: $(INSTALLABLES)
	$(MAKE) -C examples $(notdir $@)

# This target converts the markdown user manual to an HTML page.
%.html: %.md %.css
	awk '{ \
	    filename = gensub(/^\/(.*\.md)$$/, "\\1", "g"); \
	    if(filename != $$0) \
	        system("cat " filename); \
	    else \
	        print($$0); \
	}' <$< | \
	sed -e 's#\\markdownVersion{}#$(VERSION)#g' \
	    -e 's#\\markdownLastModified{}#$(LASTMODIFIED)#g' \
	    -e 's#\\TeX{}#<span class="tex">T<sub>e</sub>X</span>#g' \
	    -e 's#\\LaTeX{}#<span class="latex">L<sup>a</sup>T<sub>e</sub>X</span>#g' \
	    -e 's#\\Hologo{ConTeXt}#Con<span class="tex">T<sub>e</sub>X</span>t#g' \
	    -e 's#\\Opt{\([^}]*\)}#**`\1`**#g' \
	    -e 's#\\pkg{\([^}]*\)}#**`\1`**#g' \
	    -e 's#\\,# #g' \
	    -e 's#\\meta{\([^}]*\)}#\&LeftAngleBracket;*\1*\&RightAngleBracket;#g' \
	    -e 's#\\acro{\([^}]*\)}#<abbr>\1</abbr>#g' \
	    -e 's#😉#<i class="em em-wink"></i>#g' \
	    -e 's#\\envm{\([^}]*\)}#`\1`#g' \
	    -e 's#\\envmdef{\([^}]*\)}#`\1`#g' \
	    -e 's#\\m{\([^}]*\)}#`\\\1`#g' \
	    -e 's#\\mdef{\([^}]*\)}#`\\\1`#g' \
	| \
	pandoc -f markdown -t html -N -s --toc --toc-depth=3 --css=$(word 2, $^) >$@

# This pseudo-target runs all the tests in the `tests/` directory.
test:
	$(MAKE) -C tests

# This pseudo-target produces the distribution archives.
dist: implode
	$(MAKE) $(ARCHIVES)
	$(MAKE) clean

# This target produces the TeX directory structure archive.
$(TDSARCHIVE): $(DTXARCHIVE) $(INSTALLER) $(INSTALLABLES) $(DOCUMENTATION) $(EXAMPLES_RESOURCES) $(EXAMPLES_SOURCES)
	@# Installing the macro package.
	mkdir -p tex/generic/markdown tex/luatex/markdown tex/latex/markdown \
	  tex/context/third/markdown scripts/markdown
	cp markdown.lua tex/luatex/markdown/
	cp markdown-cli.lua scripts/markdown/
	cp markdown.sty markdownthemewitiko_dot.sty markdownthemewitiko_graphicx_http.sty \
	  markdownthemewitiko_tilde.sty tex/latex/markdown/
	cp markdown.tex tex/generic/markdown/
	cp t-markdown.tex tex/context/third/markdown/
	@# Installing the documentation.
	mkdir -p doc/generic/markdown doc/latex/markdown/examples \
	  doc/context/third/markdown/examples
	cp $(DOCUMENTATION) doc/generic/markdown/
	cp examples/context.tex $(EXAMPLES_RESOURCES) doc/context/third/markdown/examples/
	cp examples/latex.tex $(EXAMPLES_RESOURCES) doc/latex/markdown/examples/
	@# Installing the sources.
	mkdir -p source/generic/markdown
	cp $(DTXARCHIVE) $(INSTALLER) source/generic/markdown
	zip -r -v -nw $@ doc scripts source tex
	rm -rf doc scripts source tex

# This target produces the distribution archive.
$(DISTARCHIVE): $(EVERYTHING) $(TDSARCHIVE)
	-ln -s . markdown
	zip -MM -r -v -nw $@ $(addprefix markdown/,$(EVERYTHING)) $(TDSARCHIVE)
	rm -f markdown

# This target produces the CTAN archive.
$(CTANARCHIVE): $(DTXARCHIVE) $(INSTALLER) $(DOCUMENTATION) $(EXAMPLES_RESOURCES) $(EXAMPLES_SOURCES) README.md $(TDSARCHIVE)
	-ln -s . markdown
	zip -MM -r -v -nw $@ $(addprefix markdown/,$(DTXARCHIVE) $(INSTALLER) $(DOCUMENTATION) $(EXAMPLES_RESOURCES) $(EXAMPLES_SOURCES) README.md) $(TDSARCHIVE)
	rm -f markdown

# This pseudo-target removes any existing auxiliary files and directories.
clean:
	latexmk -c $(DTXARCHIVE)
	rm -f $(AUXFILES)
	rm -rf ${AUXDIRS}
	$(MAKE) -C examples clean

# This pseudo-target removes any makeable files.
implode: clean
	rm -f $(MAKEABLES) $(ARCHIVES)
	$(MAKE) -C examples implode
