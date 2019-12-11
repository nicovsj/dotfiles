#!/bin/sh
_zenity="/usr/bin/zenity"

if grep -q $USER <<< cat /home/admin_config/print_banlist; then 
	zenity --warning --text="Usted no pertenece a la facultad, o esta baneado" 
	exit 1
fi 
	
#Printer node
printernode="127.0.0.1"
	
#Get user and timestamp identifiers
time=` date +"%m-%d-%Y-%T" | sed 's/[-:]/_/g'`
time2=`date +"%s"`
user=`whoami`

maxhojas=10

if [ "$(whoami)" == 'novato' ]; then
     maxhojas=50
     echo "max=50"
fi


#Si el usuario nunca ha impreso lo agregamos a la db
if [ ! -d ~/printjobs/ ]; then
    hasprinted=`mysql  --host=127.0.0.1 --user=print_user --password=linuxprinter -D printdb -e "SELECT(user) from jobs_table where user='$user'" | wc -l`
    if [ "$hasprinted" == "0" ]; then
	mkdir -p ~/.printjobs/tmp/

	#SQL command to add a null register and initialize database
	SQL_add_null_register="INSERT INTO jobs_table (user,npages,time,filename) VALUES ('$user',0,'NULL','ZERO_REGISTER')"
	SQL_add_null_row="mysql  --host=127.0.0.1 --user=print_user --password=linuxprinter -D printdb -e \"$SQL_add_null_register\""
	ssh_opt="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet"

	#Send the command trough SSH
	sshpass -p "linuxprinter" ssh $ssh_opt print_user@127.0.0.1 $SQL_add_null_row
	echo "Se imprimio por primera vez!"
    fi
fi


#File selection dialog
filename=`zenity --file-selection --title="Select a File" 2>/dev/null`
name=`echo "$filename" |  sed -e 's/ /\ /g'`
printjob=$user"_"$time"_"

#Create MD5 for logging purposes
md5printjob=$(md5sum "$name")

#Create temporal file in .printjobs folder
cp "$name" ~/.printjobs/tmp/$printjob

#Convertion to standard PDF format (1.4)
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -sPAPERSIZE=letter -dPDFFitPage -dFIXEDMEDIA -o ~/.printjobs/tmp/$printjob"_14.pdf" ~/.printjobs/tmp/$printjob > /dev/null 2>&1
pdftocairo -pdf  -r 300 ~/.printjobs/tmp/$printjob"_14.pdf" ~/.printjobs/tmp/$printjob
mv ~/.printjobs/tmp/$printjob ~/.printjobs/tmp/$printjob"_14" 
printjob=$printjob"_14"

#Count pages
npages=`get_pages_in_pdf.pl ~/.printjobs/tmp/$printjob`
npages=`echo $((($npages+1)/2))`

echo "Intentando imprimir "$npages" hojas"

#Print command
printername="HLL6400DW"
printoptions="-o sides=two-sided-long-edge -o fit-to-page -o media=Letter"
print_command="lp -d "$printername" "$printoptions

#SQL command to add a register
#echo $filename
#echo $npages
SQL_add_register="INSERT INTO jobs_table (user,npages,time,filename) VALUES ('$user',$npages,'$time2','$filename')"

#SQL Query command to ask for printed pages
SQL_get_pages="select sum(npages) from jobs_table where user = '$user' AND ABS( UNIX_TIMESTAMP(NOW()) - time) <= 43200;"

#Remote execution SQL commands
SQL_query_pages="mysql --host=127.0.0.1 --user=print_user --password=linuxprinter -D printdb -e \"$SQL_get_pages\""
SQL_add_row="mysql  --host=127.0.0.1 --user=print_user --password=linuxprinter -D printdb -e \"$SQL_add_register\""

#SSh options 
ssh_opt="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet"

if [ $? -eq 0 ]
then
  
  #Check the file is a PDF
  type=`file -ib $filename | grep -c pdf`
  
  if [ $type -lt 1 ]
  then
    ${_zenity} --error \
         --text="ERROR: Por favor seleccionar un PDF valido para imprimir."
    exit -1
  else
  #Query printed pages for this user
    pages=`sshpass -p "linuxprinter" ssh $ssh_opt print_user@$printernode $SQL_query_pages | sed 's/[sum(npages) ]//g' | sed -n '2p'`
    re='^[0-9]+$'
    
    
    if ! [[ $pages =~ $re ]]
    then
        pages=0
    fi

	num=$(echo $pages + $npages | bc)
   
    if [ "$num" -gt "$maxhojas"  ]
    then
		restantes=$(echo $(($maxhojas - $pages)) | bc)
		${_zenity} --error \
         --text="ERROR: Cuota excedida. (Quedan "$restantes" hojas de 10, intentó imprimir "$npages$")"
    else
		restantes=$(echo $(($maxhojas - $pages - $npages)) | bc)
		echo "Exito! (quedan "$restantes"/"$maxhojas" hojas)"
		sshpass -p "linuxprinter" scp $ssh_opt ~/.printjobs/tmp/$printjob print_user@$printernode:/opt/print_user/.printjobs/$printjob  > /dev/null 2>&1
		
		sshpass -p "linuxprinter" ssh $ssh_opt print_user@$printernode $SQL_add_row  > /dev/null 2>&1
		sshpass -p "linuxprinter" ssh $ssh_opt print_user@$printernode $print_command /opt/print_user/.printjobs/$printjob   > /dev/null 2>&1
    fi
  
  fi
    
else
  ${_zenity} --error \
         --text="ERROR: No hay archivos seleccionados."
fi

#Clean temporal folder
rm ~/.printjobs/tmp/*
#------------------------------------------------------------------------------------------------
