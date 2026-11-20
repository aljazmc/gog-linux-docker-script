#!/bin/bash
#
# project.sh answers an unknown command with its usage, and "start" refuses
# to run without a GOG installer (*.sh) next to it, before it writes
# docker-compose.yml or runs a container. Runs on a copy of project.sh in a
# temporary folder, with docker replaced by a stand-in that records calls.
#
# Run from anywhere: bash tests/test_project.sh

repo=$(cd "$(dirname "$0")/.." && pwd) || exit 1
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT

mkdir "$tmp/bin" "$tmp/work"
cat > "$tmp/bin/docker" <<EOF
#!/bin/sh
[ "\$1 \$2" = "compose version" ] && exit 0
echo "docker \$*" >> "$tmp/calls"
EOF
chmod +x "$tmp/bin/docker"
cp "$repo/project.sh" "$tmp/work/project.sh"

failures=0

check() {

    local expected_code=$1 expected_text=$2 output code
    shift 2
    output=$(cd "$tmp/work" && PATH="$tmp/bin:$PATH" bash project.sh "$@" 2>&1)
    code=$?

    if [ "$code" -ne "$expected_code" ] || [[ "$output" != *"$expected_text"* ]]; then
        echo "FAIL: ./project.sh $* exited with $code: $output" >&2
        failures=$((failures + 1))
    else
        echo "ok: ./project.sh $*"
    fi

}

check 1 "Usage: ./project.sh {start|clean}"
check 1 "Usage: ./project.sh {start|clean}" install
check 1 "No .sh file found" start

if [ -e "$tmp/work/docker-compose.yml" ] || [ -e "$tmp/calls" ]; then
    echo "FAIL: start without an installer wrote docker-compose.yml or ran docker" >&2
    failures=$((failures + 1))
fi

if [ "$failures" -gt 0 ]; then
    echo "FAILED: $failures" >&2
    exit 1
fi
echo "PASS"
