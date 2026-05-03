#!/bin/bash


# Note: is_installed is now provided by detection.sh


install_tiered() {
    local app_id=$1
    local priority=($(get_app_priority "$app_id"))
    local log_file="$LOG_DIR/${app_id}.log"
    
    log_info "$STR_INSTALLING_APP $app_id..."
    log_to_file "$SUMMARY_LOG" "$(printf -- "$STR_LOG_INSTALL_START" "$app_id")"

    local redirect=""
    if [ "$DEBUG_MODE" = true ]; then
        redirect="&>> $log_file"
        echo "$(printf -- "$STR_LOG_INSTALL_LOG_HEADER" "$app_id")" > "$log_file"
    fi

    for method in "${priority[@]}"; do
        log_to_file "$SUMMARY_LOG" "$(printf -- "$STR_LOG_TRYING" "$method" "$app_id")"
        case "$method" in
            "dnf")
                local pkg=$(get_app_data "$app_id" "dnf_pkg")
                local repo_func=$(get_app_data "$app_id" "repo_func")
                local requires_repo=$(get_app_data "$app_id" "requires_repo")
                
                # Repositorios especiales
                if [ "$repo_func" != "null" ] && [ -n "$repo_func" ]; then
                    local repo_status=0
                    if [ "$DEBUG_MODE" = true ]; then
                        $repo_func &>> "$log_file" || repo_status=1
                    else
                        $repo_func || repo_status=1
                    fi
                    
                    if [ $repo_status -eq 0 ]; then
                        sudo dnf makecache -y --quiet
                    else
                        continue
                    fi
                fi

                
                if [ "$requires_repo" == "rpm-fusion" ]; then
                    if [ "$DEBUG_MODE" = true ]; then
                        add_rpm_fusion &>> "$log_file"
                    else
                        add_rpm_fusion
                    fi
                fi
                
                local cmd="sudo dnf install -y $pkg"
                if [ "$DEBUG_MODE" = true ]; then
                    eval "$cmd &>> $log_file"
                else
                    eval "$cmd"
                fi

                if [ $? -eq 0 ]; then
                    log_success "$app_id $STR_INSTALLED_VIA_DNF"
                    log_to_file "$SUMMARY_LOG" "$(printf -- "$STR_LOG_SUCCESS" "$app_id" "DNF")"
                    return 0
                fi
                ;;
            "flatpak")
                local fid=$(get_app_data "$app_id" "flatpak_id")
                local cmd_repo="sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
                local cmd_inst="sudo flatpak install -y flathub $fid"
                
                if [ "$DEBUG_MODE" = true ]; then
                    eval "$cmd_repo &>> $log_file"
                    eval "$cmd_inst &>> $log_file"
                else
                    eval "$cmd_repo"
                    eval "$cmd_inst"
                fi

                if [ $? -eq 0 ]; then
                    log_success "$app_id $STR_INSTALLED_VIA_FLATPAK"
                    log_to_file "$SUMMARY_LOG" "$(printf -- "$STR_LOG_SUCCESS" "$app_id" "Flatpak")"
                    return 0
                fi
                ;;
            "custom")
                local func=$(get_app_data "$app_id" "custom_func")
                if [ "$func" != "null" ] && [ -n "$func" ]; then
                    if [ "$DEBUG_MODE" = true ]; then
                        $func &>> "$log_file"
                    else
                        $func
                    fi
                    if [ $? -eq 0 ]; then
                        log_to_file "$SUMMARY_LOG" "$(printf -- "$STR_LOG_SUCCESS" "$app_id" "Custom Function")"
                        return 0
                    fi
                fi
                ;;
        esac
    done

    log_error "$STR_INSTALL_FAILED ($app_id)"
    log_to_file "$SUMMARY_LOG" "$(printf -- "$STR_LOG_FAILED" "$app_id")"
    return 1
}
