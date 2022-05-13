#!/bin/bash

[ ! -f /init/init_ok ] && python /init/init.py &
/lifecycle/ak server