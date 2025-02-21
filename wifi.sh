#!/bin/bash

# Vérifier si l'utilisateur est root
if [ "$EUID" -ne 0 ]; then
    echo "Erreur : Ce script doit être exécuté en tant que root."
    exit 1
fi

# Fonction pour désactiver la mise en veille et la gestion de l'alimentation
desactiver_veille() {
    echo "Désactivation de la mise en veille et de la gestion de l'alimentation..."

    # Désactiver la mise en veille automatique via systemd
    systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

    # Désactiver l'écran de veille pour GNOME
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.session idle-delay 0
    fi

    # Désactiver l'écran de veille et la gestion de l'énergie pour XFCE ou d'autres environnements
    if command -v xset &> /dev/null; then
        xset s off
        xset -dpms
    fi

    echo "La mise en veille et la gestion de l'alimentation ont été désactivées."
}

# Téléchargement du pilote RTL88x2BU depuis GitHub
echo "Téléchargement du pilote RTL88x2BU depuis le dépôt GitHub..."
git clone https://github.com/RinCat/RTL88x2BU-Linux-Driver.git

# Accéder au répertoire du pilote téléchargé
cd RTL88x2BU-Linux-Driver || { echo "Erreur : le répertoire RTL88x2BU-Linux-Driver n'existe pas."; exit 1; }

# Installer les dépendances nécessaires
echo "Installation des dépendances..."
apt-get update
apt-get install -y linux-headers-$(uname -r)

# Compilation et installation du pilote en tant que root
echo "Compilation et installation du pilote avec les privilèges root..."
make
make install

# Charger le module du noyau
echo "Chargement du module du noyau 88x2bu..."
modprobe 88x2bu

# Désactiver la mise en veille et l'écran de veille
desactiver_veille

# Mettre à jour les dépôts
echo "Mise à jour des dépôts..."
sudo apt update

# Installer les prérequis
echo "Installation des prérequis..."
sudo apt install -y dkms git build-essential linux-headers-$(uname -r)

# Cloner le dépôt du pilote
echo "Clonage du dépôt rtl8188eu..."
git clone https://github.com/lwfinger/rtl8188eu.git
cd rtl8188eu

# Compiler et installer le module
echo "Compilation et installation du module..."
make
sudo make install

# Charger le module
echo "Chargement du module..."
sudo modprobe 8188eu

# Ajouter le module au démarrage
echo "Ajout du module au démarrage..."
echo "8188eu" | sudo tee -a /etc/modules

# Redémarrage du système
echo "Installation réussie. Redémarrage du système..."
reboot
