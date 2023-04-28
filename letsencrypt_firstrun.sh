#AWS creds
export AWS_ACCESS_KEY_ID="dummyaccess"
export AWS_SECRET_ACCESS_KEY="dummysecret"

#certbot: first-run to get the certs for the given domains
certbot certonly -n --dns-route53 -d *.yourdomain.com -d *.api.yourdomain.com -d *.web.yourdomain.com --expand --agree-tos --email john.doe@yourdomain.com
