/****************************************************************************
 *                                                                          *
 *               GNU ADA RUN-TIME LIBRARY (GNARL) COMPONENTS                *
 *                                                                          *
 *                                  C R T 0                                 *
 *                                                                          *
 *                               Assembly File                              *
 *                                                                          *
 *                      Copyright (C) 2011-2012 AdaCore                     *
 *                                                                          *
 * GNAT is free software;  you can  redistribute it  and/or modify it under *
 * terms of the  GNU General Public License as published  by the Free Soft- *
 * ware  Foundation;  either version 2,  or (at your option) any later ver- *
 * sion.  GNAT is distributed in the hope that it will be useful, but WITH- *
 * OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY *
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License *
 * for  more details.  You should have  received  a copy of the GNU General *
 * Public License  distributed with GNAT;  see file COPYING.  If not, write *
 * to  the Free Software Foundation,  59 Temple Place - Suite 330,  Boston, *
 * MA 02111-1307, USA.                                                      *
 *                                                                          *
 * As a  special  exception,  if you  link  this file  with other  files to *
 * produce an executable,  this file does not by itself cause the resulting *
 * executable to be covered by the GNU General Public License. This except- *
 * ion does not  however invalidate  any other reasons  why the  executable *
 * file might be covered by the  GNU Public License.                        *
 *                                                                          *
 ****************************************************************************/

/* This file is specific to the Hercules ARM Cortex-R5F Microcontrollers,
   such as the TMS570. */

/* This file contains the trap table and start up code for the multitasking
   executive implemented for bareboard targets. */

/* Startup code */
	.global start_flash
	.section .traps

	/* The following provide default definitions for trap vectors that
	loop back to the trap address, so the system will stop in a safe
	state. The Ravenscar runtimes now can install their handlers by simply
	exporting the relevant symbols. */

	.weak	__gnat_undef_trap	/* Undefined instruction trap */
	.weak	__gnat_svc_trap		/* Supervisor call trap */
	.weak	__gnat_pabt_trap	/* prefetch abort trap	*/
	.weak	__gnat_dabt_trap	/* data abort trap */

/* 0 */	b	start_flash
__gnat_undef_trap:	/* 4 */
	b	__gnat_undef_trap	/* Undefined instruction trap */
__gnat_svc_trap:	/* 8 */
	b	__gnat_svc_trap		/* Supervisor call trap */
__gnat_pabt_trap:	/* c */
	b	__gnat_pabt_trap	/* prefetch abort trap	*/
