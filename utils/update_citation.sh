#!/bin/sh

version=$(head -n 1 VERSION)

dash='-'

parse_name() {

    name="$1"

    # try to parse first-last name
    blanks=$(echo "${name}" | sed 's/[^ ]//g' | wc -m)

    if [ "${blanks}" -gt 2 ]; then
        echo "${dash} name: ${name}" >>CITATION.cff
    else
        first=$(echo "${name}" | sed -e 's/ .*//')
        last=$(echo "${name}" | sed -e 's/[^ ]* //')
        echo "${dash} family-names: \"${last}\"" >>CITATION.cff
        echo "  given-names: \"${first}\"" >>CITATION.cff
    fi
}

# get the release date from the spec file
date=$(grep '^ *\* [0-9]' NEWS.md | head -n 1 | sed -e 's/^ *\* //' -e 's/ .*//')

cat <<EOT >CITATION.cff
cff-version: 1.2.0
message: "If you use this software, please cite it as below."
authors:
- family-names: "Corti"
  given-names: "Matteo"
  orcid: "https://orcid.org/0000-0002-1746-1108"
EOT

grep '[*] Many thanks to' AUTHORS.md |
    sed -e 's/^[*] Many thanks to //' -e 's/ for.*//' |
    sort -d |
    uniq |
    while IFS= read -r line; do

        if echo "${line}" | grep -q '^\['; then

            # GitHub Link

            user=$(echo "${line}" | sed -e 's/^\[//' -e 's/\].*//')
            url=$(echo "${line}" | sed -e 's/^.*(//' -e 's/).*//')

            if echo "${user}" | grep -q '[ ]'; then
                # most likely a name
                parse_name "${user}"

            else
                echo "${dash} name: ${user}" >>CITATION.cff
            fi

            echo "  website: ${url}" >>CITATION.cff

        else

            parse_name "${line}"

        fi

    done

cat <<EOT >>CITATION.cff
title: "check_ssl_cert"
version: ${version}
date-released: ${date}
url: "https://github.com/matteocorti/check_ssl_cert"
repository-code: "https://github.com/matteocorti/check_ssl_cert"
keywords:
  - "certificate"
  - "openssl"
  - "shell-script"
  - "nagios-plugin"
abstract: A shell script (that can be used as a Nagios/Icinga plugin) to check an SSL/TLS connection.
contact:
  - email: matteo@corti.li
    family-names: Corti
    given-names: Matteo
type: software
license: GPL-3.0
EOT
