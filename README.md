# DxVPNMonitor

0、拷贝脚本到 /etc/home/ec2-user/下

1、chmod +777 monitor 目录下的脚本

2、执行CronTabde挂载 10 8 * * 0 /bin/bash /home/ec2-user/monitor/HAcron.sh > /home/ec2-user/monitor/log/HAcron`date '+\%Y\%m\%d\%H\%M'`.log 2>&1 &

配合执行逻辑
1 利用Linux的Crond服务，每周执行一次HAcron.sh，在这个脚本中会先把进程清理掉，启动HAwatch.sh

2 HAwatch会监控HAmonitor的执行，守护它，如果异常退出，立即拉起它

3 HAmonitor进行Ping检查，判断是否需要切换路由，进行具体的路由切换。

HAmonitor的逻辑

1、VPN和DX分别做两个点对点路由，需要预先选好云上云下两个IP地址，配置单条路由。

2、一旦Ping不通，则通过修改TGW的Preference路由，进行路由切换。因此需要优先吧Prefix IP地址事先设置好
