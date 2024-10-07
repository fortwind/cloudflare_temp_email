# #!/bin/sh

pnpm build:pages
cp -rf ../pages/functions ./dist