__gnat_dabt_trap:	/* 10 */
	b	L__dabt_trap		/* data abort trap */
	b       __phantom_irq	        /* 14 */
	ldr	pc,[pc,#-0x1b0]         /* IRQ, jump to IRQVECREG, 16#ffff_fe70# */
	ldr	pc,[pc,#-0x1b0]         /* FIQ, jump to FIQVECREG, 16#ffff_fe74# */

@-------------------------------------------------------------------------------
	.text
svcSp  :	.word __svc_stack_end
abortSp:	.word __abort_stack_end
undefSp:	.word __undef_stack_end
fiqSp  :	.word __fiq_stack_end
irqSp  :	.word __irq_stack_end
userSp :	.word __stack_end

@-------------------------------------------------------------------------------
SYS_EXCEPTION          : .word 0xffffffe4
SYS_POWERON_RESET      : .word 0x8000    /* Power On Reset     */
SYS_OSC_FAILURE_RESET  : .word 0x4000    /* Osc Failure Reset  */
SYS_WATCHDOG_RESET     : .word 0x2000    /* Watch Dog Reset    */
SYS_WATCHDOG2_RESET    : .word 0x1000    /* Watch Dog 2 Reset  */
SYS_DEBUG_RESET        : .word 0x0800    /* Debug Reset        */
SYS_INTERCONNECT_RESET : .word 0x0080    /* Interconnect Reset */
SYS_CPU1_RESET         : .word 0x0040    /* CPU 1 Reset        */
SYS_CPU0_RESET         : .word 0x0020    /* CPU 0 Reset        */
SYS_SW_RESET           : .word 0x0010    /* Software Reset     */
SYS_EXT_RESET          : .word 0x0008    /* External Reset     */
SYS_NO_RESET           : .word 0x0000    /* No Reset           */

FEDACCTRL1             : .word 0xfff87008
FEDACCTRL1_INITVAL     : .word 0x000a060A

@-------------------------------------------------------------------------------

	.type start_flash,%function
start_flash:
	/* See Application Report SPNA106D - May 2013
	   Initialization of Hercules(TM) ARM(R) Cortex(TM)-R4F
	   Microcontrollers. */

	/* Reset handler: the following instructions read from the system exception
           status register to identify the cause of the CPU reset.  */
        ldr r0, SYS_EXCEPTION
        ldr r1, [r0]
        ldr r2, SYS_OSC_FAILURE_RESET
        ldr r3, SYS_WATCHDOG_RESET
        orr r2, r2, r3
        ldr r3, SYS_SW_RESET
        orr r2, r2, r3
        tst r1, r2
        bne _other_resets

	/* Reset handler: Cold reset */
        ldr r2, SYS_POWERON_RESET
        ldr r3, SYS_DEBUG_RESET
        orr r2, r2, r3
        ldr r3, SYS_EXT_RESET
        orr r2, r2, r3
        tst r1, r2
        bne _cold_reset

	/* Reset Handler : CPU0 / CPU1 resets and other resets */
	/* Enable Floating-Point Coprocessor  */
	bl	L_coreEnableVfp

        /* Initialize Core Registers to avoid CCM Error and stack pointers */
        bl	L_coreInitRegisters

        /* Enable CPU Event Export. This allows the CPU to signal any
           single-bit or double-bit errors detected by its ECC logic for
           accesses to program flash or data RAM.  */
        bl	L_coreEnableEventBusExport

        b	_other_resets

_cold_reset:
	/* Initialize L2RAM to avoid ECC errors right after power on */
        bl      L_memInit

	/* Enable Floating-Point Coprocessor  */
	bl	L_coreEnableVfp

        /* Initialize Core Registers to avoid CCM Error and stack pointers */
        bl	L_coreInitRegisters

        /* Enable response to ECC errors indicated by CPU for accesses
           to flash */
        ldr r0, FEDACCTRL1
        ldr r1, FEDACCTRL1_INITVAL
        str r1, [r0]

        /* Enable CPU Event Export. This allows the CPU to signal any
           single-bit or double-bit errors detected by its ECC logic for
           accesses to program flash or data RAM.  */
        bl	L_coreEnableEventBusExport

        /* Enable CPU ECC checking for ATCM (flash accesses) */
        mrc   p15, #0x00, r0,         c1, c0,  #0x01
        orr   r0,  r0,    #0x1<<25
        dmb
        mcr   p15, #0x00, r0,         c1, c0,  #0x01
        isb

	/* Initialize System - Clock, Flash settings with Efuse self check */
        bl      _ada_system_init

	/* Enable IRQ offset via Vic controller */
        bl	L_coreEnableIrqVicOffset

	/* Initialize the VIM Table */
        bl      L_init_vim_ram

	/* Configure system response to error conditions signaled to the ESM group1  */
	bl	_ada_esm_init

_other_resets:
	/* Initialize the MPU and the cache  */
        bl	L_mpuInit
        bl	L_cacheEnable

	/* Copy .data */
	movw	r0,#:lower16:__data_start
	movt	r0,#:upper16:__data_start
	movw	r1,#:lower16:__data_words
	movt	r1,#:upper16:__data_words
	movw	r2,#:lower16:__data_load
	movt	r2,#:upper16:__data_load
	cmp	r1,#0
	beq	1f
0:	ldr	r4,[r2],#4
	str	r4,[r0],#4
	subs	r1,r1,#1
	bne	0b
1:

	/* Clear .bss */
	movw	r0,#:lower16:__bss_start
	movt	r0,#:upper16:__bss_start
	movw	r1,#:lower16:__bss_words /* Must be less than 64K words */
	mov	r2,#0
	cmp	r1,#0
	beq	1f
0:	str	r2,[r0],#4
	subs	r1,r1,#1
	bne	0b

	/* Set system mode */
1:	cps	#31

	/* Call the main routine */
	bl	main

	.size	start_flash, . - start_flash

        /* Fall through in order to halt if main would return ... */
@-------------------------------------------------------------------------------
	.global	__exit
__exit:
	/* Write 0x8000 to SYSECR (16#FFFF_FFE0#) */
        mov	r2, #0x8000
	mvn	r3, #0
        str	r2, [r3, #-31]
	b	__exit

	.size	__exit, . - __exit

@-------------------------------------------------------------------------------
@ Enable VFP Unit
        .global L_coreEnableVfp

L_coreEnableVfp:
	mrc   p15,     #0x00,	   r0,	     c1, c0, #0x02
	orr   r0,      r0,	   #0xF00000
	mcr   p15,     #0x00,	   r0,	     c1, c0, #0x02
	mov   r0,      #0x40000000
	fmxr  fpexc,   r0
	bx    lr
        .size	L_coreEnableVfp, . - L_coreEnableVfp

@-------------------------------------------------------------------------------
@ Initialize CPU Registers

	.globl     L_coreInitRegisters

L_coreInitRegisters:
	/* Start initializing CPU registers, including backed registers for
	   all modes. This is necessary on Cortex R4F to avoid miscompares
	   between the cores running in lockstep, and is a good idea on any
	   system. */

	/* After reset, the CPU is in the Supervisor mode (M = 10011) */
	mov	r0, lr
	mov	r1, #0x0000
	mov	r2, #0x0000
	mov	r3, #0x0000
	mov	r4, #0x0000
	mov	r5, #0x0000
	mov	r6, #0x0000
	mov	r7, #0x0000
	mov	r8, #0x0000
	mov	r9, #0x0000
	mov	r10, #0x0000
	mov	r11, #0x0000
	mov	r12, #0x0000

	ldr	sp, svcSp

	/* Switch to FIQ mode (M = 10001) */
	cps	#17
	mov	r8, #0x0000
	mov	r9, #0x0000
	mov	r10, #0x0000
	mov	r11, #0x0000
	mov	r12, #0x0000

	/* Abort mode */
	cps	#23  /* 10111 */
	ldr	sp, abortSp
	mov	lr, r0

	/* Undefined instruction mode */
	cps	#27  /* 11011 */
	ldr	sp, undefSp
	mov	lr, r0

	/* FIQ mode */
	cps	#17  /* 10001 */
	ldr	sp, fiqSp
	mov	lr, r0

	/* IRQ mode */
	cps	#18  /* 10010 */
	ldr	sp, irqSp
	mov	lr, r0

	/* System mode */
	cps	#31  /* 11111 */
	ldr	sp, userSp	/* SYS mode shared stack with User mode */
	mov	lr, r0

	/* Switch back to Supervisor Mode */
	cps	#19 /* 10011 */
	fmdrr	d0, r1, r1
	fmdrr	d1, r1, r1
	fmdrr	d2, r1, r1
	fmdrr	d3, r1, r1
	fmdrr	d4, r1, r1
	fmdrr	d5, r1, r1
	fmdrr	d6, r1, r1
	fmdrr	d7, r1, r1
	fmdrr	d8, r1, r1
	fmdrr	d9, r1, r1
	fmdrr	d10, r1, r1
	fmdrr	d11, r1, r1
	fmdrr	d12, r1, r1
	fmdrr	d13, r1, r1
	fmdrr	d14, r1, r1
	fmdrr	d15, r1, r1

	/* Synchronize 4-entry call-return stack */
	bl	0f
0:	bl	1f
1:	bl	2f
2:	bl	3f
3:	bx	r0
	.size	L_coreInitRegisters, . - L_coreInitRegisters

@-------------------------------------------------------------------------------
@ Initialize CPU Stack Pointers Registers

	.globl L_coreInitStackPointer
L_coreInitStackPointer:
        cps   #17
        ldr   sp,       fiqSp
        cps   #18
        ldr   sp,       irqSp
        cps   #19
        ldr   sp,       svcSp
        cps   #23
        ldr   sp,       abortSp
        cps   #27
        ldr   sp,       undefSp
        cps   #31
        ldr   sp,       userSp
        bx    lr
        .size	L_coreInitStackPointer, . - L_coreInitStackPointer

@-------------------------------------------------------------------------------
@ Initialize RAM memory

        .globl L_memInit
L_memInit :
	   	ldr   r12, MINITGCR		@ Load MINITGCR register address
	   	mov   r4, #0xA
	   	str   r4, [r12]			@ Enable global memory hardware initialization

	   	ldr   r11,  MSIENA		@ Load MSIENA register address
	   	mov   r4, #0x1			@ Bit position 0 of MSIENA corresponds to SRAM
	   	str   r4, [r11]			@ Enable auto hardware initalisation for SRAM
mloop:						@ Loop till memory hardware initialization comletes
	 	ldr   r5, MSTCGSTAT
	  	ldr   r4, [r5]
		tst   r4, #0x100
	   	beq   mloop

		mov   r4, #5
		str   r4, [r12]			@ Disable global memory hardware initialization
		bx lr
                .size	L_memInit, . - L_memInit

MINITGCR :	.word 0xFFFFFF5C
MSIENA	 :	.word 0xFFFFFF60
MSTCGSTAT:	.word 0xFFFFFF68

@-------------------------------------------------------------------------------
@ Enable Event Bus Export

        .global     L_coreEnableEventBusExport

L_coreEnableEventBusExport:

        stmfd sp!, {r0}
        mrc   p15, #0x00, r0,         c9, c12, #0x00
        orr   r0,  r0,    #0x10
        mcr   p15, #0x00, r0,         c9, c12, #0x00
        ldmfd sp!, {r0}
        bx    lr

        .size	L_coreEnableEventBusExport, . - L_coreEnableEventBusExport

@-------------------------------------------------------------------------------
@ Enable Offset via Vic controller

        .global     L_coreEnableIrqVicOffset

L_coreEnableIrqVicOffset:

        stmfd sp!, {r0}
        mrc   p15, #0, r0,         c1, c0,  #0
        orr   r0,  r0,    #0x01000000
        mcr   p15, #0, r0,         c1, c0,  #0
        ldmfd sp!, {r0}
        bx    lr
        .size	L_coreEnableIrqVicOffset, . - L_coreEnableIrqVicOffset

@-------------------------------------------------------------------------------
@ Initalize Mpu

        .global     L_mpuInit

L_mpuInit:
        stmfd sp!, {r0}
        @ Disable mpu
        mrc   p15, #0, r0, c1, c0, #0
        bic   r0,  r0, #1
        dsb
        mcr   p15, #0, r0, c1, c0, #0
        isb
        @ Disable background region
        mrc   p15, #0, r0,      c1, c0, #0
        bic   r0,  r0, #0x20000
        mcr   p15, #0, r0,      c1, c0, #0
        @ Setup region 1
        mov   r0,  #0
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r1Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0008
        orr   r0,  r0,    #0x1000
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((1 << 15) + (1 << 14) + (1 << 13) + (1 << 12) + (1 << 11) + (1 << 10) + (1 <<  9) + (1 <<  8) + (0x1F << 1) + (1))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 2
        mov   r0,  #1
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r2Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0002
        orr   r0,  r0,    #0x0600
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x15 << 1) + (1))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region
        mov   r0,  #2
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r3Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x000B
        orr   r0,  r0,    #0x1300
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x12 << 1) + (1))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 4
        mov   r0,  #3
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r4Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0010
        orr   r0,  r0,    #0x1300
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (1 << 10) + (1 <<  9) + (1 <<  8) + (0x1A << 1) + (1))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 5
        mov   r0,  #4
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r5Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0000
        orr   r0,  r0,    #0x0300
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((1 << 15) + (1 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x1B << 1) + (1))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 6
        mov   r0,  #5
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r6Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0006
        orr   r0,  r0,    #0x0300
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x1A << 1) + (1))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 7
        mov   r0,  #6
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r7Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0002
        orr   r0,  r0,    #0x1200
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x16 << 1) + (1))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 8
        mov   r0,  #7
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r8Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0010
        orr   r0,  r0,    #0x1200
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x04 << 1) + (0))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 9
        mov   r0,  #8
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r9Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0006
        orr   r0,  r0,    #0x1200
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x04 << 1) + (0))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 10
        mov   r0,  #9
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r10Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x000C
        orr   r0,  r0,    #0x1300
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x04 << 1) + (0))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 11
        mov   r0,  #10
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r11Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0006
        orr   r0,  r0,    #0x0600
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x04 << 1) + (0))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 12
        mov   r0,  #11
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r12Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0006
        orr   r0,  r0,    #0x1600
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x04 << 1) + (0))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 13
        mov   r0,  #12
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r13Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0006
        orr   r0,  r0,    #0x1600
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x04 << 1) + (0))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 14
        mov   r0,  #13
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r14Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0006
        orr   r0,  r0,    #0x1600
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x04 << 1) + (0))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 15
        mov   r0,  #14
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r15Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0006
        orr   r0,  r0,    #0x1600
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x04 << 1) + (0))
        mcr   p15, #0,    r0, c6, c1, #2
        @ Setup region 16
        mov   r0,  #15
        mcr   p15, #0,    r0, c6, c2, #0
        ldr   r0,  r16Base
        mcr   p15, #0,    r0, c6, c1, #0
        mov   r0,  #0x0010
        orr   r0,  r0,    #0x1200
        mcr   p15, #0,    r0, c6, c1, #4
        movw  r0,  #((0 << 15) + (0 << 14) + (0 << 13) + (0 << 12) + (0 << 11) + (0 << 10) + (0 <<  9) + (0 <<  8) + (0x12 << 1) + (1))
        mcr   p15, #0,    r0, c6, c1, #2

        @ Enable mpu
        mrc   p15, #0, r0, c1, c0, #0
        orr   r0,  r0, #1
        dsb
        mcr   p15, #0, r0, c1, c0, #0
        isb
        ldmfd sp!, {r0}
        bx    lr
	.size	L_mpuInit, . - L_mpuInit

