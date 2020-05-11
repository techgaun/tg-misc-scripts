#!/usr/bin/env bash

# Usage: ${0} [OLD_REMOTE] [NEW_REMOTE] [REMOTE_NAME]

OLD_REMOTE="${1:-bitbucket.org:paylease}"
NEW_REMOTE="${2:-github.com:gozego}"
REMOTE_NAME="${3:-origin}"

find "${PWD}" -type d -name '.git' | while read dir; do
  cd "${dir}/.."
  current_remote_url=$(git remote get-url "${REMOTE_NAME}")
  if grep "${OLD_REMOTE}" <<< "${current_remote_url}"; then
    new_remote_url=$(sed "s/${OLD_REMOTE}/${NEW_REMOTE}/" <<< "${current_remote_url}")
    echo "Changing ${current_remote_url} to ${new_remote_url}"
    git remote set-url "${REMOTE_NAME}" "${new_remote_url}"
  fi
done
