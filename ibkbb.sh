#!/bin/bash
PROJECT_DIR=$(dirname "$0")
VER=0.1
echo "ibkbb: ibikei Blog Builder $VER"

build() {
    echo "ibkbb: Preparing to build..."


    echo "ibkbb/Prepare: Making output directories..."
    mkdir "$PROJECT_DIR"/out -vp
    mkdir "$PROJECT_DIR"/out/posts -vp

    echo "ibkbb/Build: Compiling index..."
    "$PROJECT_DIR"/ibikei.sh "$PROJECT_DIR"/src/index.ibkx "$PROJECT_DIR"/out/index.html

    echo "ibkbb/Build: Compiling posts..."
    for file in $PROJECT_DIR/src/posts/*.ibkx; do
        echo "ibkbb/Build: Working on post $file"
        "$PROJECT_DIR"/ibikei.sh "$file" "$PROJECT_DIR/out/posts/$(basename "$file" .ibkx).html"
    done

    echo "ibkbb/Build: Pouring in static..."
    cp -Rv "$PROJECT_DIR"/static/* "$PROJECT_DIR"/out/

    echo "ibkbb/Finish: Done!"
}

clean() {
    rm -Rv "$PROJECT_DIR"/out/*
    echo "ibkbb/Clean: Done!"
}

newpost() {
    N=1
    SRC="${PROJECT_DIR}/src/posts/template.ibkx"
    DEST_DIR="${PROJECT_DIR}/src/posts"
    TODAY=$(date +%F) # Formats as YYYY-MM-DD

    while true; do
        # Format n as a 2-digit zero-padded number (01, 02, ... 10)
        printf -v NUM "%02d" "$N"
        export DEST="${DEST_DIR}/${TODAY}-${NUM}.ibkx"

        if [ ! -e "$DEST" ]; then
            cp "$SRC" "$DEST"
            echo "ibkbb/New post: New post created at $DEST"
            break
        fi

        ((N++))
    done
}

case "$1" in
    build|b)
        build
    ;;
    clean|c)
        clean
    ;;
    new|newpost|n)
        newpost
        case "$2" in
            "-e"|"--edit")
                $EDITOR "$DEST"
            ;;
        esac
    ;;
    d|delete)
        read -rp "ibkbb/Delete post: Are you sure you want to delete this post? [y/N] " OPT
        case "$OPT" in
            y|Y|yes)
                true
            ;;
            *)
                echo "ibkbb/Delete post: Aborted."
                exit 1
            ;;
        esac
        echo "ibkbb/Delete post: Removing $2"
        rm -v "$PROJECT_DIR"/src/posts/"$2"
    ;;
    l|list)
        ls -1 "$PROJECT_DIR"/src/posts
    ;;
    e|edit)
        $EDITOR "$DEST"
    ;;
    gcp|gitcommitpush)
        pushd "${PROJECT_DIR}" || exit 1
            git add -A
            git commit
            git push
        popd || exit
    ;;
    help|h)
        echo "Subcommands: b/build, c/clean, n/new/newpost (-e/--edit), d/delete, l/list, e/edit, gcp/gitcommitpush"
    ;;
    *)
        echo "This subcommand does not exist. Use h or help."
    ;;
esac