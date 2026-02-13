FROM debian:stable-slim
LABEL org.opencontainers.image.authors="https://github.com/nbredenbals"

VOLUME /etc/cups

RUN apt-get update \
&& apt-get install -y \
  sudo \
  gettext-base \
  usbutils \
  cups \
  cups-bsd \
  cups-filters \
  cups-browsed \
  foomatic-db-engine \
  foomatic-db-compressed-ppds \
  openprinting-ppds \
  hp-ppd \
  printer-driver-hpcups \
  printer-driver-foo2zjs \
  printer-driver-pnm2ppa \
  printer-driver-cups-pdf \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

RUN cp -R  /etc/cups /etc/cups_original

# This will use port 631
#EXPOSE 631

RUN mkdir -p /opt/cupsi/
COPY --chown=root:lp --chmod=644 cupsd.conf.tpl /opt/cupsi/cupsd.conf.tpl
COPY --chown=root:lp --chmod=644 cups-files.conf /opt/cupsi/cups-files.conf

COPY --chmod=700 entrypoint.sh /entrypoint.sh

COPY --chown=root:root --chmod=644 nsswitch.conf /etc/nsswitch.conf

# Remove default config files to force usage of our templated ones
RUN rm /etc/cups/cupsd.conf \
       /etc/cups/cups-files.conf

RUN rm /etc/cups_original/cupsd.conf \
       /etc/cups_original/cups-files.conf

# Run as root, as CUPS needs to bind to low ports and manage devices
ENTRYPOINT ["/entrypoint.sh"]

# Default shell
CMD ["/usr/sbin/cupsd", "-f"]
