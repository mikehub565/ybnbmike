addEventListener('fetch', event => {
  event.respondWith(handle(event.request))
})

async function handle(request) {
  if (request.method !== 'POST') return new Response('Method Not Allowed', { status: 405 })
  try {
    const data = await request.json()
    const name = (data.Name || '').trim()
    const email = (data.Email || '').trim()
    const message = (data.Message || '').trim()
    if (!email || !message) return new Response(JSON.stringify({ status: 'error', message: 'email and message required' }), { status: 400, headers: { 'Content-Type': 'application/json' } })

    // Provide your SendGrid key and emails as Worker secrets (see README)
    const SENDGRID_API_KEY = globalThis.SENDGRID_API_KEY || ''
    const FROM_EMAIL = globalThis.FROM_EMAIL || 'no-reply@ynbmike.me'
    const TO_EMAIL = globalThis.TO_EMAIL || 'chegemichael974@gmail.com'

    if (!SENDGRID_API_KEY) {
      return new Response(JSON.stringify({ status: 'error', message: 'sendgrid key not configured' }), { status: 500, headers: { 'Content-Type': 'application/json' } })
    }

    const payload = {
      personalizations: [{ to: [{ email: TO_EMAIL }] }],
      from: { email: FROM_EMAIL, name: 'Portfolio Contact' },
      reply_to: { email: email, name: name || 'Visitor' },
      subject: `Portfolio contact: ${name || email}`,
      content: [{ type: 'text/plain', value: `Name: ${name}\nEmail: ${email}\n\nMessage:\n${message}` }]
    }

    const resp = await fetch('https://api.sendgrid.com/v3/mail/send', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${SENDGRID_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    })

    if (!resp.ok) {
      const text = await resp.text()
      return new Response(JSON.stringify({ status: 'error', message: 'sendgrid error', detail: text }), { status: 502, headers: { 'Content-Type': 'application/json' } })
    }

    return new Response(JSON.stringify({ status: 'success' }), { status: 200, headers: { 'Content-Type': 'application/json' } })
  } catch (err) {
    return new Response(JSON.stringify({ status: 'error', message: err.toString() }), { status: 500, headers: { 'Content-Type': 'application/json' } })
  }
}
