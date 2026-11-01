# 📒 작업 기록 (progress)

> **append-only** — 기존 내용은 지우거나 고치지 않고, 아래에 계속 추가만 합니다.
> 형식: `## 날짜 — 제목` + 한 일 요약

---

## 2026-11-01 — 작업 환경 구축

1. `tasks/` 폴더 생성, `todo.md`(할 일)·`progress.md`(한 일 기록) 작성
2. `SECURITY.md` 작성 — 키 노출 시 비상 대응 매뉴얼 (OpenRouter / Oracle / WordPress)
3. `README.md` 작성 — 폴더 구조와 사용법 정리

- 메모: 현재 `.env`, `~/.ssh/` 폴더는 아직 없음 → 필요할 때 생성 예정

## 2026-11-01 — 다운로드 폴더 정리

1. `Downloads`에 `images`(110), `docs`(237, psd 포함), `misc`(192) 폴더를 만들고 최상위 파일 539개 이동
2. 기존 폴더 58개와 `desktop.ini`는 그대로 둠
3. 이동 기록: `tasks/move-log.csv` (From → To, 되돌리기용)
4. 검증: 성공 539 / 실패 0, 이름 겹침 0

## 2026-11-01 — 포트폴리오 웹페이지

1. `portfolio/index.html` 생성 (소개 · 경력 3개 · 연락처, 반응형, 다크모드 자동)
2. CLAUDE.md에는 이름·직업만 있어서 경력·연락처는 `[ ]` 노란 칸으로 비워 둠
3. 외부 서비스에 올리지 않음 (내 컴퓨터에서만 열림)

## 2026-11-01 — 포트폴리오 방명록 기능 (브랜치 `guestbook`)

1. `supabase/guestbook.sql` — 테이블(이름·메시지·작성시간·숨김) + RLS(누구나 읽기/쓰기, 수정·삭제 불가)
2. `api/guestbook.js` — Vercel 서버 함수(GET 목록 / POST 작성). 키는 환경변수(`SUPABASE_URL`, `SUPABASE_ANON_KEY`)에서만 읽음. 입력 검증·봇 함정·30초 도배 방지
3. `portfolio/index.html` — 방명록 섹션(입력창+목록), 메뉴 링크, 남색 테마 유지. 글은 `textContent`로만 출력
4. `.env.example`(키 이름만) 추가, `.gitignore`에 예외 규칙, README에 설정법 추가
5. 검증: 가짜 Supabase로 API 9가지 규칙 테스트 통과, 악성 스크립트 글이 글자 그대로 표시됨을 화면으로 확인
- 미확인: 진짜 Supabase 연결 (사용자가 프로젝트 생성·환경변수 등록 후 배포해서 확인 필요)
- 메모: 도배 방지는 서버 메모리 기반이라 완벽하지 않음 → 스팸이 늘면 캡차 추가 검토
