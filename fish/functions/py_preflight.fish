function py_preflight
    poetry run black .
    poetry run ruff check --fix
    poetry run black .
end
