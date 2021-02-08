# Het starten van een vagrant box met ansible

Ansible is niet beschikbaar op Windows dus voor je het "Vagrant up" commando, om de linux server aan te maken, moet het "dependencies.sh" script uitgevoerd worden.

In dezelfde directory als de vagrantfile doe je eerst dit commando:

```
$ ./scripts/dependencies.sh
```
Dit commando installeerd alle nodige ansible rollen en dependencies.
