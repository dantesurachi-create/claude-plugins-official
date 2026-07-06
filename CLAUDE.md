# Project instructions

## Reading PDFs

Always use `markitdown` to view the content of PDF files instead of reading them directly:

```bash
markitdown path/to/file.pdf
```

markitdown (and ffmpeg for its audio converter) is installed automatically at session start by `.claude/hooks/session-start.sh`. If the command is missing, install it with `pip install cffi "markitdown[all]"`.
