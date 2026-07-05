function fastfetch_random
    set LOGO_DIR "$HOME/.config/fish/fastfetch/logos"
    command touch $LOGO_DIR"/used_logos.txt"
    set USED_FILE "$HOME/.config/fish/fastfetch/used_logos.txt"
    set CONFIG_FILE "$HOME/.config/fish/fastfetch/presets/hyde.jsonc"

    # Check if the logo directory exists
    if not test -d "$LOGO_DIR"
        echo "Logos directory does not exist: $LOGO_DIR"
        return 1
    end

    # Get a list of all logos
    set all_logos (command ls -1 "$LOGO_DIR")

    if test (count $all_logos) -eq 0
        echo "No logos found in folder: $LOGO_DIR"
        return 1
    end

    # Load previously used logos
    set used_logos
    if test -f "$USED_FILE"
        set used_logos (cat "$USED_FILE")
    end

    # Identify unused logos
    set unused_logos
    for logo in $all_logos
        if not contains $logo $used_logos
            set -a unused_logos $logo
        end
    end

    # If all logos have been used, reset the list
    if test (count $unused_logos) -eq 0
        set unused_logos $all_logos
        echo -n "" > "$USED_FILE"
    end

    # Pick a random logo from the unused list
    set LOGO (random choice $unused_logos)

    # Save the selected logo to the used file
    echo "$LOGO" >> "$USED_FILE"

    # Execute fastfetch using your custom config and formatting rules
    fastfetch -c "$CONFIG_FILE" \
        --logo "$LOGO_DIR/$LOGO" \
        --logo-type "kitty" \
        --logo-height 12 \
        --logo-padding-top 6 \
        --logo-padding-right 8 \
        --logo-padding-left 8
end
