#!/usr/bin/env bash

#-VARIAVEIS INFO-----------------------------------------------------#

NOME_PROGRAMA="$(basename $0 | cut -d. -f1)"
VERSAO="1.0"
AUTOR="Ingresse"
CONTATO="https://github.com/CarlosDominciano/PI-Grupo-5"
DESCRICAO="Script para executar o .jar do projeto do cluster"
varEXE=$1 # Se não tiver parametros ela executa normal


#-VARIAVEIS PARAMETRO----------------------------------------------------#

varINFO="
Nome do Programa: $NOME_PROGRAMA
Autor: $AUTOR
Versão: $VERSAO
Descrição do Programa: $DESCRICAO
"
varHELP="
Instruções para Ajuda:
	-h ou --help: Abre a ajuda de comandos do usuário;
	-i ou --info: Informações sobre o programa;
"

#-TESTES--------------------------------------------------------------------------#



#-LOOP PARA RODAR MAIS PARAMETROS---------------------------------------------------#

while test -n "$1"; do

	case $1 in

		-i |  --info)  	echo "$varINFO" 											;;		
		-h |  --help)  	echo "$varHELP"												;;
		-d | --debug)	bash -x $0													;;
		 *) 	echo "\nComando inválido. Digite -h ou --help para ajuda\n"	;;

	esac
	shift

done
#-FUNÇÕES--------------------------------------------------------------------------#
instalar_pacotes(){
	echo "\n\n=================================================="
	echo "Instalando e verificando todos os pacotes..."
	sudo apt-get update && sudo apt-get upgrade -y
	
	echo "\n\n=================================================="
	echo "Verificando docker..."
	echo "==================================================\n\n"
	sudo apt install docker.io -y
}
criar_ingresse100(){
	echo "\n\n=================================================="
	echo "Criando usuário ingresse100.."
	echo "==================================================\n\n"
	adduser ingresse100
	usermod -aG sudo ingresse100
}
clonar_github(){

	echo "\n\n=================================================="
	echo "Buscando .jar no github ingresse"
	echo "==================================================\n\n"
	git clone https://github.com/diegozn/docker
	echo "\n\n=================================================="
	echo "Carregando..."
	echo "==================================================\n\n"
	cd docker

}
instalar_container(){
	sudo systemctl start docker
	sudo systemctl enable  docker
	echo "\n\n=================================================="
	echo "Criando uma network..."
	echo "==================================================\n\n"
	sudo docker network create ingresse-net
	echo "\n\n=================================================="
	echo "Rodando mysql no Docker"
	echo "==================================================\n\n"
	
	sudo docker build -t ingresse-bd ./ingresse_banco/.
	sudo docker run -d --name mysql-totem -p 3306:3306 --net=ingresse-net ingresse-bd
	echo "\n\n=================================================="
	echo "Rodando java no Docker"
	echo "==================================================\n\n"
	##	
	sudo docker build -t java-image ./ingresse_app/.
	sudo docker start mysql-totem s
	sudo docker run -it --link mysql-totem --net=ingresse-net java-image       
	                                                   

}

main(){
	criar_ingresse100
	clear
	instalar_pacotes
	clear
	clonar_github
	clear
	instalar_container
}

baixar_scripts(){

	mkdir mysql
	mkdir java
	wget -O Dockerfile https://raw.githubusercontent.com/diegozn/docker/main/ingresse_app/Dockerfile
	mv ./Dockerfile ./java/Dockerfile
	wget -O Dockerfile https://raw.githubusercontent.com/diegozn/docker/main/ingresse_banco/Dockerfile
	mv ./Dockerfile ./mysql/Dockerfile
	wget -O sql.sql https://raw.githubusercontent.com/diegozn/docker/main/ingresse_banco/sql.sql
	mv ./sql.sql ./mysql/sql.sql
	mv ./ingresseCLI.jar ./java/ingresseCLI.jar
	#
}

if [ -z "$varEXE" ]; then
	main
fi
