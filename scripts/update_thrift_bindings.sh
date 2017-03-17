#!/bin/bash

HIVE_VERSION='2.3'

# Create a temporary directory
scriptdir=`dirname $0`
tmpdir=`mktemp -d 2>/dev/null || mktemp -d -t 'pyhive'`

# Copy patch that adds legacy GetLog methods
cp $scriptdir/thrift-patches/TCLIService.patch $tmpdir

# Download TCLIService.thrift from Hive
curl https://raw.githubusercontent.com/apache/hive/branch-$HIVE_VERSION/service-rpc/if/TCLIService.thrift > $tmpdir/TCLIService.thrift

# Apply patch
pushd $tmpdir
patch < TCLIService.patch
popd

thrift -r --gen py -out $scriptdir/../ $tmpdir/TCLIService.thrift

# One further step is required. For some reason, `TProgressUpdateResp` is out of
# order in the generated file, and must be manually moved above
# `TGetOperationStatusResp` which has an import-time dependency on it.
