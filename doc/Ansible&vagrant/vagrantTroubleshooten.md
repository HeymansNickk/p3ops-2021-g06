# Problemen met Vagrant
1. Probleem met shared folders die niet mounten → opgelost door alle spaces uit de filestructuur te halen.

2. Probleem met de versies van de Guest Additions op de host machine die niet overeenkwamen met de versies op de Vagrant boxen.
  - Proberen de "vagrant-vbguest" plugin te installeren -> Geen oplossing
  ```
  vagrant plugin install vagrant-vbguest
  ````
  - Proberen van dezelfde versie te installeren al op de box -> Geen oplossing
  ```
 vagrant plugin install vagrant-vbguest --plugin-version 6.1.0
 ````
 
## Gevonden oplossing
 ~~- 2 lijntjes code toevoegen aan het begin van de VagrantFile~~
```
config.vbguest.auto_update = false //Zorgt ervoor dat het opzetten van de box niet vastloopt als de versies niet overeenstemmen
config.vbguest.no_remote = true //Zorgt eroor dat de GuestAdditions ISO niet van een webserver kan worden gehaald
````
> Bron: https://github.com/dotless-de/vagrant-vbguest 

- Gebruik de laatste versie van de box en verwijder de vbguest plugin (deze is niet stabiel zonder de 2 extra lijntjes code uit de vorige oplossing).
