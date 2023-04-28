#!/bin/bash
#################################################################
# Script to Auto renew certs for given domain and upload to S3
#
# Vignesh Narasimhulu
#
#################################################################

#AWS cred for route53
export AWS_ACCESS_KEY_ID="youraccesskey"
export AWS_SECRET_ACCESS_KEY="yoursecretkey"

###########
#FUNCTIONS
###########
function clientcertV2()
{
        sudo cat /etc/letsencrypt/live/${CERTNAME}/fullchain.pem /etc/letsencrypt/live/${CERTNAME}/privkey.pem > /var/tmp/${CERTNAME}.pem

        echo "Let us upload the certs to AWS S3"

	#uncomment below 2 lines to reset AWS access, to use local-user's AWS profile
        #export AWS_ACCESS_KEY_ID=""
        #export AWS_SECRET_ACCESS_KEY=""
	${AWSBIN} s3 cp /var/tmp/${CERTNAME}.pem s3://${S3BUCKET}/certs/
}

function notify()
{
	from="noreply@example.com"
        subject="Letsencrypt Cert-renewal Automation for ${CERTNAME}"
	host=$(hostname)
        msg="Host - ${host}\nStatus - $1"
	to="devops@example.com"
	echo -e "Subject: ${subject}\nFrom: ${from}\n${msg}" | ${SENDMAIL} ${to} 
        return 0
}

#######
# MAIN
#######

#domain or sub-domain for which you want to renew certs
CERTNAME="subdomain.example.com"

AWSBIN=$(which aws)
S3BUCKET="yoursecuredomain.example.com"

#"/usr/sbin/sendmail"
SENDMAIL=$(which sendmail)

#renew certs
sudo certbot renew --cert-name ${CERTNAME}
if [ $? == 0 ] ; then
        #check if the cert was updated
        sudo find /etc/letsencrypt/live/${CERTNAME}/fullchain.pem -mtime -1 | grep fullchain.pem > /dev/null
        if [ $? == 0 ] ; then
                echo "Cert renewal successful. Let us update the certs..."

                #distribute 
                clientcertV2
                if [ $? == 0 ] ; then
                        echo "certs renewed and uploaded"
                fi

		notify "${CERTNAME}: Cert renewal successful"
	else
		notify "${CERTNAME}: Cert renewal script was triggered but renewal isn't due yet"
        fi
else
        echo "ERROR: ${CERTNAME}: Cert renewal unsuccessful. Notification will be sent."
        notify "ERROR: ${CERTNAME}: Cert renewal unsuccessful."
fi
