#!/bin/bash
set -e
echo "🧹 Full system reset in progress..."

# Remove containers & images
docker rm -f $(docker ps -aq) 2>/dev/null || true
docker rmi $(docker images -q) -f 2>/dev/null || true
docker system prune -a -f 2>/dev/null || true

# Clean Vagrant
vagrant destroy -f 2>/dev/null || true
rm -rf .vagrant/

# Remove SSH fingerprints
ssh-keygen -f ~/.ssh/known_hosts -R "[127.0.0.1]:2200" 2>/dev/null || true

echo "✅ Clean slate ready!"