r1Base  :  .word 0x00000000
r2Base  :  .word 0x00000000
r3Base  :  .word 0x08000000
r4Base  :  .word 0xF8000000
r5Base  :  .word 0x60000000
r6Base  :  .word 0x80000000
r7Base  :  .word 0xF0000000
r8Base  :  .word 0x00000000
r9Base  :  .word 0x00000000
r10Base :  .word 0x00000000
r11Base :  .word 0x00000000
r12Base :  .word 0x00000000
r13Base :  .word 0x00000000
r14Base :  .word 0x00000000
r15Base :  .word 0x00000000
r16Base :  .word 0xFFF80000

@-------------------------------------------------------------------------------
@ Enable caches

	.global  L_cacheEnable

L_cacheEnable:

        stmfd sp!, {r0-r1}
        mov r0,#0

	MRC   p15, #0, R1, c1, c0, #0 	@ Read System Control Register configuration data
	ORR   R1, R1, #0x1 <<12 	@ instruction cache enable
	ORR   R1, R1, #0x1 <<2 		@ data cache enable
	DSB
	MCR   p15, #0, r0, c15, c5, #0 	@ Invalidate entire data cache
	MCR   p15, #0, r0, c7, c5, #0 	@ Invalidate entire instruction cache
	MCR   p15, #0, R1, c1, c0, #0 	@ enabled cache RAMs
	ISB

	ldmfd sp!, {r0-r1}

	bx	  lr
        .size	L_cacheEnable, . - L_cacheEnable

