# #!/bin/sh

# EMAIL_API_DOMAIN
# EMAIL_DOMAIN
# PASSWORDS
# ADMIN_PASSWORDS
# ADMIN_USER_ROLE
# JWT_SECRET
# DB_NAME
# DB_ID

cat > wrangler.toml <<EOF
name = "cloudflare-email"
main = "src/worker.ts"
compatibility_date = "2024-09-23"
compatibility_flags = [ "nodejs_compat" ]
routes = [
    { pattern = "{{EMAIL_API_DOMAIN}}", custom_domain = true },
]

[vars]
PREFIX = ""
PASSWORDS = ["{{PASSWORDS}}"]
ADMIN_PASSWORDS = ["{{ADMIN_PASSWORDS}}"]
DOMAINS = ["{{EMAIL_DOMAIN}}"] # all domain names
ADMIN_USER_ROLE = "{{ADMIN_USER_ROLE}}"
USER_ROLES = [
   { domains = ["{{EMAIL_DOMAIN}}"], role = "{{ADMIN_USER_ROLE}}", prefix = "" },
]
JWT_SECRET = "{{JWT_SECRET}}"
BLACK_LIST = ""
ENABLE_USER_CREATE_EMAIL = true
ENABLE_USER_DELETE_EMAIL = true
ENABLE_AUTO_REPLY = false

[[d1_databases]]
binding = "DB"
database_name = "{{DB_NAME}}"
database_id = "{{DB_ID}}"
EOF
