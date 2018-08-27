#/bin/sh
# server | auth_accessfabric_audience | proxy_pass
# LIST='
# server1 | auth_accessfabric_audience1 | proxy_pass1
# server2 | auth_accessfabric_audience2 | proxy_pass2
# server3 | auth_accessfabric_audience3 | proxy_pass4
# '

ACF0="server1, server2 | auth_accessfabric_audience1 | proxy_pass1"
ACF1="server1 | auth_accessfabric_audience1 | proxy_pass1"
ACF2="server1 | auth_accessfabric_audience1 | proxy_pass1"

for index in $(seq 0 100)
do
    eval "item=\$ACF${index}"
    if [ -z "${item}" ]; then continue; fi
    item=$( echo "${item}" | sed 's/ //g; s/|/ /g' )
    echo $item
done