@-------------------------------------------------------------------------------
@  __phantom_irq

       .global	__phantom_irq

__phantom_irq :
	nop
	b __phantom_irq
        .size	__phantom_irq, . - __phantom_irq

@-------------------------------------------------------------------------------
@  ESM High Interrupt

       .global	__esm_high_irq

__esm_high_irq :
	nop
	b __esm_high_irq
        .size	__esm_high_irq, . - __esm_high_irq

@-------------------------------------------------------------------------------
@  VIM ECC Error IRQ

       .global	__vim_ecc_error_irq

__vim_ecc_error_irq :
        @ Save registers to be used
        stmfd sp!, {r0-r2}

        @ Identify corrupted address
	ldr	r0, VIM_UERRADDR
	ldr	r2, [r0]

        @ Identify the channel number
	ldr	r1, VIM_CHAN_OFFSET
	and	r2, r1
	lsr	r2, #2
	subs	r2,r2,#1
	cmp	r2,#0
	bne	1b
        @ Channel 0 = ESM
	ldr	r0, VIM_RAM_ESM_IRQ
	ldr	r1, =__esm_high_irq
	str	r1, [r0]
        b       cont

1:
	lsl	r2,#2
	ldr	r1, VIM_RAM_ESM_IRQ
	ldr	r0, [r1, r2]
	ldr	r1, =__phantom_irq
	str	r1, [r0]

