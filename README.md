# SPI Protocol Design & UVM Verification

SPI(Serial Peripheral Interface) Protocol을 RTL로 설계하고, **UVM 기반 검증 환경**을 구축하여 **Scoreboard**와 **Coverage**를 통해 동작을 검증한 프로젝트입니다.

---

## Overview

SPI Master/Slave를 직접 설계하고, CPOL/CPHA 조합에 따른 4가지 동작 Mode를 UVM으로 검증합니다.
Scoreboard로 송수신 데이터의 정확성을 확인하고, Coverage로 검증 범위를 측정합니다.

| 항목 | 내용 |
|:---:|:---|
| 설계 대상 | SPI Master / SPI Slave RTL |
| 지원 Mode | Mode 0~3 (CPOL/CPHA 4개 조합) |
| 검증 방법 | UVM (Universal Verification Methodology) |
| 검증 지표 | Scoreboard (정확성), Coverage (검증 범위) |

---

## Goals

- SPI Master/Slave Protocol을 RTL로 설계 (4개 동작 Mode 지원)
- UVM 기반 재사용 가능한 검증 환경 구축
- Scoreboard로 송수신 데이터 및 클럭 동작의 기능 정확성 검증
- Coverage로 Mode·데이터 패턴 등 검증 범위 확인

---

## SPI Operating Modes

| Mode | CPOL | CPHA | 데이터 인가/샘플링 시점 |
|:---:|:---:|:---:|:---|
| 0 | 0 | 0 | Idle Low, 첫 엣지(rising)에서 샘플 |
| 1 | 0 | 1 | Idle Low, 두 번째 엣지(falling)에서 샘플 |
| 2 | 1 | 0 | Idle High, 첫 엣지(falling)에서 샘플 |
| 3 | 1 | 1 | Idle High, 두 번째 엣지(rising)에서 샘플 |

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

### Scoreboard 비교 항목

| 비교 항목 | 비교 조건 |
|:---:|:---:|
| sclk 엣지 개수 | `== 8` |
| MOSI 데이터 | `mosi[7:0] == tx_data` |
| MISO 데이터 | `miso[7:0] == rx_data` |
| sclk idle 레벨 | `sclk_idle == cpol` |

### Coverage 항목

- **Mode coverage** : CPOL/CPHA 4개 조합 검증 여부
- **Data coverage** : tx_data 패턴 (0x00, 0xFF, 랜덤) 커버 여부
- **clk_div coverage** : 다양한 클럭 분주값 검증 여부

---

## Test Scenario

각 Mode별로 아래 시퀀스를 수행합니다. (총 102 트랜잭션 / Mode)

| 순서 | 시나리오 | 데이터 | 횟수 |
|:---:|:---:|:---:|:---:|
| 1 | All-0 패턴 | `8'h00` 고정 | 1 |
| 2 | All-1 패턴 | `8'hFF` 고정 | 1 |
| 3 | 랜덤 패턴 | randomize | 100 |

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

```

---

## 🚀 How to Run

```bash
# 시뮬레이션 실행 (VCS)
make all

# Coverage 리포트 생성
make coverage
```

---

## ✍️ Author

- 작성자: (이름 입력)
- 작성일: 2026
