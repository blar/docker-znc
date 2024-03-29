ARG ARCH=amd64
ARG ALPINE_VERSION=3.15
FROM $ARCH/alpine:$ALPINE_VERSION
ARG ZNC_VERSION=1.8.2
ARG BUILD_DATE
ARG VCS_URL
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vcs-url=$VCS_URL
LABEL maintainer="gmblar+github@gmail.com"
EXPOSE 80/tcp
EXPOSE 6667/tcp
COPY src /
RUN znc-setup
USER znc
HEALTHCHECK CMD znc-healthcheck
ENTRYPOINT ["znc-entrypoint"]
CMD ["znc", "--foreground", "--datadir=/var/lib/znc"]
