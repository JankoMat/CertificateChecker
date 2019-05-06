#!/bin/bash

#collect info
echo "Domain name for the certificate check:"
read domain
echo

#collect info on the certificate
cert_start=$(echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -text | grep "Not Before" | awk ' { print $3 " " $4 " " $6} ')

cert_end=$(echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -text | grep "Not After" | awk ' { print $4 " " $5 " " $7} ')

#curl google for current date
today=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep "< date" | awk ' { print $5 " " $4 " " $6 } ')

#turn dates from previous commands into arrays
num_year=()
num_month=()
num_day=()
j=0
tmp=0
for i in "$cert_start" "$cert_end" "$today"
do
        ((j++))
        case $i in
                *Jan*) month=01 ;;
                *Feb*) month=02 ;;
                *Mar*) month=03 ;;
                *Apr*) month=04 ;;
                *May*) month=05 ;;
                *Jun*) month=06 ;;
                *Jul*) month=07 ;;
                *Aug*) month=08 ;;
                *Sep*) month=09 ;;
                *Oct*) month=10 ;;
                *Nov*) month=11 ;;
                *Dec*) month=12 ;;
                *) echo "ahoy there skipper, Julian calendar only"
        esac
        day=$(echo $i | awk ' { print $2 } ')
        year=$(echo $i | awk ' { print $3 } ' )
        num_year[$j]=$year
        num_month[$j]=$month
        num_day[$j]=$day
done

#check that the certificate is valid and was issued with the correct date
if [ ${num_year[2]} \< ${num_year[3]} ]
then
        echo "Certificate has expired"
        exit 1
else
    if [ ${num_year[2]} == ${num_year[3]} ] && [ ${num_month[2]} \< ${num_month[3]} ]
    then
        echo "Certificate has expired"
        exit 1
    else
        if [ ${num_year[2]} == ${num_year[3]} ] && [ ${num_month[2]} == ${num_month[3]} ] && [ ${num_day[2]} \< ${num_day[3]} ]
        then
            echo "Certificate has expired"
            exit 1
        else
            if [ ${num_year[1]} \> ${num_year[3]} ]
            then
                echo "Certificate is from the future"
                exit 1
            else
                if [ ${num_year[1]} == ${num_year[3]} ] && [ ${num_month[1]} \> ${num_month[3]} ]
                then
                    echo "Certificate is from the future"
                    exit 1
                else
                    if [ ${num_year[1]} == ${num_year[3]} ] && [ ${num_month[1]} == ${num_month[3]} ] && [ ${num_day[1]} \> ${num_day[3]} ]
                    then
                        echo "Certificate is from the future"
                        exit 1
                    else
#If the certificate is valid get dates ready for the calculation of remaining days
                        if [ ${num_day[3]} -gt ${num_day[2]} ]
                        then
                            if [ ${num_month[2]} == 2 ]
                            then
                                num_day[2]=$(( ${num_day[2]} + 28 ))
                                num_month[2]=$(( ${num_month[2]} - 1 ))
                            elif [ ${num_month[2]} != 1 ] && [ ${num_month[2]} != 3 ] && [ ${num_month[2]} != 5 ] && [ ${num_month[2]} != 7 ] && [ ${num_month[2]} != 8 ] && [ ${num_month[2]} != 10 ] && [ ${num_month[2]} != 12 ]
                            then
                                num_day[2]=$(( ${num_day[2]} + 30 ))
                                num_month[2]=$(( ${num_month[2]} - 1 ))
                            else
                                num_day[2]=$(( ${num_day[2]} + 31 ))
                                num_month[2]=$(( ${num_month[2]} - 1 ))
                            fi
                        fi
                        if [ ${num_month[2]} \< ${num_month[3]} ]
                        then
                                num_month[2]=$(( ${num_month[2]} + 12 ))
                                num_year[2]=$(( ${num_year[2]} - 1 ))
                        fi
#Calculate the amount of days, months and years until certificate expires
                        till_cert_years=$(( ${num_year[2]} - ${num_year[3]} ))
                        till_cert_months=$(( ${num_month[2]} - ${num_month[3]} ))
                        till_cert_days=$(( ${num_day[2]} - ${num_day[3]} ))
##Repeat previous block for days since certificate was issued
                        if [ ${num_day[1]} -gt ${num_day[3]} ]
                        then
                            if [ ${num_month[3]} == 2 ]
                            then
                                num_day[3]=$(( ${num_day[3]} + 28 ))
                                num_month[3]=$(( ${num_month[3]} - 1 ))
                            elif [ ${num_month[3]} != 1 ] && [ ${num_month[3]} != 3 ] && [ ${num_month[3]} != 5 ] && [ ${num_month[3]} != 7 ] && [ ${num_month[3]} != 8 ] && [ ${num_month[3]} != 10 ] && [ ${num_month[3]} != 12 ]
                            then
                                num_day[3]=$(( ${num_day[3]} + 30 ))
                                num_month[3]=$(( ${num_month[3]} - 1 ))
                            else
                                num_day[3]=$(( ${num_day[3]} + 31 ))
                                num_month[3]=$(( ${num_month[3]} - 1 ))
                            fi
                        fi
                        if [ ${num_month[3]} \< ${num_month[1]} ]
                        then
                                num_month[3]=$(( ${num_month[3]} + 12 ))
                                num_year[3]=$(( ${num_year[3]} - 1 ))
                        fi
                        since_cert_years=$(( ${num_year[3]} - ${num_year[1]} ))
                        since_cert_months=$(( ${num_month[3]} - ${num_month[1]} ))
                        since_cert_days=$(( ${num_day[3]} - ${num_day[1]} ))
                    fi
                fi
            fi
        fi
    fi
fi

#Ispis podataka koje smo pronašli
echo "Since the certificate was issued it's been: $since_cert_years years, $since_cert_months months and $since_cert_days days"
echo
echo "Certificate will expire in: $till_cert_years years, $till_cert_months months and $till_cert_days days"
