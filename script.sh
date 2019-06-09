#!/bin/bash

#INSIRA SEUS DADOS AQUI
USER=123456
PASSWORD="password"

le_disciplina()
{
    echo "Selecione a disciplina para responder a chamada:"
    echo "1 - Linux"
    echo "2 - Ataques"
    read DISCIPLINA 

    if [ $DISCIPLINA == 1 ]
    then
        ID_DISCIPLINA="8655"
    elif [ $DISCIPLINA == 2 ]
    then
        ID_DISCIPLINA="8656"
    else
        echo "[ERRO] Selecione um número entre 1 e 2."
        le_disciplina
    fi
}

le_disciplina
#Pegando data atual
DATE=`date +%Y%m%d`
#Definindo nome da atividade
ATIVIDADE="chamada_$DATE"
#Arquivos temporários
COOKIE=$(mktemp)
PAGINAATIVIDADE=$(mktemp)
PAGINAENVIOATIVIDADE=$(mktemp)

echo -n "Realizando login... "
curl -c "$COOKIE" -X POST -d "username=$USER&password=$PASSWORD&rememberusername=1" --silent --output /dev/null https://moodle.unipampa.edu.br/moodle/login/index.php
echo "concluído."

echo -n "Acessando página do curso... "
curl -b "$COOKIE" --silent https://moodle.unipampa.edu.br/moodle/course/view.php?id=$ID_DISCIPLINA | grep $ATIVIDADE > $PAGINAATIVIDADE
echo "concluído."

LINK_CHAMADA="$(sed 's/^.*href="\(https[^"]*\)".*'$ATIVIDADE'/\1/;s/^\([^<]*\)<span.*$/\1/' $PAGINAATIVIDADE)&action=editsubmission"

echo -n "Acessando página da atividade... "
curl -b "$COOKIE" --silent $LINK_CHAMADA > $PAGINAENVIOATIVIDADE
echo "concluído."

#PEGANDO PARÂMETRO ID DA ATIVIDADE
IFS='=' read -a array_ID_ATIVIDADE <<< "${LINK_CHAMADA}"
ID_ATIVIDADE=${array_ID_ATIVIDADE[1]::-7}

#PEGANDO PARÂMETRO SESSKEY
linha_SESSKEY="$(cat $PAGINAENVIOATIVIDADE | grep name=\"sesskey\" | xargs)"
IFS='=' read -a array_SESSKEY <<< "${linha_SESSKEY}"
SESSKEY=${array_SESSKEY[6]::-1}

#PEGANDO PARÂMETRO LASTMODIFIED
linha_LASTMODIFIED="$(cat $PAGINAENVIOATIVIDADE | grep name=\"lastmodified\" | xargs)"
IFS='=' read -a array_LASTMODIFIED <<< "${linha_LASTMODIFIED}"
LASTMODIFIED=${array_LASTMODIFIED[4]::-3}

#PEGANDO PARÂMETRO USERID
linha_USERID="$(cat $PAGINAENVIOATIVIDADE | grep name=\"userid\" | xargs)"
IFS='=' read -a array_USERID <<< "${linha_USERID}"
USERID=${array_USERID[3]::-3}

#PEGANDO PARÂMETRO TEXTEDITORITEMID
linha_TEXTEDITORITEMID="$(cat $PAGINAENVIOATIVIDADE | grep name=\"onlinetext_editor | tr " " "\n" | grep value | sed -n 2p | xargs)"
IFS='=' read -a array_TEXTEDITORITEMID <<< "${linha_TEXTEDITORITEMID}"
TEXTEDITORITEMID=${array_TEXTEDITORITEMID[1]}

echo -n "Enviando chamada..."
curl -b "$COOKIE" -X POST -d "sesskey=$SESSKEY&id=$ID_ATIVIDADE&userid=$USERID&onlinetext_editor[itemid]=$TEXTEDITORITEMID&lastmodified=$LASTMODIFIED&action=savesubmission&_qf__mod_assign_submission_form=1&onlinetext_editor[format]=1&onlinetext_editor[text]=PRESENTE" --silent https://moodle.unipampa.edu.br/moodle/mod/assign/view.php --output /dev/null
echo "concluído."

echo "SUA CHAMADA FOI ENVIADA COM SUCESSO!"
