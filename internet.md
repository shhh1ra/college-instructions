# Глава 1: Настройка Интернета от "Провайдера"
## Что у нас происходит на инете:
- В качестве основы возьмем виртуалку ISP(номер стенда)
- в основе картина такова, что есть 3 адаптера:

![picture](https://raw.githubusercontent.com/shhh1ra/damn/refs/heads/main/images/virtual-networks.jpg)
****
### Первые 2 будут работать в формате линков между сегментами, интересует изначально VM Network, который выполняет роль местного провайдера, что нужно чтобы поднять инет на виртуалке:
1. Определиться с именем интерфейса, потому что на виртуалках они нормально не подписываются. `общая тенденция - в каком порядке они стоят в свойствах вирталки, также будут и в ней`, альт способ будет чуть позже.
2. После определения с именем интерфейса нужно зайти в каталог интерфейсов:
```bash
cd /etc/net/ifaces
```
- И создать папку интерфеса (в качестве примера ens38):
```bash
sudo mkdir -p ens38 && cd ens38 && sudo vi options
```
3. Через дранный vim (vi) надо внести конфиги в путь /etc/net/ifaces/ens38/options (В результате предыдущего пункта ты уже должен быть в нужном файле (options - файл))
- Откроется пустой файл, что делаем дальше: `нажимаем i`, на первый взгляд ниче не произойдет, на самом деле мы уже в режиме вставки текста будем. С вимом ошибаться в тексте ваще нельзя, переписывать толком не получится.
****
### Структура options файла:
```bash
TYPE=eth
BOOTPROTO=dhcp
ONBOOT=yes
CONFIG_IPV4=yes
```
Все символ в символ, без своих домыслов.
4. Рестартнуть интернет в виртуалке:
```bash
sudo systemctl restart network
sudo systemctl status network
```
Либо:
sudo service network restart (Больше в крайнем случае, зачастую systemd работает)
5. Проверка интернета:
ip a
Если на инте появился айпишник - авантюра удалась.
6. После появления айпишника:
```bash 
sudo apt-get update && sudo apt-get install nano
```
nano пригодится дальше, нам все еще 10 интов примерно поднимать также.
****
# Глава 2: Настройка межклиентской сети:
## Сразу с нулевой пишем заготовки на будущее:
- Переход в ifaces строго предполагается, поэтому лучше сразу перейти перед выполнением следующих команд
```bash
cd /etc/net/ifaces
```
- Ультимативная команда для настройки сразу всех интов на ISP(вставь свое число)
```bash
sudo mkdir -p ens36 && sudo mkdir -p ens37 && cd ens36 && sudo nano options && sudo nano ipv4address && cd ../ && cd ens37 && sudo nano options && sudo nano ipv4address && sudo systemctl restart network && sudo systemctl status network && ip a
```
- Файл options (общий для двух интов)
```bash
TYPE=eth
BOOTPROTO=static
ONBOOT=yes
CONFIG_IPV4=yes
```
- ipv4address (HQ-RTR)
```bash
172.16.4.1/28
```
- ipv4address (BR-RTR)
```bash
172.16.5.1/28
```

Примечание к п.2: ens3x - номер интерфейса будет скорее всего у всех разный, инты узнаются через команду ip a


[root@max ens37]# cd /etc/net/ifaces/ && mkdir -p ens36 && mkdir -p ens37 && mkdir -p ens38 && cd ens38 && vi options && sleep 2 && cat options && sleep 2 && systemctl restart network && systemctl status network && sleep 3 && apt-get update && apt-get install nano && cd ../ && cd ens36 && nano options && nano ipv4address && cd .. && cd ens37 && nano options && nano ipv4address && systemctl restart network && systemctl status network && sleep 3 && ip a && sleep 5 && /sbin/sysctl -w net.ipv4.ip_forward=1 && nano /etc/sysctl.conf && sysctl net.ipv4.ip_forward && sleep 4 && iptables -t nat -A POSTROUTING -s 172.16.4.0/28 -o ens38 -j MASQUERADE && iptables -t nat -A POSTROUTING -s 172.16.5.0/28 -o ens38 -j MASQUERADE && iptables -A FORWARD -i ens36 -o ens38 -s 172.16.4.0/28 -j ACCEPT && iptables -A FORWARD -i ens37 -o ens38 -s 172.16.5.0/28 -j ACCEPT && iptables -A FORWARD -i ens38 -o ens36 -d 172.16.4.0/28 -m state --state ESTABLISHED,RELATED -j ACCEPT && iptables -A FORWARD -i ens38 -o ens37 -d 172.16.5.0/28 -m state --state ESTABLISHED,RELATED -j ACCEPT && iptables -t nat -L -n -v && sleep 4 && service iptables save && systemctl enable iptables && sleep 5_