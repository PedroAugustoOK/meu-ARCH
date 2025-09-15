#!/bin/bash

# Define a ação: up, down ou mute
action=$1

# Altera o volume usando pactl
case $action in
  up)
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    ;;
  down)
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    ;;
  mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    ;;
esac

# Obtém o volume atual e a situação de mute
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -n 1 | tr -d '%')
mute=$(pactl get-sink-mute @DEFAULT_SINK@ | cut -d' ' -f2)

# Se o volume for maior que 100, define para 100
if [ "$volume" -gt 100 ]; then
  pactl set-sink-volume @DEFAULT_SINK@ 100%
  volume=100
fi

# Se o volume estiver mudo, mostra um ícone de mudo
if [ "$mute" = "yes" ]; then
  icon=""  # Ícone de mudo
  dunstify -h string:x-dunst-stack-tag:volume_osd \
           "Volume: Mudo" \
           -h int:value:0 \
           -u low \
           -t 1500
else
  # Se o volume não estiver mudo, mostra o ícone de volume e a porcentagem
  icon="墳"  # Ícone de volume
  dunstify -h string:x-dunst-stack-tag:volume_osd \
           "Volume: ${volume}%" \
           -h int:value:$volume \
           -u low \
           -t 1500
fi