cont:
        @ Clear ECC Parity flag
	ldr	r0, VIM_ECCSTAT
	mov	r2, #1
	str	r2, [r0]

        @ Disable and enable the highest priority pending channel
	ldr	r0, VIM_FIQINDEX
	ldr	r2, [r0]
	cmp     r2, #0
        beq     cont1
        subs    r2,r2,#1
        b       cont2

cont1:
	ldr	r0, VIM_IRQINDEX
	ldr	r2, [r0]
        subs    r2,r2,#1

cont2:
        @ At this point, r2 store the vector number
	cmp	r2, #0
	bne	vec1

	@ Vector = 0
	ldr	r0, VIM_INTREQ	 @ load the INTREQ register address
	mov	r1, #1
	str	r1, [r0]	 @ clear the INTREQ register

	ldr	r0, ESM_IOFFHR
	ldr	r2, [r0]
        subs    r2,r2,#1
        mov     r1,r2
        lsr     r1,#5
	cmp	r1,#0
	beq	esmgroup1     @ vec 0 .. 31
	cmp	r1,#1
	beq	esmgroup2     @ vec 32 .. 63
	cmp	r1,#2
	beq	esmgroup1_2   @ vec 64 .. 95
	cmp	r1,#4
	beq	esmgroup2_2   @ vec 128 .. 159

	@ All reserved case here
	@ Vec 96 .. 127 and 160 .. 256
	ldr	r0, ESMSR1_REG	        @ load the ESMSR1[0] status register address
	ldr	r2, ESMSR_ERR_CLR
	str	r2, [r0]	        @ clear the ESMSR1[0] register

	ldr	r0, ESMSR2_REG	        @ load the ESMSR1[1] status register address
	ldr	r2, ESMSR_ERR_CLR
	str	r2, [r0]	        @ clear the ESMSR1[1] register

	ldr	r0, ESMSR4_0_REG	@ load the ESMSR4[0] status register address
	ldr	r2, ESMSR_ERR_CLR
	str	r2, [r0]	        @ clear the ESMSR4[0] register

	ldr	r0, ESMSR4_1_REG	@ load the ESMSR4[1] status register address
	ldr	r2, ESMSR_ERR_CLR
	str	r2, [r0]	        @ clear the ESMSR4[1] register

	ldr	r0, ESMSR7_0_REG	@ load the ESMSR7[0] status register address
	ldr	r2, ESMSR_ERR_CLR
	str	r2, [r0]	        @ clear the ESMSR7[0] register

	beq	ecc_err_end

