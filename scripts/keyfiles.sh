#!/bin/bash

HOST=${1:-localhost}
case "${DEBUG}" in
  true|TRUE|DEBUG|1) DEBUG=true  ;;
  *                ) DEBUG=false ;;
esac

# Helper function for debug output
debug_out() { $DEBUG || return 0 ; echo -ne "$@" 1>&2 ; }

# --- Stage 1: Check ssh-agent First (Highest Priority) ---

IFS=$'\n' ssh_dir_files=( $(find ~/.ssh/ -maxdepth 1 -type f ! -name authorized_keys) )
debug_out "ssh_dir_files:\n$(printf "  %s\n" "${ssh_dir_files[@]}")\n"

# Get the list of public keys currently loaded in the agent.
# The SSH_AUTH_SOCK check ensures we don't wait for a non-existent agent.
if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ] && (( ${#ssh_dir_files[@]} > 0 )); then
  debug_out "== Checking ssh-agent for loaded keys ==\n"
  IFS=$'\n' agent_pub_keys=( $(ssh-add -L 2> /dev/null | awk '{print $1" "$2}') )
  if (( ${#agent_pub_keys[@]} == 0 )) ; then
    debug_out 'Found no ssh-agent public keys.\n'
  else
    debug_out "Found ${#agent_pub_keys[@]} ssh-agent public keys:\n"
    debug_out "$(printf "  %s\n" "${agent_pub_keys[@]}")\n"

    for agent_pub_key in "${agent_pub_keys[@]}"; do
      debug_out "Looking for '${agent_pub_key}'\n"
      key_type="${agent_pub_key% *}" # Strip everything starting with first space to end.
      key_data="${agent_pub_key#* }" # Strip everything starting from beginning to first space.
      pub_key_files=( $(
         awk -v type="${key_type}" -v data="${key_data}" '
          $1 == type && $2 == data {
            print FILENAME;
            exit;
          }
        ' "${ssh_dir_files[@]}"
      ) )
      debug_out "Found ${#pub_key_files[@]} potential matching public key files.\n"
      debug_out "$(printf "  %s\n" "${pub_key_files[@]}")\n"

      for pub_key_file in "${pub_key_files[@]}" ; do
        debug_out "Checking '${pub_key_file}' validity.\n"
        if ssh-keygen -l -f "${pub_key_file}" &>/dev/null ; then
          debug_out 'Validity test passed.\n'
          echo "$pub_key_file"
          exit 0
        else
          debug_out 'Validity test failed.'
        fi
      done

      debug_out "No matching public key file found for this agent key.\n"
    done
  fi
else
  debug_out "== No ssh-agent or files in ~/.ssh/ found ==\n"
fi

# --- Stage 2: Check Filesystem (If Not Found in Agent) ---

debug_out "\n== Checking filesystem for key files ==\n"
# Get list of private key files ssh would try in order.
# The tilde is expanded to the HOME directory for reliable path checking.
IFS=$'\n' keyfiles_try=( $(ssh -G "$HOST" \
  | sed -n 's/^[Ii]dentityfile //p'
) )

# Expand tildes from previous.
for i in "${!keyfiles_try[@]}"; do
    keyfiles_try[$i]="${keyfiles_try[$i]/#\~/$HOME}"
done

debug_out "Identified ssh keys ssh will tried by ssh:\n$(printf "  %s\n" "${keyfiles_try[@]}")"

for keyfile in "${keyfiles_try[@]}"; do
  debug_out "Testing ${keyfile}... "

  # The first file that exists is the one ssh will try to use.
  if [ ! -f "$keyfile" ]; then
    debug_out "does not exist.\n"
    continue
  fi

  # Attempt to generate public key with a blank password.
  # This is a non-interactive way to check if the key is encrypted.
  gen_pubkey=$(ssh-keygen -y -f "$keyfile" -P "" 2>/dev/null | awk '{print $1" "$2}')

  if [ -z "$gen_pubkey" ]; then
    # If it failed, the key is either encrypted or invalid.
    # ssh would prompt for a password here.
    debug_out 'exists, but is encrypted or invalid.\n'
    continue
  fi

  # If it succeeded, the key is not encrypted and we can fully validate it.
  pubkeyfile="${keyfile}.pub"
  if [ ! -f "$pubkeyfile" ]; then
    debug_out "exists, but public key ${pubkeyfile} is missing.\n"
    continue
  fi

  # Validate the pub key found matches the key.
  pubkey=$(awk '{print $1" "$2}' "${pubkeyfile}")
  if [ "$gen_pubkey" != "$pubkey" ]; then
    debug_out "exists, but public key ${pubkeyfile} does not match private key.\n"
    continue
  fi
  debug_out "exists, and public key ${pubkeyfile} matches\n"

  # This is the key ssh will select. It may still fail (e.g., wrong password),
  # but this is the first one it will *try*.
  echo "$pubkeyfile"
  exit 0
done

# If no keys were found at all.
exit 1
