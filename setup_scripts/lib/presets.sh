#!/bin/bash

save_preset() {
    local name=$1
    [ -z "$name" ] && return 1
    
    mkdir -p "$PRESET_DIR"
    local output_file="$PRESET_DIR/${name}.json"
    
    # Overwrite protection
    if [ -f "$output_file" ]; then
        if ! whiptail --title "$STR_MENU_SAVE_PRESET" --yesno "$STR_OVERWRITE_CONFIRM" \
            --ok-button "$STR_ACCEPT" --cancel-button "$STR_CANCEL" 10 60; then
            return 1
        fi
    fi

    local selected_ids=()
    for id in "${!SELECTED_STATE[@]}"; do
        if [[ "${SELECTED_STATE[$id]}" == "ON" ]]; then
            selected_ids+=("$id")
        fi
    done
    
    if [ ${#selected_ids[@]} -eq 0 ]; then
        log_warn "$STR_ERR_NO_APPS_SELECTED"
    fi

    # Generate JSON with versioning and metadata
    jq -n --arg ver "$PRESET_VERSION" \
          --arg date "$(date -Iseconds)" \
          '$ARGS.positional | {version: $ver, created_at: $date, selected_apps: .}' \
          --args "${selected_ids[@]}" > "$output_file"
    
    log_to_file "$SUMMARY_LOG" "$(printf "$STR_LOG_PRESET_SAVED" "$output_file" "$PRESET_VERSION")"
    whiptail --title "$STR_MENU_SAVE_PRESET" --msgbox "$STR_PRESET_SAVED $output_file" --ok-button "$STR_ACCEPT" 10 60
}

load_preset() {
    local file=$1
    if [ ! -f "$file" ]; then
        log_error "$(printf "$STR_ERR_PRESET_NOT_FOUND" "$file")"
        return 1
    fi
    
    # Version and Compatibility Check
    local p_ver=$(jq -r '.version // "legacy"' "$file")
    if [ "$p_ver" != "$PRESET_VERSION" ]; then
        log_warn "$(printf "$STR_WARN_PRESET_VERSION" "$p_ver" "$PRESET_VERSION")"
        # We continue but warn the user if we find issues
    fi

    # Check for missing apps in current system
    local missing_apps=()
    while read -r aid; do
        [ -z "$aid" ] || [ "$aid" == "null" ] && continue
        # Verify if the app exists in our MASTER_JSON
        if ! jq -e ".categories[].apps[]? | select(.id==\"$aid\")" "$MASTER_JSON_FILE" >/dev/null; then
            missing_apps+=("$aid")
        fi
    done < <(jq -r '.selected_apps[]?' "$file" 2>/dev/null)

    if [ ${#missing_apps[@]} -gt 0 ]; then
        local msg="$STR_INCOMPATIBLE_PRESET\n\n$STR_APPS_NOT_FOUND\n${missing_apps[*]}"
        whiptail --title "$STR_MENU_LOAD_PRESET" --msgbox "$msg" --ok-button "$STR_ACCEPT" 15 60
    fi

    # Reset current selection and counts
    for id in "${!SELECTED_STATE[@]}"; do
        SELECTED_STATE["$id"]="OFF"
    done
    for cid in "${!CAT_COUNTS[@]}"; do
        CAT_COUNTS["$cid"]=0
    done
    
    # Read IDs and mark as ON (only if they exist)
    local count=0
    while read -r id; do
        [ -z "$id" ] || [ "$id" == "null" ] && continue
        # Only mark if it exists in current config
        if jq -e ".categories[].apps[]? | select(.id==\"$id\")" "$MASTER_JSON_FILE" >/dev/null; then
            SELECTED_STATE["$id"]="ON"
            local cid=$(get_app_category_id "$id")
            if [ -n "$cid" ] && [ "$cid" != "null" ]; then
                ((CAT_COUNTS["$cid"]++))
            fi
            ((count++))
        fi
    done < <(jq -r '.selected_apps[]?' "$file" 2>/dev/null)

    log_success "$(printf "$STR_LOG_PRESET_LOADED" "$file" "$count")"
    log_to_file "$SUMMARY_LOG" "$(printf "$STR_LOG_PRESET_LOADED" "$file" "$count") (version $p_ver)"
    return 0
}

choose_preset_ui() {
    mkdir -p "$PRESET_DIR"
    local files=("$PRESET_DIR"/*.json)
    
    if [ ! -e "${files[0]}" ]; then
        whiptail --title "$STR_MENU_LOAD_PRESET" --msgbox "$(printf "$STR_ERR_NO_PRESETS" "$PRESET_DIR")" --ok-button "$STR_ACCEPT" 10 60
        return 1
    fi
    
    local args=()
    for f in "${files[@]}"; do
        args+=("$(basename "$f")" "")
    done
    
    local p_desc="  $STR_SELECT_PRESET\n  ──────────────────────────────"
    local choice=$(whiptail --title "$STR_MENU_LOAD_PRESET" --menu "$p_desc" \
        --ok-button "$STR_OK" --cancel-button "$STR_CANCEL" \
        $HEIGHT $WIDTH $LIST_HEIGHT "${args[@]}" 3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        load_preset "$PRESET_DIR/$choice"
    fi
}
