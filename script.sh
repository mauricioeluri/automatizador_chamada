#!/bin/bash
rm cookie
rm saida.txt

USER=161150897
PASSWORD="#B@tatinhas"

DATE=`date +%Y%m%d`
ATIVIDADE="TESTEchamada_$DATE"

curl -c "cookie" -X POST -d "username=$USER&password=$PASSWORD&rememberusername=1" --silent --output /dev/null https://moodle.unipampa.edu.br/moodle/login/index.php

curl -b "cookie" --silent https://moodle.unipampa.edu.br/moodle/course/view.php?id=8655 | grep $ATIVIDADE > saida.txt


LINK_CHAMADA="$(sed 's/^.*href="\(https[^"]*\)".*'$ATIVIDADE'/\1/;s/^\([^<]*\)<span.*$/\1/' saida.txt)"
#BACKUP DA EXPRESSÃO REGULAR QUE FUNCIONA
#LINK_CHAMADA="$(sed 's/^.*href="\(https[^"]*\)".*TESTEchamada_20190604/\1/;s/^\([^<]*\)<span.*$/\1/' saida.txt)"

echo $LINK_CHAMADA"&action=editsubmission"

curl -b "cookie" $LINK_CHAMADA > saidaAtividade.txt
