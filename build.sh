#!/bin/sh
# TODO:
# C++ compilation flags.
# zig build-exe --help
# -fno-compiler-rt -fno-sanitize=undefined -fPIE -fPIC -mcmodel=
usage() {
    echo "USAGE:"
    echo "    build.sh [command]"
    echo
    echo "COMMANDS:"
    echo "    help       Print help and exit."
    echo "    release    Build Speedo in release mode."
    echo "    debug      Build Speedo in debug mode and test it with Valgrind."
    echo "    profile    Build Speedo in profiling mode and profile it with Strace and Tracy."
    exit $1
}
if [ 1 != $# ]; then
    echo "ERROR: Expected 1 command, found $#."
    echo
    usage 1
fi
base_cmd="zig build-exe src/main.zig -Isrc/ -Ilib/ --name speedo --color on -femit-bin=bin/speedo -fno-emit-implib --cache-dir bin/.cache/ -freference-trace=16 -ftime-report -fstack-report"
release_cmd="$base_cmd -OReleaseFast -fllvm -flibllvm -fclang -flld -flto -fformatted-panics -fstrip -fno-stack-check -fno-stack-protector -fno-unwind-tables"
case $1 in
    "release")
        $release_cmd
        strip -R.comment bin/speedo
        ./bin/speedo
        ;;
    "debug")
        $base_cmd -ODebug -fformatted-panics -fsanitize-thread -fsanitize-c -ferror-tracing -fvalgrind
        valgrind --leak-check=full --show-leak-kinds=all ./bin/speedo
        ;;
    "profile")
        $release_cmd lib/tracy/public/TracyClient.cpp -DTRACY_ENABLE=1 -lc -lc++
        strace -rtTvyyYCw ./bin/speedo
        Tracy &
        ./bin/speedo
        ;;
    "help")
        usage 0
        ;;
    *)
        echo "ERROR: Unexpected command '$1'."
        echo
        usage 1
        ;;
esac
