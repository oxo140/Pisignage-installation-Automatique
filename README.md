<div align="center">

# Pisignage-installation-Automatique

</div>

🧰 Simplifiez l'installation du Software Pisignage sur Debian 11.8

🏗️ Fonction principale : Installation automatique du software Pisignage.

🛠️ Executer les commandes ci-dessous en tant que superutilisateur 
```
sudo apt install curl
curl -O https://raw.githubusercontent.com/oxo140/Pisignage-installation-Automatique/main/Deploy.sh
chmod +x Deploy.sh
sudo ./Deploy.sh
```

🖥️ Accédez à http://localhost:8000

🖥️ Parametrer l'ip de serveur Pisignage.

🛠️ Installation du drivers wifi clé usb 
```
curl -O https://raw.githubusercontent.com/oxo140/Pisignage-installation-Automatique/main/wifi.sh
chmod +x wifi.sh
sudo ./wifi.sh
```

🛠️ Installation de l'arret automatique dans le CRONTAB 
```
curl -O https://raw.githubusercontent.com/oxo140/Pisignage-installation-Automatique/main/arret.sh
chmod +x arret.sh
sudo ./arret.sh
```
<div align="center">


</div>
