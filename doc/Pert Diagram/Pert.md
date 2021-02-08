## PERT diagram

| Index | Activity Description      | Required Predecessor | Duration (Hours)  |
|:------|:--------------------------|:---------------------|:------------------|
|   A   |IP-Adressing table         |          /           |        20         |
|   B   |Setup GNS3                 |          A           |        32         |
|   C   |Deploy DNS Server          |          B           |        40         |
|   D   |Deploy domain controller   |          C           |        32         |
|   E   |Deploy emailserver         |          D           |        30         |
|   F   |Deploy webserver           |          D           |        22         |
|   G   |Deploy SCCM		            |          E, F        |        35         |
|   H   |Cisco Labs  		            |          /           |        32         |
|   I   |Full setup locally         |          G           |        15         |
|   j   |Documentation              |          I           |        18         |
|   K   |Full setup cloud           |          I           |        46         |
|   L   |Deploy monitoring system   |          I           |        22         |
|   M   |Deploy fileserver          |          I           |        26         |
|   N   |Deploy secondary DNS       |          I           |        42         |
|   O   |Containervirtualisatie     |          I           |        60         |


## Critical path

Start -> A -> B -> D -> E -> G -> I -> J -> end = 226 hours

## PERT Chart

![Chart](https://i.imgur.com/8oprudl.png)
