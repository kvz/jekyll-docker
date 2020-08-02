# WIP: currently unused. trying to reverse engineer the Dockerfile so we're
# not relying on docker-template anymore
FROM ruby:2.7.1-alpine3.11
ADD repos/jekyll/copy/ /
CMD ["/bin/sh"]
RUN apk add --no-cache \
  gmp-dev
RUN set -eux;  mkdir -p /usr/local/etc;  { \
  echo 'install: --no-document'; \
  echo 'update: --no-document';  } >> /usr/local/etc/gemrc
ENV RUBY_MAJOR=2.7
ENV RUBY_VERSION=2.7.1
ENV RUBY_DOWNLOAD_SHA256=b224f9844646cc92765df8288a46838511c1cec5b550d8874bd4686a904fcee7
RUN set -eux; \
  apk add --no-cache --virtual .ruby-builddeps \
  autoconf \
  bison \
  bzip2 \
  bzip2-dev \
  ca-certificates \
  coreutils \
  dpkg-dev dpkg \
  gcc \
  gdbm-dev \
  glib-dev \
  libc-dev \
  libffi-dev \
  libxml2-dev \
  libxslt-dev \
  linux-headers \
  make \
  ncurses-dev \
  openssl \
  openssl-dev \
  procps \
  readline-dev \
  ruby \
  tar \
  xz \
  yaml-dev \
  zlib-dev  ; \
  wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz";  echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum --check --strict; \
  mkdir -p /usr/src/ruby;  tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1;  rm ruby.tar.xz; \
  cd /usr/src/ruby; \
  wget -O 'thread-stack-fix.patch' 'https://bugs.ruby-lang.org/attachments/download/7081/0001-thread_pthread.c-make-get_main_stack-portable-on-lin.patch';  echo '3ab628a51d92fdf0d2b5835e93564857aea73e0c1de00313864a94a6255cb645 *thread-stack-fix.patch' | sha256sum --check --strict;  patch -p1 -i thread-stack-fix.patch;  rm thread-stack-fix.patch; \
  { \
  echo '#define ENABLE_PATH_CHECK 0'; \
  echo; \
  cat file.c;  } > file.c.new;  mv file.c.new file.c; \
  autoconf;  gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)";  export ac_cv_func_isnan=yes ac_cv_func_isinf=yes;  ./configure \
  --build="$gnuArch" \
  --disable-install-doc \
  --enable-shared  ;  make -j "$(nproc)";  make install; \
  runDeps="$( \
  scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
  | tr ',' '\n' \
  | sort -u \
  | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }'  )";  apk add --no-network --virtual .ruby-rundeps \
  $runDeps \
  bzip2 \
  ca-certificates \
  libffi-dev \
  procps \
  yaml-dev \
  zlib-dev  ;  apk del --no-network .ruby-builddeps; \
  cd /;  rm -r /usr/src/ruby;  ! apk --no-network list --installed \
  | grep -v '^[.]ruby-rundeps' \
  | grep -i ruby  ;  [ "$(command -v ruby)" = '/usr/local/bin/ruby' ];  ruby --version;  gem --version;  bundle --version
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 BUNDLE_APP_CONFIG=/usr/local/bundle
ENV PATH=/usr/local/bundle/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"
CMD ["irb"]
LABEL maintainer="Jordon Bedwell <jordon@envygeeks.io>"
COPY repos/jekyll/copy/ /
ENV BUNDLE_HOME=/usr/local/bundle
ENV BUNDLE_APP_CONFIG=/usr/local/bundle
ENV BUNDLE_DISABLE_PLATFORM_WARNINGS=true
ENV BUNDLE_BIN=/usr/local/bundle/bin
ENV GEM_BIN=/usr/gem/bin
ENV GEM_HOME=/usr/gem
ENV RUBYOPT=-W0
ENV JEKYLL_VAR_DIR=/var/jekyll
ENV JEKYLL_DOCKER_TAG=4.1.1
ENV JEKYLL_VERSION=4.1.1
ENV JEKYLL_DOCKER_COMMIT=c943c3494bbd019fa2e54178a27e405b495b7ec9
ENV JEKYLL_DOCKER_NAME=jekyll
ENV JEKYLL_DATA_DIR=/srv/jekyll
ENV JEKYLL_BIN=/usr/jekyll/bin
ENV JEKYLL_ENV=development
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV TZ=America/Chicago
ENV PATH=/usr/jekyll/bin:/usr/local/bundle/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US
ENV VERBOSE=false
ENV FORCE_POLLING=false
ENV DRAFTS=false
RUN apk --no-cache add \
  zlib-dev \
  libffi-dev \
  build-base \
  libxml2-dev \
  imagemagick-dev \
  readline-dev \
  libxslt-dev \
  libffi-dev \
  yaml-dev \
  zlib-dev \
  vips-dev \
  sqlite-dev \
  cmake
RUN apk --no-cache add \
  linux-headers \
  openjdk8-jre \
  less \
  zlib \
  libxml2 \
  readline \
  libxslt \
  libffi \
  git \
  nodejs \
  tzdata \
  shadow \
  bash \
  su-exec \
  nodejs-npm \
  libressl \
  yarn
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN unset GEM_HOME && unset GEM_BIN && \
  yes | gem update --system
RUN unset GEM_HOME && unset GEM_BIN && yes | gem install --force bundler
RUN gem install jekyll -v4.1.1 -- \
    --use-system-libraries
RUN gem install html-proofer jekyll-reload jekyll-mentions jekyll-coffeescript jekyll-sass-converter jekyll-commonmark jekyll-paginate jekyll-compose jekyll-assets RedCloth kramdown jemoji jekyll-redirect-from jekyll-sitemap jekyll-feed minima -- \
    --use-system-libraries
RUN addgroup -Sg 1000 jekyll
RUN adduser  -Su 1000 -G \
  jekyll jekyll
RUN mkdir -p $JEKYLL_VAR_DIR
RUN mkdir -p $JEKYLL_DATA_DIR
RUN chown -R jekyll:jekyll $JEKYLL_DATA_DIR
RUN chown -R jekyll:jekyll $JEKYLL_VAR_DIR
RUN chown -R jekyll:jekyll $BUNDLE_HOME
RUN rm -rf /home/jekyll/.gem
RUN rm -rf $BUNDLE_HOME/cache
RUN rm -rf $GEM_HOME/cache
RUN rm -rf /root/.gem
RUN mkdir -p /usr/gem/cache/bundle
RUN chown -R jekyll:jekyll \
  /usr/gem/cache/bundle
CMD ["jekyll" "--help"]
ENTRYPOINT ["/usr/jekyll/bin/entrypoint"]
WORKDIR /srv/jekyll
VOLUME [/srv/jekyll]
EXPOSE 35729
EXPOSE 4000