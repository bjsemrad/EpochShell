#!/usr/bin/env bash
cd "$1"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

nix flake update \
  --output-lock-file "$tmp"

if cmp -s flake.lock "$tmp"; then
  echo "No updates for nixpkgs."
  exit 0
else
  echo "Updates available for nixpkgs:"
  diff -u flake.lock "$tmp" || true
  exit 2
fi
