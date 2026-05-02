#!/bin/bash

save_preset() {
    local name=$1
    [ -z "$name" ] && return 1
    
    mkdir -p "$PRESET_DIR"
    local output_file="$PRESET_DIR/${name}.json"
    
    local selected_ids=()
    for id in "${!SELECTED_STATE[@]}"; do
        if [[ "${SELECTED_STATE[$id]}" == "ON" ]]; then
            selected_ids+=("$id")
        fi
    done
    
    if [ ${#selected_ids[@]} -eq 0 ]; then
        # No apps selected, but we still save an empty preset? 
        # Better to warn the user.
        log_warn "No apps selected. Saving empty preset."
    fi

    # Generate JSON safely using jq
    jq -n '$ARGS.positional | {selected_apps: .}' --args "${selected_ids[@]}" > "$output_file"
    
    log_to_file "$SUMMARY_LOG" "Preset saved: $output_file"
    whiptail --title "$STR_MENU_SAVE_PRESET" --msgbox "$STR_PRESET_SAVED $output_file" 10 60
}

load_preset() {
    local file=$1
    if [ ! -f "$file" ]; then
        log_error "Preset file not found: $file"
        log_to_file "$SUMMARY_LOG" "ERROR: Preset file not found: $file"
        return 1
    fi
    
    # Reset current selection and counts
    for id in "${!SELECTED_STATE[@]}"; do
        SELECTED_STATE["$id"]="OFF"
    done
    for cid in "${!CAT_COUNTS[@]}"; do
        CAT_COUNTS["$cid"]=0
    done
    
    # Read IDs from JSON and mark as ON safely
    local count=0
    while read -r id; do
        [ -z "$id" ] || [ "$id" == "null" ] && continue
        SELECTED_STATE["$id"]="ON"
        local cid=$(get_app_category_id "$id")
        if [ -n "$cid" ] && [ "$cid" != "null" ]; then
            ((CAT_COUNTS["$cid"]++))
        fi
        ((count++))
    done < <(jq -r '.selected_apps[]?' "$file" 2>/dev/null)

    if [ "$count" -eq 0 ]; then
        log_warn "No valid apps found in preset: $file"
        log_to_file "$SUMMARY_LOG" "WARNING: Loaded empty or invalid preset: $file"
    else
        log_success "Preset loaded: $file ($count apps)"
        log_to_file "$SUMMARY_LOG" "Preset loaded successfully: $file ($count apps)"
    fi
}

choose_preset_ui() {
    mkdir -p "$PRESET_DIR"
    local files=("$PRESET_DIR"/*.json)
    
    if [ ! -e "${files[0]}" ]; then
        whiptail --title "$STR_MENU_LOAD_PRESET" --msgbox "No presets found in $PRESET_DIR" 10 60
        return 1
    fi
    
    local args=()
    for f in "${files[@]}"; do
        args+=("$(basename "$f")" "")
    done
    
    local choice=$(whiptail --title "$STR_SELECT_PRESET" --menu "$STR_SELECT_PRESET" $HEIGHT $WIDTH $LIST_HEIGHT "${args[@]}" 3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        load_preset "$PRESET_DIR/$choice"
    fi
}
