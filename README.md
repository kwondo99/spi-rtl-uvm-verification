# SPI Protocol Design & UVM Verification

SPI(Serial Peripheral Interface) Protocol을 RTL로 설계하고, **UVM 기반 검증 환경**을 구축하여 **Scoreboard**와 **Coverage**를 통해 동작을 검증한 프로젝트입니다.
SPI **Master**와 **Slave**를 각각 독립적인 UVM 환경으로 검증하였습니다.

---

## Overview

SPI Master/Slave를 직접 설계하고, UVM으로 각각 검증합니다.
- **SPI Master** : CPOL/CPHA 조합에 따른 4가지 동작 Mode(Mode 0~3) 전체 검증
- **SPI Slave** : Mode 0 (CPOL=0, CPHA=0) 지원 및 검증

각 DUT마다 가상의 상대(BFM)를 driver로 생성하여 독립적으로 검증하며,
Scoreboard로 송수신 데이터의 정확성을, Coverage로 검증 범위를 측정합니다.

| 항목 | 내용 |
|:---:|:---|
| 설계 대상 | SPI Master / SPI Slave RTL |
| 통신 방식 | Full-duplex 동기식 직렬 통신 (SCLK, MOSI, MISO, SS_n) |
| Master 지원 Mode | Mode 0~3 (CPOL/CPHA 4개 조합) |
| Slave 지원 Mode | Mode 0 (CPOL=0, CPHA=0) |
| 검증 방법 | UVM (Master / Slave 독립 검증) |
| 검증 지표 | Scoreboard (정확성), Coverage (검증 범위) |

---

## Goals

SPI Protocol(Master/Slave)을 설계하고, UVM 기반 검증 환경을 구축하여 Scoreboard와 Coverage를 통해 동작을 검증한다.

- SPI Master/Slave Protocol RTL 설계
- UVM 기반 재사용 가능한 검증 환경 구축
- Master / Slave를 각각 독립 DUT로 검증 (상대측은 가상으로 모델링)
- Scoreboard로 송수신 데이터·클럭 동작의 정확성 검증
- Coverage로 Mode·데이터 패턴·clk_div 등 검증 범위 확인

---

## SPI Protocol

4개의 신호선을 이용해 마스터와 슬레이브 간 데이터를 동시에 주고받는(full-duplex) 동기식 직렬 통신 프로토콜입니다.

| 핀 | 신호 방향 | 역할 |
|:---:|:---:|:---|
| SCLK | Master → Slave | 통신 타이밍 동기화 클럭 |
| MOSI | Master → Slave | 마스터 → 슬레이브 데이터 (Master Out Slave In) |
| MISO | Slave → Master | 슬레이브 → 마스터 데이터 (Master In Slave Out) |
| SS_n | Master → Slave | 슬레이브 선택 신호 (Active Low) |

### 설정 파라미터

| 파라미터 | 값 | 동작 |
|:---:|:---:|:---|
| CPOL | 0 / 1 | Idle 시 SCLK 레벨 (0=Low, 1=High) |
| CPHA | 0 / 1 | 데이터 샘플링 엣지 (0=첫 엣지, 1=두 번째 엣지) |
| clk_div | 0~255 | 시스템 클럭 분주값 (SCLK 주파수 제어) |

### SPI Operating Modes

| Mode | CPOL | CPHA | 지원 |
|:---:|:---:|:---:|:---:|
| 0 | 0 | 0 | Master ✅ / Slave ✅ |
| 1 | 0 | 1 | Master ✅ |
| 2 | 1 | 0 | Master ✅ |
| 3 | 1 | 1 | Master ✅ |

---

## UVM Verification Environment

| 컴포넌트 | 역할 |
|:---:|:---|
| Sequence | 테스트 시나리오(자극) 생성 |
| Sequencer | Sequence와 Driver 사이 트랜잭션 전달 |
| Driver | 트랜잭션을 신호로 변환하여 DUT에 인가 |
| Monitor | DUT 신호를 관찰·수집하여 트랜잭션으로 복원 |
| Scoreboard | 기댓값과 실제값을 비교하여 정확성 검증 |
| Coverage | 검증된 시나리오·조건을 측정하여 검증 범위 확인 |
| Agent / Env | 컴포넌트를 묶어 검증 환경 구성 |

---

## SPI Master Verification

Master를 DUT로 두고, Driver가 `fork...join`으로 **master 자극**과 **가상 slave 응답(MISO)** 을 동시에 생성합니다.
가상 slave는 SPI Mode(CPOL/CPHA)에 따라 MISO 데이터 인가 시점을 다르게 처리합니다.

### Test Scenario (Mode별 102 트랜잭션)

| 순서 | 테스트 목표 | CPOL, CPHA | 데이터 조건 | 횟수 |
|:---:|:---:|:---:|:---:|:---:|
| Step 1 | Mode 0 검증 | 0, 0 | 고정(00, FF) + 랜덤 | 102 |
| Step 2 | Mode 1 검증 | 0, 1 | 고정(00, FF) + 랜덤 | 102 |
| Step 3 | Mode 2 검증 | 1, 0 | 고정(00, FF) + 랜덤 | 102 |
| Step 4 | Mode 3 검증 | 1, 1 | 고정(00, FF) + 랜덤 | 102 |

### Scoreboard 비교 항목

