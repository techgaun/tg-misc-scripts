#!/usr/bin/env bash

# moves repos listed in a file from bb to gh
# usage: GH_TOKEN=<github_token> ./repo-mover.sh <file_with_repo_name_list>

set -euo pipefail

BB_ORG="${BB_ORG:-paylease}"
GH_ORG="${GH_ORG:-gozego}"
GH_USER="${GH_USER:-techgaun}"
GH_CRED="${GH_USER}:${GH_TOKEN}"

ROOT=$(pwd)
BRANCH_PROTECTION_BODY="$(cat <<-EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": []
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismissal_restrictions": {
      "users": [],
      "teams": [
        "qe",
        "engineering"
      ]
    },
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 2
  },
  "restrictions": {
    "users": [],
    "teams": [
      "qe"
    ]
  },
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
)"

while read repo; do
  echo
  echo "Starting repo creation for ${repo}..."

  cd "${ROOT}"
  rm -rf "${repo}.git"
  git clone --bare "git@bitbucket.org:${BB_ORG}/${repo}.git"
  cd "${repo}.git"
  curl -H 'Accept: application/vnd.github.nebula-preview+json' -u "${GH_CRED}" "https://api.github.com/orgs/${GH_ORG}/repos" -d "{\"name\": \"${repo}\", \"private\": true, \"visibility\": \"internal\", \"delete_branch_on_merge\": true}"
  curl -XPUT -u "${GH_CRED}" "https://api.github.com/orgs/${GH_ORG}/teams/engineering/repos/${GH_ORG}/${repo}" -d '{"permission": "push"}'
  curl -XPUT -u "${GH_CRED}" "https://api.github.com/orgs/${GH_ORG}/teams/qe/repos/${GH_ORG}/${repo}" -d '{"permission": "push"}'
  git push --mirror "git@github.com:${GH_ORG}/${repo}.git"
  echo "${BRANCH_PROTECTION_BODY}" | curl -H 'Accept: application/vnd.github.luke-cage-preview+json' -XPUT -u "${GH_CRED}" "https://api.github.com/repos/${GH_ORG}/${repo}/branches/master/protection" -d @-

  echo "Completed repo creation for ${repo}..."
  cd "${ROOT}"
  rm -rf "${repo}.git"
done < "${1}"
