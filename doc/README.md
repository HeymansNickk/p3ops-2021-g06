# Overzicht documentatie

## IP adrestabel
<br/>
<br/>

| VLAN    | Network Address     | Subnet Mask Decimal | Subnet Mask CIDR | Default Gateway |
| :-----: | :-----------------: | :-----------------: | :--------------: | :-------------: |
| VLAN 30 | 192.100.100.0        | 25                  | 255.255.255.128  | 192.100.100.1    |
| VLAN 40 | 192.100.100.128      | 26                  | 255.255.255.192  | 192.100.100.129  |
| VLAN 20 | 192.100.100.192      | 27                  | 255.255.255.224  | 192.100.100.193  |
| VLAN 50 | 192.100.100.224      | 30                  | 255.255.255.252  | -               |

<br/>
<br/>

| Device            | Name    | VLAN    | IP Address     | Subnet Mask Decimal | Subnet Mask CIDR |
| :---------------: | :-----: | :-----: | :------------: | :-----------------: | :--------------: |
| Domain Controller | alfa    | VLAN 20 | 192.100.100.194 | 27                  | 255.255.255.224  |
| Primary DNS       | bravo   | VLAN 20 | 192.100.100.195 | 27                  | 255.255.255.224  |
| Secondary DNS     | golf    | VLAN 20 | 192.100.100.196 | 27                  | 255.255.255.224  |
| Forwarding DNS    | india   | VLAN 20 | 192.100.100.197 | 27                  | 255.255.255.224  |
| Webserver         | charlie | VLAN 20 | 192.100.100.198 | 27                  | 255.255.255.224  |
| Email Server      | delta   | VLAN 20 | 192.100.100.199 | 27                  | 255.255.255.224  |
| SCCM Server       | echo    | VLAN 20 | 192.100.100.200 | 27                  | 255.255.255.224  |
| FTP Server        | foxtrot | VLAN 20 | 192.100.100.201 | 27                  | 255.255.255.224  |

<br/>
<br/>

## Inhoud documentatie

Voeg hier een tabel of inhoudstafel toe met links naar de juiste documenten. Maak een duidelijke directorystructuur met bv. een map per component/deelopdracht.

Wat verwachten we qua documentatie?

- Lastenboek per component/deelopdracht
    - Specificaties en requirements
    - Wat zijn de deeltaken? Dit worden tickets in Trello
    - Wie is verantwoordelijk voor realisatie en testen?
    - Hoe lang schat je voor elke deeltaak nodig te hebben?
- Technische documentatie
    - Achtergrondinfo, neerslag opzoekingswerk
    - Procedurebeschrijvingen
    - Functionele testplannen en -rapporten
    - Integratietestplannen en -rapporten
