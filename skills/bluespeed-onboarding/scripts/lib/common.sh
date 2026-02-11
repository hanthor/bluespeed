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

# common.sh - Common utility functions for bluespeed-onboarding
# NOTE: Reference implementation - agents follow SKILL.md instructions inline

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions with formatted output
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

# Get current username
# Returns: username string
get_username() {
    whoami
}

# Create timestamped backup of a file
# Args:
#   $1 - file path to backup
# Returns: 0 on success, 1 on failure
backup_file() {
    local file_path="$1"
    
    if [[ ! -f "$file_path" ]]; then
        log_warn "File does not exist, skipping backup: $file_path"
        return 0
    fi
    
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S")
    local backup_path="${file_path}.${timestamp}.backup"
    
    if cp "$file_path" "$backup_path"; then
        log_info "Backup created: $backup_path"
        echo "$backup_path" # Return backup path for restore
        return 0
    else
        log_error "Failed to create backup: $backup_path"
        return 1
    fi
}

# Restore file from timestamped backup
# Args:
#   $1 - original file path
#   $2 - backup file path
# Returns: 0 on success, 1 on failure
restore_backup() {
    local file_path="$1"
    local backup_path="$2"
    
    if [[ ! -f "$backup_path" ]]; then
        log_error "Backup file not found: $backup_path"
        return 1
    fi
    
    if cp "$backup_path" "$file_path"; then
        log_success "Restored from backup: $backup_path"
        return 0
    else
        log_error "Failed to restore from backup: $backup_path"
        return 1
    fi
}

# Cleanup function for error handling (trap handler)
# Args:
#   $1 - original file path
#   $2 - backup file path
cleanup_on_error() {
    local file_path="$1"
    local backup_path="$2"
    
    if [[ -n "$backup_path" ]] && [[ -f "$backup_path" ]]; then
        log_error "Error detected, restoring backup..."
        restore_backup "$file_path" "$backup_path"
    fi
}
