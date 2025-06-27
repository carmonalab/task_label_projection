#!/bin/bash

set -e

common/scripts/create_component \
  --name sctypeeval \
  --language r \
  --type metric
