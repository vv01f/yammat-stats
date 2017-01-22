#!/bin/bash

arch_diff=10
norm_diff=50

url="http://matemat.hq.c3d2.de/"
tmpdir="./tmp/"
listfile="-list.text"

cash=0
#echo -en "\nCount The Cash!\n\nAmount:\t"	
#read cash
data=""

mkdir -p ${tmpdir}
datum=$( date +"%y%m%dT%H%M%S" )
udate=$( date +"%s" )
file=$(echo ${tmpdir}${datum}"-")
out=${udate}${listfile}

echo -en "\n["

#~ stage=inventory.json
#~ dir="backup/"
#~ path=${url}${dir}${stage}
#~ filename=${file}${stage}
#~ wget -q ${path} -O ${tmpdir}${stage}
#~ e=$?
#~ if [ $e -ne 0 ]; then
	#~ echo "Stats not available: "${path}
	#~ exit 1;
#~ fi
#~ invfile=${tmpdir}${stage}
#~ json_file=${invfile}
#~ n=$(( $( cat ${invfile} | jq -rMS . | grep "{" | wc -l ) - 1 ))
#~ printf '{'"\n" >> ${out}
#~ for i in $( seq 0 1 ${n} ); do
	#~ json_file_i=${json_file}"_"${i}
	#~ cat ${json_file} | jq -S ".["${i}"]" > ${json_file_i}
	#~ #echo -n "----------------"
	#~ #echo "\"item\": "${i}","
	#~ json_vars=$( cat ${json_file_i} | jq -rMS . | cut -d'"' -f2|head -n -1|tac|head -n -1|tac )
	#~ printf '{'"\n" >> ${out}
	#~ for e in ${json_vars}; do
		#~ var_name=$e
		#~ var_cont=$( cat ${json_file_i} | jq "."${e} )
		#~ if [[ $var_cont = "null" ]]; then
			#~ var_cont=0;
		#~ fi
		#~ # variablennamen dem namen in einer variable zuweisen (printf -v) und auslesen (printf ${!name})
		#~ printf -v ${var_name} "%q" ${var_cont}
		#~ #ginge in bash auch mit `declare`
		#~ #für sh geht `eval ${var_name}` $( cat ${json_file} | jq "."${var_name} )
		#~ #declare ${var_name} $( cat ${json_file} | jq "."${var_name} )
		#~ printf "\"${var_name}\": ${!var_name},\n" >> ${out}
		#~ if [[ ${data} != "" ]]; then
			#~ data=${data}","
		#~ fi
		#~ #echo -n ${i}
		#~ echo -n ":"
		#~ data=${data}"item"${i}"_"${var_name}"="${!var_name}
		#~ #echo $data
		#~ #sleep .1
	#~ done
	#~ printf '"none": 0\n},'"\n" >> ${out}
#~ done
#~ printf '{"none": 0}}'"\n" >> ${out}


stage=statistics.json
dir=""
path=${url}${dir}${stage}
filename=${file}${stage}
wget -q ${path} -O ${tmpdir}${stage}
e=$?
if [ $e -ne 0 ]; then
	echo "Stats not available: "${path}
	exit 1;
fi
statsfile=${tmpdir}${stage}

json_file=${statsfile}
json_vars=$( cat ${json_file} | jq -rMS . | cut -d'"' -f2|head -n -1|tac|head -n -1|tac )
for e in ${json_vars}; do
	var_name=$e
	# variablennamen dem namen in einer variable zuweisen (printf -v) und auslesen (printf ${!name})
	printf -v ${var_name} "%q" $( cat ${json_file} | jq "."${var_name} )
	#ginge in bash auch mit `declare`
	#für sh geht `eval ${var_name}` $( cat ${json_file} | jq "."${var_name} )
	#declare ${var_name} $( cat ${json_file} | jq "."${var_name} )
	if [[ ${data} != "" ]]; then
		data=${data}","
	fi
	echo -n ":"
	data=${data}${var_name}"="${!var_name}
	#printf ${var_name}": "${!var_name}"\n"
	printf ${var_name}": "${!var_name}"\n" >> ${out}
done

echo -e "]\n"

#total_loss_prime_price=$( $buyprice / $bottlespercrate * $missing_bottles) )#verlust der getränke zum einkaufpreis

#var="hack"; value="ePeter"; printf -v $var $value; printf ${var}": "${!var%}"\n"

data=${data}" "${udate}"000000000"
echo ${data} > ./data.post


source influxdb-conf.sh
# nur ein bsp
url=https://${influx_usr}:${influx_pwd}@${influx_hst}:${influx_prt}/write?db=${influx_dbn}
data=${influx_tbl}\ ${data}
echo curl -v -i -POST ${url} --data-binary ${data}
echo -e "\n\n"
curl -v -i -POST ${url} --data-binary ${data}


echo -e "\nDump-File: "${out}
