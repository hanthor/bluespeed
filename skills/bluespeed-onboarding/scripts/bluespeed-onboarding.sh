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

# bluespeed-onboarding.sh - Main entry point for bluespeed-onboarding skill
# NOTE: Reference implementation - agents follow SKILL.md instructions inline

set -euo pipefail

# Source library functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/validation.sh"

# Show help
show_help() {
    cat << EOF
bluespeed-onboarding - Setup MCP servers for Bluefin maintenance

Usage: $0 [OPTIONS]

Configure OpenCode and/or Goose with dosu MCP and linux-mcp-server for
Project Bluefin maintenance work.

Options:
  -h, --help     Show this help message
  -o, --opencode Configure OpenCode only
  -g, --goose    Configure Goose only
  -a, --all      Configure both OpenCode and Goose (default if no option)

Prerequisites:
  brew install jq
  brew install yq
  brew install ublue-os/tap/linux-mcp-server
  brew install --cask ublue-os/experimental-tap/opencode-desktop-linux
  brew install --cask ublue-os/tap/goose-linux  # Optional

Examples:
  $0              # Interactive mode - asks which tool to configure
  $0 --opencode   # Configure OpenCode only
  $0 --goose      # Configure Goose only
  $0 --all        # Configure both tools

For more information, see:
  https://github.com/castrojo/bluespeed
EOF
}

# Interactive mode - ask user which tool to configure
interactive_mode() {
    echo ""
    log_info "bluespeed-onboarding - Bluefin MCP Server Setup"
    echo ""
    echo "Which AI tool would you like to configure?"
    echo ""
    echo "  1) OpenCode (recommended - full support)"
    echo "  2) Goose (partial support - linux-mcp-server only)"
    echo "  3) Both"
    echo "  4) Exit"
    echo ""
    read -p "Enter choice [1-4]: " choice
    
    case $choice in
        1)
            log_info "Selected: OpenCode"
            return 1
            ;;
        2)
            log_info "Selected: Goose"
            return 2
            ;;
        3)
            log_info "Selected: Both"
            return 3
            ;;
        4)
            log_info "Exiting..."
            exit 0
            ;;
        *)
            log_error "Invalid choice: $choice"
            exit 1
            ;;
    esac
}

main() {
    local mode=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -o|--opencode)
                mode="opencode"
                shift
                ;;
            -g|--goose)
                mode="goose"
                shift
                ;;
            -a|--all)
                mode="all"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # If no mode specified, use interactive mode
    if [[ -z "$mode" ]]; then
        interactive_mode
        choice=$?
        case $choice in
            1) mode="opencode" ;;
            2) mode="goose" ;;
            3) mode="all" ;;
        esac
    fi
    
    log_info "Starting bluespeed-onboarding setup..."
    
    # Validate generic prerequisites
    if ! validate_prerequisites; then
        log_error "Generic prerequisites not met. Please install missing packages and try again."
        exit 1
    fi
    
    # Run appropriate setup script(s)
    case $mode in
        opencode)
            log_info "Configuring OpenCode..."
            "${SCRIPT_DIR}/setup-opencode.sh" || {
                log_error "OpenCode setup failed"
                exit 1
            }
            ;;
        goose)
            log_info "Configuring Goose..."
            "${SCRIPT_DIR}/setup-goose.sh" || {
                log_error "Goose setup failed"
                exit 1
            }
            ;;
        all)
            log_info "Configuring OpenCode..."
            "${SCRIPT_DIR}/setup-opencode.sh" || {
                log_error "OpenCode setup failed"
                exit 1
            }
            echo ""
            log_info "Configuring Goose..."
            "${SCRIPT_DIR}/setup-goose.sh" || {
                log_error "Goose setup failed"
                exit 1
            }
            ;;
        *)
            log_error "Invalid mode: $mode"
            exit 1
            ;;
    esac
    
    # Final summary
    echo ""
    log_success "bluespeed-onboarding setup complete!"
    echo ""
    log_info "Summary of changes:"
    case $mode in
        opencode)
            echo "  ✓ OpenCode configured with dosu MCP and linux-mcp-server"
            echo "  → Restart OpenCode to activate changes"
            ;;
        goose)
            echo "  ✓ Goose configured with linux-mcp-server"
            echo "  → Restart Goose to activate changes"
            echo "  ℹ Note: dosu MCP support for Goose planned for Phase 4"
            ;;
        all)
            echo "  ✓ OpenCode configured with dosu MCP and linux-mcp-server"
            echo "  ✓ Goose configured with linux-mcp-server"
            echo "  → Restart both tools to activate changes"
            echo "  ℹ Note: dosu MCP support for Goose planned for Phase 4"
            ;;
    esac
    echo ""
    log_info "Backups created with timestamp suffix (.backup)"
    log_info "For troubleshooting, see ~/.config/opencode/logs/ or ~/.config/goose/logs/"
}

main "$@"
