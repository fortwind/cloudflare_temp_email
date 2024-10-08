# #!/bin/bash

# EMAIL_DOMAIN
# PASSWORDS
# ADMIN_PASSWORDS
# ADMIN_USER_ROLE
# DB_NAME
# DB_ID
# JWT_SECRET
# RESEND_TOKEN

uid=$(cat /dev/urandom | tr -dc 'a-z0-9' | head -c 18)

echo "uid: ${uid}"

function wrangler_toml() {
    cat > wrangler.toml <<EOF
    name = "cloudflare-temp-email"
    main = "src/worker.ts"
    compatibility_date = "2024-09-23"
    compatibility_flags = [ "nodejs_compat" ]
    workers_dev = false  # 禁用默认的workers.dev域名，只接收pages转发

    [vars]
    PREFIX = ""
    PASSWORDS = ["${PASSWORDS}"]
    ADMIN_PASSWORDS = ["${ADMIN_PASSWORDS}"]
    DOMAINS = ["${EMAIL_DOMAIN}"] # all domain names
    ADMIN_USER_ROLE = "${ADMIN_USER_ROLE}"
    USER_ROLES = [
        { domains = ["${EMAIL_DOMAIN}"], role = "${ADMIN_USER_ROLE}", prefix = "" },
    ]
    BLACK_LIST = ""
    ENABLE_USER_CREATE_EMAIL = true
    ENABLE_USER_DELETE_EMAIL = true
    ENABLE_AUTO_REPLY = false
    JWT_SECRET="${JWT_SECRET}"
    RESEND_TOKEN="${RESEND_TOKEN}"

    [[d1_databases]]
    binding = "DB"
    database_name = "${DB_NAME}"
    database_id = "${DB_ID}"

    [observability]
    enabled = true
EOF
}

function code_204() {
    code="
app.use('/*', async (c, n) => {
    const url = new URL(c.req.url);
    const reqPath = url.pathname;
    if (reqPath === '/api/${uid}' && c.req.method === 'GET') {
        return c.body('', 301, {
            'Set-Cookie': 'uid=${uid}; Max-Age=2592000; Secure; HttpOnly',
            'Location': 'https://' + url.host
        });
    }

    const cookie = c.req.header('cookie');
    if (!cookie || !cookie.includes('uid=${uid}')) {
        return c.body(null, 204);
    }

    await n();
})"

    worker_file=./src/worker.ts
    idx=0
    while read -r line; do
        idx=$((idx+1))
        if [[ "${line}" =~ ^\ *const\ app ]];then
            sed -i "${idx}a $(echo ${code})" ${worker_file}
            break
        fi
    done < ${worker_file}
}

wrangler_toml
# code_204
