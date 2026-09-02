$ErrorActionPreference = 'Stop'

cd "C:\Users\Windows\Documents\antigravity\amazing-galileo"

# Attempt to cleanly abort any ongoing merges or rebases just in case
try { git merge --abort 2>$null } catch {}
try { git rebase --abort 2>$null } catch {}

# Checkout main and ensure it's up to date
git checkout main

# Create Branch X (feature/base-feature)
git checkout -b feature/base-feature

Set-Content -Path database_connector.sh -Value @'
#!/bin/bash
function connect_to_db() {
    echo "Connecting to database at $DB_HOST..."
    echo "Connected!"
}
'@
git add database_connector.sh
git commit -m "feat: add initial database connector"

# Create Branch Y (feature/dependent-feature) from Branch X
git checkout -b feature/dependent-feature

Set-Content -Path Assignment.md -Value @'
# Assignment: Incremental PR / Dependent Branch

## Goal
Learn how to synchronize a dependent branch with its base branch.

## Instructions
1. This branch (`feature/dependent-feature`) was created from `feature/base-feature`.
2. After this branch was created, a crucial bug fix was merged into `feature/base-feature` (a commit fixing a connection leak).
3. Your task is to bring those new changes from `feature/base-feature` into your current branch so you have the bug fix!
4. You can solve this by running:
   `git merge feature/base-feature`
   OR
   `git rebase feature/base-feature`
'@

Set-Content -Path user_service.sh -Value @'
#!/bin/bash
source database_connector.sh

function get_user() {
    connect_to_db
    echo "Fetching user $1..."
}
'@
git add Assignment.md user_service.sh
git commit -m "feat: add user service depending on db connector"

# Go back to Branch X and add the "Gotcha" commit
git checkout feature/base-feature

Set-Content -Path database_connector.sh -Value @'
#!/bin/bash
function connect_to_db() {
    echo "Connecting to database at $DB_HOST..."
    echo "Connected safely. (Connection leak fixed!)"
}
'@
git add database_connector.sh
git commit -m "fix: resolve connection leak in database connector"

# Go back to main as a clean state
git checkout main

Write-Output "Incremental PR scenario added successfully."
