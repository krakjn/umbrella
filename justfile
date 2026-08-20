set shell := ["sh", "-cu"]

port := env("PORT", "3333")
image_name := "umbrella"

_:
    @just --list

# generate api schema.json + schema.h
gen:
    ./api/pkg/generate.sh

# pack all modules, then the calver meta-package
pack:
    ./pkg/create.sh

# pack umbrella-api.deb
api:
    ./api/pkg/create.sh

# pack umbrella-cli.deb
cli:
    ./cli/pkg/create.sh

# pack umbrella-lib.deb
lib:
    ./lib/pkg/create.sh

# pack umbrella-net.deb
net:
    ./net/pkg/create.sh

# print product + module versions
versions:
    @printf "umbrella  %s\n" "$(bump print bump.toml)"
    @printf "api       %s\n" "$(bump print api/bump.toml)"
    @printf "cli       %s\n" "$(bump print cli/bump.toml)"
    @printf "lib       %s\n" "$(bump print lib/bump.toml)"
    @printf "net       %s\n" "$(bump print net/bump.toml)"

# build the env image (toolchains + installed debs)
image:
    docker build -t {{image_name}} .

# shell in the env; `umbrella` is the cli, site is http://localhost:{{port}}
run: image
    docker run --rm -it -e HOST_PORT={{port}} -p {{port}}:3333 {{image_name}}

# remove generated files and debs
clean:
    rm -rf dist api/dist cli/dist lib/dist net/dist
    rm -rf api/gen cli/target cli/schema.json lib/build lib/version.h net/version
