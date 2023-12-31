! RUN: llvm-mc %s -triple=sparc   -show-encoding | FileCheck %s --check-prefixes=CHECK,V8
! RUN: llvm-mc %s -triple=sparcv9 -show-encoding | FileCheck %s --check-prefixes=CHECK,V9

        ! CHECK: rd %y, %i0            ! encoding: [0xb1,0x40,0x00,0x00]
        rd %y, %i0

        ! CHECK: rd %asr1, %i0         ! encoding: [0xb1,0x40,0x40,0x00]
        rd %asr1, %i0

        ! CHECK: wr %i0, 5, %y         ! encoding: [0x81,0x86,0x20,0x05]
        wr %i0, 5, %y

        ! CHECK: wr %i0, %i1, %asr15   ! encoding: [0x9f,0x86,0x00,0x19]
        wr %i0, %i1, %asr15

        ! CHECK: rd %asr15, %g0        ! encoding: [0x81,0x43,0xc0,0x00]
        rd %asr15, %g0

        ! CHECK: rd %psr, %i0          ! encoding: [0xb1,0x48,0x00,0x00]
        rd %psr, %i0

        ! CHECK: rd %wim, %i0          ! encoding: [0xb1,0x50,0x00,0x00]
        rd %wim, %i0

        ! CHECK: rd %tbr, %i0          ! encoding: [0xb1,0x58,0x00,0x00]
        rd %tbr, %i0

        ! CHECK: wr %i0, 5, %psr          ! encoding: [0x81,0x8e,0x20,0x05]
        wr %i0, 5, %psr

        ! CHECK: wr %i0, 5, %wim          ! encoding: [0x81,0x96,0x20,0x05]
        wr %i0, 5, %wim

        ! CHECK: wr %i0, 5, %tbr          ! encoding: [0x81,0x9e,0x20,0x05]
        wr %i0, 5, %tbr

        ! CHECK: ld [%g2+20], %fsr     ! encoding: [0xc1,0x08,0xa0,0x14]
        ld [%g2 + 20],%fsr

        ! CHECK: ld [%g2+%i5], %fsr    ! encoding: [0xc1,0x08,0x80,0x1d]
        ld [%g2 + %i5],%fsr

        ! CHECK: st %fsr, [%g2+20]     ! encoding: [0xc1,0x28,0xa0,0x14]
        st %fsr,[%g2 + 20]

        ! CHECK: st %fsr, [%g2+%i5]    ! encoding: [0xc1,0x28,0x80,0x1d]
        st %fsr,[%g2 + %i5]

        ! CHECK: std %fq, [%g6+%i2]    ! encoding: [0xc1,0x31,0x80,0x1a]
        std %fq, [%g6 + %i2]

!! Those instructions are processed differently on V8 and V9.

! V8: rd %asr2, %i0         ! encoding: [0xb1,0x40,0x80,0x00]
! V9: rd %ccr, %i0          ! encoding: [0xb1,0x40,0x80,0x00]
rd %asr2, %i0
! V8: wr %i0, 7, %asr2      ! encoding: [0x85,0x86,0x20,0x07]
! V9: wr %i0, 7, %ccr       ! encoding: [0x85,0x86,0x20,0x07]
wr %i0, 7, %asr2

! V8: rd %asr3, %i0         ! encoding: [0xb1,0x40,0xc0,0x00]
! V9: rd %asi, %i0          ! encoding: [0xb1,0x40,0xc0,0x00]
rd %asr3, %i0
! V8: wr %i0, 7, %asr3      ! encoding: [0x87,0x86,0x20,0x07]
! V9: wr %i0, 7, %asi       ! encoding: [0x87,0x86,0x20,0x07]
wr %i0, 7, %asr3

! V8: rd %asr4, %i0         ! encoding: [0xb1,0x41,0x00,0x00]
! V9: rd %tick, %i0         ! encoding: [0xb1,0x41,0x00,0x00]
rd %asr4, %i0
! V8: wr %i0, 7, %asr4      ! encoding: [0x89,0x86,0x20,0x07]
! V9: wr %i0, 7, %tick      ! encoding: [0x89,0x86,0x20,0x07]
wr %i0, 7, %asr4

! V8: rd %asr5, %i0         ! encoding: [0xb1,0x41,0x40,0x00]
! V9: rd %pc, %i0           ! encoding: [0xb1,0x41,0x40,0x00]
rd %asr5, %i0
! V8: wr %i0, 7, %asr5      ! encoding: [0x8b,0x86,0x20,0x07]
! V9: wr %i0, 7, %pc        ! encoding: [0x8b,0x86,0x20,0x07]
wr %i0, 7, %asr5

! V8: rd %asr6, %i0         ! encoding: [0xb1,0x41,0x80,0x00]
! V9: rd %fprs, %i0         ! encoding: [0xb1,0x41,0x80,0x00]
rd %asr6, %i0
! V8: wr %i0, 7, %asr6      ! encoding: [0x8d,0x86,0x20,0x07]
! V9: wr %i0, 7, %fprs      ! encoding: [0x8d,0x86,0x20,0x07]
wr %i0, 7, %asr6

!! Alternate names for %asr2-%asr6 are only for V9.
!! TODO: make sure that using alternate names returns
!! an error on V8 (currently it doesn't, see SparcRegisterInfo.td).

! V9: rd %ccr, %i0          ! encoding: [0xb1,0x40,0x80,0x00]
rd %ccr, %i0
! V9: wr %i0, 7, %ccr       ! encoding: [0x85,0x86,0x20,0x07]
wr %i0, 7, %ccr

! V9: rd %asi, %i0          ! encoding: [0xb1,0x40,0xc0,0x00]
rd %asi, %i0
! V9: wr %i0, 7, %asi       ! encoding: [0x87,0x86,0x20,0x07]
wr %i0, 7, %asi

! V9: rd %tick, %i0         ! encoding: [0xb1,0x41,0x00,0x00]
rd %tick, %i0
! V9: wr %i0, 7, %tick      ! encoding: [0x89,0x86,0x20,0x07]
wr %i0, 7, %tick

! V9: rd %pc, %i0           ! encoding: [0xb1,0x41,0x40,0x00]
rd %pc, %i0
! V9: wr %i0, 7, %pc        ! encoding: [0x8b,0x86,0x20,0x07]
wr %i0, 7, %pc

! V9: rd %fprs, %i0         ! encoding: [0xb1,0x41,0x80,0x00]
rd %fprs, %i0
! V9: wr %i0, 7, %fprs      ! encoding: [0x8d,0x86,0x20,0x07]
wr %i0, 7, %fprs
