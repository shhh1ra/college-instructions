# Предисловие:
- Поясняю я весь этот процесс не очень активно, поэтому если теории не хватает, пишите в `веселье с alt server в телегу` и задавайте вопросы, отвечу там и сюда допишу на будущее.
****
# Инерлюдия про интерфейсы:
- Надо понимать какие интерфейсы настраивать, потому что можно застрять на том, что все настроено, но настроено не то/не так, и не понимать в чем проблема.
- Сага про интерфейсы будет расписана в отдельном файле:
****
# Глава 1: Настройка Интернета от "Провайдера"
### Кстати считаю нужным сказать, что вся работа выполняется от имени `root` и не иначе.
```bash
login: root
passwd: сами знаете
```
## Что у нас происходит на инете:
- В качестве основы возьмем виртуалку ISP(номер стенда)
- в основе картина такова, что есть 3 адаптера:

![picture](https://raw.githubusercontent.com/shhh1ra/damn/refs/heads/main/images/virtual-networks.jpg)
****
### Первые 2 будут работать в формате линков между сегментами, интересует изначально VM Network, который выполняет роль местного провайдера, что нужно чтобы поднять инет на виртуалке:
1. Определиться с именем интерфейса, потому что на виртуалках они нормально не подписываются. `общая тенденция - в каком порядке они стоят в свойствах виртуалки, также будут и в ней`, альт способ будет чуть позже.
2. После определения с именем интерфейса нужно зайти в каталог интерфейсов:
```bash
cd /etc/net/ifaces
```
- И создать папку интерфеса (в качестве примера ens38):
```bash
mkdir -p ens38 && cd ens38 && mcedit options
```
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
systemctl restart network
systemctl status network
```
Либо:
  service network restart (Больше в крайнем случае, зачастую systemd работает)
5. Проверка интернета:
ip a
Если на инте появился айпишник - авантюра удалась.
****
# Глава 2: Настройка межклиентской сети (Все еще на ISP):
- Переход в ifaces строго предполагается, поэтому лучше сразу перейти перед выполнением следующих команд
```bash
cd /etc/net/ifaces
```
- Создаем папки:
```bash
mkdir -p ens36 && mkdir -p ens37
```
- Настройка ens36 (Интернет с которого пойдет на HQ-RTR)
```bash
cd ens36 && mcedit options && mcedit ipv4address
```
- Настройка ens37 (Интернет с которого пойдет на BR-RTR)
```bash
cd ../ && cd ens37 && mcedit options && mcedit ipv4address
```
- Рестарт служб и проверка айпишников:
```bash
systemctl restart network && systemctl status network && ip -c a
```
- Файл options (общий для двух интов)
```bash
TYPE=eth
BOOTPROTO=static
ONBOOT=yes
CONFIG_IPV4=yes
```
- ipv4address (ens36 (Который пойдет на HQ-RTR)
```bash
172.16.4.1/28
```
- ipv4address (ens37 (Который пойдет на BR-RTR)
```bash
172.16.5.1/28
```
# Глава 3: Настройка NAT (Все еще ISP):
## Считаю нужным выделить эту настройку в отдельный раздел, потому что тут веселья еще больше.
- Включаем маршрутизацию:
```bash
/sbin/sysctl -w net.ipv4.ip_forward=1
```
- Сохраняем внесенное изменение:
```bash
mcedit /etc/sysctl.conf
```
- В открывшийся файл сразу после коментариев (Которые всегда начинаются с #) отступаем одну строку и дописываем:
```bash
net.ipv4.ip_forward=1
```
- Проверяем внесенные изменения:
```bash
/sbin/sysctl net.ipv4.ip_forward
```
- В ответе ожидается цифра 1, если нет, то еще раз в начало главы.
****
## Собтсвенно сам NAT:
### В Alt Server реализуется через iptables, правил будет много, писать надо внимательно:
- Настройка NAT наружу:
```bash
iptables -t nat -A POSTROUTING -s 172.16.4.0/28 -o ens38 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.5.0/28 -o ens38 -j MASQUERADE
```
- Если вдруг случился момент, что iptables вдруг не найдена, то в начало каждой команды добавляешь /sbin и все будет отлично, итоговый вид команды: `/sbin/iptables ...`
- **Примечание: NAT наружу предполагает настройку ретрансляции во внешнюю сеть (провайдера), в качестве внешнего инта у меня ens38, поэтому правила такие (К слову 2 команды вводятся по одной, начинаются с iptables.**
- Разрешаем NAT с локальных сетей на внешку:
```bash
iptables -A FORWARD -i ens36 -o ens38 -s 172.16.4.0/28 -j ACCEPT
iptables -A FORWARD -i ens37 -o ens38 -s 172.16.5.0/28 -j ACCEPT
```
- Разрешаем NAT во внутрь сетей:
```bash
iptables -A FORWARD -i ens38 -o ens36 -d 172.16.4.0/28 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i ens38 -o ens37 -d 172.16.5.0/28 -m state --state ESTABLISHED,RELATED -j ACCEPT
```
- Проверяем правила:
```bash
iptables -t nat -L -n -v
iptables -L FORWARD -n -v
```
- Ожидаемый вывод: строки MASQUERADE для двух подсетей.
- Сохранение iptables:
```bash
iptables-save >> /etc/sysconfig/iptables
```
- Включение автозагрузки правил:
```bash
systemctl enable iptables
systemctl restart iptables
systemctl status iptables
```
- Проверка, что правила сохранились:
```bash
cat /etc/sysconfig/iptables
```
- Ожидаемый вывод: много строк с правилами.
# Глава 4: настройка HQ-RTR
## Начнем с поднятия интернета, конкретно тут уже прикол начинается, первый инт внутренний, второй внешний, в рамках начала нам нужен сначала внешний для получения интернета.
- Настройка интерфейсов:
```bash
cd /etc/net/ifaces && mkdir ens37 && cd ens37
```
- Файлы конфигов:
```bash
touch options ipv4address ipv4route && mcedit options
```
- options:
```bash
TYPE=eth
BOOTPROTO=static
ONBOOT=yes
CONFIG_IPV4=yes
```
- ipv4address
```bash
172.16.4.2/28
```
- ipv4route
```bash
default via 172.16.4.1
```
- Рестарт служб
```bash
systemctl restart network && systemctl status network && ip -c a
```
- На этот момент интернет уже должен быть на виртуалке. Если произойдет так называемый сбой в разрешении имен:
```bash
mcedit /etc/resolv.conf
nameserver 8.8.8.8
```
****
### Настройка vlan-ов:
- Сначала создается trunk порт:
```bash
cd /etc/net/ifaces && mkdir ens36 && cd ens36 && mcedit options
```
- options файл:
```bash
TYPE=eth
BOOTPROTO=none
ONBOOT=yes
```
- Дальше создаются отдельные vlan инты:
```bash
cd /etc/net/ifaces && mkdir ens36.100 ens36.200 ens36.999
```
- Дальше заходим в каждую папку интерфейса и настраиваем options файл (Пример для ens36.100):
```bash
TYPE=vlan
HOST=ens36
VID=100
BOOTPROTO=static
ONBOOT=yes
```
- Файл ipv4address:
```bash
192.168.10.1/26
```
- ens36.200
- options:
```bash
TYPE=vlan
HOST=ens36
VID=200
BOOTPROTO=static
ONBOOT=yes
```
- ipv4address:
```bash
192.168.20.1/28
```
- ens36.999
- options:
```bash
TYPE=vlan
HOST=ens36
VID=999
BOOTPROTO=static
ONBOOT=yes
```
- ipv4address:
```bash
192.168.99.1/29
```
****
### Донастройка NAT
- Сначала включаем маршрутизацию
```bash
echo "net.ipv4_ip_forward=1"
```