esmgroup1:
        @ Get the channel 0 .. 31
        @ r2 = channel 0 .. 160
        and	r2,#31
        mov	r1,#1
        lsl	r1,r2
	ldr	r0, ESMSR1_REG	 @ load  the ESMSR1 status register address
	str	r1, [r0]	 @ clear the ESMSR1 register
        b	ecc_err_end

esmgroup2:
        @ Get the channel 32 .. 63
        @ r2 = channel 0 .. 160
        subs	r2,r2,#32
        mov	r1,#1
        lsl	r1,r2
	ldr	r0, ESMSR2_REG	 @ load the ESMSR2 status register address
	str	r1, [r0]	 @ clear the ESMSR2 register
        b	ecc_err_end

esmgroup1_2:
        @ Get the channel 64 .. 95
        @ r2 = channel 0 .. 160
        subs	r2,r2,#64
        mov	r1,#1
        lsl	r1,r2
	ldr	r0, ESMSR4_0_REG   @ load the ESMSR4 [0] status register address
	str	r1, [r0]	   @ clear the ESMSR4 [0] register
        b	ecc_err_end

esmgroup2_2:
        @ Get the channel 128 .. 159
        @ r2 = channel 0 .. 160
        subs	r2,r2,#128
        mov	r1,#1
        lsl	r1,r2
	ldr	r0, ESMSR7_0_REG   @ load the ESMSR7 [0] status register address
	str	r1, [r0]	   @ clear the ESMSR7 [0] register
        b	ecc_err_end

        @ Vectors /= 0
        @ r2 = vector number
