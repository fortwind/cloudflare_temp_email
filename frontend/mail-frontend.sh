# #!/bin/sh

uid=$(cat /dev/urandom | tr -dc 'a-z0-9' | head -c 18)

echo "uid: ${uid}"

pnpm build:pages
cp -rf ../pages/functions .

sed -i 's@export async function onRequest@async function onRequest1@' ./functions/_middleware.js

cat >> ./functions/_middleware.js <<EOF

export async function onRequest(context) {
    const reqPath = new URL(context.request.url).pathname
    if (reqPath === '/${uid}' && context.request.method === 'GET') {
        return new Response('', {
            status: 301,
            headers: {
                'Set-Cookie': 'uid=${uid}; Max-Age=2592000; Secure; HttpOnly'
            }
        })
    }

    const cookie = context.request.headers.get('cookie')
    if (!cookie || !cookie.includes('uid=${uid};')) {
        return new Response(null, { status: 204 })
    }

    return onRequest1(context)
}
EOF

# cat > wrangler.toml <<EOF
# name = "temp-email-pages"
# pages_build_output_dir = "./dist"
# compatibility_date = "2024-05-13"

# [[services]]
# binding = "BACKEND"
# service = "cloudflare-temp-email"
# environment = "production"
# EOF
