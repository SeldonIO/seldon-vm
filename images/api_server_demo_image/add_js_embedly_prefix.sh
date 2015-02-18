#!/bin/bash

set -o nounset
set -o errexit

export EMBEDLY_KEY=${EMBEDLY_KEY:-}

JS_SCRIPT=$(ls /webapps/movie-demo/scripts/scripts.*.js)

if [ -z "${EMBEDLY_KEY}" ]; then
    sed -i -e 's/<EMBEDLY_HERE>//g' ${JS_SCRIPT}
else
    sed -i -e 's/<EMBEDLY_HERE>/http:\/\/i.embed.ly\/1\/display\/resize?key='${EMBEDLY_KEY}'\&url=/g' ${JS_SCRIPT}
fi

