#!/bin/bash

# Fonction pour désactiver la mise en veille et la gestion de l'alimentation
desactiver_veille() {
    echo "Désactivation de la mise en veille et de la gestion de l'alimentation..."

    # Désactiver la mise en veille automatique via systemd
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

    # Désactiver l'écran de veille
    gsettings set org.gnome.desktop.session idle-delay 0

    # Si XFCE ou d'autres environnements sont utilisés, désactiver l'écran de veille avec xset
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
cd RTL88x2BU-Linux-Driver || { echo "Erreur: le répertoire RTL88x2BU-Linux-Driver n'existe pas."; exit 1; }

# Installer les dépendances nécessaires
echo "Installation des dépendances..."
sudo apt-get update
sudo apt-get install -y linux-headers-$(uname -r)

# Compilation et installation du pilote en tant que root
echo "Compilation et installation du pilote avec les privilèges root..."

# Exécuter make en tant que root
sudo make

# Exécuter make install en tant que root
sudo make install

# Charger le module du noyau
echo "Chargement du module du noyau 88x2bu..."
sudo modprobe 88x2bu

# Désactiver la mise en veille et l'écran de veille
desactiver_veille

# Redémarrage du système
echo "Installation réussie. Redémarrage du système..."
sudo reboot
