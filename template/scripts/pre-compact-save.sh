#!/bin/bash
# Pre-compact save — saves state before context compaction
# Part of Big Gulps memory persistence system

bash "$(dirname "$0")/session-save.sh"
echo "Session state saved before compaction."
