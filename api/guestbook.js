// 방명록 API (Vercel 서버리스 함수)
//   GET  /api/guestbook  → 최신 글 50개
//   POST /api/guestbook  → 새 글 등록 { name, message }
//
// 키는 코드에 쓰지 않고 Vercel 환경변수에서만 읽습니다.
//   SUPABASE_URL, SUPABASE_ANON_KEY  (anon 공개 키만 사용 — service_role 금지)

const NAME_MAX = 30;
const MESSAGE_MAX = 500;
const LIST_LIMIT = 50;

// 간단한 도배 방지: 같은 IP는 30초에 1번 (서버가 새로 뜨면 초기화되는 "최소한의" 방어)
const COOLDOWN_MS = 30 * 1000;
const lastPost = new Map();

function send(res, status, body) {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify(body));
}

function clientIp(req) {
  const xff = req.headers['x-forwarded-for'];
  return (xff ? String(xff).split(',')[0] : req.socket && req.socket.remoteAddress) || 'unknown';
}

async function readBody(req) {
  if (req.body !== undefined && req.body !== null) {
    if (typeof req.body === 'string') return JSON.parse(req.body);
    return req.body;
  }
  let raw = '';
  for await (const chunk of req) {
    raw += chunk;
    if (raw.length > 10_000) throw new Error('too large');
  }
  return raw ? JSON.parse(raw) : {};
}

module.exports = async function handler(req, res) {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_ANON_KEY;
  if (!url || !key) {
    return send(res, 500, { error: '서버 설정이 아직 안 되어 있어요.' });
  }

  const base = `${url.replace(/\/+$/, '')}/rest/v1/guestbook`;
  const headers = { apikey: key, Authorization: `Bearer ${key}` };

  try {
    if (req.method === 'GET') {
      const r = await fetch(
        `${base}?select=id,name,message,created_at&order=created_at.desc&limit=${LIST_LIMIT}`,
        { headers }
      );
      if (!r.ok) return send(res, 502, { error: '목록을 불러오지 못했어요.' });
      return send(res, 200, { items: await r.json() });
    }

    if (req.method === 'POST') {
      let data;
      try {
        data = await readBody(req);
      } catch {
        return send(res, 400, { error: '잘못된 요청이에요.' });
      }

      // 봇 함정: 사람 눈에 안 보이는 칸이 채워져 있으면 조용히 성공한 척 무시
      if (data && data.website) return send(res, 201, { ok: true });

      const name = typeof data.name === 'string' ? data.name.trim() : '';
      const message = typeof data.message === 'string' ? data.message.trim() : '';
      if (!name || name.length > NAME_MAX) {
        return send(res, 400, { error: `이름은 1~${NAME_MAX}자로 적어 주세요.` });
      }
      if (!message || message.length > MESSAGE_MAX) {
        return send(res, 400, { error: `메시지는 1~${MESSAGE_MAX}자로 적어 주세요.` });
      }

      const ip = clientIp(req);
      const now = Date.now();
      if (now - (lastPost.get(ip) || 0) < COOLDOWN_MS) {
        return send(res, 429, { error: '잠시 후 다시 남겨 주세요. (30초에 1번)' });
      }

      const r = await fetch(base, {
        method: 'POST',
        headers: { ...headers, 'Content-Type': 'application/json', Prefer: 'return=minimal' },
        body: JSON.stringify({ name, message }),
      });
      if (!r.ok) return send(res, 502, { error: '저장하지 못했어요. 잠시 후 다시 시도해 주세요.' });

      lastPost.set(ip, now);
      return send(res, 201, { ok: true });
    }

    res.setHeader('Allow', 'GET, POST');
    return send(res, 405, { error: '허용되지 않는 요청이에요.' });
  } catch {
    return send(res, 500, { error: '일시적인 오류예요. 잠시 후 다시 시도해 주세요.' });
  }
};
