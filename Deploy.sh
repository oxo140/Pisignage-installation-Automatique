#!/bin/bash

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
    fi
  fi

else
  echo "Erreur : l'utilisateur $username n'existe pas sur le système."
fi