| 비교 항목 | 비교 조건 | 검증 목적 |
|:---:|:---:|:---|
| sclk 엣지 개수 | `sclk_edge == 8` | 1바이트 전송에 8 클럭 토글 확인 |
| MOSI 데이터 | `mosi[7:0] == tx_data` | 송신 데이터가 라인에 올바르게 실렸는지 |
| MISO 데이터 | `miso[7:0] == rx_data` | slave 응답이 정상 수신되었는지 |
| sclk idle 레벨 | `sclk_idle == cpol` | Idle SCLK 레벨이 CPOL과 일치하는지 |

### Coverage Bin

- `cx_mode` : 4가지 통신 모드가 누락 없이 실행되었는지
- `cx_mode_master_tx` : 각 모드에서 master 송신 패턴(00, FF, Random) 균등 생성 여부
- `cx_mode_slave_tx` : 각 모드에서 가상 slave 패턴(00, FF, Random) 균등 생성 여부
- `cp_clk_div` : clk_div 균등 생성 여부

---

## SPI Slave Verification

Slave를 DUT로 두고, Driver가 **가상 master 신호(sclk, mosi, ss_n)** 를 직접 생성합니다.
**Mode 0 (CPOL=0, CPHA=0)** 만 지원하며, 고정 `CLK_DIV = 4`로 클럭 delay를 정의합니다.

### Test Scenario (총 102 트랜잭션)

| 순서 | 테스트 목표 | 데이터 조건 | 횟수 |
|:---:|:---:|:---:|:---:|
| Step 1 | All-0 패턴 검증 | 고정 `8'h00` | 1 |
| Step 2 | All-1 패턴 검증 | 고정 `8'hFF` | 1 |
| Step 3 | 랜덤 데이터 검증 | 랜덤 | 100 |

### Monitor 수집 항목

| 수집 항목 | 신호/소스 | 수집 방식 |
|:---:|:---:|:---|
| tx_data | DUT의 tx_data | slave 송신 값 캡처 (전송 시작 시) |
| rx_data | DUT의 rx_data | slave 수신 값 캡처 (wait(done) 이후) |
| master_tx_data | mosi | 가상 master가 보낸 8비트 수신 데이터 |
| slave_tx_data | miso | slave가 내보낸 8비트 송신 데이터 |

### Scoreboard 비교 항목

| 비교 항목 | 비교 조건 | 검증 목적 |
|:---:|:---:|:---|
| MISO 데이터 | `tx_data == slave_tx_data` | slave tx_data가 정상 송신되었는지 |
| MOSI 데이터 | `rx_data == master_tx_data` | 가상 master 송신 데이터가 정상 수신되었는지 |

### Coverage Bin

- `cp_master_tx` : 가상 master 송신 패턴(00, FF, Random) 균등 생성 여부
- `cp_slave_tx` : slave 송신 패턴(00, FF, Random) 균등 생성 여부

---

## Directory Structure

```
.
├── README.md
├── spi_master
|   ├── Makefile
│   ├── rtl
│   │   └── spi_master.sv
│   └── tb
│       ├── spi_master_agent.sv
│       ├── spi_master_coverage.sv
│       ├── spi_master_driver.sv
│       ├── spi_master_env.sv
│       ├── spi_master_interface.sv
│       ├── spi_master_monitor.sv
│       ├── spi_master_pkg.sv
│       ├── spi_master_scoreboard.sv
│       ├── spi_master_sequence.sv
│       ├── spi_master_template.sv
│       ├── spi_master_test.sv
│       ├── spi_seq_item.sv
│       └── tb_spi_master.sv
└── spi_slave
    ├── Makefile
    ├── rtl
    │   └── spi_slave.sv
    └── tb
        ├── spi_seq_item.sv
        ├── spi_slave_agent.sv
        ├── spi_slave_coverage.sv
        ├── spi_slave_driver.sv
        ├── spi_slave_env.sv
        ├── spi_slave_interface.sv
        ├── spi_slave_monitor.sv
        ├── spi_slave_pkg.sv
        ├── spi_slave_scoreboard.sv
        ├── spi_slave_sequence.sv
        ├── spi_slave_template.sv
        ├── spi_slave_test.sv
        └── tb_spi_slave.sv
└── docs
     └── 260617_UVM_SPI_I2C_Verification_권동오.pptx
```

---

## How to Run

```bash
# 시뮬레이션 실행 (VCS)
make all

# Coverage 리포트 생성
make coverage
```

---
## 고찰

UVM 기반 검증의 전체 흐름(Sequence → Driver → Monitor → Scoreboard 구조)을 익혔다.

Coverage의 정의와 작성법(coverpoint, cross)을 배웠다.

Factory 개념을 이해하여 컴포넌트의 생성·재정의 방식을 익혔다.

Phase 개념(build_phase, connect_phase, run_phase)을 이해했다.

UVM 구조와 Factory 개념이 처음에는 복잡했지만, 반복 실습을 통해 디버깅과 재사용 측면에서 효율적임을 체감했다.

Phase 개념이 익숙해지니 각 컴포넌트가 언제 무엇을 수행해야 하는지 명확해져 전체 흐름을 잡기 수월했다.

Port의 종류와 연결 방식은 아직 더 익숙해질 시간이 필요하다고 느꼈다.

## Author

- 권동오
- 2026.06
