#!/usr/bin/env bash
# Copyright 2026 Jorge Castro
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# setup-goose.sh - Configure Goose with linux-mcp-server
# NOTE: Reference implementation - agents follow SKILL.md instructions inline
# TODO: Phase 4 - Add dosu remote MCP support (pending Goose research)

set -euo pipefail

# Source library functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/validation.sh"

# Configuration
GOOSE_CONFIG="$HOME/.config/goose/config.yaml"

main() {
    log_info "Starting Goose setup for bluespeed-onboarding..."
    
    # Validate prerequisites
    if ! validate_goose_prerequisites; then
        log_error "Prerequisites not met. Exiting."
        exit 1
    fi
    
    # Detect username
    USERNAME=$(get_username)
    log_info "Detected username: $USERNAME"
    
    # Create config if it doesn't exist
    if [[ ! -f "$GOOSE_CONFIG" ]]; then
        log_info "Goose config not found, creating default..."
        create_default_goose_config "$GOOSE_CONFIG" || {
            log_error "Failed to create default config"
            exit 1
        }
    fi
    
    # Backup existing config
    BACKUP_PATH=$(backup_file "$GOOSE_CONFIG")
    if [[ -z "$BACKUP_PATH" ]]; then
        log_error "Failed to create backup"
        exit 1
    fi
    
    # Set up error handler to restore backup
    trap "cleanup_on_error '$GOOSE_CONFIG' '$BACKUP_PATH'" ERR
    
    # Merge linux-mcp-server extension
    log_info "Configuring linux-mcp-server extension..."
    merge_goose_linux_mcp "$GOOSE_CONFIG" "$USERNAME" || {
        status=$?
        if [[ $status -eq 2 ]]; then
            # Error occurred, trap will restore backup
            exit 1
        fi
        # status=1 means already exists, continue
    }
    
    # TODO: Phase 4 - Add dosu remote MCP support for Goose
    log_warn "Phase 4 TODO: dosu remote MCP support pending Goose research"
    
    # Validate final configuration
    log_info "Validating configuration..."
    if ! validate_yaml "$GOOSE_CONFIG"; then
        log_error "Configuration validation failed, restoring backup..."
        restore_backup "$GOOSE_CONFIG" "$BACKUP_PATH"
        exit 1
    fi
    
    # Success!
    log_success "Goose configuration complete!"
    echo ""
    log_info "Next steps:"
    echo "  1. Exit Goose session: 'exit' command or Ctrl+D"
    echo "  2. Restart Goose from terminal: 'goose'"
    echo "  3. Verify extensions: Check startup messages for 'linux-mcp-server' loading"
    echo "  4. Test: Ask 'Can you check my disk usage?' (tests linux-mcp-server)"
    echo ""
    log_info "Troubleshooting:"
    echo "  - Logs: ~/.config/goose/logs/"
    echo "  - Config: ~/.config/goose/config.yaml"
    echo "  - Backup: $BACKUP_PATH"
    echo ""
    log_info "Note: dosu MCP support for Goose is planned for Phase 4"
}

# Show help
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Usage: $0"
    echo ""
    echo "Configure Goose with linux-mcp-server for Bluefin maintenance."
    echo ""
    echo "This script:"
    echo "  - Validates prerequisites (yq, linux-mcp-server)"
    echo "  - Backs up existing Goose config"
    echo "  - Merges linux-mcp-server extension configuration"
    echo "  - Validates final configuration"
    echo "  - Auto-restores backup on error"
    echo ""
    echo "Prerequisites:"
    echo "  brew install jq"
    echo "  brew install yq"
    echo "  brew install ublue-os/tap/linux-mcp-server"
    echo ""
    echo "Note: dosu MCP support for Goose is planned for Phase 4"
    exit 0
fi

main
