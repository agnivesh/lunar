#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# full_audit_osx_services
#
# Audit All System
#.

full_audit_osx_services () {
  print_function "full_audit_osx_services"
  audit_bluetooth
  audit_guest_sharing
  audit_file_sharing
  audit_web_sharing
  audit_login_warning
  audit_firewall_setting
  audit_infrared_remote
  audit_setup_file
  audit_screen_lock
  audit_screen_sharing
  audit_sleep
  audit_secure_swap
  audit_login_guest
  audit_login_details
  audit_core_limit
  audit_remote_apple_events
  audit_remote_management
  audit_wake_on_lan
  audit_file_vault
  audit_gate_keeper
  audit_safe_downloads
  audit_secure_keyboard_entry
  audit_bonjour_advertising
  audit_keychain_lock
  audit_keychain_sync
  audit_auto_login
  audit_auto_logout
  audit_file_extensions
  audit_internet_sharing
  audit_java
  audit_asl
  audit_auditd
  audit_wireless
  audit_app_perms
  audit_login_root
  audit_system_preferences
  audit_system_integrity
  audit_icloud_drive
  audit_air_drop
  audit_air_play
  audit_asset_cache
  audit_media_sharing
  audit_time_machine
  audit_siri
  audit_location_services
  audit_usage_data
  audit_screen_corner
  audit_lockdown
  audit_universal_control
  audit_touch_id
  audit_apfs
  audit_core_storage
  audit_amfi
  audit_sudo_timeout
  audit_sudo_timestamp
  audit_sudo_authenticate
  audit_sudo_nopassword
  audit_sudo_logfile
  audit_sudo_usepty
  audit_sudo_perms
  audit_safari_auto_run
  audit_safari_history
  audit_safari_warn
  audit_safari_tracking
  audit_safari_auto_fill
  audit_safari_allow_popups
  audit_safari_javascript
  audit_safari_show_statusbar
  audit_account_switching
}
