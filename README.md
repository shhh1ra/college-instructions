# Инвентаризация виртуальных машин  
**Платформа:** ALT Linux  
**Версия ОС:** ALT Server 10.4 (Mendelevium)

---

## Общие характеристики

- **Процессор:** Intel Xeon Gold 5218R  
- **Конфигурация CPU:** 2 сокета × 1 ядро  
- **Оперативная память:** 4 GiB  
- **Swap:** 4 GiB  
- **Диски:** один виртуальный диск (имя не указано)  
- **Сетевые интерфейсы:** в состоянии `DOWN`, IP-адреса отсутствуют  

---

## Разметка диска (общая для всех ВМ)

| Раздел | Размер | Точка монтирования |
|------|--------|--------------------|
| sda1 | 512 MB | /boot/efi |
| sda2 | 3.8 GiB | swap |
| sda3 | 30.7 GiB | / |

- **Использование `/`:** ~11%

---

## Таблица виртуальных машин

| ВМ | ОС | CPU | RAM | Swap | Разметка диска | Сетевые интерфейсы | IP |
|---|---|---|---|---|---|---|---|
| ISP4 | ALT Server 10.4 | 2×1 core | 4 GiB | 4 GiB | sda1 /boot/efi<br>sda2 swap<br>sda3 / | ens36 DOWN<br>ens37 DOWN<br>ens38 DOWN | нет |
| HQ-SRV4 | ALT Server 10.4 | 2×1 core | 4 GiB | 4 GiB | sda1 /boot/efi<br>sda2 swap<br>sda3 / | ens36 DOWN | нет |
| HQ-RTR4 | ALT Server 10.4 | 2×1 core | 4 GiB | 4 GiB | sda1 /boot/efi<br>sda2 swap<br>sda3 / | ens36 DOWN | нет |
| BR-SRV4 | ALT Server 10.4 | 2×1 core | 4 GiB | 4 GiB | sda1 /boot/efi<br>sda2 swap<br>sda3 / | ens36 DOWN | нет |
| BR-RTR4 | ALT Server 10.4 | 2×1 core | 4 GiB | 4 GiB | sda1 /boot/efi<br>sda2 swap<br>sda3 / | ens36 DOWN<br>ens37 DOWN | нет |

---

## Примечания

- Все сетевые интерфейсы находятся в состоянии `DOWN`
- IP-адреса не назначены
- Конфигурация виртуальных машин унифицирована, различия только в количестве сетевых адаптеров