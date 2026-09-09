# Process Management

## Background Processes

```bash
# Run in background, get PID
long_running_task &
TASK_PID=$!

# Wait for it to complete
wait "$TASK_PID"
TASK_EXIT=$?

# Run multiple in parallel, wait for all
task1 &
task2 &
task3 &
wait
```

## Signal Handling with Trap

```bash
cleanup() {
    local signal="$1"
    [[ -n "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
    [[ -n "$BG_PID" ]] && kill "$BG_PID" 2>/dev/null
    exit 1
}

trap 'cleanup SIGINT' INT
trap 'cleanup SIGTERM' TERM
trap 'cleanup EXIT' EXIT
```

## Common Signals

| Signal | Number | Meaning |
|--------|--------|---------|
| `SIGINT` | 2 | Ctrl+C pressed |
| `SIGTERM` | 15 | Graceful termination request |
| `SIGKILL` | 9 | Force kill (cannot be trapped) |
| `SIGHUP` | 1 | Terminal disconnected |

## Avoiding Zombies

Always `wait` for background processes you start, or disown them:

```bash
fire_and_forget &
disown
```

## `kill` Patterns

```bash
# Graceful shutdown request first
kill "$PID"                    # SIGTERM
sleep 2
if kill -0 "$PID" 2>/dev/null; then
    kill -9 "$PID"             # SIGKILL — last resort only
fi
```
