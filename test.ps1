# Get the outputs from Terraform
$SQL_HOSTNAME = terraform output -raw sql_hostname
$SQL_PRIVATE_ENDPOINT = terraform output -raw sql_private_endpoint
$WEBAPP1_HOSTNAME = terraform output -raw webapp1_hostname
$WEBAPP1_IP = terraform output -raw webapp1_private_endpoint
$WEBAPP2_HOSTNAME = terraform output -raw webapp2_hostname
$WEBAPP2_IP = terraform output -raw webapp2_private_endpoint

# Set search strings and timeout
$WEB_STRING = "Your web app is running"
$SQL_STRING = "succeeded"
$TIMEOUT = "15"

# Output to console

Write-Host "Run the following on the Azure VMs:"
Write-Host "-------------------------------------------"

# Bash Commands
Write-Host "printf '\n\n' &&`
(grep -q '$SQL_STRING' <(nc -w $TIMEOUT -zv $SQL_HOSTNAME 1433 2>&1) && echo $SQL_HOSTNAME' Success!' || echo $SQL_HOSTNAME' Failed!') &&`
(grep -q '$SQL_STRING' <(nc -w $TIMEOUT  -zv $SQL_PRIVATE_ENDPOINT 1433 2>&1) && echo $SQL_PRIVATE_ENDPOINT' Success!' || echo $SQL_PRIVATE_ENDPOINT' Failed!') && `
(curl --connect-timeout $TIMEOUT -s $WEBAPP1_HOSTNAME | grep  '$WEB_STRING' > /dev/null && echo $WEBAPP1_HOSTNAME' Success!' || echo $WEBAPP1_HOSTNAME' Failed!') && `
((curl --connect-timeout $TIMEOUT -s https://$WEBAPP1_HOSTNAME | grep '$WEB_STRING' > /dev/null) && echo 'https://$WEBAPP1_HOSTNAME Success!' || echo 'https://$WEBAPP1_HOSTNAME Failed!') && `
(curl --connect-timeout $TIMEOUT -s $WEBAPP1_IP | grep '$WEB_STRING' > /dev/null && echo $WEBAPP1_IP' Success!' || echo $WEBAPP1_IP' Failed!') && `
(curl --connect-timeout $TIMEOUT -s $WEBAPP2_HOSTNAME | grep '$WEB_STRING'> /dev/null && echo $WEBAPP2_HOSTNAME' Success!' || echo $WEBAPP2_HOSTNAME' Failed!') && `
((curl --connect-timeout $TIMEOUT -s https://$WEBAPP2_HOSTNAME | grep '$WEB_STRING' > /dev/null) && echo 'https://$WEBAPP2_HOSTNAME Success!' || echo 'https://$WEBAPP2_HOSTNAME Failed!') && `
(curl --connect-timeout $TIMEOUT -s $WEBAPP2_IP | grep '$WEB_STRING' > /dev/null && echo $WEBAPP2_IP' Success!' || echo $WEBAPP2_IP' Failed!')"

Write-Host "-------------------------------------------"

# Output to test.sh

"#! /bin/bash`
`
`
printf '\n\n' &&`
(grep -q '$SQL_STRING' <(nc -w $TIMEOUT -zv $SQL_HOSTNAME 1433 2>&1) && echo $SQL_HOSTNAME' Success!' || echo $SQL_HOSTNAME' Failed!') &&`
(grep -q '$SQL_STRING' <(nc -w $TIMEOUT  -zv $SQL_PRIVATE_ENDPOINT 1433 2>&1) && echo $SQL_PRIVATE_ENDPOINT' Success!' || echo $SQL_PRIVATE_ENDPOINT' Failed!') && `
(curl --connect-timeout $TIMEOUT -s $WEBAPP1_HOSTNAME | grep -q '$WEB_STRING' && echo $WEBAPP1_HOSTNAME' Success!' || echo $WEBAPP1_HOSTNAME' Failed!') && `
((curl --connect-timeout $TIMEOUT -s https://$WEBAPP1_HOSTNAME | grep '$WEB_STRING' > /dev/null) && echo 'https://$WEBAPP1_HOSTNAME Success!' || echo 'https://$WEBAPP1_HOSTNAME Failed!') && `
(curl --connect-timeout $TIMEOUT -s $WEBAPP1_IP | grep -q '$WEB_STRING' && echo $WEBAPP1_IP' Success!' || echo $WEBAPP1_IP' Failed!') && `
(curl --connect-timeout $TIMEOUT -s $WEBAPP2_HOSTNAME | grep -q '$WEB_STRING' && echo $WEBAPP2_HOSTNAME' Success!' || echo $WEBAPP2_HOSTNAME' Failed!') && `
((curl --connect-timeout $TIMEOUT -s https://$WEBAPP2_HOSTNAME | grep '$WEB_STRING' > /dev/null) && echo 'https://$WEBAPP2_HOSTNAME Success!' || echo 'https://$WEBAPP2_HOSTNAME Failed!') && `
(curl --connect-timeout $TIMEOUT -s $WEBAPP2_IP | grep -q '$WEB_STRING' && echo $WEBAPP2_IP' Success!' || echo $WEBAPP2_IP' Failed!')" | Out-File -FilePath test.sh