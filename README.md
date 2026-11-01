# 🗂️ claude-workspace

오창석의 Claude Code 작업 공간입니다.
Claude Code가 일할 때 따르는 규칙, 할 일, 작업 기록, 보안 매뉴얼을 한곳에 모아둡니다.

---

## 📁 폴더 구조

```
claude-workspace/
├── CLAUDE.md          📜 Claude Code 지침서 (규칙·소통 방식·작업 원칙)
├── README.md          📖 지금 보고 있는 파일 — 폴더 안내
├── SECURITY.md        🚨 키 노출 시 비상 매뉴얼
├── .gitignore         🙈 git에 올리지 않을 파일 목록
├── .env               🔒 API 키 보관 (로컬에만 존재 · GitHub에는 없음)
├── tasks/
│   ├── todo.md        ✅ 오늘 할 일 (체크리스트)
│   └── progress.md    📒 한 일 기록 (추가만 하고 지우지 않음)
├── docs/
│   └── sample_sales.csv   📊 샘플 매출 데이터
└── portfolio/
    └── index.html     🌐 포트폴리오 웹페이지
```

> 🙈 `docs/resume.pdf`, `tasks/move-log.csv`는 개인·거래처 정보가 있어 로컬에만 두고 GitHub에는 올리지 않아요.

**작업 폴더 밖에 있는 것**

```
~/.ssh/
├── oracle-server.key  🔑 오라클 서버 SSH 키 (절대 공유 금지)
└── config             ⚙️ SSH 설정 — 별칭 `oracle-server` 등록
```

---

## 📄 파일별 역할

| 파일 | 언제 보나요? | 누가 쓰나요? |
|---|---|---|
| `CLAUDE.md` | Claude Code가 작업 시작할 때 자동으로 읽음 | 내가 직접 수정 |
| `tasks/todo.md` | 작업 **시작** 전에 확인 | Claude Code + 나 |
| `tasks/progress.md` | 작업 **끝날** 때 기록 | Claude Code |
| `SECURITY.md` | 키가 노출된 것 같을 때 | 비상시 참고 |
| `.env` | 프로그램이 키를 읽을 때 | 나만 (절대 공유 X) |
| `docs/` | 참고 자료·샘플 데이터가 필요할 때 | 나 |
| `portfolio/index.html` | 포트폴리오 페이지를 볼 때 (브라우저로 열기) | 나 + Claude Code |

---

## 🔄 하루 작업 흐름

1. **시작** → `tasks/todo.md` 확인
2. **계획** → 3단계 이상 걸리는 일은 `todo.md`에 계획부터 쓰고 OK 받기
3. **실행** → 한 단계씩, 확인하면서
4. **확인** → 실제로 돌려보고 결과 보기
5. **기록** → `tasks/progress.md`에 한 일 추가

---

## 🔒 보안 한눈에 보기

- 키는 **`.env`에만**, 코드에 직접 쓰지 않기
- `.env` · `*.key` · `*.pem` · `id_rsa` · `credentials` → **git에 올리지 않기**
- 키 노출 의심 → **`SECURITY.md`** 열고 "② 폐기"부터

---

*마지막 정리: 2026-11-01*
