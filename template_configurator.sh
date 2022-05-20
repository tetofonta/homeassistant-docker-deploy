#!/bin/bash
# template_configurator.sh [--non-interactive] source_file.env.template destination.env
NON_INTERACTIVE=0
ENV_IN_FILE=$1
ENV_OUT_FILE=${2:-/dev/null}

if [ "$ENV_IN_FILE" == "--non-interactive" ]; then
    NON_INTERACTIVE=1
    ENV_IN_FILE=$2
    ENV_OUT_FILE=${3:-/dev/null}
fi
[ -z "$ENV_IN_FILE" ] && exit 1

echo "# this file has been compiled" > "${ENV_OUT_FILE}"

while read -u 10 line; do

    if [[ $line =~ ^\#defvar\ [A-Za-z0-9_]+=.* ]]; then
        INST=$(echo $line | sed -r 's/^#defvar //g')
        VARNAME=$(echo $line | sed -r 's/^#defvar ([A-Za-z0-9_]+)=.*/\1/g')
        VALUE=$(echo $line | sed -r 's/^#defvar [A-Za-z0-9_]+=(.*)/\1/g')
        EVAL_VALUE=$(eval echo "$VALUE")
        echo "#defvar ${VARNAME}=${EVAL_VALUE}" | tee -a ${ENV_OUT_FILE}
        eval "export ${VARNAME}=${EVAL_VALUE}"
    elif [[ $line =~ ^\#input\ [A-Za-z0-9_] ]]; then
        VARNAME=$(echo $line | sed -r 's/^#input ([A-Za-z0-9_]+)=.+#.*/\1/g')
        DEFAULT=$(echo $line | sed -r 's/^#input [A-Za-z0-9_]+=(.+)#.*/\1/g')
        DESC=$(echo $line | sed -r 's/^#input [A-Za-z0-9_]+=.+#(.*)/\1/g')
        eval "[ ! -z '$DESC' -a -z \"\$$VARNAME\" ] && echo -n '$DESC\\n\\n >[$DEFAULT]'; [ -z \"\$$VARNAME\" ] && read $VARNAME || echo \"\$$VARNAME\"; [ -z \"\$$VARNAME\" ] && $VARNAME=\"$DEFAULT\"; export $VARNAME=\"\$$VARNAME\""
    else
        if [[ $line =~ ^\#noask\ [A-Za-z0-9_]+=.* ]]; then
            INST=$(echo $line | sed -r 's/^#noask //g' | envsubst)
            eval "export $INST"
            echo "$INST" >> ${ENV_OUT_FILE}
        else
            if [ -z "$line" ]; then
                continue
            fi

            VARNAME=$(echo $line | sed -r 's/^([A-Za-z0-9_]+)=.*/\1/g')
            DEFAULT_VALUE=$(echo $line | sed -r 's/^[A-Za-z0-9_]+=(.*)#.*/\1/g')
            DOCS=$(echo $line | sed -r 's/^[A-Za-z0-9_]+=.*#(.*)/\1/g')

            echo -ne "Choose value for ${VARNAME}:\n${DOCS}\n\n>[${DEFAULT_VALUE}]"
            if [ $NON_INTERACTIVE -eq 0 ]; then
                read CHOICE
            fi
            if 
            [ ! -z "$CHOICE" -o ! -z "$DEFAULT_VALUE" ]; then
                INST=$(echo "${VARNAME}=${CHOICE:-$DEFAULT_VALUE}" | envsubst)
                eval "export $INST"
                echo "$INST" >> ${ENV_OUT_FILE}
            fi
        fi
    fi
done 10< "$ENV_IN_FILE"