#!/bin/bash
rsync -rci  --exclude='.git*' --progress $webappwar_path* $JBOSS_WEBAPPWAR;
