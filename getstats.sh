#!/bin/bash

url=http://matemat.hq.c3d2.de/
#angel-amounts
agl=10
aal=50
#file-dir
tmpdir="./tmp/"
#output file extension
listfile="-list.text"
#counter
user=0
errcnt=0
errusr=0
e=0
dbt=0
cdt=0
cnt=0
pos=0
neg=0
dev=0
ang=0
adv=0
aag=0
#Kassensturz
echo -en "\nCount The Cash!\n\nAmount:\t"
read cash

mkdir -p ${tmpdir}
datum=$( date +"%y%m%dT%H%M%S" )
file=$(echo ${tmpdir}${datum}"-")
echo -e "Auswertung vom: "$( date +"%d.%m.%Y %H:%M" )"\n\nUser\tEuro\tName" > ${datum}${listfile}
echo -ne "\nProcessing Matemat Users ...\n["
#devil-amounts 
dvl=$(echo "-1 * ${agl}" | bc )
adl=$(echo "-1 * ${aal}" | bc )


filename=${file}-journal.html
wget -q ${url}journal -O ${filename}
e=$?
if [ $e -ne 0 ]; then
	echo "Jornal not available: "${url}/journal
	exit 1;
fi
stock=$( echo $( grep -i "Kassenbestand:" ${filename} | cut -d":" -f2 | cut -d"<" -f1 ) )
while : ; do
	filename=${file}${user}.html
	#datei holen
	wget -q ${url}user/${user} -O ${filename}
	#datei auf erfolg prüfen
	e=$?
	if [ $e -ne 0 ]; then
		errcnt=$(( ${errcnt} +1 ))
	else
		grep '<div id="message">Nutzer unbekannt</div>' ${filename} > /dev/null
		e=$?
		if [ $e -ne 0 ]; then
			#erfolg speichern
			errcnt=0
			cnt=$(( ${cnt} + 1 ))
			echo -n ":"
				#guthaben
			euro=$( grep -o 'aktuelles Guthaben:.*' ${filename} | cut -d'<' -f1 | cut -d':' -f2 | cut -d' ' -f2 | tr ',' '.' )
			if [[ $( echo "${euro} < 0" | bc ) -eq 1 ]]; then
				dbt=$( echo "${dbt} + ${euro}" |bc )
				neg=$(( ${neg} + 1 ))
			else
	#			#cdt=$(( ${cdt} + ${euro} ))
				cdt=$( echo "${cdt} + ${euro}" | bc )
				pos=$(( ${pos} + 1 ))
			fi
			if [[ $( echo "${euro} < ${dvl}" | bc ) -eq 1 ]]; then
				dev=$(( ${dev} + 1 ))
			fi
			if [[ $( echo "${euro} > ${agl}" | bc ) -eq 1 ]]; then
				ang=$(( ${ang} + 1 ))
			fi
			if [[ $( echo "${euro} < ${adl}" | bc ) -eq 1 ]]; then
				adv=$(( ${adv} + 1 ))
			fi
			if [[ $( echo "${euro} > ${aal}" | bc ) -eq 1 ]]; then
				aag=$(( ${aag} + 1 ))
			fi
	#		echo -e "\n€: "${euro}"\nS: "${dbt}"\nH: "${cdt}
			#name
			name=$( grep '<h3>Wähle deinen Artikel,' ${filename}|cut -d',' -f2|cut -d' ' -f2|cut -d'<' -f1 )
			echo -e ${user}"\t"${euro}"\t"${name} >> ${datum}${listfile}
		else
			#fehler speichern
			errcnt=$(( ${errcnt} +1 ))
			#fehlerhaftes erebnis löschen
			rm ${filename}
		fi
	fi
	if [[ ${errcnt} -gt 3 ]]; then
		#bei >x fehlern abbrechen
		break
	fi
	#next userfile
	user=$(( ${user} + 1 ))
done
rm ${file}*.html
wget -q ${url} -O ./tmp/startpage
useractive=$( echo $( cat ./tmp/startpage | grep -c -i 'href="http://matemat.hq.c3d2.de/user/' ) - 1 | bc )
rm ./tmp/startpage
##
# get information for missing items
##
#filename=${file}-summary.html
#wget -q ${url}summary -O ${filename}
#
##

echo -e "]\n\n== Matemat User Statistics ==\n\nTotal Users:\t"${cnt}"\nActive Users:\t"${useractive}"\nGood Users:\t+"${cdt}" € ("${pos}" Users)\nEvil Users:\t"${dbt}" € ("${neg}" Users)\nNoobangel:\t"${ang}" ( > +${agl} €)\nNoobdevil:\t"${dev}" ( < ${dvl} €)\nArchangel:\t"${aag}" ( > +${aal} €)\nArchdevil:\t"${adv}" ( < ${adl} €)\n"
echo -e "\nTotal Users:\t"${cnt}"\nActive Users:\t"${useractive}"\nGood Users:\t+"${cdt}" € ("${pos}" Users)\nEvil Users:\t"${dbt}" € ("${neg}" Users)\nNoobangel:\t"${ang}" ( > +${agl} €)\nNoobdevil:\t"${dev}" ( < ${dvl} €)\nArchangel:\t"${aag}" ( > +${aal} €)\nArchdevil:\t"${adv}" ( < ${adl} €)" >> ${datum}${listfile}
if [[ ! -z ${cash} ]]; then
	echo -e "CashReg:\t"${cash}" €"
	echo -e "\nCashReg:\t"${cash}" €\n" >> ${datum}${listfile}
fi
echo -e "CashYMT:\t"${stock}
echo -e "\nCashYMT:\t"${stock}"\n" >> ${datum}${listfile}
