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
    python3-pygments \
    ruby \
    wget \
    zip \
"
ARG BUILD_DIR=/git-repo
ARG DIST_DIR=${BUILD_DIR}/dist
ARG INSTALL_DIR=/usr/local/texlive/texmf-local

FROM texlive/texlive:latest as build
ARG DEPENDENCIES
ARG BUILD_DIR
ARG DIST_DIR
ARG INSTALL_DIR
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm
COPY . /git-repo/
RUN set -o errexit \
 && set -o nounset \
 && set -o xtrace \
 && apt-get -qy update \
 && apt-get -qy install --no-install-recommends ${DEPENDENCIES} \
 && mtxrun --generate \
 && make -C ${BUILD_DIR} base \
 && mkdir -p                                                  ${INSTALL_DIR}/tex/luatex/markdown/ \
 && cp -f ${BUILD_DIR}/markdown.lua                           ${INSTALL_DIR}/tex/luatex/markdown/ \
 && mkdir -p                                                  ${INSTALL_DIR}/scripts/markdown/ \
 && cp -f ${BUILD_DIR}/markdown-cli.lua                       ${INSTALL_DIR}/scripts/markdown/ \
 && mkdir -p                                                  ${INSTALL_DIR}/tex/generic/markdown/ \
 && cp -f ${BUILD_DIR}/markdown.tex                           ${INSTALL_DIR}/tex/generic/markdown/ \
 && mkdir -p                                                  ${INSTALL_DIR}/tex/latex/markdown/ \
 && cp -f ${BUILD_DIR}/markdown.sty                           ${INSTALL_DIR}/tex/latex/markdown/ \
 && cp -f ${BUILD_DIR}/markdownthemewitiko_dot.sty            ${INSTALL_DIR}/tex/latex/markdown/ \
 && cp -f ${BUILD_DIR}/markdownthemewitiko_graphicx_http.sty  ${INSTALL_DIR}/tex/latex/markdown/ \
 && cp -f ${BUILD_DIR}/markdownthemewitiko_tilde.sty          ${INSTALL_DIR}/tex/latex/markdown/ \
 && mkdir -p                                                  ${INSTALL_DIR}/tex/context/third/markdown/ \
 && cp -f ${BUILD_DIR}/t-markdown.tex                         ${INSTALL_DIR}/tex/context/third/markdown/ \
 && texhash \
 && make -C ${BUILD_DIR} dist \
 && mkdir ${DIST_DIR} \
 && unzip ${BUILD_DIR}/markdown.tds.zip -d ${DIST_DIR}

FROM texlive/texlive:latest
ARG AUXILIARY_FILES
ARG DEPENDENCIES
ARG DIST_DIR
ARG INSTALL_DIR
LABEL authors="Vít Novotný <witiko@mail.muni.cz>"
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm
COPY --from=build ${DIST_DIR} ${INSTALL_DIR}/
RUN set -o errexit \
 && set -o nounset \
 && set -o xtrace \
 && apt-get -qy update \
 && apt-get -qy install --no-install-recommends ${DEPENDENCIES} \
 && apt-get -qy autoclean \
 && apt-get -qy clean \
 && apt-get -qy autoremove --purge \
 && rm -rf ${AUXILIARY_FILES} \
 && mtxrun --generate \
 && texhash
