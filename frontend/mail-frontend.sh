# #!/bin/sh

pnpm build:pages
cp -rf ../pages/functions ./dist

# cat > wrangler.toml <<EOF
# name = "temp-email-pages"
# pages_build_output_dir = "./dist"
# compatibility_date = "2024-05-13"

# [[services]]
# binding = "BACKEND"
# service = "cloudflare-temp-email"
# environment = "production"
# EOF
