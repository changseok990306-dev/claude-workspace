-- ============================================================
-- 방명록 스키마 · Supabase (Postgres) · 테이블 이름: messages
-- 사용법: Supabase 대시보드 → SQL Editor → New query 에
--         이 파일을 통째로 붙여넣고 Run (여러 번 실행해도 안전)
-- 정책: 누구나 읽기 + 누구나 쓰기, 수정/삭제는 불가(관리자만 대시보드에서)
-- ============================================================

-- 1) 테이블 ------------------------------------------------
create table if not exists public.messages (
  id          bigint generated always as identity primary key,
  name        text        not null,
  content     text        not null,
  created_at  timestamptz not null default now(),   -- 서버가 자동 기록

  -- 길이 제한: 빈 값·공백만 있는 값·너무 긴 글 차단
  constraint messages_name_len    check (char_length(btrim(name))    between 1 and 30),
  constraint messages_content_len check (char_length(btrim(content)) between 1 and 500)
);

comment on table public.messages is '포트폴리오 방명록';

-- 최신글 조회용 인덱스
create index if not exists messages_created_at_idx
  on public.messages (created_at desc);

-- 2) RLS(행 단위 보안) 켜기 -----------------------------------
alter table public.messages enable row level security;

-- 3) 정책 (다시 실행해도 에러 나지 않게 먼저 지우고 만듦) ----------
drop policy if exists "messages_select_public" on public.messages;
drop policy if exists "messages_insert_public" on public.messages;

-- 읽기: 누구나
create policy "messages_select_public"
  on public.messages
  for select
  to anon, authenticated
  using (true);

-- 쓰기: 누구나
create policy "messages_insert_public"
  on public.messages
  for insert
  to anon, authenticated
  with check (true);

-- UPDATE / DELETE 정책은 일부러 만들지 않음 → 방문자는 수정·삭제 불가

-- 4) 권한(grant) — RLS 와 이중 잠금 ---------------------------
revoke all on public.messages from anon, authenticated;

grant select on public.messages to anon, authenticated;

-- 방문자는 name, content 두 칸만 입력 가능.
-- (id, created_at 을 마음대로 조작하는 것을 막음)
grant insert (name, content) on public.messages to anon, authenticated;

-- ============================================================
-- 글을 지우고 싶을 때: Supabase 대시보드 → Table Editor → messages → 행 삭제
--   ※ 프론트엔드에는 anon(공개) 키만 사용. service_role 키는 절대 넣지 말 것
-- ============================================================
