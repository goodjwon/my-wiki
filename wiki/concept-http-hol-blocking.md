---
title: HTTP 진화와 HOL 블로킹 (1.1 → 2 → 3/QUIC)
type: concept
tags: [http, networking, protocol, quic, hol-blocking, tcp, udp, performance]
sources:
  - ai-engineering/2bun-coding/http-evolution-quic.md
external:
  - https://www.youtube.com/watch?v=RZTsrCjpoZc
  - https://www.rfc-editor.org/rfc/rfc9114.html
  - https://www.rfc-editor.org/rfc/rfc9000.html
created: 2026-06-06
updated: 2026-09-28
---

# HTTP 진화와 HOL 블로킹 — 1.1 → 2 → 3/QUIC

## 한 줄 요약

HTTP의 세 차례 재설계는 모두 **같은 문제(HOL 블로킹)** 를 해결하기 위해 **네트워크 계층을 한 단계씩 내려간** 역사입니다. 애플리케이션 → 전송 계층 → 결국 UDP 위에 QUIC을 새로 쌓아 올렸습니다.

## HOL 블로킹이란

**H**ead-**o**f-**L**ine Blocking — 줄(line)의 **맨 앞(head)** 요청이 늦어지면 그 뒤가 전부 대기하는 현상입니다. 큐 형태 처리의 본질적 함정입니다.

## 3세대 비교표

| 버전 | 출시 | 동시 처리 방식 | HOL 발생 위치 | 우회 방법 |
|------|------|------------|------------|----------|
| **HTTP/1.0** | 1996 | 매 요청마다 TCP handshake | 매 요청 시점 | — |
| **HTTP/1.1** | 1997 | Keep-Alive (커넥션 재사용) | **응용 레벨** — 한 커넥션에서 순서 강제 | 브라우저: 서버당 6개 커넥션 동시 |
| **HTTP/2** | 2015 | 멀티플렉싱 (한 TCP에 여러 stream) | **TCP 레벨** — 패킷 1개 유실하면 모든 stream 대기 | (해결 못 함) |
| **HTTP/3** | 2022 | QUIC over UDP, stream별 독립 패킷 관리 | (해결됨) | UDP 차단 환경에선 HTTP/2 fallback |

## 1.1: Keep-Alive와 첫 HOL

```
[클라이언트]                  [서버]
  ── GET /index.html ──►
  ◄── 200 OK (10s 걸림) ──    (이 10초 동안 ↓ 못 보냄)
  ── GET /style.css ──►       (대기)
  ◄── 200 OK ──
  ── GET /app.js ──►
```

- 한 커넥션이 곧 한 줄이라 순서가 강제됩니다.
- 첫 응답이 느리면 뒤 요청이 전부 대기하는 HOL이 생깁니다.
- 브라우저는 **도메인당 6개 커넥션**을 열어 우회합니다. CDN 도메인 분리나 sprite 합치기 같은 최적화가 유행했던 이유입니다.

## 2: 멀티플렉싱 (HTTP 레벨 HOL 해결)

```
한 TCP 커넥션 안에:
  stream 1: GET /index.html  ── (느린 응답)
  stream 2: GET /style.css   ── (빠르게 응답 가능)
  stream 3: GET /app.js      ── (빠르게 응답 가능)
```

- HTTP 메시지를 stream + frame 단위로 분해해 **다중화**합니다.
- 응답이 다른 순서로 와도 클라이언트가 frame 식별자로 재조립합니다.
- **애플리케이션 레벨 HOL이 사라집니다** ✅

### 그런데 TCP 레벨에서 다시 HOL

```
TCP 패킷:  [P1][P2][P3][P4][P5]
                  ↑
                  유실!
TCP: "순서 보장. 재전송될 때까지 P3 이후 패킷 사용자에게 전달 안 함"
→ stream 1, 2, 3 모두 멈춤 (실제로는 stream 1의 패킷만 유실됐는데도)
```

**원인**: TCP는 신뢰성 + 순서 보장이 본질이라, 한 패킷 유실이 **그 커넥션 전체**를 멈추게 합니다. HTTP/2가 한 커넥션에 stream을 묶었기 때문에 더 아픕니다.

→ **HTTP는 다중화했지만 TCP가 따라오지 못했습니다.**

## 3: QUIC (UDP 위 새 전송 계층)

```
QUIC over UDP:
  stream 1: 자기 패킷 시퀀스 관리 ── 유실 시 stream 1만 대기
  stream 2: 자기 패킷 시퀀스 관리 ── 영향 없음 ✅
  stream 3: 자기 패킷 시퀀스 관리 ── 영향 없음 ✅
```

**QUIC의 핵심 결정**은 다음과 같습니다.

- TCP를 버리고 UDP를 베이스로 삼았습니다. UDP는 순서를 보장하지 않으므로 stream 독립성을 확보할 수 있습니다.
- 신뢰성·암호화·혼잡 제어는 QUIC이 직접 구현합니다.
- TLS 1.3을 통합해 1-RTT(또는 0-RTT) 핸드셰이크로 연결합니다.
- **연결 마이그레이션**으로 Wi-Fi ↔ LTE 전환 시에도 연결을 유지합니다 (TCP는 IP가 바뀌면 끊김).

### QUIC의 부수 효과 (보너스)

- TLS 1.3과 핸드셰이크를 통합해 HTTPS 협상이 더 빠릅니다.
- 모바일 네트워크 전환에 강합니다.

## HTTP/3 실무 한계

