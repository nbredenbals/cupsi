#!/bin/sh
if [ ! -f /etc/cups/cupsd.conf ]; then
    echo "Generating /etc/cups/cupsd.conf from template"
    LOGLEVEL="${LOGLEVEL:-warn}" \
    LOCALNET="${LOCALNET:-192.168.1.*}" \
    CUPS_HOSTNAME="${CUPS_HOSTNAME:-`hostname -f`}" \
    CUPS_PORT="${CUPS_PORT:-443}" \
    envsubst < /opt/cupsi/cupsd.conf.tpl > /etc/cups/cupsd.conf
fi

if [ ! -f /etc/cups/cups-files.conf ]; then
    echo "Copying default /etc/cups/cups-files.conf"
    cp -R /etc/cups_original/* /etc/cups/
    cp /opt/cupsi/cups-files.conf /etc/cups/cups-files.conf
fi


CUPSUSER=${CUPSUSER:-cupsadm}
CUPSPASSWORD="${CUPSPASSWORD:-`cat ${CUPSPASSWORD_FILE}`}"
if [ -z $CUPSPASSWORD ]; then 
    CUPSPASSWORD=$(openssl rand -base64 12)
    echo "Generated random CUPS password for user ${CUPSUSER}: ${CUPSPASSWORD}" >&2
fi

mkdir -p /etc/cups/ssl

# Add the user `cups` if it does not exist
# The user does not run any processes, but is member in lp and lpadmin
# to allow web access to printer administration
if ! id "${CUPSUSER}" > /dev/null 2>&1; then
    addgroup ${CUPSUSER}
    useradd -G lp,lpadmin -g ${CUPSUSER} --shell /bin/false "${CUPSUSER}"
    echo ${CUPSPASSWORD} | passwd ${CUPSUSER} --stdin >/dev/null 2>&1
fi

# Run the standard container command.
exec "$@"
