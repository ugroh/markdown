Markdown
========

[![license](https://img.shields.io/github/license/witiko/markdown)](LICENSE)
[![release](https://img.shields.io/github/release/witiko/markdown.svg)][release]
[![docker pulls](https://img.shields.io/docker/pulls/witiko/markdown)][docker-witiko/markdown]
[![docker image size](https://img.shields.io/docker/image-size/witiko/markdown)][docker-witiko/markdown]
[![ci](https://github.com/witiko/markdown/actions/workflows/main.yml/badge.svg)][ci]

 [release]:  https://github.com/Witiko/markdown/releases/latest  "Releases · Witiko/markdown"
 [ci]:       https://github.com/Witiko/markdown/actions          "GitHub Actions"

The Markdown package converts [markdown][] markup to TeX commands. The
functionality is provided both as a Lua module, and as plain TeX, LaTeX, and
ConTeXt macro packages that can be used to directly typeset TeX documents
containing markdown markup. Unlike other convertors, the Markdown package
does not require any external programs, and makes it easy to redefine how each
and every markdown element is rendered. Creative abuse of the markdown syntax
is encouraged. 😉

 [markdown]: https://daringfireball.net/projects/markdown/basics  "Daring Fireball: Markdown Basics"

Your first Markdown document
----------------------------

Using a text editor, create a text document named `workdir/document.tex` with
the following content:

``` latex
\documentclass{book}
\usepackage{markdown}
\markdownSetup{pipeTables,tableCaptions}
\begin{document}
\begin{markdown}
Introduction
============
## Section
### Subsection
Hello *Markdown*!

| Right | Left | Default | Center |
|------:|:-----|---------|:------:|
|   12  |  12  |    12   |    12  |
|  123  |  123 |   123   |   123  |
|    1  |    1 |     1   |     1  |

: Table
\end{markdown}
\end{document}
```

Next, run the [LaTeXMK][] tool from [our official Docker
image][docker-witiko/markdown]:

    docker run --rm -v "$PWD"/workdir:/workdir -w /workdir witiko/markdown \
      latexmk -lualatex -silent document.tex

Alternatively, you can install [TeX Live][tex-live] (can take up to several
hours) and use its [LaTeXMK][] tool:

    latexmk -cd -lualatex -silent workdir/document.tex

A PDF document named `workdir/document.pdf` should be produced and contain the
following output:

 ![banner](banner.png "An example LaTeX document using the Markdown package")

Congratulations, you have just typeset your first Markdown document! 🥳

 [tex-live]: https://www.tug.org/texlive/  "TeX Live - TeX Users Group"

Using Markdown for continuous integration
-----------------------------------------

Can't live without the latest features of the Markdown package in your
continuous integration pipelines? It's ok, you can use
[our official Docker image][docker-witiko/markdown] as a drop-in replacement
for [the `texlive/texlive:latest` Docker image][docker-texlive/texlive]!
The following example shows a [GitHub Actions][github-actions] pipeline, which
will automatically typeset and prerelease a PDF document:

``` yaml
name: Typeset and prerelease the book
on:
  push:
jobs:
  typeset:
    runs-on: ubuntu-latest
    container:
      image: witiko/markdown:latest
    steps:
      - uses: actions/checkout@v2
      - run: latexmk -lualatex document.tex
      - uses: marvinpinto/action-automatic-releases@latest
        with:
          title: The latest typeset book
          automatic_release_tag: latest
          prerelease: true
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          files: document.pdf
```

In fact, this is how we automatically produce
[the latest documentation][latest-release] for the Markdown package.

 [docker-witiko/markdown]: https://hub.docker.com/r/witiko/markdown/tags  "witiko/markdown - Docker Image"
 [docker-texlive/texlive]: https://hub.docker.com/r/texlive/texlive/tags  "texlive/texlive - Docker Image"

 [github-actions]: https://docs.github.com/actions  "GitHub Actions Documentation"
 [latest-release]: https://github.com/witiko/markdown/releases/tag/latest

Further information
-------------------

For further information, consult one of the following:

1. The [user manual][manual], which can be produced by interpreting the
   `markdown.ins` file using a Unicode-aware TeX engine, such as XeTeX
   (`xetex markdown.ins`) or LuaTeX (`luatex markdown.ins`). The manual will
   reside in the file `markdown.md` and the CSS stylesheet `markdown.css`.
2. The technical documentation for either [the released version][techdoc-tex-live]
   or [the latest development version][techdoc-latest], which can be typeset by
   running the [LaTeXMK][] tool on the `markdown.dtx` file (`latexmk
   markdown.dtx`) after [installing the Markdown package][install].
   [LaTeXMK][] should be included in your TeX distribution.
   The typeset documentation will reside in the file `markdown.pdf`.
3. Tutorials and example documents by [Lian Tze Lim][liantze] at [Overleaf][]:
    - [How to write in Markdown on Overleaf][overleaf-1],
    - [Markdown into LaTeX with Style][overleaf-2],
    - [Writing Markdown in LaTeX Documents][overleaf-3],
    - [Writing Beamer Slides with Markdown][overleaf-4],
    - [Writing Posters with Markdown][overleaf-5], and
    - [Using Markdown in LaTeX documents][overleaf-6].
4. My journal articles published by [TUGboat][]:
    - [Using Markdown inside TeX documents][tb119],
    - [Markdown 2.7.0: Towards lightweight markup in TeX][tb124],
    - [Making Markdown into a Microwave Meal][tb129], and
    - [Markdown 2.10.0: LaTeX Themes & Snippets, Two Flavors of Comments, and LuaMetaTeX][tb131-preprint].
5. My journal articles published by [CSTUG][] (in Czech):
    - [Rendering Markdown inside TeX Documents][10.5300/2016-1-4/78], and
    - [Markdown 2.8.1: Boldly Unto the Throne of Lightweight Markup in TeX][10.5300/2020-1-2/48].
6. My talks:
    - [Five Years of Markdown in LaTeX: What, Why, How, and Whereto][pv212-fall2020] (in Czech), and
    - [Markdown 2.10.0: LaTeX Themes & Snippets, Two Flavors of Comments, and LuaMetaTeX][tb131-video] ([slides][tb131-slides]).

 [overleaf-1]: https://www.overleaf.com/learn/latex/Articles/How_to_write_in_Markdown_on_Overleaf       "How to write in Markdown on Overleaf"
 [overleaf-2]: https://www.overleaf.com/learn/latex/Articles/Markdown_into_LaTeX_with_Style             "Markdown into LaTeX with Style"
 [overleaf-3]: https://www.overleaf.com/learn/how-to/Writing_Markdown_in_LaTeX_Documents                "Writing Markdown in LaTeX Documents"
 [overleaf-4]: https://www.overleaf.com/latex/examples/writing-beamer-slides-with-markdown/dnrwnjrpjjhw "Writing Beamer Slides with Markdown"
 [overleaf-5]: https://www.overleaf.com/latex/examples/writing-posters-with-markdown/jtbgmmgqrqmh       "Writing Posters with Markdown"
 [overleaf-6]: https://www.overleaf.com/latex/examples/using-markdown-in-latex-documents/whdrnpcpnwrm   "Using Markdown in LaTeX documents"

 [tb119]: https://www.tug.org/TUGboat/tb38-2/tb119novotny.pdf           "Using Markdown inside TeX documents"
 [tb124]: https://www.tug.org/TUGboat/tb40-1/tb124novotny-markdown.pdf  "Markdown 2.7.0: Towards lightweight markup in TeX"
 [tb129]: https://www.tug.org/TUGboat/tb41-3/tb129novotny-frozen.pdf    "Making Markdown into a Microwave Meal"

 [tb131-preprint]: https://tug.org/tug2021/assets/pdf/novotny-tug2021-preprint.pdf  "Markdown 2.10.0: LaTeX Themes & Snippets, Two Flavors of Comments, and LuaMetaTeX"
 [tb131-slides]:   https://tug.org/tug2021/assets/pdf/tug2021-novotny-slides.pdf    "Markdown 2.10.0: LaTeX Themes & Snippets, Two Flavors of Comments, and LuaMetaTeX"
 [tb131-video]:    https://youtu.be/i2GJMnLCZls                                     "Markdown 2.10.0: LaTeX Themes & Snippets, Two Flavors of Comments, and LuaMetaTeX"

 [10.5300/2016-1-4/78]: https://bulletin.cstug.cz/pdf/2016-1-4.pdf#page=80 "Rendering Markdown inside TeX Documents"
 [10.5300/2020-1-2/48]: https://bulletin.cstug.cz/pdf/2020-1-2.pdf#page=50 "Markdown 2.8.1: Boldly Unto the Throne of Lightweight Markup in TeX"

 [pv212-fall2020]: https://is.muni.cz/el/fi/podzim2020/PV212/index.qwarp?prejit=5595952

 [install]:  https://mirrors.ctan.org/macros/generic/markdown/markdown.html#installation "Markdown Package User Manual"
 [liantze]:  https://liantze.penguinattack.org/                                          "Rants from the Lab"
 [manual]:   https://mirrors.ctan.org/macros/generic/markdown/markdown.html              "Markdown Package User Manual"
 [overleaf]: https://www.overleaf.com/                                                   "Overleaf: Real-time Collaborative Writing and Publishing Tools with Integrated PDF Preview"
 [tugboat]:  https://www.tug.org/tugboat/                                                "TUGboat - Communications of the TeX Users Group"
 [cstug]:    https://www.cstug.cz/                                                       "Československé sdružení uživatelů TeXu"

 [techdoc-latest]:    https://github.com/Witiko/markdown/releases/download/latest/markdown.pdf  "A Markdown Interpreter for TeX"
 [techdoc-tex-live]:  https://mirrors.ctan.org/macros/generic/markdown/markdown.pdf             "A Markdown Interpreter for TeX"

Acknowledgements
----------------

| Logo | Acknowledgement |
| ------------- | ------------- |
| [<img width="150" src="https://www.fi.muni.cz/images/fi-logo.png">][fimu] | I gratefully acknowledge the funding from the [Faculty of Informatics][fimu] at the [Masaryk University][mu] in Brno, Czech Republic, for the development of the Markdown package. |
| [<img width="150" src="https://cdn.overleaf.com/img/ol-brand/overleaf_og_logo.png">][overleaf] | Extensive user documentation for the Markdown package was kindly written by [Lian Tze Lim][liantze] and published by [Overleaf][]. |
| [<img width="150" src="https://pbs.twimg.com/profile_images/1004769879319334912/6Bh1UthD.jpg">][omedym] | Support for content slicing (Lua options [`shiftHeadings`][option-shift-headings] and [`slice`][option-slice]) and pipe tables (Lua options [`pipeTables`][option-pipe-tables] and [`tableCaptions`][option-table-captions]) was graciously sponsored by [David Vins][dvins] and [Omedym][]. |

 [dvins]:  https://github.com/dvins             "David Vins"
 [fimu]:   https://www.fi.muni.cz/index.html.en "Faculty of Informatics, Masaryk University"
 [mu]:     https://www.muni.cz/en               "Masaryk University"
 [Omedym]: https://www.omedym.com/              "Omedym"

 [option-pipe-tables]:    https://mirrors.ctan.org/macros/generic/markdown/markdown.html#pipe-tables          "Markdown Package User Manual"
 [option-shift-headings]: https://mirrors.ctan.org/macros/generic/markdown/markdown.html#option-shiftheadings "Markdown Package User Manual"
 [option-slice]:          https://mirrors.ctan.org/macros/generic/markdown/markdown.html#slice                "Markdown Package User Manual"
 [option-table-captions]: https://mirrors.ctan.org/macros/generic/markdown/markdown.html#option-tablecaptions "Markdown Package User Manual"

Contributing
------------

Apart from the example markdown documents, tests, and continuous integration,
which are placed in the `examples/`, `tests/`, and `.github/` directories,
the complete source code and documentation of the package are placed in the
`markdown.dtx` document following the [literate programming][] paradigm.
Some useful commands, such as building the release archives and typesetting
the documentation, are placed in the `Makefile` file for ease of maintenance.

When the file `markdown.ins` is interpreted using a Unicode-aware TeX engine,
such as XeTeX (`xetex markdown.ins`) or LuaTeX (`luatex markdown.ins`), several
files are produced from the `markdown.dtx` document. The `make base` command
is provided by `Makefile` for convenience. In `markdown.dtx`, the boundaries
between the produced files are marked up using an XML-like syntax provided by
the [DocStrip][] plain TeX package.

Running the [LaTeXMK][] tool on the `markdown.dtx` file
(`latexmk markdown.dtx`) after the Markdown package has been
[installed][install] typesets the documentation. The `make markdown.pdf`
command is provided by `Makefile` for convenience. In `markdown.dtx`, the
documentation is placed inside TeX comments and marked up using the
[ltxdockit][] LaTeX document class. Support for typesetting the documentation
is provided by the [doc][] LaTeX package.

To facilitate continuous integration and sharing of the Markdown package,
there exists an [official Docker image][docker-witiko/markdown], which can be
reproduced by running the `docker build` command on `Dockerfile` (`docker build
-t witiko/markdown .`). The `make docker-image` command is provided by
`Makefile` for convenience.

 [doc]:                  https://ctan.org/pkg/doc                           "doc – Format LaTeX documentation"
 [DocStrip]:             https://ctan.org/pkg/docstrip                      "docstrip – Remove comments from file"
 [LaTeXMK]:              https://ctan.org/pkg/latexmk                       "latexmk – Fully automated LaTeX document generation"
 [literate programming]: https://en.wikipedia.org/wiki/Literate_programming "Literate programming"
 [ltxdockit]:            https://ctan.org/pkg/ltxdockit                     "ltxdockit – Documentation support"

Citing Markdown
---------------

When citing Markdown in academic papers and theses, please use the following
BibTeX entry:

```bib
@article{novotny17markdown,
  author  = {V\'{i}t Novotn\'{y}},
  year    = {2017},
  title   = {Using {M}arkdown Inside {\TeX} Documents},
  journal = {TUGboat},
  volume  = {38},
  number  = {2},
  pages   = {214--217},
  issn    = {0896-3207},
  url     = {https://tug.org/TUGboat/tb38-2/tb119novotny.pdf},
  urldate = {2020-07-31},
}
```
