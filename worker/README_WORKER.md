Cloudflare Worker for portfolio contact (SendGrid forwarding)

Overview
- This Worker accepts POST requests with JSON {Name, Email, Message} and forwards them to SendGrid.
- Keep API keys and email addresses as secrets; do NOT commit them to git.

Deployment (wrangler)
1. Install wrangler: `npm install -g wrangler` (or use Cloudflare dashboard)
2. Authenticate: `wrangler login` or set `CF_API_TOKEN` per wrangler docs
3. In the `worker` folder run:
   - `wrangler secret put SENDGRID_API_KEY` (paste your SendGrid API key)
   - `wrangler secret put FROM_EMAIL` (e.g., no-reply@ynbmike.me)
   - `wrangler secret put TO_EMAIL` (e.g., chegemichael974@gmail.com)
4. Deploy: `wrangler publish`

Notes
- Verify `FROM_EMAIL` in SendGrid (unverified senders may be blocked or marked spam).
- Add SPF/DKIM records for `ynbmike.me` to improve deliverability.
- For small sites this setup is reliable and inexpensive.
