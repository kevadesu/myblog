#!/bin/sh
PROJECT_DIR=$(dirname "$0")
VER=0.1
echo "ibkbb: ibikei Blog Builder $VER"

build() {
    echo "ibkbb: Preparing to build..."


    echo "ibkbb/Prepare: Making output directories..."
    mkdir $PROJECT_DIR/out -vp
    mkdir $PROJECT_DIR/out/posts -vp

    echo "ibkbb/Build: Compiling index..."
    $PROJECT_DIR/ibikei.sh $PROJECT_DIR/src/index.ibkx $PROJECT_DIR/out/index.html

    echo "ibkbb/Build: Compiling posts..."
    for file in $PROJECT_DIR/src/posts/*.ibkx; do
        $PROJECT_DIR/ibikei.sh "$file" $PROJECT_DIR/out/posts/$(basename "$file" .ibkx).html
    done

    echo "ibkbb/Build: Pouring in static..."
    cp -Rv $PROJECT_DIR/static/* $PROJECT_DIR/out/

    echo "ibkbb/Finish: Done!"
}

clean() {
    rm -Rv $PROJECT_DIR/out/*
    echo "ibkbb/Clean: Done!"
}

case "$1" in
    build|b)
        build
    ;;
    clean|c)
        clean
    ;;
    help|h)
        echo "Subcommands: build, clean"
    ;;
    *)
        echo "This subcommand does not exist."
    ;;
esac