# Get the outputs from Terraform
$SQL_HOSTNAME = terraform output -raw sql_hostname
$SQL_PRIVATE_ENDPOINT = terraform output -raw sql_private_endpoint
$WEBAPP1_HOSTNAME = terraform output -raw webapp1_hostname
$WEBAPP1_IP = terraform output -raw webapp1_private_endpoint
$WEBAPP2_HOSTNAME = terraform output -raw webapp2_hostname
$WEBAPP2_IP = terraform output -raw webapp2_private_endpoint
$SEARCH_STRING = "Starting a new web site"
$FOUND_STRING = "succeeded"

# Output the commands
Write-Host "Run the following commands on the Azure VMs:"
Write-Host "-------------------------------------------"
# Write-Host "nslookup $SQL_HOSTNAME"
# Write-Host "nc -zv $SQL_HOSTNAME 1433"
# Write-Host "nc -zv $SQL_PRIVATE_ENDPOINT 1433"
# Write-Host "nslookup $WEBAPP1_HOSTNAME"
# Write-Host "echo -n '$WEBAPP1_HOSTNAME : ' "
# Write-Host "curl -s $WEBAPP1_HOSTNAME | grep -q '$SEARCH_STRING' && echo 'Success!' || echo 'Failed!' "
# Write-Host "echo -n '$WEBAPP1_IP : '"
# Write-Host "curl -s $WEBAPP1_IP | grep -q '$SEARCH_STRING' && echo 'Success!' || echo 'Failed!' "
# Write-Host "nslookup $WEBAPP2_HOSTNAME"
# Write-Host "curl -s $WEBAPP2_HOSTNAME | grep -q '$SEARCH_STRING' && echo 'Success!' || echo 'Failed!'"
# Write-Host "curl -s $WEBAPP2_IP | grep -q '$SEARCH_STRING' && echo 'Success!' || echo 'Failed!'"

# Write-Host "nslookup $SQL_HOSTNAME && echo '$SQL_HOSTNAME : ' && `
# (nc -zv $SQL_HOSTNAME 1433 && echo 'Success!' || echo 'Failed!') && `
# nc -zv $SQL_PRIVATE_ENDPOINT 1433 && echo '$WEBAPP1_HOSTNAME : ' && `
# (curl -s $WEBAPP1_HOSTNAME | grep -q '$SEARCH_STRING' && echo $WEBAPP1_HOSTNAME 'Success!' || echo $WEBAPP1_HOSTNAME 'Failed!') && `
# (curl -s $WEBAPP1_IP | grep -q '$SEARCH_STRING' && echo $WEBAPP1_IP 'Success!' || echo $WEBAPP1_IP 'Failed!') && `
# (curl -s $WEBAPP2_HOSTNAME | grep -q '$SEARCH_STRING' && echo $WEBAPP2_HOSTNAME 'Success!' || echo $WEBAPP2_HOSTNAME 'Failed!') && `
# (curl -s $WEBAPP2_IP | grep -q '$SEARCH_STRING' && echo $WEBAPP2_IP 'Success!' || echo $WEBAPP2_IP 'Failed!')"

# Write-Host "nslookup $SQL_HOSTNAME | findstr /v /c:'$NOT_FOUND_STRING' >nul && (echo 'nslookup $SQL_HOSTNAME : Success!') || (echo 'nslookup $SQL_HOSTNAME : Failed!') && `
# (nc -zv $SQL_HOSTNAME 1433 | grep -q '$FOUND_STRING' && echo $SQL_HOSTNAME ': Success!' || echo $SQL_HOSTNAME ': Failed!') && `
# (nc -zv $SQL_PRIVATE_ENDPOINT 1433 | grep -q '$FOUND_STRING' &&echo  $SQL_PRIVATE_ENDPOINT ': Success!' || echo $SQL_PRIVATE_ENDPOINT ': Failed!') && `
# (curl -s $WEBAPP1_HOSTNAME | grep -q '$SEARCH_STRING' && echo $WEBAPP1_HOSTNAME 'Success!' || echo $WEBAPP1_HOSTNAME ': Failed!') && `
# (curl -s $WEBAPP1_IP | grep -q '$SEARCH_STRING' && echo $WEBAPP1_IP ': Success!' || echo $WEBAPP1_IP ': Failed!') && `
# (curl -s $WEBAPP2_HOSTNAME | grep -q '$SEARCH_STRING' && echo $WEBAPP2_HOSTNAME ': Success!' || echo $WEBAPP2_HOSTNAME ': Failed!') && `
# (curl -s $WEBAPP2_IP | grep -q '$SEARCH_STRING' && echo $WEBAPP2_IP ': Success!' || echo $WEBAPP2_IP ': Failed!')"

