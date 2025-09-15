#!/bin/bash

# Define a ação: up (aumentar) ou down (diminuir)
action=$1

# Altera o brilho usando brightnessctl
if [ "$action" = "up" ]; then
    brightnessctl set +5%
elif [ "$action" = "down" ]; then
    brightnessctl set 5%-
fi

# Pega os valores atual e máximo de brilho
actual_brightness=$(brightnessctl get)
max_brightness=$(brightnessctl max)

# Calcula a porcentagem
brightness_percentage=$(( (actual_brightness * 100) / max_brightness ))

# Exibe a notificação usando dunstify
# O comando `dunstify` é a interface de linha de comando do Dunst
dunstify -h string:x-dunst-stack-tag:brightness_osd \
         "Brilho: ${brightness_percentage}%" \
         -h int:value:$brightness_percentage \
         -u low \
         -t 1500
