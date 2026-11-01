-- ============================================================
-- 방명록(guestbook) 스키마 · Supabase (Postgres)
-- 사용법: Supabase 대시보드 → SQL Editor 에 통째로 붙여넣고 Run
-- 정책: 누구나 읽기 + 누구나 쓰기, 수정/삭제는 불가(관리자만 대시보드에서)
-- ============================================================

-- 1) 테이블 ------------------------------------------------
create table if not exists public.guestbook (
  id          bigint generated always as identity primary key,
  name        text        not null,
  message     text        not null,
  is_hidden   boolean     not null default false,   -- 스팸/부적절한 글을 숨길 때 사용
  created_at  timestamptz not null default now(),   -- 작성시간 (서버가 자동 기록)

  -- 길이 제한: 빈 값·공백만 있는 값·너무 긴 글 차단
  constraint guestbook_name_len    check (char_length(btrim(name))    between 1 and 30),
  constraint guestbook_message_len check (char_length(btrim(message)) between 1 and 500)
);

comment on table  public.guestbook            is '포트폴리오 방명록';
comment on column public.guestbook.is_hidden  is 'true면 화면에 안 보임 (관리자가 대시보드에서 변경)';

-- 최신글 조회용 인덱스
create index if not exists guestbook_created_at_idx
  on public.guestbook (created_at desc);

-- 2) RLS(행 단위 보안) 켜기 -----------------------------------
alter table public.guestbook enable row level security;

-- 3) 정책 -------------------------------------------------
-- 읽기: 누구나, 단 숨김 처리된 글은 제외
create policy "guestbook_select_public"
  on public.guestbook
  for select
  to anon, authenticated
  using (is_hidden = false);

-- 쓰기: 누구나. 단 새 글은 항상 '보이는 상태'로만 등록 가능
create policy "guestbook_insert_public"
  on public.guestbook
  for insert
  to anon, authenticated
  with check (is_hidden = false);

-- UPDATE / DELETE 정책은 일부러 만들지 않음 → 방문자는 수정·삭제 불가

-- 4) 권한(grant) — RLS 와 이중 잠금 ---------------------------
revoke all on public.guestbook from anon, authenticated;

grant select on public.guestbook to anon, authenticated;

-- 방문자는 name, message 두 칸만 입력 가능.
-- (id, created_at, is_hidden 을 마음대로 조작하는 것을 막음)
grant insert (name, message) on public.guestbook to anon, authenticated;

-- ============================================================
-- 사용 예 (프론트엔드, supabase-js)
--   읽기: supabase.from('guestbook').select('id,name,message,created_at')
--                 .order('created_at', { ascending: false }).limit(50)
--   쓰기: supabase.from('guestbook').insert({ name, message })
--   ※ 화면에 출력할 때는 innerHTML 대신 textContent 사용 (악성 스크립트 방지)
--   ※ 프론트엔드에는 anon(공개) 키만 사용. service_role 키는 절대 넣지 말 것
-- ============================================================
