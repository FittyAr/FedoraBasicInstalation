#!/bin/bash

# Función para ejecutar reparación
run_repair() {
    local repair_id=$1
    local name=$2
    
    log_info "$STR_EXECUTING_REPAIR $name..."
    
    local cmd=$(get_repair_command "$repair_id")
    
    if [ "$cmd" != "null" ] && [ -n "$cmd" ]; then
        eval "$cmd"
        if [ $? -eq 0 ]; then
            log_success "$STR_REPAIR_SUCCESS"
        else
            log_error "$STR_REPAIR_FAILED"
        fi
    else
        log_warn "$STR_REPAIR_NOT_FOUND $repair_id."
    fi
}