vec1:
        mov     r1,r2
        lsr     r1,#5
	cmp	r1,#0
	beq	clrmask0
	cmp	r1,#1
	beq	clrmask1
	cmp	r1,#2
	beq	clrmask2

        @ Do the other cases
        @ vec 96 .. 128

        subs	r2,r2,#96
        mov	r1,#1
        lsl	r1,r2
	ldr	r0, VIM_REQMASKCLR3
	str	r1, [r0]
	ldr	r0, VIM_REQMASKSET3
	str	r1, [r0]
        b	ecc_err_end

clrmask0: @ vec 0 .. 31
        and	r2,#31
        mov	r1,#1
        lsl	r1,r2
	ldr	r0, VIM_REQMASKCLR0
	str	r1, [r0]
	ldr	r0, VIM_REQMASKSET0
	str	r1, [r0]
        b	ecc_err_end

clrmask1: @ vec 32 .. 63
        subs	r2,r2,#32
        mov	r1,#1
        lsl	r1,r2
	ldr	r0, VIM_REQMASKCLR1
	str	r1, [r0]
	ldr	r0, VIM_REQMASKSET1
	str	r1, [r0]
        b	ecc_err_end

clrmask2: @ vec 64 .. 95
        subs	r2,r2,#64
        mov	r1,#1
        lsl	r1,r2
	ldr	r0, VIM_REQMASKCLR2
	str	r1, [r0]
	ldr	r0, VIM_REQMASKSET2
	str	r1, [r0]
        b	ecc_err_end

        @ End
ecc_err_end:

	ldmfd sp!, {r0-r2}
	bx	lr
        .size	__vim_ecc_error_irq, . - __vim_ecc_error_irq

ESMSR1_REG:	 .word	0xFFFFF518
ESMSR2_REG:	 .word	0xFFFFF51C
ESMSR3_REG:	 .word	0xFFFFF520
VIM_INTREQ:	 .word	0xFFFFFE20
ESM_IOFFHR:	 .word	0xFFFFF528
ESMSR4_0_REG:	 .word	0xFFFFF558
ESMSR4_1_REG:	 .word	0xFFFFF55C
ESMSR4_2_REG:	 .word	0xFFFFF560
ESMSR7_0_REG:	 .word	0xFFFFF598
ESMSR7_1_REG:	 .word	0xFFFFF59C
ESMSR7_2_REG:	 .word	0xFFFFF5A0
ESMSR_ERR_CLR:   .word	0xFFFFFFFF

@-------------------------------------------------------------------------------
@  Initialize VIM

       .global	L_init_vim_ram

L_init_vim_ram :
        @ Save registers to be used
        stmfd sp!, {r0-r2}

        @ Enable ECC for VIM_Parity RAM
        @ Errata VIM#28 Workaround: Disable Single Bit error correction

	ldr	r0, VIM_ECCCTL
	ldr	r2, VIM_ECCCTL_DIS
	str	r2, [r0]

        @ Initialize the VIM RAM
        @ Initialize the Phantom interrupt
	ldr	r0, VIM_RAM_BASE
	ldr	r2, =__phantom_irq
	str	r2, [r0]

        @ Initialize the channel_0
	ldr	r0, VIM_RAM_ESM_IRQ
	ldr	r2, =__esm_high_irq
	str	r2, [r0]

        @ Initialize the channel_1 .. channel_126
	ldr	r0, VIM_RAM_IRQ
	mov	r1,#125
	ldr	r2, =__phantom_irq
	cmp	r1,#0
	beq	1f

