#!/bin/bash

#nohup /home/ec2-user/monitor/HAmonitor.sh > /home/ec2-user/monitor/log/HAmonitor`date '+%Y%m%d%H%M'`.log 2>&1 &

echo `date` "-- Starting HA Monitor"
#custom setting
dxTargetIP=172.31.84.36
period=2
failCount=5
vpnTargetIP=localhost
connectionStatus=0
# 0 is dx
# 1 is vpn

#modifty tgw route for switch
tgwRT=tgw-rtb-0d86bcd71877f6d88
idcPrId=pl-0d81338f99b4770b6
vpnAttId=tgw-attach-0f21402e36c7c65ed

# modify vpc route used by switchRouteTable function
dxRouteTableId=rtb-0b6f1f97bcadb7bfc
vpnRouteTableId=rtb-0ad5fb3618f81afe7

#internal setting
dxFail=0
vpnFail=0
dxFailCount=0
vpnFailCount=0
# ping time out 3 seconds
pingTimeout=2


# call with 1 parameter , target routeTableID
switchRouteTable(){
    subnetIds=(subnet-07a51e256179a88f2 subnet-07d0af3ce00946872)
    regionId=us-east-1
    echo "switch route table function"
    for((i=0;i<${#subnetIds[*]};i++))
    do
    echo ${subnetIds[$i]}
    RT_ASSOCIATE_ID=`aws ec2 describe-route-tables --region $regionId \
      --filters "Name=association.subnet-id,Values=${subnetIds[$i]}" \
      --query 'RouteTables[*].{RTBASSOID:Associations[0].RouteTableAssociationId}' \
      --output text`
    /usr/bin/aws ec2 replace-route-table-association --route-table-id $1 --association-id $RT_ASSOCIATE_ID --region $regionId
    done
}

switchTGWRouteTableToVPN(){
    echo "add vpn prefix preference in tgw route table "
aws ec2 create-transit-gateway-prefix-list-reference  \
--transit-gateway-route-table-id  $tgwRT \
--prefix-list-id  $idcPrId \
--transit-gateway-attachment-id $vpnAttId
}

switchTGWRouteTableToDx(){
    echo "delete vpn prefix preference in tgw route table"
aws ec2 delete-transit-gateway-prefix-list-reference  \
--transit-gateway-route-table-id $tgwRT \
--prefix-list-id=$idcPrId
}

echo "default we use dx when this script begin， this is reset to default"
connectionStatus=0
switchTGWRouteTableToDx

while :; do
#dx monitoring
if ping -c 1 -t $pingTimeout $dxTargetIP &> /dev/null
then
echo "dx test success"
dxFailCount=0
dxFail=0
else
echo "dx ping test fail "
dxFailCount=$[$dxFailCount+1]
fi

echo "dxFailCount=$dxFailCount"

#dx status set
if [ $dxFailCount -gt $failCount ]
then
echo  "dx status is  fail "
dxFailCount=$[$failCount+1]
dxFail=1
fi

#vpn monitoring
if ping -c 1 -t $pingTimeout $vpnTargetIP &> /dev/null
then
echo "vpn ping test success "
vpnFailCount=0
vpnFail=0
else
echo "vpn ping test fail "
vpnFailCount=$[$vpnFailCount+1]
fi

#vpn status
if [ $vpnFailCount -gt $failCount ]
then
echo "vpn status is fail "
vpnFailCount=$[$failCount+1]
vpnFail=1
fi

echo "vpnFailCount=$vpnFailCount"

echo "connectionStatus=$connectionStatus"

#switch according status
# $connectionStatus=0 so route is dx
if [ $connectionStatus -eq 0 ]
then
echo "vpnFail = $vpnFail, dxFail = $dxFail"
if [ $vpnFail -eq 0 ] && [ $dxFail -eq 1 ]
then
echo "trigger switch from dx to vpn a"
connectionStatus=1
switchTGWRouteTableToVPN
echo "trigger switch from dx to vpn b"
fi
# $connectionStatus=1 so route is vpn
elif [ $connectionStatus -eq 1 ]
then
if [ $dxFail -eq 0 ]
then
echo "trigger switch from vpn to dx a"
connectionStatus=0
switchTGWRouteTableToDx
echo "trigger switch from vpn to dx b"
fi
fi

#sleep for a interval
sleep $period
done


