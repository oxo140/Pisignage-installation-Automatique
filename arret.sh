#!/bin/bash

# Demande à l'utilisateur l'heure d'arrêt
read -p "À quelle heure souhaitez-vous éteindre le PC quotidiennement ? (HH:MM) : " heure

# Vérifie si l'entrée est correcte
if [[ ! $heure =~ ^([01]?[0-9]|2[0-3]):([0-5][0-9])$ ]]; then
    echo "Format invalide. Veuillez entrer l'heure au format HH:MM."
    exit 1
fi

# Extraction des heures et minutes
hh=$(echo $heure | cut -d":" -f1)
mm=$(echo $heure | cut -d":" -f2)

# Ajout de la tâche au crontab
(crontab -l 2>/dev/null; echo "$mm $hh * * * /sbin/shutdown -h now") | crontab -

echo "L'arrêt quotidien du PC est programmé à $heure."