0:	str	r2,[r0],#4
	subs	r1,r1,#1
	bne	0b

1:
        @ Initialize FBVECADDR
        ldr 	r0, VIM_FBVECADDR
	ldr	r2, =__vim_ecc_error_irq
	str	r2, [r0]

        @ Set IRQ / FIQ priorities
	ldr	r0, VIM_FIRQPR0
	mov	r2, #3
	str	r2, [r0],#4
        @ Other priorities 0
	mov	r2, #0
	str	r2, [r0],#4
	str	r2, [r0],#4
	str	r2, [r0],#4

        @ Enable interrupts
	ldr	r0, VIM_REQMASKSET0
	mov	r2, #3
	str	r2, [r0],#4
        @ Other mask  0
	mov	r2, #0
	str	r2, [r0],#4
	str	r2, [r0],#4
	str	r2, [r0],#4

        @ Set Capture event sources
	ldr	r0, VIM_CAPEVT
	mov	r2, #0
	str	r2, [r0]

	ldmfd sp!, {r0-r2}
	bx	lr
        .size	L_init_vim_ram, . - L_init_vim_ram

VIM_ECCSTAT     : .word   0xFFFFFDEC
VIM_ECCCTL      : .word   0xFFFFFDF0
VIM_UERRADDR    : .word   0xFFFFFDF4
VIM_FBVECADDR   : .word   0xFFFFFDF8
VIM_IRQINDEX    : .word   0xFFFFFE00
VIM_FIQINDEX    : .word   0xFFFFFE04
VIM_FIRQPR0     : .word   0xFFFFFE10
VIM_REQMASKSET0 : .word   0xFFFFFE30
VIM_REQMASKSET1 : .word   0xFFFFFE34
VIM_REQMASKSET2 : .word   0xFFFFFE38
VIM_REQMASKSET3 : .word   0xFFFFFE3C
VIM_REQMASKCLR0 : .word   0xFFFFFE40
VIM_REQMASKCLR1 : .word   0xFFFFFE44
VIM_REQMASKCLR2 : .word   0xFFFFFE48
VIM_REQMASKCLR3 : .word   0xFFFFFE4C
VIM_CAPEVT      : .word   0xFFFFFE78
VIM_ECCCTL_DIS  : .word   0x0005000A
VIM_RAM_BASE    : .word   0xFFF82000
VIM_RAM_ESM_IRQ : .word   0xFFF82004
VIM_RAM_IRQ     : .word   0xFFF82008
VIM_CHAN_OFFSET : .word   0x000003FF

@-------------------------------------------------------------------------------
@-------------------------------------------------------------------------------
L__dabt_trap:
	stmfd	sp!, {r0 - r3}

	/* Check for uncorrectable ECC error on B0TCM/B1TCM.  */
        ldr	r3, ESMSR3_REG
        ldr	r0, [r3]
        tst	r0, #0x28
        beq	1f

	/* Yes, check of ECC memory write is enabled.  */
	ldr	r1, tcram1_ramctrl
	ldr	r2, [r1]
	tst	r2, #0x100
	/* Yes: self-checking mode; skip fault.  */
	bne	Ldabt_skip_insn
	b	0f

	/* Check for uncorrectable ECC error on ATCM.  */
1:	tst	r0, #0x80
	bne	Ldabt_flash_error

	/* Normal data abort handler.  */
0:	ldmfd	sp!, {r0 - r3}
	b	__gnat_dabt_trap

Ldabt_skip_insn:
	/* Branch to the next instruction.  */
	ldmfd	sp!, {r0 - r3}
	subs	pc, lr, #4

Ldabt_flash_error:
	/* Read FDIAGCTRL register.  */
	ldr	r1, flashbase
	ldr	r2, [r1, #0x6C]
	lsr	r2, #16
	tst	r2, #5			@ check if bits 19:16 are 5, this indicates diagnostic mode is enabled
	/* If not, normal handler.  */
	beq	0b
	b	Ldabt_skip_insn

tcram1_ramctrl:	.word	0xFFFFF800
tcram2_ramctrl:	.word	0xFFFFF900
flashbase:	.word	0xFFF87000
@-------------------------------------------------------------------------------
