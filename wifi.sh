#!/bin/bash

# Téléchargement du pilote RTL88x2BU depuis GitHub
echo "Téléchargement du pilote RTL88x2BU depuis le dépôt GitHub..."
git clone https://github.com/RinCat/RTL88x2BU-Linux-Driver.git

# Accéder au répertoire du pilote téléchargé
cd RTL88x2BU-Linux-Driver || { echo "Erreur: le répertoire RTL88x2BU-Linux-Driver n'existe pas."; exit 1; }

# Installer les dépendances nécessaires
echo "Installation des dépendances..."
sudo apt-get update
sudo apt-get install -y linux-headers-$(uname -r)

# Compilation et installation du pilote
echo "Compilation et installation du pilote..."
sudo make install

# Charger le module du noyau
echo "Chargement du module du noyau 88x2bu..."
sudo modprobe 88x2bu

# Redémarrage du système
echo "Installation réussie. Redémarrage du système..."
sudo reboot
