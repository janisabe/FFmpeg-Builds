#!/bin/bash

OGG_REPO="https://github.com/xiph/ogg.git"
OGG_COMMIT="684c73773e7e2683245ffd6aa75f04115b51123a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /root/ogg.sh"
    to_df "RUN bash -c 'source /root/ogg.sh && ffbuild_dockerbuild && rm /root/ogg.sh'"
}

ffbuild_dockerbuild() {
    git clone "$OGG_REPO" ogg || return -1
    cd ogg
    git checkout "$OGG_COMMIT" || return -1

    ./autogen.sh || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    cd ..
    rm -rf ogg
}