# Write-Host "nslookup $SQL_HOSTNAME | findstr /v /c:'$NOT_FOUND_STRING' &> /dev/null && (echo 'nslookup $SQL_HOSTNAME : Success!') || (echo 'nslookup $SQL_HOSTNAME : Failed!') && `
# (nc -zv $SQL_HOSTNAME 1433 | grep -q '$FOUND_STRING' &> /dev/null && echo  $SQL_HOSTNAME 'nc: Success!' || echo $SQL_HOSTNAME 'nc: Failed!') && `
# (nc -zv $SQL_PRIVATE_ENDPOINT 1433 | grep -q '$FOUND_STRING' &> /dev/null  && echo  $SQL_PRIVATE_ENDPOINT 'nc: Success!' || echo $SQL_PRIVATE_ENDPOINT 'nc: Failed!') && `
# (curl -s $WEBAPP1_HOSTNAME | grep -q '$SEARCH_STRING' && echo $WEBAPP1_HOSTNAME 'curl: Success!' || echo $WEBAPP1_HOSTNAME 'curl: Failed!') && `
# (curl -s $WEBAPP1_IP | grep -q '$SEARCH_STRING' && echo $WEBAPP1_IP 'curl: Success!' || echo $WEBAPP1_IP ':curl Failed!') && `
# (curl -s $WEBAPP2_HOSTNAME | grep -q '$SEARCH_STRING' && echo $WEBAPP2_HOSTNAME 'curl: Success!' || echo $WEBAPP2_HOSTNAME 'curl: Failed!') && `
# (curl -s $WEBAPP2_IP | grep -q '$SEARCH_STRING' && echo $WEBAPP2_IP 'curl: Success!' || echo $WEBAPP2_IP 'curl: Failed!')"



Write-Host "echo '-------------------------------------------' &&`
(grep -q '$FOUND_STRING' <(nc -zv $SQL_HOSTNAME 1433 2>&1) && echo $SQL_HOSTNAME ': nc > Success!' || echo $SQL_HOSTNAME ':nc > Failed!') &&`
(grep -q '$FOUND_STRING' <(nc -zv $SQL_PRIVATE_ENDPOINT 1433 2>&1) && echo $SQL_PRIVATE_ENDPOINT ': nc > Success!' || echo $SQL_PRIVATE_ENDPOINT ': nc > Failed!') && `
(curl -s $WEBAPP1_HOSTNAME | grep -q '$SEARCH_STRING' && echo $WEBAPP1_HOSTNAME ': curl > Success!' || echo $WEBAPP1_HOSTNAME ': curl > Failed!') && `
(curl -s $WEBAPP1_IP | grep -q '$SEARCH_STRING' && echo $WEBAPP1_IP ': curl > Success!' || echo $WEBAPP1_IP ': curl > Failed!') && `
(curl -s $WEBAPP2_HOSTNAME | grep -q '$SEARCH_STRING' && echo $WEBAPP2_HOSTNAME ': curl > Success!' || echo $WEBAPP2_HOSTNAME ':curl > Failed!') && `
(curl -s $WEBAPP2_IP | grep -q '$SEARCH_STRING' && echo $WEBAPP2_IP ': curl > Success!' || echo $WEBAPP2_IP ': curl > Failed!')"



Write-Host "-------------------------------------------"