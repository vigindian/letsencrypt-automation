# letsencrypt automation

## Pre-requisites
- We assume that the domain is hosted in AWS Route53
- Any Linux OS to run this automation
- Install certbot
- AWS access to route53 from the Linux machine that runs this automation. The renew-cert automation uses S3, so corresponding AWS permissions needed.

## Create certs
[letsencrypt_firstrun](./letsencrypt_firstrun.sh)

Example:
```
certbot certonly -n --dns-route53 -d *.yourdomain.com -d *.api.yourdomain.com -d *.web.yourdomain.com --expand --agree-tos --email john.doe@yourdomain.com
```

## Renew certs
[letsencrypt_cert_renew](./letsencrypt_cert_renew.sh): Auto-renew certs using certbot.

### Script Overview
- renew certs
- upload to s3 bucket configured in the script
- send email notification with cert renew status

### Automated Scheduling
Letsencrypt certs are usually valid for 90 days and can be renewed 30 days before expiry. So if we schedule it at least once a month, we can be sure that the certs will be renewed before its expiry.

- Use Linux cron to run this once a week or once a month.

Thanks.
