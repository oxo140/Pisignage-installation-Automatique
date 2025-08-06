#!/bin/bash

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction d'affichage avec couleurs
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

# Vérifier si l'utilisateur est root
if [ "$EUID" -ne 0 ]; then
    print_error "Ce script doit être exécuté en tant que root."
    print_info "Utilisation: sudo $0"
    exit 1
fi

# Fonction pour désactiver la mise en veille et la gestion de l'alimentation
desactiver_veille() {
    print_info "Désactivation de la mise en veille et de la gestion de l'alimentation..."

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

    print_info "La mise en veille et la gestion de l'alimentation ont été désactivées."
}

# Fonction pour installer les dépendances communes
installer_dependances() {
    print_info "Mise à jour des dépôts et installation des dépendances..."
    apt-get update
    apt-get install -y git dkms build-essential linux-headers-$(uname -r)
}

# Fonction pour installer le pilote RTL88x2BU
installer_rtl88x2bu() {
    print_info "Installation du pilote RTL88x2BU..."
    
    # Nettoyer les éventuels répertoires existants
    [ -d "RTL88x2BU-Linux-Driver" ] && rm -rf RTL88x2BU-Linux-Driver
    
    # Téléchargement du pilote RTL88x2BU depuis GitHub
    print_info "Téléchargement du pilote RTL88x2BU..."
    git clone https://github.com/RinCat/RTL88x2BU-Linux-Driver.git

    # Accéder au répertoire du pilote téléchargé
    cd RTL88x2BU-Linux-Driver || { 
        print_error "Le répertoire RTL88x2BU-Linux-Driver n'existe pas."
        return 1
    }

    # Compilation et installation du pilote
    print_info "Compilation et installation du pilote RTL88x2BU..."
    make && make install

    # Charger le module du noyau
    print_info "Chargement du module 88x2bu..."
    modprobe 88x2bu

    # Ajouter le module au démarrage
    echo "88x2bu" >> /etc/modules
    
    cd ..
}

# Fonction pour installer le pilote RTL8188EU
installer_rtl8188eu() {
    print_info "Installation du pilote RTL8188EU..."
    
    # Nettoyer les éventuels répertoires existants
    [ -d "rtl8188eu" ] && rm -rf rtl8188eu
    
    # Cloner le dépôt du pilote
    print_info "Téléchargement du pilote RTL8188EU..."
    git clone https://github.com/lwfinger/rtl8188eu.git
    cd rtl8188eu || {
        print_error "Le répertoire rtl8188eu n'existe pas."
        return 1
    }

    # Compiler et installer le module
    print_info "Compilation et installation du pilote RTL8188EU..."
    make && make install

    # Charger le module
    print_info "Chargement du module 8188eu..."
    modprobe 8188eu

    # Ajouter le module au démarrage
    echo "8188eu" >> /etc/modules
    
    cd ..
}

# Fonction pour attendre l'appui sur une touche
attendre_touche() {
    echo
    print_warning "Installation terminée !"
    print_info "Le système doit redémarrer pour finaliser l'installation des pilotes."
    echo
    read -p "Appuyez sur Entrée pour redémarrer le système..." -r
}

# Script principal
main() {
    print_info "Début de l'installation des pilotes WiFi RTL..."
    
    # Créer un répertoire de travail temporaire
    WORK_DIR="/tmp/wifi-drivers-install"
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
    
    # Installation des dépendances
    installer_dependances
    
    # Désactiver la mise en veille
    desactiver_veille
    
    # Installation des pilotes
    installer_rtl88x2bu
    installer_rtl8188eu
    
    # Nettoyer les fichiers temporaires
    print_info "Nettoyage des fichiers temporaires..."
    cd /
    rm -rf "$WORK_DIR"
    
    # Attendre avant de redémarrer
    attendre_touche
    
    # Redémarrage du système
    print_info "Redémarrage du système..."
    reboot
}

# Exécution du script principal
main
