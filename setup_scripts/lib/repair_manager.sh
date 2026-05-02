#!/bin/bash

# Función para obtener herramientas de reparación globales
get_global_repair_tools() {
    jq -r '.repair_tools[] | "\(.id)|\(.name)"' "$JSON_FILE"
}

# Función para ejecutar reparación
run_repair() {
    local repair_id=$1
    local name=$2
    
    log_info "Ejecutando reparacion: $name..."
    
    # Buscar en herramientas globales
    local cmd=$(jq -r ".repair_tools[] | select(.id==\"$repair_id\") | .command" "$JSON_FILE")
    
    # Si no es global, buscar en apps
    if [ "$cmd" == "null" ] || [ -z "$cmd" ]; then
        cmd=$(jq -r ".categories[].apps[] | select(.id==\"$repair_id\") | .repair" "$JSON_FILE")
    fi
    
    if [ "$cmd" != "null" ] && [ -n "$cmd" ]; then
        eval "$cmd"
        if [ $? -eq 0 ]; then
            log_success "Reparacion completada con exito."
        else
            log_error "Fallo al ejecutar la reparacion."
        fi
    else
        log_warn "No se encontro un comando de reparacion para $repair_id."
    fi
}
