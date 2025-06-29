import os

MAX_CONTEXT_SIZE = 1024 * 1024  # 1MB

def save_context(context: str, path: str):
    with open(path, 'w') as f:
        f.write(context)

def load_context(path: str) -> str:
    if not os.path.exists(path):
        return ''
    with open(path, 'r') as f:
        return f.read()

def prune_context(path: str):
    if not os.path.exists(path):
        return
    size = os.path.getsize(path)
    if size > MAX_CONTEXT_SIZE:
        with open(path, 'r') as f:
            data = f.read()
        # Keep only the last MAX_CONTEXT_SIZE bytes
        pruned = data[-MAX_CONTEXT_SIZE:]
        with open(path, 'w') as f:
            f.write(pruned) 