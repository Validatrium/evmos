#!/usr/bin/env bash

set -eo pipefail

protoc_gen_go_pulsar() {
  if ! grep "github.com/gogo/protobuf => github.com/regen-network/protobuf" go.mod &>/dev/null ; then
    echo -e "\tPlease run this command from somewhere inside the evmos folder."
    return 1
  fi

  go install github.com/cosmos/cosmos-proto/cmd/protoc-gen-go-pulsar@v1.0.0-alpha7
}

protoc_gen_doc() {
  go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@latest 2>/dev/null
}

protoc_gen_go_pulsar
protoc_gen_doc




#!/usr/bin/env bash

#== Requirements ==
#
## make sure your `go env GOPATH` is in the `$PATH`
## Install:
## + latest buf (v1.0.0-rc11 or later)
## + protobuf v3
#
## All protoc dependencies must be installed not in the module scope
## currently we must use grpc-gateway v1
# cd ~
# go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
# go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
# go install github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@v1.16.0
# go install github.com/cosmos/cosmos-proto/cmd/protoc-gen-go-pulsar@latest
# go get github.com/regen-network/cosmos-proto@latest # doesn't work in install mode
# go get github.com/regen-network/cosmos-proto/protoc-gen-gocosmos@v0.3.1

set -eo pipefail

echo "Generating gogo proto code"
cd proto
proto_dirs=$(find ./evmos -path -prune -o -name '*.proto' -print0 | xargs -0 -n1 dirname | sort | uniq)
for dir in $proto_dirs; do
  for file in $(find "${dir}" -maxdepth 1 -name '*.proto'); do
    if grep "option go_package" $file &> /dev/null ; then
      buf generate --template buf.gen.gogo.yaml $file
    fi
  done
done

cd ..

# move proto files to the right places
cp -r github.com/evmos/evmos/v*/x/* x/
rm -rf github.com

go mod tidy -compat=1.18