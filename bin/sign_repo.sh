#!/bin/sh
#
# Copyright (c) 2011 Citrix Systems, Inc.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

#
# Generates the XC-SIGNATURE metadata file for an OpenXT repository.

parse_args()
{
    if [ $# -ne 3 ] ; then
        usage
        exit 1
    fi

    CERTIFICATE="$1"
    PRIVATE_KEY="$2"
    REPOSITORY_DIR="$3"

    REPOSITORY_FILE="${REPOSITORY_DIR}/XC-REPOSITORY"
    SIGNATURE_FILE="${REPOSITORY_DIR}/XC-SIGNATURE"
}

usage()
{
    cat <<EOF
Usage: $(basename $0) CERTIFICATE PRIVATE_KEY REPOSITORY_DIR

Signs an OpenXT repository: uses the supplied certificate and private key
to generate a signature of the XC-REPOSITORY file and writes it to the
XC-SIGNATURE file.
EOF
}

generate_signature()
{
    local PASSPHRASE_ARG

    [ "${PASSPHRASE}" ] && PASSPHRASE_ARG="-passin env:PASSPHRASE"

    openssl smime -sign \
                  -aes256 \
                  -binary \
                  -in "${REPOSITORY_FILE}" \
                  -out "${SIGNATURE_FILE}" \
                  -outform PEM \
                  -signer "${CERTIFICATE}" \
                  -inkey "${PRIVATE_KEY}" \
                  ${PASSPHRASE_ARG} ||
        die "error generating signature"
}

die()
{
    echo "$(basename $0): $*" >&2
    exit 1
}

parse_args "$@"

generate_signature
