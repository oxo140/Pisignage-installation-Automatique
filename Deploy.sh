#!/bin/bash

# Fonction pour ajouter un utilisateur dans sudoers
ajouter_sudoers() {
    # Demander à l'utilisateur de saisir le nom d'utilisateur
    read -p "Entrez le nom d'utilisateur à ajouter au groupe sudo avec NOPASSWD: " username

    # Vérifier si l'utilisateur existe sur le système
    if id "$username" &>/dev/null; then
        echo "L'utilisateur $username existe, préparation pour l'ajout dans sudoers."

        # Sauvegarder le fichier sudoers avant de le modifier
        sudo cp /etc/sudoers /etc/sudoers.bak

        # Vérifier si la ligne existe déjà
        if sudo grep -q "^$username[[:space:]]*ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
            echo "La configuration pour l'utilisateur $username existe déjà dans le fichier sudoers."
        else
            # Ajouter la ligne au fichier sudoers avec une tabulation entre username et ALL
            echo -e "$username\tALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers > /dev/null

            # Vérifier la syntaxe du fichier sudoers
            sudo visudo -c
            if [ $? -eq 0 ]; then
                echo "La ligne a été ajoutée avec succès et le fichier sudoers est valide."
            else
                echo "Erreur : la syntaxe du fichier sudoers est incorrecte. Restauration de la sauvegarde."
                sudo cp /etc/sudoers.bak /etc/sudoers
                exit 1
            fi
        fi
    else
        echo "Erreur : l'utilisateur $username n'existe pas sur le système."
        exit 1
    fi
}

# Fonction pour exécuter les commandes de configuration
executer_commandes() {
    echo "Exécution des commandes avec sudo pour l'utilisateur $username..."

    sudo -u "$username" bash <<EOF
    # Mettre à jour les paquets et effectuer une mise à niveau complète
    sudo apt update
    sudo apt -y full-upgrade

    # Installer Chromium et créer un lien symbolique
    sudo apt-get -y install chromium
    cd /usr/bin
    sudo ln -s chromium chromium-browser

    # Installer OpenSSH server et npm
    sudo apt install -y openssh-server npm

    # Installer les certificats, curl, et gnupg pour Node.js
    sudo apt install -y ca-certificates curl gnupg

    # Créer le dossier pour les clés GPG
    sudo mkdir -p /etc/apt/keyrings

    # Télécharger et installer la clé GPG de NodeSource
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

    # Définir la version de Node.js (20 dans ce cas)
    NODE_MAJOR=20

    # Ajouter le dépôt de NodeSource pour Node.js
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_\$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

    # Mettre à jour les paquets après l'ajout du dépôt de NodeSource
    sudo apt update

    # Installer Node.js
    sudo apt install -y nodejs

    # Installer dhcpcd5 et rfkill
    sudo apt install -y dhcpcd5
    sudo apt install -y rfkill

    # Débloquer le Wi-Fi
    sudo rfkill unblock wlan

    # Créer un lien symbolique pour wpa_supplicant
    sudo ln -s /usr/share/dhcpcd/hooks/10-wpa_supplicant /usr/lib/dhcpcd/dhcpcd-hooks/

    # Redémarrer le service dhcpcd
    sudo systemctl restart dhcpcd

    # Fin
    echo "Toutes les commandes ont été exécutées avec succès pour l'utilisateur $username."
EOF
}

# Appel des fonctions
ajouter_sudoers
executer_commandes
