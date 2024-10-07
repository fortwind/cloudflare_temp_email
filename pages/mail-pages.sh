# #!/bin/sh

cd ../frontend
pnpm install
pnpm build:pages

cd ../pages
cat > wrangler.toml <<EOF
name = "temp-email-pages"
pages_build_output_dir = "../frontend/dist"
compatibility_date = "2024-05-13"

[[services]]
binding = "BACKEND"
service = "cloudflare-email"
environment = "production"
EOF

pnpm run deploy
