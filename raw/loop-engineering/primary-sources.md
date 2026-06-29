# Loop Engineering — 1차 출처 검증본 (2026-06-29 확보)

> [[loop-engineering-notes.md]]는 2026-06-13에 전달받은 **2차 정리본**이다. 이 파일은 그 정리본의 인용·발화를 **원전과 대조해 검증**한 결과를 보존한다.
> 검증 방식: WebSearch + WebFetch (2026-06-29). X(트위터)는 비로그인 402로 본문 직접 접근 불가 → 해당 항목은 2차 매체로 교차 확인.

---

## ✅ 직접 접근 검증된 1차 출처

### Addy Osmani — "Loop Engineering"
- **URL**: https://addyosmani.com/blog/loop-engineering/
- **날짜**: 2026-06-07 · addyosmani.com 블로그 (미러: O'Reilly Radar, addyo.substack.com)
- **용어를 명명·구조화한 핵심 1차 글.** Steinberger·Cherny를 글 안에서 직접 인용.
- **검증된 verbatim 인용**:
  - "Loop engineering is replacing yourself as the person who prompts the agent. You design the system that does it instead."
  - (토큰 신중론) "you absolutely *have* to be careful about token costs (usage patterns can vary wildly if you are token rich or poor)"
  - (서브에이전트 비용) "Subagents do burn more tokens... so spend them where a second opinion is worth paying for."
  - (검증 책임) "Verification is still on you. A loop running unattended is also a loop making mistakes unattended."
  - "your job is to ship code you confirmed works"

### Sonar — "Loop engineering without verification is just automation"
- **URL**: https://www.sonarsource.com/blog/loop-engineering-without-verification-is-just-automation/
- **날짜·저자**: 2026-06-11 · Sonar(SonarSource) · Prasenjit Sarkar
- **검증된 verbatim 인용**:
  - "A failing build is a fact; an opinion is a starting point." (※ 정리본·위키에서 앞 절만 인용 시 한 쌍임을 명기)
  - "Without a hard, objective stop condition, a loop doesn't fail loudly, it fails quietly."
  - "A loop that can reliably tell 'done and correct' from 'done' converges; it stops at the right moment."

---

## ✅ 이론 1차 출처 (arXiv — 영구 안정 URL)

| 논문 | arXiv | 정확 제목 | 저자 | 제출 |
|------|-------|----------|------|------|
| ReAct | [2210.03629](https://arxiv.org/abs/2210.03629) | ReAct: Synergizing Reasoning and Acting in Language Models | Shunyu Yao et al. (Princeton + Google) | 2022-10-06 (v3 2023-03) |
| Reflexion | [2303.11366](https://arxiv.org/abs/2303.11366) | Reflexion: Language Agents with Verbal Reinforcement Learning | Noah Shinn et al. | 2023-03-20 |
| Self-Refine | [2303.17651](https://arxiv.org/abs/2303.17651) | Self-Refine: Iterative Refinement with Self-Feedback | Aman Madaan et al. (17인) | 2023-03-30 |

→ 세 편 모두 제목·1저자·연도가 정리본과 일치. 인용은 "Yao et al. 2022 / Shinn et al. 2023 / Madaan et al. 2023"로 축약 적절.

---

## ⚠️ 2차 인용으로만 확인 (1차 직접 검증 실패 — 표기 주의)

### Peter Steinberger — X 게시물
- **URL(canonical)**: https://x.com/steipete/status/2063697162748260627 — **본문 402로 직접 검증 불가**
- **계정 정체성**: @steipete = OpenClaw 제작자, **현재 OpenAI 소속** (Anthropic 아님)
- **인용(다수 2차 매체 일치)**: "Here's your monthly reminder that you shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents."
- **⚠️ 교정 필요**: "2026-06-08", "650만 조회수"는 **2차 매체 주장이며 원본 미검증**. 정리본이 사실처럼 적은 "650만 조회"는 "2차 매체 주장"으로 격하할 것.
- 보완 2차 매체: Yahoo Tech (`tech.yahoo.com/ai/claude/articles/forget-prompt-engineering-loop-engineering-...`), linas.substack, explainx.ai

### Boris Cherny — "My job is to write loops"
- **매체**: Acquired ("Acquired Unplugged presented by WorkOS") · 영상 https://www.youtube.com/watch?v=RkQQ7WEor7w · 요약 https://workos.com/blog/boris-cherny-claude-code-acquired-interview-takeaways
- **인용(매체별 자구 편차)**: "I don't prompt Claude anymore. I have loops running that prompt Claude... My job is to write loops." ↔ WorkOS는 패러프레이즈("Now he doesn't even prompt Claude directly. He writes loops.")
- **⚠️ 날짜 충돌**: WorkOS 글 게시 2026-06-02 vs note.com 에피소드 표기 2026-06-09 → **에피소드 날짜 미확정**. "write loops" vs "write the loop" 자구도 매체별 편차 → verbatim 단정 피할 것.

---

## 위키 반영 시 교정 체크리스트
- [ ] Steinberger "650만 조회수" → "(2차 매체 주장, 원본 미검증)" 단서
- [ ] Steinberger 소속 = OpenAI (Anthropic 표기 금지)
- [ ] Cherny 발화 날짜 = "2026-06 Acquired (게시 06-02 / 에피소드 날짜 미확정)"
- [ ] Sonar "A failing build is a fact" = "...; an opinion is a starting point"와 한 쌍임 인지
- [ ] Osmani 글이 용어의 명명 1차 출처 — URL 직접 접근 가능
