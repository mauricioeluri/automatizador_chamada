#!/bin/bash
rm cookie
rm saida.txt
rm saidaAtividade.txt

USER=161150897
PASSWORD="#B@tatinhas"

DATE=`date +%Y%m%d`
ATIVIDADE="TESTEchamada_$DATE"


echo -n "Realizando login... "
curl -c "cookie" -X POST -d "username=$USER&password=$PASSWORD&rememberusername=1" --silent --output /dev/null https://moodle.unipampa.edu.br/moodle/login/index.php
echo "concluído."

echo -n "Acessando página do curso... "
curl -b "cookie" --silent https://moodle.unipampa.edu.br/moodle/course/view.php?id=8655 | grep $ATIVIDADE > saida.txt
echo "concluído."


LINK_CHAMADA="$(sed 's/^.*href="\(https[^"]*\)".*'$ATIVIDADE'/\1/;s/^\([^<]*\)<span.*$/\1/' saida.txt)&action=editsubmission"
#BACKUP DA EXPRESSÃO REGULAR QUE FUNCIONA
#LINK_CHAMADA="$(sed 's/^.*href="\(https[^"]*\)".*TESTEchamada_20190604/\1/;s/^\([^<]*\)<span.*$/\1/' saida.txt)"

echo -n "Acessando página da atividade... "
curl -b "cookie" --silent $LINK_CHAMADA > saidaAtividade.txt
echo "concluído."

IFS='=' read -a array_ID_ATIVIDADE <<< "${LINK_CHAMADA}"
ID_ATIVIDADE=${array_ID_ATIVIDADE[1]::-7}
linha_SESSKEY="$(cat saidaAtividade.txt | grep name=\"sesskey\" | xargs)"
IFS='=' read -a array_SESSKEY <<< "${linha_SESSKEY}"
SESSKEY=${array_SESSKEY[6]::-1}
linha_LASTMODIFIED="$(cat saidaAtividade.txt | grep name=\"lastmodified\" | xargs)"
IFS='=' read -a array_LASTMODIFIED <<< "${linha_LASTMODIFIED}"
LASTMODIFIED=${array_LASTMODIFIED[4]::-3}
linha_USERID="$(cat saidaAtividade.txt | grep name=\"userid\" | xargs)"
IFS='=' read -a array_USERID <<< "${linha_USERID}"
USERID=${array_USERID[3]::-3}
linha_TEXTEDITORITEMID="$(cat saidaAtividade.txt | grep name=\"onlinetext_editor | tr " " "\n" | grep value | sed -n 2p | xargs)"
IFS='=' read -a array_TEXTEDITORITEMID <<< "${linha_TEXTEDITORITEMID}"
TEXTEDITORITEMID=${array_TEXTEDITORITEMID[1]}

echo -n "Enviando chamada..."
curl -b "cookie" -X POST -d "sesskey=$SESSKEY&id=$ID_ATIVIDADE&userid=$USERID&onlinetext_editor[itemid]=$TEXTEDITORITEMID&lastmodified=$LASTMODIFIED&action=savesubmission&_qf__mod_assign_submission_form=1&onlinetext_editor[format]=1&onlinetext_editor[text]=PRESENTE" --silent https://moodle.unipampa.edu.br/moodle/mod/assign/view.php --output /dev/null
echo "concluído."

echo "SUA CHAMADA FOI ENVIADA COM SUCESSO!"