| 한계 | 영향 |
|------|------|
| **방화벽이 UDP 차단** | 기업 네트워크에서 QUIC 통신 불가 → HTTP/2 fallback 필요 |
| **CPU 비용** | QUIC은 **유저 스페이스(애플리케이션 레벨)** 에서 동작하고 TCP는 커널이 처리하므로, 같은 트래픽에서 CPU 사용량이 늘어납니다 |
| **운영 도구 미성숙** | tcpdump 같은 기존 도구의 QUIC 페이로드 분석 한계 (암호화) |
| **로드밸런서 지원** | 일부 LB의 HTTP/3 미지원 |

### 실무 권장

대부분의 운영 서버는 **HTTP/2와 HTTP/3를 동시에 활성화**합니다. 클라이언트가 가능하면 HTTP/3, 안 되면 HTTP/2로 자동 협상합니다. Cloudflare, AWS CloudFront, Fastly, Nginx 등이 표준으로 지원합니다.

Cloudflare에서는 대시보드 → Network → HTTP/3 (with QUIC) → ON으로 활성화합니다.

## 같은 인사이트 패턴 — "한 계층의 해결이 다음 계층 문제를 드러낸다"

| 영역 | 해결한 곳 | 새로 드러난 문제 | 다음 해결 |
|------|---------|----------------|----------|
| HTTP/2 멀티플렉싱 | HTTP 레벨 HOL | TCP 레벨 HOL | HTTP/3 = QUIC over UDP |
| DB 커넥션 풀 | TCP 핸드셰이크 비용 | 좀비 커넥션 ([[concept-db-connection-pool]]) | `maxLifetime` < 인프라 idle 제한 + `keepaliveTime` |
| Keep-Alive ([[concept-keepalive-timeout-race]]) | 커넥션 재사용 | 타임아웃 불일치 → 502 | 서버 > LB |

→ **추상화는 한 층 위의 문제를 풀지만, 한 층 아래의 가정도 함께 바꿔야 진짜 해결**됩니다.

## Spring Boot에서 HTTP/2·HTTP/3

HTTP/3는 보통 Spring Boot 자체보다 앞단(LB·CDN)에서 종단 처리합니다. HTTP/2는 Spring Boot가 속성 하나로 지원합니다.

```yaml
server:
  http2:
    enabled: true       # HTTP/2 활성화
  ssl:
    enabled: true       # HTTP/2 사실상 TLS 필수
```

HTTP/3는 Spring Boot 4.1 기준으로도 `server.http3.*` 같은 설정 속성이 없고, 기본 서블릿 서버인 Tomcat 11도 HTTP/3를 지원하지 않습니다. WebFlux + Reactor Netty 조합에서만 가능하며, `io.netty:netty-codec-native-quic` 의존성을 추가하고 `WebServerFactoryCustomizer<NettyReactiveWebServerFactory>`에서 `HttpProtocol.HTTP3`와 SSL을 직접 설정해야 합니다. Reactor Netty 1.2(Spring Boot 3.4)에서 실험적 기능으로 들어왔고, 1.3(Spring Boot 4.x) 레퍼런스에는 정식 HTTP/3 장으로 수록되어 있습니다. 운영에서는 일반적으로 Cloudflare·Nginx·Envoy를 앞에 두고, 그쪽에서 HTTP/3를 받아 백엔드와는 HTTP/2로 통신합니다.

## 빠른 진단 — 우리 사이트는 어느 버전 쓰나

브라우저에서는 다음처럼 확인합니다.

- **Chrome DevTools** → Network 탭 → 헤더 우클릭 → Protocol 컬럼 추가
  - `h2` = HTTP/2, `h3` = HTTP/3

명령줄에서는 다음 명령을 씁니다.
```bash
curl --http3 -I https://example.com 2>&1 | head -5
# 또는
nghttp -nv --version=h3 https://example.com
```

## 원본 출처

- raw: `raw/ai-engineering/2bun-coding/http-evolution-quic.md`
- 외부: [2분코딩 — 왜 HTTP는 세 번이나 다시 만들어졌을까요?](https://www.youtube.com/watch?v=RZTsrCjpoZc)
- RFC: [RFC 9114 — HTTP/3](https://www.rfc-editor.org/rfc/rfc9114.html) · [RFC 9000 — QUIC](https://www.rfc-editor.org/rfc/rfc9000.html)
- Spring Boot 공식: [Embedded Web Servers — HTTP/2](https://docs.spring.io/spring-boot/how-to/webserver.html) — 4.1 문서 기준 HTTP/3 설정 항목 없음
- Spring 블로그: [HTTP/3 support in Reactor 2024.0](https://spring.io/blog/2024/11/26/http3-in-reactor-2024/) — Reactor Netty 1.2 실험적 지원, 커스터마이저 설정 예시
- Reactor Netty 공식: [HTTP Server — HTTP/3](https://projectreactor.io/docs/netty/release/reference/http-server.html) — 1.3 기준 의존성 `netty-codec-native-quic`

## 관련 페이지

- [[concept-keepalive-timeout-race]] — LB↔서버 Keep-Alive 불일치 (TCP·HTTP 위에서 발생)
- [[concept-db-connection-pool]] — 같은 "연결 재사용 비용" 메커니즘
- [[src-java-study-2024-2025]] — Ch10 입출력과 네트워크
- [[src-spring-web-mvc-ref]] — Spring Web 위에서 HTTP 운영 맥락
- [[concept-claude-md]] — 인프라 의사결정 시 STOP 트리거 후보
