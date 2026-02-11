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

# setup-opencode.sh - Configure OpenCode with dosu and linux-mcp-server
# NOTE: Reference implementation - agents follow SKILL.md instructions inline

set -euo pipefail

# Source library functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/validation.sh"

# Configuration
OPENCODE_CONFIG="$HOME/.config/opencode/opencode.json"

main() {
    log_info "Starting OpenCode setup for bluespeed-onboarding..."
    
    # Validate prerequisites
    if ! validate_opencode_prerequisites; then
        log_error "Prerequisites not met. Exiting."
        exit 1
    fi
    
    # Detect username
    USERNAME=$(get_username)
    log_info "Detected username: $USERNAME"
    
    # Create config if it doesn't exist
    if [[ ! -f "$OPENCODE_CONFIG" ]]; then
        log_info "OpenCode config not found, creating default..."
        create_default_opencode_config "$OPENCODE_CONFIG" || {
            log_error "Failed to create default config"
            exit 1
        }
    fi
    
    # Backup existing config
    BACKUP_PATH=$(backup_file "$OPENCODE_CONFIG")
    if [[ -z "$BACKUP_PATH" ]]; then
        log_error "Failed to create backup"
        exit 1
    fi
    
    # Set up error handler to restore backup
    trap "cleanup_on_error '$OPENCODE_CONFIG' '$BACKUP_PATH'" ERR
    
    # Merge dosu MCP configuration
    log_info "Configuring dosu MCP..."
    merge_dosu_mcp "$OPENCODE_CONFIG" "$USERNAME" || {
        status=$?
        if [[ $status -eq 2 ]]; then
            # Error occurred, trap will restore backup
            exit 1
        fi
        # status=1 means already exists, continue
    }
    
    # Merge linux-mcp-server configuration
    log_info "Configuring linux-mcp-server..."
    merge_linux_mcp "$OPENCODE_CONFIG" "$USERNAME" || {
        status=$?
        if [[ $status -eq 2 ]]; then
            # Error occurred, trap will restore backup
            exit 1
        fi
        # status=1 means already exists, continue
    }
    
    # Validate final configuration
    log_info "Validating configuration..."
    if ! validate_json "$OPENCODE_CONFIG"; then
        log_error "Configuration validation failed, restoring backup..."
        restore_backup "$OPENCODE_CONFIG" "$BACKUP_PATH"
        exit 1
    fi
    
    # Success!
    log_success "OpenCode configuration complete!"
    echo ""
    log_info "Next steps:"
    echo "  1. Close all OpenCode windows"
    echo "  2. Restart OpenCode from application menu or 'opencode' command"
    echo "  3. Verify MCP servers loaded: Check 'MCP Servers' panel in sidebar"
    echo "  4. Test: Ask 'Can you check my system information?' (tests linux-mcp-server)"
    echo ""
    log_info "Troubleshooting:"
    echo "  - Logs: ~/.config/opencode/logs/"
    echo "  - Config: ~/.config/opencode/opencode.json"
    echo "  - Backup: $BACKUP_PATH"
}

# Show help
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Usage: $0"
    echo ""
    echo "Configure OpenCode with dosu MCP and linux-mcp-server for Bluefin maintenance."
    echo ""
    echo "This script:"
    echo "  - Validates prerequisites (jq, linux-mcp-server)"
    echo "  - Backs up existing OpenCode config"
    echo "  - Merges dosu and linux-mcp-server MCP configurations"
    echo "  - Validates final configuration"
    echo "  - Auto-restores backup on error"
    echo ""
    echo "Prerequisites:"
    echo "  brew install jq"
    echo "  brew install yq"
    echo "  brew install ublue-os/tap/linux-mcp-server"
    exit 0
fi

main
