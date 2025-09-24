#!/bin/bash

# Diretório base para todos os perfis de tema
THEMES_DIR="$HOME/.config/TEMAS"

# Verifica se um nome de tema foi fornecido como argumento
if [ -z "$1" ]; then
    echo "Erro: Forneça o nome de um perfil de tema."
    echo "Exemplo de uso: $0 catppuccin"
    echo "Perfis disponíveis:"
    ls "$THEMES_DIR" | grep -v ".sh\|.css"
    exit 1
fi

THEME_NAME=$1
SELECTED_THEME_DIR="$THEMES_DIR/$THEME_NAME"

# Verifica se o diretório do perfil de tema existe
if [ ! -d "$SELECTED_THEME_DIR" ]; then
    echo "Erro: Perfil de tema '$THEME_NAME' não encontrado em $THEMES_DIR."
    exit 1
fi

# Carrega as configurações do perfil (GTK_THEME, ICON_THEME, etc.)
source "$SELECTED_THEME_DIR/theme.conf"

# --- APLICAÇÃO DOS TEMAS ---

# 1. PAPEL DE PAREDE
WALLPAPER_DIR="$SELECTED_THEME_DIR/wallpapers"
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    echo "Nenhum wallpaper encontrado em $WALLPAPER_DIR. Pulando."
else
    swww img "$WALLPAPER" --transition-type any --transition-fps 60
    wal -i "$WALLPAPER" -q -n 
fi

# 2. TEMAS GTK (Ícones, Cursor, etc.)
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
gsettings set org.gnome.desktop.wm.preferences theme "$GTK_THEME"

# 3. TERMINAL KITTY
if [ ! -z "$KITTY_THEME" ]; then
    kitty +kitten themes --reload-in=all "$KITTY_THEME"
fi

# 4. WAYBAR (LÓGICA CORRIGIDA)
if [ "$THEME_NAME" == "rose-pine" ]; then
    # Se o tema for rose-pine, copia o CSS estático dele.
    cp "$SELECTED_THEME_DIR/waybar-style.css" "$HOME/.config/waybar/style.css"
else
    # Para QUALQUER OUTRO tema, restaura o CSS a partir do nosso modelo pywal.
    cp "$THEMES_DIR/waybar-pywal-template.css" "$HOME/.config/waybar/style.css"
    # Cria o link para as cores do pywal que o modelo precisa
    ln -sf "$HOME/.cache/wal/colors-waybar.css" "$HOME/.config/waybar/colors-pywal.css"
fi

# Recarrega a Waybar para aplicar as novas cores/estilo
killall -SIGUSR2 waybar

# Salva o nome do tema ativado em um arquivo para que outros scripts saibam qual é o perfil atual
echo "$THEME_NAME" > "$THEMES_DIR/.current_theme"

echo "Perfil de tema '$THEME_NAME' aplicado com sucesso!"
