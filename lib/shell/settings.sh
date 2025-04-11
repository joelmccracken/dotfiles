#!/usr/bin/env sh

# always avoid nix channels

# export NIX_PATH=""
# export PKG_CONFIG_PATH
# PKG_CONFIG_PATH="/opt/homebrew/opt/mysql-client@8.0/lib/pkgconfig:${PKG_CONFIG_PATH}"
# PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig:${PKG_CONFIG_PATH}"
# PKG_CONFIG_PATH="/usr/local/opt/libpq/lib/pkgconfig:${PKG_CONFIG_PATH}"


export LDFLAGS="-L/usr/local/opt/libpq/lib"
export CPPFLAGS="-I/usr/local/opt/libpq/include"


export C_INCLUDE_PATH
C_INCLUDE_PATH="$(xcrun --show-sdk-path)/usr/include/ffi:$C_INCLUDE_PATH"
C_INCLUDE_PATH="/opt/homebrew/Cellar/pcre/8.45/include:$C_INCLUDE_PATH"
C_INCLUDE_PATH="/opt/homebrew/Cellar/librdkafka/2.6.1/include:$C_INCLUDE_PATH"

# C_INCLUDE_PATH="/opt/homebrew/Cellar/zstd/1.5.5/include:$C_INCLUDE_PATH"
# C_INCLUDE_PATH="/opt/homebrew/Cellar/openssl@3/3.2.1/include/openssl:$C_INCLUDE_PATH"
# C_INCLUDE_PATH="/opt/homebrew/Cellar/mysql-client@8.0/8.0.36/include/mysql-client:$C_INCLUDE_PATH"

export C_LIBRARY_PATH
C_LIBRARY_PATH="/opt/homebrew/Cellar/librdkafka/2.6.1/lib:$C_LIBRARY_PATH"
# C_LIBRARY_PATH="/opt/homebrew/Cellar/zstd/1.5.5/lib:$C_LIBRARY_PATH"
# C_LIBRARY_PATH="/opt/homebrew/Cellar/openssl@3/3.2.1/lib:$C_LIBRARY_PATH"
# C_LIBRARY_PATH="/opt/homebrew/Cellar/mysql-client@8.0/8.0.36/lib:$C_LIBRARY_PATH"
# export C_LIBRARY_PATH="/opt/homebrew/opt/mysql-client/lib:$C_LIBRARY_PATH"


export INCLUDE_PATH="$C_INCLUDE_PATH:$INCLUDE_PATH"

export LIBRARY_PATH="$C_LIBRARY_PATH:$LIBRARY_PATH"
export LD_LIBRARY_PATH="$C_LIBRARY_PATH:$LD_LIBRARY_PATH"
