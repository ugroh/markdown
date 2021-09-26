# syntax = docker/dockerfile:1.3-labs

ARG AUXILIARY_FILES="\
    /tmp/* \
    /var/tmp/* \
    /var/log/* \
    /var/lib/apt/lists/* \
    /var/lib/{apt,dpkg,cache,log}/* \
    /usr/share/man/* \
    /usr/share/locale/* \
    /var/cache/apt/* \
"

ARG DEPENDENCIES="\
    curl \
    gawk \
    graphviz \
    m4 \
    pandoc \
    parallel \
    poppler-utils \
    python3-pygments \
    ruby \
    unzip \
    wget \
    zip \
"

ARG BINARY_DIR=/usr/local/bin
ARG BUILD_DIR=/git-repo
ARG INSTALL_DIR=/usr/local/texlive/texmf-local

ARG TEXLIVE_TAG=latest-with-cache

FROM texlive/texlive:$TEXLIVE_TAG as build

ARG DEPENDENCIES

ARG BUILD_DIR
ARG INSTALL_DIR

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm

COPY . ${BUILD_DIR}/

RUN <<EOF

set -o errexit
set -o nounset
set -o xtrace

# Install dependencies
apt-get -qy update
apt-get -qy install --no-install-recommends ${DEPENDENCIES}

# Generate the ConTeXt file database
mtxrun --generate

# Install the Markdown package
make -C ${BUILD_DIR} implode
make -C ${BUILD_DIR} base
mkdir -p                                                  ${INSTALL_DIR}/tex/luatex/markdown/
cp -f ${BUILD_DIR}/markdown.lua                           ${INSTALL_DIR}/tex/luatex/markdown/
cp -f ${BUILD_DIR}/libraries/markdown-tinyyaml.lua        ${INSTALL_DIR}/tex/luatex/markdown/
mkdir -p                                                  ${INSTALL_DIR}/scripts/markdown/
cp -f ${BUILD_DIR}/markdown-cli.lua                       ${INSTALL_DIR}/scripts/markdown/
mkdir -p                                                  ${INSTALL_DIR}/tex/generic/markdown/
cp -f ${BUILD_DIR}/markdown.tex                           ${INSTALL_DIR}/tex/generic/markdown/
mkdir -p                                                  ${INSTALL_DIR}/tex/latex/markdown/
cp -f ${BUILD_DIR}/markdown.sty                           ${INSTALL_DIR}/tex/latex/markdown/
cp -f ${BUILD_DIR}/markdownthemewitiko_dot.sty            ${INSTALL_DIR}/tex/latex/markdown/
cp -f ${BUILD_DIR}/markdownthemewitiko_graphicx_http.sty  ${INSTALL_DIR}/tex/latex/markdown/
cp -f ${BUILD_DIR}/markdownthemewitiko_tilde.sty          ${INSTALL_DIR}/tex/latex/markdown/
mkdir -p                                                  ${INSTALL_DIR}/tex/context/third/markdown/
cp -f ${BUILD_DIR}/t-markdown.tex                         ${INSTALL_DIR}/tex/context/third/markdown/

# Generate the ConTeXt file database
mtxrun --generate

# Reindex the TeX directory structure
texhash

# Produce the complete distribution archive of the Markdown package
make -C ${BUILD_DIR} dist
mkdir ${BUILD_DIR}/dist
unzip ${BUILD_DIR}/markdown.tds.zip -d ${BUILD_DIR}/dist

EOF


FROM texlive/texlive:$TEXLIVE_TAG

ARG AUXILIARY_FILES
ARG DEPENDENCIES

ARG BINARY_DIR
ARG BUILD_DIR
ARG INSTALL_DIR

LABEL authors="Vít Novotný <witiko@mail.muni.cz>"

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm

# Install the Markdown package
COPY --from=build ${BUILD_DIR}/dist ${INSTALL_DIR}/

COPY <<EOF ${BINARY_DIR}/markdown-cli
#!/bin/bash
# Expand the output of markdown-cli.lua to make it more human-readable

RESULT=\"\$(texlua ${INSTALL_DIR}/scripts/markdown/markdown-cli.lua \"\$@\")\"
EXIT_CODE=\$?

if (( \$(wc -l <<< \"\$RESULT\") == 1 )) && grep -q \'^\\\\input\' <<< \"\$RESULT\"
then
    FILENAME=\"\$(sed -r \'s/\\\\input (.*)\\\\relax\\{\\}/\\1/\' <<< \"\$RESULT\")\"
    RESULT=\"\$(cat \"\$FILENAME\")\"
fi

printf \'%s\\n\' \"\$RESULT\"
exit \$EXIT_CODE

EOF


RUN <<EOF

set -o errexit
set -o nounset
set -o xtrace

# Make the markdown-cli script executable
chmod +x ${BINARY_DIR}/markdown-cli

# Install dependencies, but this time we clean up after ourselves
apt-get -qy update
apt-get -qy install --no-install-recommends ${DEPENDENCIES}
apt-get -qy autoclean
apt-get -qy clean
apt-get -qy autoremove --purge
rm -rf ${AUXILIARY_FILES}

# Generate the ConTeXt file database
mtxrun --generate

# Reindex the TeX directory structure
texhash

EOF
