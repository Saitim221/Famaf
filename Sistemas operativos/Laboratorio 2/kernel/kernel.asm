
kernel/kernel:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8d013103          	ld	sp,-1840(sp) # 800088d0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8e070713          	addi	a4,a4,-1824 # 80008930 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	e1e78793          	addi	a5,a5,-482 # 80005e80 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc73f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	390080e7          	jalr	912(ra) # 800024ba <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8e650513          	addi	a0,a0,-1818 # 80010a70 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8d648493          	addi	s1,s1,-1834 # 80010a70 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	96690913          	addi	s2,s2,-1690 # 80010b08 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7f4080e7          	jalr	2036(ra) # 800019b4 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	13c080e7          	jalr	316(ra) # 80002304 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	e86080e7          	jalr	-378(ra) # 8000205c <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	252080e7          	jalr	594(ra) # 80002464 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	84a50513          	addi	a0,a0,-1974 # 80010a70 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	83450513          	addi	a0,a0,-1996 # 80010a70 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	88f72b23          	sw	a5,-1898(a4) # 80010b08 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	7a450513          	addi	a0,a0,1956 # 80010a70 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	21e080e7          	jalr	542(ra) # 80002510 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	77650513          	addi	a0,a0,1910 # 80010a70 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	75270713          	addi	a4,a4,1874 # 80010a70 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	72878793          	addi	a5,a5,1832 # 80010a70 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7927a783          	lw	a5,1938(a5) # 80010b08 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6e670713          	addi	a4,a4,1766 # 80010a70 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6d648493          	addi	s1,s1,1750 # 80010a70 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	69a70713          	addi	a4,a4,1690 # 80010a70 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	72f72223          	sw	a5,1828(a4) # 80010b10 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	65e78793          	addi	a5,a5,1630 # 80010a70 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6cc7ab23          	sw	a2,1750(a5) # 80010b0c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6ca50513          	addi	a0,a0,1738 # 80010b08 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	c7a080e7          	jalr	-902(ra) # 800020c0 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	61050513          	addi	a0,a0,1552 # 80010a70 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	ab078793          	addi	a5,a5,-1360 # 80020f28 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	5e07a223          	sw	zero,1508(a5) # 80010b30 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	36f72823          	sw	a5,880(a4) # 800088f0 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	574dad83          	lw	s11,1396(s11) # 80010b30 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	51e50513          	addi	a0,a0,1310 # 80010b18 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	3c050513          	addi	a0,a0,960 # 80010b18 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	3a448493          	addi	s1,s1,932 # 80010b18 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	36450513          	addi	a0,a0,868 # 80010b38 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	0f07a783          	lw	a5,240(a5) # 800088f0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	0c07b783          	ld	a5,192(a5) # 800088f8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	0c073703          	ld	a4,192(a4) # 80008900 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	2d6a0a13          	addi	s4,s4,726 # 80010b38 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	08e48493          	addi	s1,s1,142 # 800088f8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	08e98993          	addi	s3,s3,142 # 80008900 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	82c080e7          	jalr	-2004(ra) # 800020c0 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	26850513          	addi	a0,a0,616 # 80010b38 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	0107a783          	lw	a5,16(a5) # 800088f0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	01673703          	ld	a4,22(a4) # 80008900 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	0067b783          	ld	a5,6(a5) # 800088f8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	23a98993          	addi	s3,s3,570 # 80010b38 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	ff248493          	addi	s1,s1,-14 # 800088f8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	ff290913          	addi	s2,s2,-14 # 80008900 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00001097          	auipc	ra,0x1
    80000922:	73e080e7          	jalr	1854(ra) # 8000205c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	20448493          	addi	s1,s1,516 # 80010b38 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	fae7bc23          	sd	a4,-72(a5) # 80008900 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	17e48493          	addi	s1,s1,382 # 80010b38 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00021797          	auipc	a5,0x21
    80000a00:	6c478793          	addi	a5,a5,1732 # 800220c0 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	15490913          	addi	s2,s2,340 # 80010b70 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	0b650513          	addi	a0,a0,182 # 80010b70 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	5f250513          	addi	a0,a0,1522 # 800220c0 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	08048493          	addi	s1,s1,128 # 80010b70 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	06850513          	addi	a0,a0,104 # 80010b70 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	03c50513          	addi	a0,a0,60 # 80010b70 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e28080e7          	jalr	-472(ra) # 80001998 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	df6080e7          	jalr	-522(ra) # 80001998 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	dea080e7          	jalr	-534(ra) # 80001998 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dd2080e7          	jalr	-558(ra) # 80001998 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d92080e7          	jalr	-622(ra) # 80001998 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d66080e7          	jalr	-666(ra) # 80001998 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdcf41>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b08080e7          	jalr	-1272(ra) # 80001988 <cpuid>
    userinit();      // first user process
    init_sem();      // initializa los semáforos
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a8070713          	addi	a4,a4,-1408 # 80008908 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	aec080e7          	jalr	-1300(ra) # 80001988 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0e0080e7          	jalr	224(ra) # 80000f96 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00001097          	auipc	ra,0x1
    80000ec2:	794080e7          	jalr	1940(ra) # 80002652 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	ffa080e7          	jalr	-6(ra) # 80005ec0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fdc080e7          	jalr	-36(ra) # 80001eaa <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	32e080e7          	jalr	814(ra) # 8000124c <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	070080e7          	jalr	112(ra) # 80000f96 <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	9a6080e7          	jalr	-1626(ra) # 800018d4 <procinit>
    trapinit();      // trap vectors
    80000f36:	00001097          	auipc	ra,0x1
    80000f3a:	6f4080e7          	jalr	1780(ra) # 8000262a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	714080e7          	jalr	1812(ra) # 80002652 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	f64080e7          	jalr	-156(ra) # 80005eaa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	f72080e7          	jalr	-142(ra) # 80005ec0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	112080e7          	jalr	274(ra) # 80003068 <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	7b2080e7          	jalr	1970(ra) # 80003710 <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	758080e7          	jalr	1880(ra) # 800046be <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	05a080e7          	jalr	90(ra) # 80005fc8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d16080e7          	jalr	-746(ra) # 80001c8c <userinit>
    init_sem();      // initializa los semáforos
    80000f7e:	00002097          	auipc	ra,0x2
    80000f82:	e1e080e7          	jalr	-482(ra) # 80002d9c <init_sem>
    __sync_synchronize();
    80000f86:	0ff0000f          	fence
    started = 1;
    80000f8a:	4785                	li	a5,1
    80000f8c:	00008717          	auipc	a4,0x8
    80000f90:	96f72e23          	sw	a5,-1668(a4) # 80008908 <started>
    80000f94:	bf2d                	j	80000ece <main+0x56>

0000000080000f96 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f96:	1141                	addi	sp,sp,-16
    80000f98:	e422                	sd	s0,8(sp)
    80000f9a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa0:	00008797          	auipc	a5,0x8
    80000fa4:	9707b783          	ld	a5,-1680(a5) # 80008910 <kernel_pagetable>
    80000fa8:	83b1                	srli	a5,a5,0xc
    80000faa:	577d                	li	a4,-1
    80000fac:	177e                	slli	a4,a4,0x3f
    80000fae:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb0:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fb4:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb8:	6422                	ld	s0,8(sp)
    80000fba:	0141                	addi	sp,sp,16
    80000fbc:	8082                	ret

0000000080000fbe <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fbe:	7139                	addi	sp,sp,-64
    80000fc0:	fc06                	sd	ra,56(sp)
    80000fc2:	f822                	sd	s0,48(sp)
    80000fc4:	f426                	sd	s1,40(sp)
    80000fc6:	f04a                	sd	s2,32(sp)
    80000fc8:	ec4e                	sd	s3,24(sp)
    80000fca:	e852                	sd	s4,16(sp)
    80000fcc:	e456                	sd	s5,8(sp)
    80000fce:	e05a                	sd	s6,0(sp)
    80000fd0:	0080                	addi	s0,sp,64
    80000fd2:	84aa                	mv	s1,a0
    80000fd4:	89ae                	mv	s3,a1
    80000fd6:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd8:	57fd                	li	a5,-1
    80000fda:	83e9                	srli	a5,a5,0x1a
    80000fdc:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fde:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fe0:	04b7f263          	bgeu	a5,a1,80001024 <walk+0x66>
    panic("walk");
    80000fe4:	00007517          	auipc	a0,0x7
    80000fe8:	0ec50513          	addi	a0,a0,236 # 800080d0 <digits+0x90>
    80000fec:	fffff097          	auipc	ra,0xfffff
    80000ff0:	554080e7          	jalr	1364(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ff4:	060a8663          	beqz	s5,80001060 <walk+0xa2>
    80000ff8:	00000097          	auipc	ra,0x0
    80000ffc:	aee080e7          	jalr	-1298(ra) # 80000ae6 <kalloc>
    80001000:	84aa                	mv	s1,a0
    80001002:	c529                	beqz	a0,8000104c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001004:	6605                	lui	a2,0x1
    80001006:	4581                	li	a1,0
    80001008:	00000097          	auipc	ra,0x0
    8000100c:	cca080e7          	jalr	-822(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001010:	00c4d793          	srli	a5,s1,0xc
    80001014:	07aa                	slli	a5,a5,0xa
    80001016:	0017e793          	ori	a5,a5,1
    8000101a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000101e:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdcf37>
    80001020:	036a0063          	beq	s4,s6,80001040 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001024:	0149d933          	srl	s2,s3,s4
    80001028:	1ff97913          	andi	s2,s2,511
    8000102c:	090e                	slli	s2,s2,0x3
    8000102e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001030:	00093483          	ld	s1,0(s2)
    80001034:	0014f793          	andi	a5,s1,1
    80001038:	dfd5                	beqz	a5,80000ff4 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000103a:	80a9                	srli	s1,s1,0xa
    8000103c:	04b2                	slli	s1,s1,0xc
    8000103e:	b7c5                	j	8000101e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001040:	00c9d513          	srli	a0,s3,0xc
    80001044:	1ff57513          	andi	a0,a0,511
    80001048:	050e                	slli	a0,a0,0x3
    8000104a:	9526                	add	a0,a0,s1
}
    8000104c:	70e2                	ld	ra,56(sp)
    8000104e:	7442                	ld	s0,48(sp)
    80001050:	74a2                	ld	s1,40(sp)
    80001052:	7902                	ld	s2,32(sp)
    80001054:	69e2                	ld	s3,24(sp)
    80001056:	6a42                	ld	s4,16(sp)
    80001058:	6aa2                	ld	s5,8(sp)
    8000105a:	6b02                	ld	s6,0(sp)
    8000105c:	6121                	addi	sp,sp,64
    8000105e:	8082                	ret
        return 0;
    80001060:	4501                	li	a0,0
    80001062:	b7ed                	j	8000104c <walk+0x8e>

0000000080001064 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001064:	57fd                	li	a5,-1
    80001066:	83e9                	srli	a5,a5,0x1a
    80001068:	00b7f463          	bgeu	a5,a1,80001070 <walkaddr+0xc>
    return 0;
    8000106c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000106e:	8082                	ret
{
    80001070:	1141                	addi	sp,sp,-16
    80001072:	e406                	sd	ra,8(sp)
    80001074:	e022                	sd	s0,0(sp)
    80001076:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001078:	4601                	li	a2,0
    8000107a:	00000097          	auipc	ra,0x0
    8000107e:	f44080e7          	jalr	-188(ra) # 80000fbe <walk>
  if(pte == 0)
    80001082:	c105                	beqz	a0,800010a2 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001084:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001086:	0117f693          	andi	a3,a5,17
    8000108a:	4745                	li	a4,17
    return 0;
    8000108c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000108e:	00e68663          	beq	a3,a4,8000109a <walkaddr+0x36>
}
    80001092:	60a2                	ld	ra,8(sp)
    80001094:	6402                	ld	s0,0(sp)
    80001096:	0141                	addi	sp,sp,16
    80001098:	8082                	ret
  pa = PTE2PA(*pte);
    8000109a:	83a9                	srli	a5,a5,0xa
    8000109c:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010a0:	bfcd                	j	80001092 <walkaddr+0x2e>
    return 0;
    800010a2:	4501                	li	a0,0
    800010a4:	b7fd                	j	80001092 <walkaddr+0x2e>

00000000800010a6 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a6:	715d                	addi	sp,sp,-80
    800010a8:	e486                	sd	ra,72(sp)
    800010aa:	e0a2                	sd	s0,64(sp)
    800010ac:	fc26                	sd	s1,56(sp)
    800010ae:	f84a                	sd	s2,48(sp)
    800010b0:	f44e                	sd	s3,40(sp)
    800010b2:	f052                	sd	s4,32(sp)
    800010b4:	ec56                	sd	s5,24(sp)
    800010b6:	e85a                	sd	s6,16(sp)
    800010b8:	e45e                	sd	s7,8(sp)
    800010ba:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010bc:	c639                	beqz	a2,8000110a <mappages+0x64>
    800010be:	8aaa                	mv	s5,a0
    800010c0:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010c2:	777d                	lui	a4,0xfffff
    800010c4:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c8:	fff58993          	addi	s3,a1,-1
    800010cc:	99b2                	add	s3,s3,a2
    800010ce:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010d2:	893e                	mv	s2,a5
    800010d4:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d8:	6b85                	lui	s7,0x1
    800010da:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010de:	4605                	li	a2,1
    800010e0:	85ca                	mv	a1,s2
    800010e2:	8556                	mv	a0,s5
    800010e4:	00000097          	auipc	ra,0x0
    800010e8:	eda080e7          	jalr	-294(ra) # 80000fbe <walk>
    800010ec:	cd1d                	beqz	a0,8000112a <mappages+0x84>
    if(*pte & PTE_V)
    800010ee:	611c                	ld	a5,0(a0)
    800010f0:	8b85                	andi	a5,a5,1
    800010f2:	e785                	bnez	a5,8000111a <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f4:	80b1                	srli	s1,s1,0xc
    800010f6:	04aa                	slli	s1,s1,0xa
    800010f8:	0164e4b3          	or	s1,s1,s6
    800010fc:	0014e493          	ori	s1,s1,1
    80001100:	e104                	sd	s1,0(a0)
    if(a == last)
    80001102:	05390063          	beq	s2,s3,80001142 <mappages+0x9c>
    a += PGSIZE;
    80001106:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001108:	bfc9                	j	800010da <mappages+0x34>
    panic("mappages: size");
    8000110a:	00007517          	auipc	a0,0x7
    8000110e:	fce50513          	addi	a0,a0,-50 # 800080d8 <digits+0x98>
    80001112:	fffff097          	auipc	ra,0xfffff
    80001116:	42e080e7          	jalr	1070(ra) # 80000540 <panic>
      panic("mappages: remap");
    8000111a:	00007517          	auipc	a0,0x7
    8000111e:	fce50513          	addi	a0,a0,-50 # 800080e8 <digits+0xa8>
    80001122:	fffff097          	auipc	ra,0xfffff
    80001126:	41e080e7          	jalr	1054(ra) # 80000540 <panic>
      return -1;
    8000112a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000112c:	60a6                	ld	ra,72(sp)
    8000112e:	6406                	ld	s0,64(sp)
    80001130:	74e2                	ld	s1,56(sp)
    80001132:	7942                	ld	s2,48(sp)
    80001134:	79a2                	ld	s3,40(sp)
    80001136:	7a02                	ld	s4,32(sp)
    80001138:	6ae2                	ld	s5,24(sp)
    8000113a:	6b42                	ld	s6,16(sp)
    8000113c:	6ba2                	ld	s7,8(sp)
    8000113e:	6161                	addi	sp,sp,80
    80001140:	8082                	ret
  return 0;
    80001142:	4501                	li	a0,0
    80001144:	b7e5                	j	8000112c <mappages+0x86>

0000000080001146 <kvmmap>:
{
    80001146:	1141                	addi	sp,sp,-16
    80001148:	e406                	sd	ra,8(sp)
    8000114a:	e022                	sd	s0,0(sp)
    8000114c:	0800                	addi	s0,sp,16
    8000114e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001150:	86b2                	mv	a3,a2
    80001152:	863e                	mv	a2,a5
    80001154:	00000097          	auipc	ra,0x0
    80001158:	f52080e7          	jalr	-174(ra) # 800010a6 <mappages>
    8000115c:	e509                	bnez	a0,80001166 <kvmmap+0x20>
}
    8000115e:	60a2                	ld	ra,8(sp)
    80001160:	6402                	ld	s0,0(sp)
    80001162:	0141                	addi	sp,sp,16
    80001164:	8082                	ret
    panic("kvmmap");
    80001166:	00007517          	auipc	a0,0x7
    8000116a:	f9250513          	addi	a0,a0,-110 # 800080f8 <digits+0xb8>
    8000116e:	fffff097          	auipc	ra,0xfffff
    80001172:	3d2080e7          	jalr	978(ra) # 80000540 <panic>

0000000080001176 <kvmmake>:
{
    80001176:	1101                	addi	sp,sp,-32
    80001178:	ec06                	sd	ra,24(sp)
    8000117a:	e822                	sd	s0,16(sp)
    8000117c:	e426                	sd	s1,8(sp)
    8000117e:	e04a                	sd	s2,0(sp)
    80001180:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001182:	00000097          	auipc	ra,0x0
    80001186:	964080e7          	jalr	-1692(ra) # 80000ae6 <kalloc>
    8000118a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000118c:	6605                	lui	a2,0x1
    8000118e:	4581                	li	a1,0
    80001190:	00000097          	auipc	ra,0x0
    80001194:	b42080e7          	jalr	-1214(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001198:	4719                	li	a4,6
    8000119a:	6685                	lui	a3,0x1
    8000119c:	10000637          	lui	a2,0x10000
    800011a0:	100005b7          	lui	a1,0x10000
    800011a4:	8526                	mv	a0,s1
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	fa0080e7          	jalr	-96(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011ae:	4719                	li	a4,6
    800011b0:	6685                	lui	a3,0x1
    800011b2:	10001637          	lui	a2,0x10001
    800011b6:	100015b7          	lui	a1,0x10001
    800011ba:	8526                	mv	a0,s1
    800011bc:	00000097          	auipc	ra,0x0
    800011c0:	f8a080e7          	jalr	-118(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011c4:	4719                	li	a4,6
    800011c6:	004006b7          	lui	a3,0x400
    800011ca:	0c000637          	lui	a2,0xc000
    800011ce:	0c0005b7          	lui	a1,0xc000
    800011d2:	8526                	mv	a0,s1
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	f72080e7          	jalr	-142(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011dc:	00007917          	auipc	s2,0x7
    800011e0:	e2490913          	addi	s2,s2,-476 # 80008000 <etext>
    800011e4:	4729                	li	a4,10
    800011e6:	80007697          	auipc	a3,0x80007
    800011ea:	e1a68693          	addi	a3,a3,-486 # 8000 <_entry-0x7fff8000>
    800011ee:	4605                	li	a2,1
    800011f0:	067e                	slli	a2,a2,0x1f
    800011f2:	85b2                	mv	a1,a2
    800011f4:	8526                	mv	a0,s1
    800011f6:	00000097          	auipc	ra,0x0
    800011fa:	f50080e7          	jalr	-176(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011fe:	4719                	li	a4,6
    80001200:	46c5                	li	a3,17
    80001202:	06ee                	slli	a3,a3,0x1b
    80001204:	412686b3          	sub	a3,a3,s2
    80001208:	864a                	mv	a2,s2
    8000120a:	85ca                	mv	a1,s2
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f38080e7          	jalr	-200(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001216:	4729                	li	a4,10
    80001218:	6685                	lui	a3,0x1
    8000121a:	00006617          	auipc	a2,0x6
    8000121e:	de660613          	addi	a2,a2,-538 # 80007000 <_trampoline>
    80001222:	040005b7          	lui	a1,0x4000
    80001226:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001228:	05b2                	slli	a1,a1,0xc
    8000122a:	8526                	mv	a0,s1
    8000122c:	00000097          	auipc	ra,0x0
    80001230:	f1a080e7          	jalr	-230(ra) # 80001146 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001234:	8526                	mv	a0,s1
    80001236:	00000097          	auipc	ra,0x0
    8000123a:	608080e7          	jalr	1544(ra) # 8000183e <proc_mapstacks>
}
    8000123e:	8526                	mv	a0,s1
    80001240:	60e2                	ld	ra,24(sp)
    80001242:	6442                	ld	s0,16(sp)
    80001244:	64a2                	ld	s1,8(sp)
    80001246:	6902                	ld	s2,0(sp)
    80001248:	6105                	addi	sp,sp,32
    8000124a:	8082                	ret

000000008000124c <kvminit>:
{
    8000124c:	1141                	addi	sp,sp,-16
    8000124e:	e406                	sd	ra,8(sp)
    80001250:	e022                	sd	s0,0(sp)
    80001252:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001254:	00000097          	auipc	ra,0x0
    80001258:	f22080e7          	jalr	-222(ra) # 80001176 <kvmmake>
    8000125c:	00007797          	auipc	a5,0x7
    80001260:	6aa7ba23          	sd	a0,1716(a5) # 80008910 <kernel_pagetable>
}
    80001264:	60a2                	ld	ra,8(sp)
    80001266:	6402                	ld	s0,0(sp)
    80001268:	0141                	addi	sp,sp,16
    8000126a:	8082                	ret

000000008000126c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000126c:	715d                	addi	sp,sp,-80
    8000126e:	e486                	sd	ra,72(sp)
    80001270:	e0a2                	sd	s0,64(sp)
    80001272:	fc26                	sd	s1,56(sp)
    80001274:	f84a                	sd	s2,48(sp)
    80001276:	f44e                	sd	s3,40(sp)
    80001278:	f052                	sd	s4,32(sp)
    8000127a:	ec56                	sd	s5,24(sp)
    8000127c:	e85a                	sd	s6,16(sp)
    8000127e:	e45e                	sd	s7,8(sp)
    80001280:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001282:	03459793          	slli	a5,a1,0x34
    80001286:	e795                	bnez	a5,800012b2 <uvmunmap+0x46>
    80001288:	8a2a                	mv	s4,a0
    8000128a:	892e                	mv	s2,a1
    8000128c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	0632                	slli	a2,a2,0xc
    80001290:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001294:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001296:	6b05                	lui	s6,0x1
    80001298:	0735e263          	bltu	a1,s3,800012fc <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000129c:	60a6                	ld	ra,72(sp)
    8000129e:	6406                	ld	s0,64(sp)
    800012a0:	74e2                	ld	s1,56(sp)
    800012a2:	7942                	ld	s2,48(sp)
    800012a4:	79a2                	ld	s3,40(sp)
    800012a6:	7a02                	ld	s4,32(sp)
    800012a8:	6ae2                	ld	s5,24(sp)
    800012aa:	6b42                	ld	s6,16(sp)
    800012ac:	6ba2                	ld	s7,8(sp)
    800012ae:	6161                	addi	sp,sp,80
    800012b0:	8082                	ret
    panic("uvmunmap: not aligned");
    800012b2:	00007517          	auipc	a0,0x7
    800012b6:	e4e50513          	addi	a0,a0,-434 # 80008100 <digits+0xc0>
    800012ba:	fffff097          	auipc	ra,0xfffff
    800012be:	286080e7          	jalr	646(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012c2:	00007517          	auipc	a0,0x7
    800012c6:	e5650513          	addi	a0,a0,-426 # 80008118 <digits+0xd8>
    800012ca:	fffff097          	auipc	ra,0xfffff
    800012ce:	276080e7          	jalr	630(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012d2:	00007517          	auipc	a0,0x7
    800012d6:	e5650513          	addi	a0,a0,-426 # 80008128 <digits+0xe8>
    800012da:	fffff097          	auipc	ra,0xfffff
    800012de:	266080e7          	jalr	614(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012e2:	00007517          	auipc	a0,0x7
    800012e6:	e5e50513          	addi	a0,a0,-418 # 80008140 <digits+0x100>
    800012ea:	fffff097          	auipc	ra,0xfffff
    800012ee:	256080e7          	jalr	598(ra) # 80000540 <panic>
    *pte = 0;
    800012f2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f6:	995a                	add	s2,s2,s6
    800012f8:	fb3972e3          	bgeu	s2,s3,8000129c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012fc:	4601                	li	a2,0
    800012fe:	85ca                	mv	a1,s2
    80001300:	8552                	mv	a0,s4
    80001302:	00000097          	auipc	ra,0x0
    80001306:	cbc080e7          	jalr	-836(ra) # 80000fbe <walk>
    8000130a:	84aa                	mv	s1,a0
    8000130c:	d95d                	beqz	a0,800012c2 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000130e:	6108                	ld	a0,0(a0)
    80001310:	00157793          	andi	a5,a0,1
    80001314:	dfdd                	beqz	a5,800012d2 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001316:	3ff57793          	andi	a5,a0,1023
    8000131a:	fd7784e3          	beq	a5,s7,800012e2 <uvmunmap+0x76>
    if(do_free){
    8000131e:	fc0a8ae3          	beqz	s5,800012f2 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001322:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001324:	0532                	slli	a0,a0,0xc
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	6c2080e7          	jalr	1730(ra) # 800009e8 <kfree>
    8000132e:	b7d1                	j	800012f2 <uvmunmap+0x86>

0000000080001330 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001330:	1101                	addi	sp,sp,-32
    80001332:	ec06                	sd	ra,24(sp)
    80001334:	e822                	sd	s0,16(sp)
    80001336:	e426                	sd	s1,8(sp)
    80001338:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000133a:	fffff097          	auipc	ra,0xfffff
    8000133e:	7ac080e7          	jalr	1964(ra) # 80000ae6 <kalloc>
    80001342:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001344:	c519                	beqz	a0,80001352 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001346:	6605                	lui	a2,0x1
    80001348:	4581                	li	a1,0
    8000134a:	00000097          	auipc	ra,0x0
    8000134e:	988080e7          	jalr	-1656(ra) # 80000cd2 <memset>
  return pagetable;
}
    80001352:	8526                	mv	a0,s1
    80001354:	60e2                	ld	ra,24(sp)
    80001356:	6442                	ld	s0,16(sp)
    80001358:	64a2                	ld	s1,8(sp)
    8000135a:	6105                	addi	sp,sp,32
    8000135c:	8082                	ret

000000008000135e <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000135e:	7179                	addi	sp,sp,-48
    80001360:	f406                	sd	ra,40(sp)
    80001362:	f022                	sd	s0,32(sp)
    80001364:	ec26                	sd	s1,24(sp)
    80001366:	e84a                	sd	s2,16(sp)
    80001368:	e44e                	sd	s3,8(sp)
    8000136a:	e052                	sd	s4,0(sp)
    8000136c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000136e:	6785                	lui	a5,0x1
    80001370:	04f67863          	bgeu	a2,a5,800013c0 <uvmfirst+0x62>
    80001374:	8a2a                	mv	s4,a0
    80001376:	89ae                	mv	s3,a1
    80001378:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	76c080e7          	jalr	1900(ra) # 80000ae6 <kalloc>
    80001382:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001384:	6605                	lui	a2,0x1
    80001386:	4581                	li	a1,0
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	94a080e7          	jalr	-1718(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001390:	4779                	li	a4,30
    80001392:	86ca                	mv	a3,s2
    80001394:	6605                	lui	a2,0x1
    80001396:	4581                	li	a1,0
    80001398:	8552                	mv	a0,s4
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	d0c080e7          	jalr	-756(ra) # 800010a6 <mappages>
  memmove(mem, src, sz);
    800013a2:	8626                	mv	a2,s1
    800013a4:	85ce                	mv	a1,s3
    800013a6:	854a                	mv	a0,s2
    800013a8:	00000097          	auipc	ra,0x0
    800013ac:	986080e7          	jalr	-1658(ra) # 80000d2e <memmove>
}
    800013b0:	70a2                	ld	ra,40(sp)
    800013b2:	7402                	ld	s0,32(sp)
    800013b4:	64e2                	ld	s1,24(sp)
    800013b6:	6942                	ld	s2,16(sp)
    800013b8:	69a2                	ld	s3,8(sp)
    800013ba:	6a02                	ld	s4,0(sp)
    800013bc:	6145                	addi	sp,sp,48
    800013be:	8082                	ret
    panic("uvmfirst: more than a page");
    800013c0:	00007517          	auipc	a0,0x7
    800013c4:	d9850513          	addi	a0,a0,-616 # 80008158 <digits+0x118>
    800013c8:	fffff097          	auipc	ra,0xfffff
    800013cc:	178080e7          	jalr	376(ra) # 80000540 <panic>

00000000800013d0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013d0:	1101                	addi	sp,sp,-32
    800013d2:	ec06                	sd	ra,24(sp)
    800013d4:	e822                	sd	s0,16(sp)
    800013d6:	e426                	sd	s1,8(sp)
    800013d8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013da:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013dc:	00b67d63          	bgeu	a2,a1,800013f6 <uvmdealloc+0x26>
    800013e0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013e2:	6785                	lui	a5,0x1
    800013e4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013e6:	00f60733          	add	a4,a2,a5
    800013ea:	76fd                	lui	a3,0xfffff
    800013ec:	8f75                	and	a4,a4,a3
    800013ee:	97ae                	add	a5,a5,a1
    800013f0:	8ff5                	and	a5,a5,a3
    800013f2:	00f76863          	bltu	a4,a5,80001402 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013f6:	8526                	mv	a0,s1
    800013f8:	60e2                	ld	ra,24(sp)
    800013fa:	6442                	ld	s0,16(sp)
    800013fc:	64a2                	ld	s1,8(sp)
    800013fe:	6105                	addi	sp,sp,32
    80001400:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001402:	8f99                	sub	a5,a5,a4
    80001404:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001406:	4685                	li	a3,1
    80001408:	0007861b          	sext.w	a2,a5
    8000140c:	85ba                	mv	a1,a4
    8000140e:	00000097          	auipc	ra,0x0
    80001412:	e5e080e7          	jalr	-418(ra) # 8000126c <uvmunmap>
    80001416:	b7c5                	j	800013f6 <uvmdealloc+0x26>

0000000080001418 <uvmalloc>:
  if(newsz < oldsz)
    80001418:	0ab66563          	bltu	a2,a1,800014c2 <uvmalloc+0xaa>
{
    8000141c:	7139                	addi	sp,sp,-64
    8000141e:	fc06                	sd	ra,56(sp)
    80001420:	f822                	sd	s0,48(sp)
    80001422:	f426                	sd	s1,40(sp)
    80001424:	f04a                	sd	s2,32(sp)
    80001426:	ec4e                	sd	s3,24(sp)
    80001428:	e852                	sd	s4,16(sp)
    8000142a:	e456                	sd	s5,8(sp)
    8000142c:	e05a                	sd	s6,0(sp)
    8000142e:	0080                	addi	s0,sp,64
    80001430:	8aaa                	mv	s5,a0
    80001432:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001434:	6785                	lui	a5,0x1
    80001436:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001438:	95be                	add	a1,a1,a5
    8000143a:	77fd                	lui	a5,0xfffff
    8000143c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001440:	08c9f363          	bgeu	s3,a2,800014c6 <uvmalloc+0xae>
    80001444:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001446:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000144a:	fffff097          	auipc	ra,0xfffff
    8000144e:	69c080e7          	jalr	1692(ra) # 80000ae6 <kalloc>
    80001452:	84aa                	mv	s1,a0
    if(mem == 0){
    80001454:	c51d                	beqz	a0,80001482 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001456:	6605                	lui	a2,0x1
    80001458:	4581                	li	a1,0
    8000145a:	00000097          	auipc	ra,0x0
    8000145e:	878080e7          	jalr	-1928(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001462:	875a                	mv	a4,s6
    80001464:	86a6                	mv	a3,s1
    80001466:	6605                	lui	a2,0x1
    80001468:	85ca                	mv	a1,s2
    8000146a:	8556                	mv	a0,s5
    8000146c:	00000097          	auipc	ra,0x0
    80001470:	c3a080e7          	jalr	-966(ra) # 800010a6 <mappages>
    80001474:	e90d                	bnez	a0,800014a6 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001476:	6785                	lui	a5,0x1
    80001478:	993e                	add	s2,s2,a5
    8000147a:	fd4968e3          	bltu	s2,s4,8000144a <uvmalloc+0x32>
  return newsz;
    8000147e:	8552                	mv	a0,s4
    80001480:	a809                	j	80001492 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001482:	864e                	mv	a2,s3
    80001484:	85ca                	mv	a1,s2
    80001486:	8556                	mv	a0,s5
    80001488:	00000097          	auipc	ra,0x0
    8000148c:	f48080e7          	jalr	-184(ra) # 800013d0 <uvmdealloc>
      return 0;
    80001490:	4501                	li	a0,0
}
    80001492:	70e2                	ld	ra,56(sp)
    80001494:	7442                	ld	s0,48(sp)
    80001496:	74a2                	ld	s1,40(sp)
    80001498:	7902                	ld	s2,32(sp)
    8000149a:	69e2                	ld	s3,24(sp)
    8000149c:	6a42                	ld	s4,16(sp)
    8000149e:	6aa2                	ld	s5,8(sp)
    800014a0:	6b02                	ld	s6,0(sp)
    800014a2:	6121                	addi	sp,sp,64
    800014a4:	8082                	ret
      kfree(mem);
    800014a6:	8526                	mv	a0,s1
    800014a8:	fffff097          	auipc	ra,0xfffff
    800014ac:	540080e7          	jalr	1344(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b0:	864e                	mv	a2,s3
    800014b2:	85ca                	mv	a1,s2
    800014b4:	8556                	mv	a0,s5
    800014b6:	00000097          	auipc	ra,0x0
    800014ba:	f1a080e7          	jalr	-230(ra) # 800013d0 <uvmdealloc>
      return 0;
    800014be:	4501                	li	a0,0
    800014c0:	bfc9                	j	80001492 <uvmalloc+0x7a>
    return oldsz;
    800014c2:	852e                	mv	a0,a1
}
    800014c4:	8082                	ret
  return newsz;
    800014c6:	8532                	mv	a0,a2
    800014c8:	b7e9                	j	80001492 <uvmalloc+0x7a>

00000000800014ca <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014ca:	7179                	addi	sp,sp,-48
    800014cc:	f406                	sd	ra,40(sp)
    800014ce:	f022                	sd	s0,32(sp)
    800014d0:	ec26                	sd	s1,24(sp)
    800014d2:	e84a                	sd	s2,16(sp)
    800014d4:	e44e                	sd	s3,8(sp)
    800014d6:	e052                	sd	s4,0(sp)
    800014d8:	1800                	addi	s0,sp,48
    800014da:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014dc:	84aa                	mv	s1,a0
    800014de:	6905                	lui	s2,0x1
    800014e0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e2:	4985                	li	s3,1
    800014e4:	a829                	j	800014fe <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e6:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e8:	00c79513          	slli	a0,a5,0xc
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	fde080e7          	jalr	-34(ra) # 800014ca <freewalk>
      pagetable[i] = 0;
    800014f4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f8:	04a1                	addi	s1,s1,8
    800014fa:	03248163          	beq	s1,s2,8000151c <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014fe:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001500:	00f7f713          	andi	a4,a5,15
    80001504:	ff3701e3          	beq	a4,s3,800014e6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001508:	8b85                	andi	a5,a5,1
    8000150a:	d7fd                	beqz	a5,800014f8 <freewalk+0x2e>
      panic("freewalk: leaf");
    8000150c:	00007517          	auipc	a0,0x7
    80001510:	c6c50513          	addi	a0,a0,-916 # 80008178 <digits+0x138>
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	02c080e7          	jalr	44(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    8000151c:	8552                	mv	a0,s4
    8000151e:	fffff097          	auipc	ra,0xfffff
    80001522:	4ca080e7          	jalr	1226(ra) # 800009e8 <kfree>
}
    80001526:	70a2                	ld	ra,40(sp)
    80001528:	7402                	ld	s0,32(sp)
    8000152a:	64e2                	ld	s1,24(sp)
    8000152c:	6942                	ld	s2,16(sp)
    8000152e:	69a2                	ld	s3,8(sp)
    80001530:	6a02                	ld	s4,0(sp)
    80001532:	6145                	addi	sp,sp,48
    80001534:	8082                	ret

0000000080001536 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001536:	1101                	addi	sp,sp,-32
    80001538:	ec06                	sd	ra,24(sp)
    8000153a:	e822                	sd	s0,16(sp)
    8000153c:	e426                	sd	s1,8(sp)
    8000153e:	1000                	addi	s0,sp,32
    80001540:	84aa                	mv	s1,a0
  if(sz > 0)
    80001542:	e999                	bnez	a1,80001558 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001544:	8526                	mv	a0,s1
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	f84080e7          	jalr	-124(ra) # 800014ca <freewalk>
}
    8000154e:	60e2                	ld	ra,24(sp)
    80001550:	6442                	ld	s0,16(sp)
    80001552:	64a2                	ld	s1,8(sp)
    80001554:	6105                	addi	sp,sp,32
    80001556:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001558:	6785                	lui	a5,0x1
    8000155a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000155c:	95be                	add	a1,a1,a5
    8000155e:	4685                	li	a3,1
    80001560:	00c5d613          	srli	a2,a1,0xc
    80001564:	4581                	li	a1,0
    80001566:	00000097          	auipc	ra,0x0
    8000156a:	d06080e7          	jalr	-762(ra) # 8000126c <uvmunmap>
    8000156e:	bfd9                	j	80001544 <uvmfree+0xe>

0000000080001570 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001570:	c679                	beqz	a2,8000163e <uvmcopy+0xce>
{
    80001572:	715d                	addi	sp,sp,-80
    80001574:	e486                	sd	ra,72(sp)
    80001576:	e0a2                	sd	s0,64(sp)
    80001578:	fc26                	sd	s1,56(sp)
    8000157a:	f84a                	sd	s2,48(sp)
    8000157c:	f44e                	sd	s3,40(sp)
    8000157e:	f052                	sd	s4,32(sp)
    80001580:	ec56                	sd	s5,24(sp)
    80001582:	e85a                	sd	s6,16(sp)
    80001584:	e45e                	sd	s7,8(sp)
    80001586:	0880                	addi	s0,sp,80
    80001588:	8b2a                	mv	s6,a0
    8000158a:	8aae                	mv	s5,a1
    8000158c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000158e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001590:	4601                	li	a2,0
    80001592:	85ce                	mv	a1,s3
    80001594:	855a                	mv	a0,s6
    80001596:	00000097          	auipc	ra,0x0
    8000159a:	a28080e7          	jalr	-1496(ra) # 80000fbe <walk>
    8000159e:	c531                	beqz	a0,800015ea <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015a0:	6118                	ld	a4,0(a0)
    800015a2:	00177793          	andi	a5,a4,1
    800015a6:	cbb1                	beqz	a5,800015fa <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a8:	00a75593          	srli	a1,a4,0xa
    800015ac:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015b0:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b4:	fffff097          	auipc	ra,0xfffff
    800015b8:	532080e7          	jalr	1330(ra) # 80000ae6 <kalloc>
    800015bc:	892a                	mv	s2,a0
    800015be:	c939                	beqz	a0,80001614 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015c0:	6605                	lui	a2,0x1
    800015c2:	85de                	mv	a1,s7
    800015c4:	fffff097          	auipc	ra,0xfffff
    800015c8:	76a080e7          	jalr	1898(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015cc:	8726                	mv	a4,s1
    800015ce:	86ca                	mv	a3,s2
    800015d0:	6605                	lui	a2,0x1
    800015d2:	85ce                	mv	a1,s3
    800015d4:	8556                	mv	a0,s5
    800015d6:	00000097          	auipc	ra,0x0
    800015da:	ad0080e7          	jalr	-1328(ra) # 800010a6 <mappages>
    800015de:	e515                	bnez	a0,8000160a <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015e0:	6785                	lui	a5,0x1
    800015e2:	99be                	add	s3,s3,a5
    800015e4:	fb49e6e3          	bltu	s3,s4,80001590 <uvmcopy+0x20>
    800015e8:	a081                	j	80001628 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015ea:	00007517          	auipc	a0,0x7
    800015ee:	b9e50513          	addi	a0,a0,-1122 # 80008188 <digits+0x148>
    800015f2:	fffff097          	auipc	ra,0xfffff
    800015f6:	f4e080e7          	jalr	-178(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015fa:	00007517          	auipc	a0,0x7
    800015fe:	bae50513          	addi	a0,a0,-1106 # 800081a8 <digits+0x168>
    80001602:	fffff097          	auipc	ra,0xfffff
    80001606:	f3e080e7          	jalr	-194(ra) # 80000540 <panic>
      kfree(mem);
    8000160a:	854a                	mv	a0,s2
    8000160c:	fffff097          	auipc	ra,0xfffff
    80001610:	3dc080e7          	jalr	988(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001614:	4685                	li	a3,1
    80001616:	00c9d613          	srli	a2,s3,0xc
    8000161a:	4581                	li	a1,0
    8000161c:	8556                	mv	a0,s5
    8000161e:	00000097          	auipc	ra,0x0
    80001622:	c4e080e7          	jalr	-946(ra) # 8000126c <uvmunmap>
  return -1;
    80001626:	557d                	li	a0,-1
}
    80001628:	60a6                	ld	ra,72(sp)
    8000162a:	6406                	ld	s0,64(sp)
    8000162c:	74e2                	ld	s1,56(sp)
    8000162e:	7942                	ld	s2,48(sp)
    80001630:	79a2                	ld	s3,40(sp)
    80001632:	7a02                	ld	s4,32(sp)
    80001634:	6ae2                	ld	s5,24(sp)
    80001636:	6b42                	ld	s6,16(sp)
    80001638:	6ba2                	ld	s7,8(sp)
    8000163a:	6161                	addi	sp,sp,80
    8000163c:	8082                	ret
  return 0;
    8000163e:	4501                	li	a0,0
}
    80001640:	8082                	ret

0000000080001642 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001642:	1141                	addi	sp,sp,-16
    80001644:	e406                	sd	ra,8(sp)
    80001646:	e022                	sd	s0,0(sp)
    80001648:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000164a:	4601                	li	a2,0
    8000164c:	00000097          	auipc	ra,0x0
    80001650:	972080e7          	jalr	-1678(ra) # 80000fbe <walk>
  if(pte == 0)
    80001654:	c901                	beqz	a0,80001664 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001656:	611c                	ld	a5,0(a0)
    80001658:	9bbd                	andi	a5,a5,-17
    8000165a:	e11c                	sd	a5,0(a0)
}
    8000165c:	60a2                	ld	ra,8(sp)
    8000165e:	6402                	ld	s0,0(sp)
    80001660:	0141                	addi	sp,sp,16
    80001662:	8082                	ret
    panic("uvmclear");
    80001664:	00007517          	auipc	a0,0x7
    80001668:	b6450513          	addi	a0,a0,-1180 # 800081c8 <digits+0x188>
    8000166c:	fffff097          	auipc	ra,0xfffff
    80001670:	ed4080e7          	jalr	-300(ra) # 80000540 <panic>

0000000080001674 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001674:	c6bd                	beqz	a3,800016e2 <copyout+0x6e>
{
    80001676:	715d                	addi	sp,sp,-80
    80001678:	e486                	sd	ra,72(sp)
    8000167a:	e0a2                	sd	s0,64(sp)
    8000167c:	fc26                	sd	s1,56(sp)
    8000167e:	f84a                	sd	s2,48(sp)
    80001680:	f44e                	sd	s3,40(sp)
    80001682:	f052                	sd	s4,32(sp)
    80001684:	ec56                	sd	s5,24(sp)
    80001686:	e85a                	sd	s6,16(sp)
    80001688:	e45e                	sd	s7,8(sp)
    8000168a:	e062                	sd	s8,0(sp)
    8000168c:	0880                	addi	s0,sp,80
    8000168e:	8b2a                	mv	s6,a0
    80001690:	8c2e                	mv	s8,a1
    80001692:	8a32                	mv	s4,a2
    80001694:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001696:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001698:	6a85                	lui	s5,0x1
    8000169a:	a015                	j	800016be <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000169c:	9562                	add	a0,a0,s8
    8000169e:	0004861b          	sext.w	a2,s1
    800016a2:	85d2                	mv	a1,s4
    800016a4:	41250533          	sub	a0,a0,s2
    800016a8:	fffff097          	auipc	ra,0xfffff
    800016ac:	686080e7          	jalr	1670(ra) # 80000d2e <memmove>

    len -= n;
    800016b0:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b4:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ba:	02098263          	beqz	s3,800016de <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016be:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016c2:	85ca                	mv	a1,s2
    800016c4:	855a                	mv	a0,s6
    800016c6:	00000097          	auipc	ra,0x0
    800016ca:	99e080e7          	jalr	-1634(ra) # 80001064 <walkaddr>
    if(pa0 == 0)
    800016ce:	cd01                	beqz	a0,800016e6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016d0:	418904b3          	sub	s1,s2,s8
    800016d4:	94d6                	add	s1,s1,s5
    800016d6:	fc99f3e3          	bgeu	s3,s1,8000169c <copyout+0x28>
    800016da:	84ce                	mv	s1,s3
    800016dc:	b7c1                	j	8000169c <copyout+0x28>
  }
  return 0;
    800016de:	4501                	li	a0,0
    800016e0:	a021                	j	800016e8 <copyout+0x74>
    800016e2:	4501                	li	a0,0
}
    800016e4:	8082                	ret
      return -1;
    800016e6:	557d                	li	a0,-1
}
    800016e8:	60a6                	ld	ra,72(sp)
    800016ea:	6406                	ld	s0,64(sp)
    800016ec:	74e2                	ld	s1,56(sp)
    800016ee:	7942                	ld	s2,48(sp)
    800016f0:	79a2                	ld	s3,40(sp)
    800016f2:	7a02                	ld	s4,32(sp)
    800016f4:	6ae2                	ld	s5,24(sp)
    800016f6:	6b42                	ld	s6,16(sp)
    800016f8:	6ba2                	ld	s7,8(sp)
    800016fa:	6c02                	ld	s8,0(sp)
    800016fc:	6161                	addi	sp,sp,80
    800016fe:	8082                	ret

0000000080001700 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001700:	caa5                	beqz	a3,80001770 <copyin+0x70>
{
    80001702:	715d                	addi	sp,sp,-80
    80001704:	e486                	sd	ra,72(sp)
    80001706:	e0a2                	sd	s0,64(sp)
    80001708:	fc26                	sd	s1,56(sp)
    8000170a:	f84a                	sd	s2,48(sp)
    8000170c:	f44e                	sd	s3,40(sp)
    8000170e:	f052                	sd	s4,32(sp)
    80001710:	ec56                	sd	s5,24(sp)
    80001712:	e85a                	sd	s6,16(sp)
    80001714:	e45e                	sd	s7,8(sp)
    80001716:	e062                	sd	s8,0(sp)
    80001718:	0880                	addi	s0,sp,80
    8000171a:	8b2a                	mv	s6,a0
    8000171c:	8a2e                	mv	s4,a1
    8000171e:	8c32                	mv	s8,a2
    80001720:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001722:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001724:	6a85                	lui	s5,0x1
    80001726:	a01d                	j	8000174c <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001728:	018505b3          	add	a1,a0,s8
    8000172c:	0004861b          	sext.w	a2,s1
    80001730:	412585b3          	sub	a1,a1,s2
    80001734:	8552                	mv	a0,s4
    80001736:	fffff097          	auipc	ra,0xfffff
    8000173a:	5f8080e7          	jalr	1528(ra) # 80000d2e <memmove>

    len -= n;
    8000173e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001742:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001744:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001748:	02098263          	beqz	s3,8000176c <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000174c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001750:	85ca                	mv	a1,s2
    80001752:	855a                	mv	a0,s6
    80001754:	00000097          	auipc	ra,0x0
    80001758:	910080e7          	jalr	-1776(ra) # 80001064 <walkaddr>
    if(pa0 == 0)
    8000175c:	cd01                	beqz	a0,80001774 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000175e:	418904b3          	sub	s1,s2,s8
    80001762:	94d6                	add	s1,s1,s5
    80001764:	fc99f2e3          	bgeu	s3,s1,80001728 <copyin+0x28>
    80001768:	84ce                	mv	s1,s3
    8000176a:	bf7d                	j	80001728 <copyin+0x28>
  }
  return 0;
    8000176c:	4501                	li	a0,0
    8000176e:	a021                	j	80001776 <copyin+0x76>
    80001770:	4501                	li	a0,0
}
    80001772:	8082                	ret
      return -1;
    80001774:	557d                	li	a0,-1
}
    80001776:	60a6                	ld	ra,72(sp)
    80001778:	6406                	ld	s0,64(sp)
    8000177a:	74e2                	ld	s1,56(sp)
    8000177c:	7942                	ld	s2,48(sp)
    8000177e:	79a2                	ld	s3,40(sp)
    80001780:	7a02                	ld	s4,32(sp)
    80001782:	6ae2                	ld	s5,24(sp)
    80001784:	6b42                	ld	s6,16(sp)
    80001786:	6ba2                	ld	s7,8(sp)
    80001788:	6c02                	ld	s8,0(sp)
    8000178a:	6161                	addi	sp,sp,80
    8000178c:	8082                	ret

000000008000178e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000178e:	c2dd                	beqz	a3,80001834 <copyinstr+0xa6>
{
    80001790:	715d                	addi	sp,sp,-80
    80001792:	e486                	sd	ra,72(sp)
    80001794:	e0a2                	sd	s0,64(sp)
    80001796:	fc26                	sd	s1,56(sp)
    80001798:	f84a                	sd	s2,48(sp)
    8000179a:	f44e                	sd	s3,40(sp)
    8000179c:	f052                	sd	s4,32(sp)
    8000179e:	ec56                	sd	s5,24(sp)
    800017a0:	e85a                	sd	s6,16(sp)
    800017a2:	e45e                	sd	s7,8(sp)
    800017a4:	0880                	addi	s0,sp,80
    800017a6:	8a2a                	mv	s4,a0
    800017a8:	8b2e                	mv	s6,a1
    800017aa:	8bb2                	mv	s7,a2
    800017ac:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017ae:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017b0:	6985                	lui	s3,0x1
    800017b2:	a02d                	j	800017dc <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ba:	37fd                	addiw	a5,a5,-1
    800017bc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017c0:	60a6                	ld	ra,72(sp)
    800017c2:	6406                	ld	s0,64(sp)
    800017c4:	74e2                	ld	s1,56(sp)
    800017c6:	7942                	ld	s2,48(sp)
    800017c8:	79a2                	ld	s3,40(sp)
    800017ca:	7a02                	ld	s4,32(sp)
    800017cc:	6ae2                	ld	s5,24(sp)
    800017ce:	6b42                	ld	s6,16(sp)
    800017d0:	6ba2                	ld	s7,8(sp)
    800017d2:	6161                	addi	sp,sp,80
    800017d4:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017da:	c8a9                	beqz	s1,8000182c <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017dc:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017e0:	85ca                	mv	a1,s2
    800017e2:	8552                	mv	a0,s4
    800017e4:	00000097          	auipc	ra,0x0
    800017e8:	880080e7          	jalr	-1920(ra) # 80001064 <walkaddr>
    if(pa0 == 0)
    800017ec:	c131                	beqz	a0,80001830 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017ee:	417906b3          	sub	a3,s2,s7
    800017f2:	96ce                	add	a3,a3,s3
    800017f4:	00d4f363          	bgeu	s1,a3,800017fa <copyinstr+0x6c>
    800017f8:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017fa:	955e                	add	a0,a0,s7
    800017fc:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001800:	daf9                	beqz	a3,800017d6 <copyinstr+0x48>
    80001802:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001804:	41650633          	sub	a2,a0,s6
    80001808:	fff48593          	addi	a1,s1,-1
    8000180c:	95da                	add	a1,a1,s6
    while(n > 0){
    8000180e:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001810:	00f60733          	add	a4,a2,a5
    80001814:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdcf40>
    80001818:	df51                	beqz	a4,800017b4 <copyinstr+0x26>
        *dst = *p;
    8000181a:	00e78023          	sb	a4,0(a5)
      --max;
    8000181e:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001822:	0785                	addi	a5,a5,1
    while(n > 0){
    80001824:	fed796e3          	bne	a5,a3,80001810 <copyinstr+0x82>
      dst++;
    80001828:	8b3e                	mv	s6,a5
    8000182a:	b775                	j	800017d6 <copyinstr+0x48>
    8000182c:	4781                	li	a5,0
    8000182e:	b771                	j	800017ba <copyinstr+0x2c>
      return -1;
    80001830:	557d                	li	a0,-1
    80001832:	b779                	j	800017c0 <copyinstr+0x32>
  int got_null = 0;
    80001834:	4781                	li	a5,0
  if(got_null){
    80001836:	37fd                	addiw	a5,a5,-1
    80001838:	0007851b          	sext.w	a0,a5
}
    8000183c:	8082                	ret

000000008000183e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000183e:	7139                	addi	sp,sp,-64
    80001840:	fc06                	sd	ra,56(sp)
    80001842:	f822                	sd	s0,48(sp)
    80001844:	f426                	sd	s1,40(sp)
    80001846:	f04a                	sd	s2,32(sp)
    80001848:	ec4e                	sd	s3,24(sp)
    8000184a:	e852                	sd	s4,16(sp)
    8000184c:	e456                	sd	s5,8(sp)
    8000184e:	e05a                	sd	s6,0(sp)
    80001850:	0080                	addi	s0,sp,64
    80001852:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001854:	0000f497          	auipc	s1,0xf
    80001858:	76c48493          	addi	s1,s1,1900 # 80010fc0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000185c:	8b26                	mv	s6,s1
    8000185e:	00006a97          	auipc	s5,0x6
    80001862:	7a2a8a93          	addi	s5,s5,1954 # 80008000 <etext>
    80001866:	04000937          	lui	s2,0x4000
    8000186a:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00015a17          	auipc	s4,0x15
    80001872:	152a0a13          	addi	s4,s4,338 # 800169c0 <tickslock>
    char *pa = kalloc();
    80001876:	fffff097          	auipc	ra,0xfffff
    8000187a:	270080e7          	jalr	624(ra) # 80000ae6 <kalloc>
    8000187e:	862a                	mv	a2,a0
    if(pa == 0)
    80001880:	c131                	beqz	a0,800018c4 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001882:	416485b3          	sub	a1,s1,s6
    80001886:	858d                	srai	a1,a1,0x3
    80001888:	000ab783          	ld	a5,0(s5)
    8000188c:	02f585b3          	mul	a1,a1,a5
    80001890:	2585                	addiw	a1,a1,1
    80001892:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001896:	4719                	li	a4,6
    80001898:	6685                	lui	a3,0x1
    8000189a:	40b905b3          	sub	a1,s2,a1
    8000189e:	854e                	mv	a0,s3
    800018a0:	00000097          	auipc	ra,0x0
    800018a4:	8a6080e7          	jalr	-1882(ra) # 80001146 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a8:	16848493          	addi	s1,s1,360
    800018ac:	fd4495e3          	bne	s1,s4,80001876 <proc_mapstacks+0x38>
  }
}
    800018b0:	70e2                	ld	ra,56(sp)
    800018b2:	7442                	ld	s0,48(sp)
    800018b4:	74a2                	ld	s1,40(sp)
    800018b6:	7902                	ld	s2,32(sp)
    800018b8:	69e2                	ld	s3,24(sp)
    800018ba:	6a42                	ld	s4,16(sp)
    800018bc:	6aa2                	ld	s5,8(sp)
    800018be:	6b02                	ld	s6,0(sp)
    800018c0:	6121                	addi	sp,sp,64
    800018c2:	8082                	ret
      panic("kalloc");
    800018c4:	00007517          	auipc	a0,0x7
    800018c8:	91450513          	addi	a0,a0,-1772 # 800081d8 <digits+0x198>
    800018cc:	fffff097          	auipc	ra,0xfffff
    800018d0:	c74080e7          	jalr	-908(ra) # 80000540 <panic>

00000000800018d4 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018d4:	7139                	addi	sp,sp,-64
    800018d6:	fc06                	sd	ra,56(sp)
    800018d8:	f822                	sd	s0,48(sp)
    800018da:	f426                	sd	s1,40(sp)
    800018dc:	f04a                	sd	s2,32(sp)
    800018de:	ec4e                	sd	s3,24(sp)
    800018e0:	e852                	sd	s4,16(sp)
    800018e2:	e456                	sd	s5,8(sp)
    800018e4:	e05a                	sd	s6,0(sp)
    800018e6:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e8:	00007597          	auipc	a1,0x7
    800018ec:	8f858593          	addi	a1,a1,-1800 # 800081e0 <digits+0x1a0>
    800018f0:	0000f517          	auipc	a0,0xf
    800018f4:	2a050513          	addi	a0,a0,672 # 80010b90 <pid_lock>
    800018f8:	fffff097          	auipc	ra,0xfffff
    800018fc:	24e080e7          	jalr	590(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001900:	00007597          	auipc	a1,0x7
    80001904:	8e858593          	addi	a1,a1,-1816 # 800081e8 <digits+0x1a8>
    80001908:	0000f517          	auipc	a0,0xf
    8000190c:	2a050513          	addi	a0,a0,672 # 80010ba8 <wait_lock>
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	236080e7          	jalr	566(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001918:	0000f497          	auipc	s1,0xf
    8000191c:	6a848493          	addi	s1,s1,1704 # 80010fc0 <proc>
      initlock(&p->lock, "proc");
    80001920:	00007b17          	auipc	s6,0x7
    80001924:	8d8b0b13          	addi	s6,s6,-1832 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001928:	8aa6                	mv	s5,s1
    8000192a:	00006a17          	auipc	s4,0x6
    8000192e:	6d6a0a13          	addi	s4,s4,1750 # 80008000 <etext>
    80001932:	04000937          	lui	s2,0x4000
    80001936:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001938:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193a:	00015997          	auipc	s3,0x15
    8000193e:	08698993          	addi	s3,s3,134 # 800169c0 <tickslock>
      initlock(&p->lock, "proc");
    80001942:	85da                	mv	a1,s6
    80001944:	8526                	mv	a0,s1
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	200080e7          	jalr	512(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    8000194e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001952:	415487b3          	sub	a5,s1,s5
    80001956:	878d                	srai	a5,a5,0x3
    80001958:	000a3703          	ld	a4,0(s4)
    8000195c:	02e787b3          	mul	a5,a5,a4
    80001960:	2785                	addiw	a5,a5,1
    80001962:	00d7979b          	slliw	a5,a5,0xd
    80001966:	40f907b3          	sub	a5,s2,a5
    8000196a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000196c:	16848493          	addi	s1,s1,360
    80001970:	fd3499e3          	bne	s1,s3,80001942 <procinit+0x6e>
  }
}
    80001974:	70e2                	ld	ra,56(sp)
    80001976:	7442                	ld	s0,48(sp)
    80001978:	74a2                	ld	s1,40(sp)
    8000197a:	7902                	ld	s2,32(sp)
    8000197c:	69e2                	ld	s3,24(sp)
    8000197e:	6a42                	ld	s4,16(sp)
    80001980:	6aa2                	ld	s5,8(sp)
    80001982:	6b02                	ld	s6,0(sp)
    80001984:	6121                	addi	sp,sp,64
    80001986:	8082                	ret

0000000080001988 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001988:	1141                	addi	sp,sp,-16
    8000198a:	e422                	sd	s0,8(sp)
    8000198c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000198e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001990:	2501                	sext.w	a0,a0
    80001992:	6422                	ld	s0,8(sp)
    80001994:	0141                	addi	sp,sp,16
    80001996:	8082                	ret

0000000080001998 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001998:	1141                	addi	sp,sp,-16
    8000199a:	e422                	sd	s0,8(sp)
    8000199c:	0800                	addi	s0,sp,16
    8000199e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019a0:	2781                	sext.w	a5,a5
    800019a2:	079e                	slli	a5,a5,0x7
  return c;
}
    800019a4:	0000f517          	auipc	a0,0xf
    800019a8:	21c50513          	addi	a0,a0,540 # 80010bc0 <cpus>
    800019ac:	953e                	add	a0,a0,a5
    800019ae:	6422                	ld	s0,8(sp)
    800019b0:	0141                	addi	sp,sp,16
    800019b2:	8082                	ret

00000000800019b4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019b4:	1101                	addi	sp,sp,-32
    800019b6:	ec06                	sd	ra,24(sp)
    800019b8:	e822                	sd	s0,16(sp)
    800019ba:	e426                	sd	s1,8(sp)
    800019bc:	1000                	addi	s0,sp,32
  push_off();
    800019be:	fffff097          	auipc	ra,0xfffff
    800019c2:	1cc080e7          	jalr	460(ra) # 80000b8a <push_off>
    800019c6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c8:	2781                	sext.w	a5,a5
    800019ca:	079e                	slli	a5,a5,0x7
    800019cc:	0000f717          	auipc	a4,0xf
    800019d0:	1c470713          	addi	a4,a4,452 # 80010b90 <pid_lock>
    800019d4:	97ba                	add	a5,a5,a4
    800019d6:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d8:	fffff097          	auipc	ra,0xfffff
    800019dc:	252080e7          	jalr	594(ra) # 80000c2a <pop_off>
  return p;
}
    800019e0:	8526                	mv	a0,s1
    800019e2:	60e2                	ld	ra,24(sp)
    800019e4:	6442                	ld	s0,16(sp)
    800019e6:	64a2                	ld	s1,8(sp)
    800019e8:	6105                	addi	sp,sp,32
    800019ea:	8082                	ret

00000000800019ec <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019ec:	1141                	addi	sp,sp,-16
    800019ee:	e406                	sd	ra,8(sp)
    800019f0:	e022                	sd	s0,0(sp)
    800019f2:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019f4:	00000097          	auipc	ra,0x0
    800019f8:	fc0080e7          	jalr	-64(ra) # 800019b4 <myproc>
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	28e080e7          	jalr	654(ra) # 80000c8a <release>

  if (first) {
    80001a04:	00007797          	auipc	a5,0x7
    80001a08:	e7c7a783          	lw	a5,-388(a5) # 80008880 <first.1>
    80001a0c:	eb89                	bnez	a5,80001a1e <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a0e:	00001097          	auipc	ra,0x1
    80001a12:	c5c080e7          	jalr	-932(ra) # 8000266a <usertrapret>
}
    80001a16:	60a2                	ld	ra,8(sp)
    80001a18:	6402                	ld	s0,0(sp)
    80001a1a:	0141                	addi	sp,sp,16
    80001a1c:	8082                	ret
    first = 0;
    80001a1e:	00007797          	auipc	a5,0x7
    80001a22:	e607a123          	sw	zero,-414(a5) # 80008880 <first.1>
    fsinit(ROOTDEV);
    80001a26:	4505                	li	a0,1
    80001a28:	00002097          	auipc	ra,0x2
    80001a2c:	c68080e7          	jalr	-920(ra) # 80003690 <fsinit>
    80001a30:	bff9                	j	80001a0e <forkret+0x22>

0000000080001a32 <allocpid>:
{
    80001a32:	1101                	addi	sp,sp,-32
    80001a34:	ec06                	sd	ra,24(sp)
    80001a36:	e822                	sd	s0,16(sp)
    80001a38:	e426                	sd	s1,8(sp)
    80001a3a:	e04a                	sd	s2,0(sp)
    80001a3c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a3e:	0000f917          	auipc	s2,0xf
    80001a42:	15290913          	addi	s2,s2,338 # 80010b90 <pid_lock>
    80001a46:	854a                	mv	a0,s2
    80001a48:	fffff097          	auipc	ra,0xfffff
    80001a4c:	18e080e7          	jalr	398(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a50:	00007797          	auipc	a5,0x7
    80001a54:	e3478793          	addi	a5,a5,-460 # 80008884 <nextpid>
    80001a58:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a5a:	0014871b          	addiw	a4,s1,1
    80001a5e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a60:	854a                	mv	a0,s2
    80001a62:	fffff097          	auipc	ra,0xfffff
    80001a66:	228080e7          	jalr	552(ra) # 80000c8a <release>
}
    80001a6a:	8526                	mv	a0,s1
    80001a6c:	60e2                	ld	ra,24(sp)
    80001a6e:	6442                	ld	s0,16(sp)
    80001a70:	64a2                	ld	s1,8(sp)
    80001a72:	6902                	ld	s2,0(sp)
    80001a74:	6105                	addi	sp,sp,32
    80001a76:	8082                	ret

0000000080001a78 <proc_pagetable>:
{
    80001a78:	1101                	addi	sp,sp,-32
    80001a7a:	ec06                	sd	ra,24(sp)
    80001a7c:	e822                	sd	s0,16(sp)
    80001a7e:	e426                	sd	s1,8(sp)
    80001a80:	e04a                	sd	s2,0(sp)
    80001a82:	1000                	addi	s0,sp,32
    80001a84:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a86:	00000097          	auipc	ra,0x0
    80001a8a:	8aa080e7          	jalr	-1878(ra) # 80001330 <uvmcreate>
    80001a8e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a90:	c121                	beqz	a0,80001ad0 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a92:	4729                	li	a4,10
    80001a94:	00005697          	auipc	a3,0x5
    80001a98:	56c68693          	addi	a3,a3,1388 # 80007000 <_trampoline>
    80001a9c:	6605                	lui	a2,0x1
    80001a9e:	040005b7          	lui	a1,0x4000
    80001aa2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aa4:	05b2                	slli	a1,a1,0xc
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	600080e7          	jalr	1536(ra) # 800010a6 <mappages>
    80001aae:	02054863          	bltz	a0,80001ade <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ab2:	4719                	li	a4,6
    80001ab4:	05893683          	ld	a3,88(s2)
    80001ab8:	6605                	lui	a2,0x1
    80001aba:	020005b7          	lui	a1,0x2000
    80001abe:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ac0:	05b6                	slli	a1,a1,0xd
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	5e2080e7          	jalr	1506(ra) # 800010a6 <mappages>
    80001acc:	02054163          	bltz	a0,80001aee <proc_pagetable+0x76>
}
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	60e2                	ld	ra,24(sp)
    80001ad4:	6442                	ld	s0,16(sp)
    80001ad6:	64a2                	ld	s1,8(sp)
    80001ad8:	6902                	ld	s2,0(sp)
    80001ada:	6105                	addi	sp,sp,32
    80001adc:	8082                	ret
    uvmfree(pagetable, 0);
    80001ade:	4581                	li	a1,0
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	00000097          	auipc	ra,0x0
    80001ae6:	a54080e7          	jalr	-1452(ra) # 80001536 <uvmfree>
    return 0;
    80001aea:	4481                	li	s1,0
    80001aec:	b7d5                	j	80001ad0 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aee:	4681                	li	a3,0
    80001af0:	4605                	li	a2,1
    80001af2:	040005b7          	lui	a1,0x4000
    80001af6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af8:	05b2                	slli	a1,a1,0xc
    80001afa:	8526                	mv	a0,s1
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	770080e7          	jalr	1904(ra) # 8000126c <uvmunmap>
    uvmfree(pagetable, 0);
    80001b04:	4581                	li	a1,0
    80001b06:	8526                	mv	a0,s1
    80001b08:	00000097          	auipc	ra,0x0
    80001b0c:	a2e080e7          	jalr	-1490(ra) # 80001536 <uvmfree>
    return 0;
    80001b10:	4481                	li	s1,0
    80001b12:	bf7d                	j	80001ad0 <proc_pagetable+0x58>

0000000080001b14 <proc_freepagetable>:
{
    80001b14:	1101                	addi	sp,sp,-32
    80001b16:	ec06                	sd	ra,24(sp)
    80001b18:	e822                	sd	s0,16(sp)
    80001b1a:	e426                	sd	s1,8(sp)
    80001b1c:	e04a                	sd	s2,0(sp)
    80001b1e:	1000                	addi	s0,sp,32
    80001b20:	84aa                	mv	s1,a0
    80001b22:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b24:	4681                	li	a3,0
    80001b26:	4605                	li	a2,1
    80001b28:	040005b7          	lui	a1,0x4000
    80001b2c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b2e:	05b2                	slli	a1,a1,0xc
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	73c080e7          	jalr	1852(ra) # 8000126c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b38:	4681                	li	a3,0
    80001b3a:	4605                	li	a2,1
    80001b3c:	020005b7          	lui	a1,0x2000
    80001b40:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b42:	05b6                	slli	a1,a1,0xd
    80001b44:	8526                	mv	a0,s1
    80001b46:	fffff097          	auipc	ra,0xfffff
    80001b4a:	726080e7          	jalr	1830(ra) # 8000126c <uvmunmap>
  uvmfree(pagetable, sz);
    80001b4e:	85ca                	mv	a1,s2
    80001b50:	8526                	mv	a0,s1
    80001b52:	00000097          	auipc	ra,0x0
    80001b56:	9e4080e7          	jalr	-1564(ra) # 80001536 <uvmfree>
}
    80001b5a:	60e2                	ld	ra,24(sp)
    80001b5c:	6442                	ld	s0,16(sp)
    80001b5e:	64a2                	ld	s1,8(sp)
    80001b60:	6902                	ld	s2,0(sp)
    80001b62:	6105                	addi	sp,sp,32
    80001b64:	8082                	ret

0000000080001b66 <freeproc>:
{
    80001b66:	1101                	addi	sp,sp,-32
    80001b68:	ec06                	sd	ra,24(sp)
    80001b6a:	e822                	sd	s0,16(sp)
    80001b6c:	e426                	sd	s1,8(sp)
    80001b6e:	1000                	addi	s0,sp,32
    80001b70:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b72:	6d28                	ld	a0,88(a0)
    80001b74:	c509                	beqz	a0,80001b7e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b76:	fffff097          	auipc	ra,0xfffff
    80001b7a:	e72080e7          	jalr	-398(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001b7e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b82:	68a8                	ld	a0,80(s1)
    80001b84:	c511                	beqz	a0,80001b90 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b86:	64ac                	ld	a1,72(s1)
    80001b88:	00000097          	auipc	ra,0x0
    80001b8c:	f8c080e7          	jalr	-116(ra) # 80001b14 <proc_freepagetable>
  p->pagetable = 0;
    80001b90:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b94:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b98:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b9c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ba0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ba4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bac:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bb0:	0004ac23          	sw	zero,24(s1)
}
    80001bb4:	60e2                	ld	ra,24(sp)
    80001bb6:	6442                	ld	s0,16(sp)
    80001bb8:	64a2                	ld	s1,8(sp)
    80001bba:	6105                	addi	sp,sp,32
    80001bbc:	8082                	ret

0000000080001bbe <allocproc>:
{
    80001bbe:	1101                	addi	sp,sp,-32
    80001bc0:	ec06                	sd	ra,24(sp)
    80001bc2:	e822                	sd	s0,16(sp)
    80001bc4:	e426                	sd	s1,8(sp)
    80001bc6:	e04a                	sd	s2,0(sp)
    80001bc8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bca:	0000f497          	auipc	s1,0xf
    80001bce:	3f648493          	addi	s1,s1,1014 # 80010fc0 <proc>
    80001bd2:	00015917          	auipc	s2,0x15
    80001bd6:	dee90913          	addi	s2,s2,-530 # 800169c0 <tickslock>
    acquire(&p->lock);
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	ffa080e7          	jalr	-6(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001be4:	4c9c                	lw	a5,24(s1)
    80001be6:	cf81                	beqz	a5,80001bfe <allocproc+0x40>
      release(&p->lock);
    80001be8:	8526                	mv	a0,s1
    80001bea:	fffff097          	auipc	ra,0xfffff
    80001bee:	0a0080e7          	jalr	160(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf2:	16848493          	addi	s1,s1,360
    80001bf6:	ff2492e3          	bne	s1,s2,80001bda <allocproc+0x1c>
  return 0;
    80001bfa:	4481                	li	s1,0
    80001bfc:	a889                	j	80001c4e <allocproc+0x90>
  p->pid = allocpid();
    80001bfe:	00000097          	auipc	ra,0x0
    80001c02:	e34080e7          	jalr	-460(ra) # 80001a32 <allocpid>
    80001c06:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c08:	4785                	li	a5,1
    80001c0a:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	eda080e7          	jalr	-294(ra) # 80000ae6 <kalloc>
    80001c14:	892a                	mv	s2,a0
    80001c16:	eca8                	sd	a0,88(s1)
    80001c18:	c131                	beqz	a0,80001c5c <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	00000097          	auipc	ra,0x0
    80001c20:	e5c080e7          	jalr	-420(ra) # 80001a78 <proc_pagetable>
    80001c24:	892a                	mv	s2,a0
    80001c26:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c28:	c531                	beqz	a0,80001c74 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c2a:	07000613          	li	a2,112
    80001c2e:	4581                	li	a1,0
    80001c30:	06048513          	addi	a0,s1,96
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	09e080e7          	jalr	158(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c3c:	00000797          	auipc	a5,0x0
    80001c40:	db078793          	addi	a5,a5,-592 # 800019ec <forkret>
    80001c44:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c46:	60bc                	ld	a5,64(s1)
    80001c48:	6705                	lui	a4,0x1
    80001c4a:	97ba                	add	a5,a5,a4
    80001c4c:	f4bc                	sd	a5,104(s1)
}
    80001c4e:	8526                	mv	a0,s1
    80001c50:	60e2                	ld	ra,24(sp)
    80001c52:	6442                	ld	s0,16(sp)
    80001c54:	64a2                	ld	s1,8(sp)
    80001c56:	6902                	ld	s2,0(sp)
    80001c58:	6105                	addi	sp,sp,32
    80001c5a:	8082                	ret
    freeproc(p);
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	00000097          	auipc	ra,0x0
    80001c62:	f08080e7          	jalr	-248(ra) # 80001b66 <freeproc>
    release(&p->lock);
    80001c66:	8526                	mv	a0,s1
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	022080e7          	jalr	34(ra) # 80000c8a <release>
    return 0;
    80001c70:	84ca                	mv	s1,s2
    80001c72:	bff1                	j	80001c4e <allocproc+0x90>
    freeproc(p);
    80001c74:	8526                	mv	a0,s1
    80001c76:	00000097          	auipc	ra,0x0
    80001c7a:	ef0080e7          	jalr	-272(ra) # 80001b66 <freeproc>
    release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	00a080e7          	jalr	10(ra) # 80000c8a <release>
    return 0;
    80001c88:	84ca                	mv	s1,s2
    80001c8a:	b7d1                	j	80001c4e <allocproc+0x90>

0000000080001c8c <userinit>:
{
    80001c8c:	1101                	addi	sp,sp,-32
    80001c8e:	ec06                	sd	ra,24(sp)
    80001c90:	e822                	sd	s0,16(sp)
    80001c92:	e426                	sd	s1,8(sp)
    80001c94:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c96:	00000097          	auipc	ra,0x0
    80001c9a:	f28080e7          	jalr	-216(ra) # 80001bbe <allocproc>
    80001c9e:	84aa                	mv	s1,a0
  initproc = p;
    80001ca0:	00007797          	auipc	a5,0x7
    80001ca4:	c6a7bc23          	sd	a0,-904(a5) # 80008918 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ca8:	03400613          	li	a2,52
    80001cac:	00007597          	auipc	a1,0x7
    80001cb0:	be458593          	addi	a1,a1,-1052 # 80008890 <initcode>
    80001cb4:	6928                	ld	a0,80(a0)
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	6a8080e7          	jalr	1704(ra) # 8000135e <uvmfirst>
  p->sz = PGSIZE;
    80001cbe:	6785                	lui	a5,0x1
    80001cc0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cc2:	6cb8                	ld	a4,88(s1)
    80001cc4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cc8:	6cb8                	ld	a4,88(s1)
    80001cca:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ccc:	4641                	li	a2,16
    80001cce:	00006597          	auipc	a1,0x6
    80001cd2:	53258593          	addi	a1,a1,1330 # 80008200 <digits+0x1c0>
    80001cd6:	15848513          	addi	a0,s1,344
    80001cda:	fffff097          	auipc	ra,0xfffff
    80001cde:	142080e7          	jalr	322(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001ce2:	00006517          	auipc	a0,0x6
    80001ce6:	52e50513          	addi	a0,a0,1326 # 80008210 <digits+0x1d0>
    80001cea:	00002097          	auipc	ra,0x2
    80001cee:	3d0080e7          	jalr	976(ra) # 800040ba <namei>
    80001cf2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cf6:	478d                	li	a5,3
    80001cf8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	f8e080e7          	jalr	-114(ra) # 80000c8a <release>
}
    80001d04:	60e2                	ld	ra,24(sp)
    80001d06:	6442                	ld	s0,16(sp)
    80001d08:	64a2                	ld	s1,8(sp)
    80001d0a:	6105                	addi	sp,sp,32
    80001d0c:	8082                	ret

0000000080001d0e <growproc>:
{
    80001d0e:	1101                	addi	sp,sp,-32
    80001d10:	ec06                	sd	ra,24(sp)
    80001d12:	e822                	sd	s0,16(sp)
    80001d14:	e426                	sd	s1,8(sp)
    80001d16:	e04a                	sd	s2,0(sp)
    80001d18:	1000                	addi	s0,sp,32
    80001d1a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d1c:	00000097          	auipc	ra,0x0
    80001d20:	c98080e7          	jalr	-872(ra) # 800019b4 <myproc>
    80001d24:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d26:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d28:	01204c63          	bgtz	s2,80001d40 <growproc+0x32>
  } else if(n < 0){
    80001d2c:	02094663          	bltz	s2,80001d58 <growproc+0x4a>
  p->sz = sz;
    80001d30:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d32:	4501                	li	a0,0
}
    80001d34:	60e2                	ld	ra,24(sp)
    80001d36:	6442                	ld	s0,16(sp)
    80001d38:	64a2                	ld	s1,8(sp)
    80001d3a:	6902                	ld	s2,0(sp)
    80001d3c:	6105                	addi	sp,sp,32
    80001d3e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d40:	4691                	li	a3,4
    80001d42:	00b90633          	add	a2,s2,a1
    80001d46:	6928                	ld	a0,80(a0)
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	6d0080e7          	jalr	1744(ra) # 80001418 <uvmalloc>
    80001d50:	85aa                	mv	a1,a0
    80001d52:	fd79                	bnez	a0,80001d30 <growproc+0x22>
      return -1;
    80001d54:	557d                	li	a0,-1
    80001d56:	bff9                	j	80001d34 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d58:	00b90633          	add	a2,s2,a1
    80001d5c:	6928                	ld	a0,80(a0)
    80001d5e:	fffff097          	auipc	ra,0xfffff
    80001d62:	672080e7          	jalr	1650(ra) # 800013d0 <uvmdealloc>
    80001d66:	85aa                	mv	a1,a0
    80001d68:	b7e1                	j	80001d30 <growproc+0x22>

0000000080001d6a <fork>:
{
    80001d6a:	7139                	addi	sp,sp,-64
    80001d6c:	fc06                	sd	ra,56(sp)
    80001d6e:	f822                	sd	s0,48(sp)
    80001d70:	f426                	sd	s1,40(sp)
    80001d72:	f04a                	sd	s2,32(sp)
    80001d74:	ec4e                	sd	s3,24(sp)
    80001d76:	e852                	sd	s4,16(sp)
    80001d78:	e456                	sd	s5,8(sp)
    80001d7a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d7c:	00000097          	auipc	ra,0x0
    80001d80:	c38080e7          	jalr	-968(ra) # 800019b4 <myproc>
    80001d84:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d86:	00000097          	auipc	ra,0x0
    80001d8a:	e38080e7          	jalr	-456(ra) # 80001bbe <allocproc>
    80001d8e:	10050c63          	beqz	a0,80001ea6 <fork+0x13c>
    80001d92:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d94:	048ab603          	ld	a2,72(s5)
    80001d98:	692c                	ld	a1,80(a0)
    80001d9a:	050ab503          	ld	a0,80(s5)
    80001d9e:	fffff097          	auipc	ra,0xfffff
    80001da2:	7d2080e7          	jalr	2002(ra) # 80001570 <uvmcopy>
    80001da6:	04054863          	bltz	a0,80001df6 <fork+0x8c>
  np->sz = p->sz;
    80001daa:	048ab783          	ld	a5,72(s5)
    80001dae:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001db2:	058ab683          	ld	a3,88(s5)
    80001db6:	87b6                	mv	a5,a3
    80001db8:	058a3703          	ld	a4,88(s4)
    80001dbc:	12068693          	addi	a3,a3,288
    80001dc0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dc4:	6788                	ld	a0,8(a5)
    80001dc6:	6b8c                	ld	a1,16(a5)
    80001dc8:	6f90                	ld	a2,24(a5)
    80001dca:	01073023          	sd	a6,0(a4)
    80001dce:	e708                	sd	a0,8(a4)
    80001dd0:	eb0c                	sd	a1,16(a4)
    80001dd2:	ef10                	sd	a2,24(a4)
    80001dd4:	02078793          	addi	a5,a5,32
    80001dd8:	02070713          	addi	a4,a4,32
    80001ddc:	fed792e3          	bne	a5,a3,80001dc0 <fork+0x56>
  np->trapframe->a0 = 0;
    80001de0:	058a3783          	ld	a5,88(s4)
    80001de4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001de8:	0d0a8493          	addi	s1,s5,208
    80001dec:	0d0a0913          	addi	s2,s4,208
    80001df0:	150a8993          	addi	s3,s5,336
    80001df4:	a00d                	j	80001e16 <fork+0xac>
    freeproc(np);
    80001df6:	8552                	mv	a0,s4
    80001df8:	00000097          	auipc	ra,0x0
    80001dfc:	d6e080e7          	jalr	-658(ra) # 80001b66 <freeproc>
    release(&np->lock);
    80001e00:	8552                	mv	a0,s4
    80001e02:	fffff097          	auipc	ra,0xfffff
    80001e06:	e88080e7          	jalr	-376(ra) # 80000c8a <release>
    return -1;
    80001e0a:	597d                	li	s2,-1
    80001e0c:	a059                	j	80001e92 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e0e:	04a1                	addi	s1,s1,8
    80001e10:	0921                	addi	s2,s2,8
    80001e12:	01348b63          	beq	s1,s3,80001e28 <fork+0xbe>
    if(p->ofile[i])
    80001e16:	6088                	ld	a0,0(s1)
    80001e18:	d97d                	beqz	a0,80001e0e <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e1a:	00003097          	auipc	ra,0x3
    80001e1e:	936080e7          	jalr	-1738(ra) # 80004750 <filedup>
    80001e22:	00a93023          	sd	a0,0(s2)
    80001e26:	b7e5                	j	80001e0e <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e28:	150ab503          	ld	a0,336(s5)
    80001e2c:	00002097          	auipc	ra,0x2
    80001e30:	aa4080e7          	jalr	-1372(ra) # 800038d0 <idup>
    80001e34:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e38:	4641                	li	a2,16
    80001e3a:	158a8593          	addi	a1,s5,344
    80001e3e:	158a0513          	addi	a0,s4,344
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	fda080e7          	jalr	-38(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e4a:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e4e:	8552                	mv	a0,s4
    80001e50:	fffff097          	auipc	ra,0xfffff
    80001e54:	e3a080e7          	jalr	-454(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e58:	0000f497          	auipc	s1,0xf
    80001e5c:	d5048493          	addi	s1,s1,-688 # 80010ba8 <wait_lock>
    80001e60:	8526                	mv	a0,s1
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	d74080e7          	jalr	-652(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e6a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e6e:	8526                	mv	a0,s1
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	e1a080e7          	jalr	-486(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e78:	8552                	mv	a0,s4
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	d5c080e7          	jalr	-676(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e82:	478d                	li	a5,3
    80001e84:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e88:	8552                	mv	a0,s4
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	e00080e7          	jalr	-512(ra) # 80000c8a <release>
}
    80001e92:	854a                	mv	a0,s2
    80001e94:	70e2                	ld	ra,56(sp)
    80001e96:	7442                	ld	s0,48(sp)
    80001e98:	74a2                	ld	s1,40(sp)
    80001e9a:	7902                	ld	s2,32(sp)
    80001e9c:	69e2                	ld	s3,24(sp)
    80001e9e:	6a42                	ld	s4,16(sp)
    80001ea0:	6aa2                	ld	s5,8(sp)
    80001ea2:	6121                	addi	sp,sp,64
    80001ea4:	8082                	ret
    return -1;
    80001ea6:	597d                	li	s2,-1
    80001ea8:	b7ed                	j	80001e92 <fork+0x128>

0000000080001eaa <scheduler>:
{
    80001eaa:	7139                	addi	sp,sp,-64
    80001eac:	fc06                	sd	ra,56(sp)
    80001eae:	f822                	sd	s0,48(sp)
    80001eb0:	f426                	sd	s1,40(sp)
    80001eb2:	f04a                	sd	s2,32(sp)
    80001eb4:	ec4e                	sd	s3,24(sp)
    80001eb6:	e852                	sd	s4,16(sp)
    80001eb8:	e456                	sd	s5,8(sp)
    80001eba:	e05a                	sd	s6,0(sp)
    80001ebc:	0080                	addi	s0,sp,64
    80001ebe:	8792                	mv	a5,tp
  int id = r_tp();
    80001ec0:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ec2:	00779a93          	slli	s5,a5,0x7
    80001ec6:	0000f717          	auipc	a4,0xf
    80001eca:	cca70713          	addi	a4,a4,-822 # 80010b90 <pid_lock>
    80001ece:	9756                	add	a4,a4,s5
    80001ed0:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ed4:	0000f717          	auipc	a4,0xf
    80001ed8:	cf470713          	addi	a4,a4,-780 # 80010bc8 <cpus+0x8>
    80001edc:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ede:	498d                	li	s3,3
        p->state = RUNNING;
    80001ee0:	4b11                	li	s6,4
        c->proc = p;
    80001ee2:	079e                	slli	a5,a5,0x7
    80001ee4:	0000fa17          	auipc	s4,0xf
    80001ee8:	caca0a13          	addi	s4,s4,-852 # 80010b90 <pid_lock>
    80001eec:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001eee:	00015917          	auipc	s2,0x15
    80001ef2:	ad290913          	addi	s2,s2,-1326 # 800169c0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001efa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001efe:	10079073          	csrw	sstatus,a5
    80001f02:	0000f497          	auipc	s1,0xf
    80001f06:	0be48493          	addi	s1,s1,190 # 80010fc0 <proc>
    80001f0a:	a811                	j	80001f1e <scheduler+0x74>
      release(&p->lock);
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	d7c080e7          	jalr	-644(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f16:	16848493          	addi	s1,s1,360
    80001f1a:	fd248ee3          	beq	s1,s2,80001ef6 <scheduler+0x4c>
      acquire(&p->lock);
    80001f1e:	8526                	mv	a0,s1
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	cb6080e7          	jalr	-842(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f28:	4c9c                	lw	a5,24(s1)
    80001f2a:	ff3791e3          	bne	a5,s3,80001f0c <scheduler+0x62>
        p->state = RUNNING;
    80001f2e:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f32:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f36:	06048593          	addi	a1,s1,96
    80001f3a:	8556                	mv	a0,s5
    80001f3c:	00000097          	auipc	ra,0x0
    80001f40:	684080e7          	jalr	1668(ra) # 800025c0 <swtch>
        c->proc = 0;
    80001f44:	020a3823          	sd	zero,48(s4)
    80001f48:	b7d1                	j	80001f0c <scheduler+0x62>

0000000080001f4a <sched>:
{
    80001f4a:	7179                	addi	sp,sp,-48
    80001f4c:	f406                	sd	ra,40(sp)
    80001f4e:	f022                	sd	s0,32(sp)
    80001f50:	ec26                	sd	s1,24(sp)
    80001f52:	e84a                	sd	s2,16(sp)
    80001f54:	e44e                	sd	s3,8(sp)
    80001f56:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f58:	00000097          	auipc	ra,0x0
    80001f5c:	a5c080e7          	jalr	-1444(ra) # 800019b4 <myproc>
    80001f60:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f62:	fffff097          	auipc	ra,0xfffff
    80001f66:	bfa080e7          	jalr	-1030(ra) # 80000b5c <holding>
    80001f6a:	c93d                	beqz	a0,80001fe0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f6c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f6e:	2781                	sext.w	a5,a5
    80001f70:	079e                	slli	a5,a5,0x7
    80001f72:	0000f717          	auipc	a4,0xf
    80001f76:	c1e70713          	addi	a4,a4,-994 # 80010b90 <pid_lock>
    80001f7a:	97ba                	add	a5,a5,a4
    80001f7c:	0a87a703          	lw	a4,168(a5)
    80001f80:	4785                	li	a5,1
    80001f82:	06f71763          	bne	a4,a5,80001ff0 <sched+0xa6>
  if(p->state == RUNNING)
    80001f86:	4c98                	lw	a4,24(s1)
    80001f88:	4791                	li	a5,4
    80001f8a:	06f70b63          	beq	a4,a5,80002000 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f8e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f92:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f94:	efb5                	bnez	a5,80002010 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f96:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f98:	0000f917          	auipc	s2,0xf
    80001f9c:	bf890913          	addi	s2,s2,-1032 # 80010b90 <pid_lock>
    80001fa0:	2781                	sext.w	a5,a5
    80001fa2:	079e                	slli	a5,a5,0x7
    80001fa4:	97ca                	add	a5,a5,s2
    80001fa6:	0ac7a983          	lw	s3,172(a5)
    80001faa:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fac:	2781                	sext.w	a5,a5
    80001fae:	079e                	slli	a5,a5,0x7
    80001fb0:	0000f597          	auipc	a1,0xf
    80001fb4:	c1858593          	addi	a1,a1,-1000 # 80010bc8 <cpus+0x8>
    80001fb8:	95be                	add	a1,a1,a5
    80001fba:	06048513          	addi	a0,s1,96
    80001fbe:	00000097          	auipc	ra,0x0
    80001fc2:	602080e7          	jalr	1538(ra) # 800025c0 <swtch>
    80001fc6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fc8:	2781                	sext.w	a5,a5
    80001fca:	079e                	slli	a5,a5,0x7
    80001fcc:	993e                	add	s2,s2,a5
    80001fce:	0b392623          	sw	s3,172(s2)
}
    80001fd2:	70a2                	ld	ra,40(sp)
    80001fd4:	7402                	ld	s0,32(sp)
    80001fd6:	64e2                	ld	s1,24(sp)
    80001fd8:	6942                	ld	s2,16(sp)
    80001fda:	69a2                	ld	s3,8(sp)
    80001fdc:	6145                	addi	sp,sp,48
    80001fde:	8082                	ret
    panic("sched p->lock");
    80001fe0:	00006517          	auipc	a0,0x6
    80001fe4:	23850513          	addi	a0,a0,568 # 80008218 <digits+0x1d8>
    80001fe8:	ffffe097          	auipc	ra,0xffffe
    80001fec:	558080e7          	jalr	1368(ra) # 80000540 <panic>
    panic("sched locks");
    80001ff0:	00006517          	auipc	a0,0x6
    80001ff4:	23850513          	addi	a0,a0,568 # 80008228 <digits+0x1e8>
    80001ff8:	ffffe097          	auipc	ra,0xffffe
    80001ffc:	548080e7          	jalr	1352(ra) # 80000540 <panic>
    panic("sched running");
    80002000:	00006517          	auipc	a0,0x6
    80002004:	23850513          	addi	a0,a0,568 # 80008238 <digits+0x1f8>
    80002008:	ffffe097          	auipc	ra,0xffffe
    8000200c:	538080e7          	jalr	1336(ra) # 80000540 <panic>
    panic("sched interruptible");
    80002010:	00006517          	auipc	a0,0x6
    80002014:	23850513          	addi	a0,a0,568 # 80008248 <digits+0x208>
    80002018:	ffffe097          	auipc	ra,0xffffe
    8000201c:	528080e7          	jalr	1320(ra) # 80000540 <panic>

0000000080002020 <yield>:
{
    80002020:	1101                	addi	sp,sp,-32
    80002022:	ec06                	sd	ra,24(sp)
    80002024:	e822                	sd	s0,16(sp)
    80002026:	e426                	sd	s1,8(sp)
    80002028:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000202a:	00000097          	auipc	ra,0x0
    8000202e:	98a080e7          	jalr	-1654(ra) # 800019b4 <myproc>
    80002032:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	ba2080e7          	jalr	-1118(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    8000203c:	478d                	li	a5,3
    8000203e:	cc9c                	sw	a5,24(s1)
  sched();
    80002040:	00000097          	auipc	ra,0x0
    80002044:	f0a080e7          	jalr	-246(ra) # 80001f4a <sched>
  release(&p->lock);
    80002048:	8526                	mv	a0,s1
    8000204a:	fffff097          	auipc	ra,0xfffff
    8000204e:	c40080e7          	jalr	-960(ra) # 80000c8a <release>
}
    80002052:	60e2                	ld	ra,24(sp)
    80002054:	6442                	ld	s0,16(sp)
    80002056:	64a2                	ld	s1,8(sp)
    80002058:	6105                	addi	sp,sp,32
    8000205a:	8082                	ret

000000008000205c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000205c:	7179                	addi	sp,sp,-48
    8000205e:	f406                	sd	ra,40(sp)
    80002060:	f022                	sd	s0,32(sp)
    80002062:	ec26                	sd	s1,24(sp)
    80002064:	e84a                	sd	s2,16(sp)
    80002066:	e44e                	sd	s3,8(sp)
    80002068:	1800                	addi	s0,sp,48
    8000206a:	89aa                	mv	s3,a0
    8000206c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000206e:	00000097          	auipc	ra,0x0
    80002072:	946080e7          	jalr	-1722(ra) # 800019b4 <myproc>
    80002076:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002078:	fffff097          	auipc	ra,0xfffff
    8000207c:	b5e080e7          	jalr	-1186(ra) # 80000bd6 <acquire>
  release(lk);
    80002080:	854a                	mv	a0,s2
    80002082:	fffff097          	auipc	ra,0xfffff
    80002086:	c08080e7          	jalr	-1016(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    8000208a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000208e:	4789                	li	a5,2
    80002090:	cc9c                	sw	a5,24(s1)

  sched();
    80002092:	00000097          	auipc	ra,0x0
    80002096:	eb8080e7          	jalr	-328(ra) # 80001f4a <sched>

  // Tidy up.
  p->chan = 0;
    8000209a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000209e:	8526                	mv	a0,s1
    800020a0:	fffff097          	auipc	ra,0xfffff
    800020a4:	bea080e7          	jalr	-1046(ra) # 80000c8a <release>
  acquire(lk);
    800020a8:	854a                	mv	a0,s2
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	b2c080e7          	jalr	-1236(ra) # 80000bd6 <acquire>
}
    800020b2:	70a2                	ld	ra,40(sp)
    800020b4:	7402                	ld	s0,32(sp)
    800020b6:	64e2                	ld	s1,24(sp)
    800020b8:	6942                	ld	s2,16(sp)
    800020ba:	69a2                	ld	s3,8(sp)
    800020bc:	6145                	addi	sp,sp,48
    800020be:	8082                	ret

00000000800020c0 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020c0:	7139                	addi	sp,sp,-64
    800020c2:	fc06                	sd	ra,56(sp)
    800020c4:	f822                	sd	s0,48(sp)
    800020c6:	f426                	sd	s1,40(sp)
    800020c8:	f04a                	sd	s2,32(sp)
    800020ca:	ec4e                	sd	s3,24(sp)
    800020cc:	e852                	sd	s4,16(sp)
    800020ce:	e456                	sd	s5,8(sp)
    800020d0:	0080                	addi	s0,sp,64
    800020d2:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020d4:	0000f497          	auipc	s1,0xf
    800020d8:	eec48493          	addi	s1,s1,-276 # 80010fc0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020dc:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020de:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020e0:	00015917          	auipc	s2,0x15
    800020e4:	8e090913          	addi	s2,s2,-1824 # 800169c0 <tickslock>
    800020e8:	a811                	j	800020fc <wakeup+0x3c>
      }
      release(&p->lock);
    800020ea:	8526                	mv	a0,s1
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	b9e080e7          	jalr	-1122(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020f4:	16848493          	addi	s1,s1,360
    800020f8:	03248663          	beq	s1,s2,80002124 <wakeup+0x64>
    if(p != myproc()){
    800020fc:	00000097          	auipc	ra,0x0
    80002100:	8b8080e7          	jalr	-1864(ra) # 800019b4 <myproc>
    80002104:	fea488e3          	beq	s1,a0,800020f4 <wakeup+0x34>
      acquire(&p->lock);
    80002108:	8526                	mv	a0,s1
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	acc080e7          	jalr	-1332(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002112:	4c9c                	lw	a5,24(s1)
    80002114:	fd379be3          	bne	a5,s3,800020ea <wakeup+0x2a>
    80002118:	709c                	ld	a5,32(s1)
    8000211a:	fd4798e3          	bne	a5,s4,800020ea <wakeup+0x2a>
        p->state = RUNNABLE;
    8000211e:	0154ac23          	sw	s5,24(s1)
    80002122:	b7e1                	j	800020ea <wakeup+0x2a>
    }
  }
}
    80002124:	70e2                	ld	ra,56(sp)
    80002126:	7442                	ld	s0,48(sp)
    80002128:	74a2                	ld	s1,40(sp)
    8000212a:	7902                	ld	s2,32(sp)
    8000212c:	69e2                	ld	s3,24(sp)
    8000212e:	6a42                	ld	s4,16(sp)
    80002130:	6aa2                	ld	s5,8(sp)
    80002132:	6121                	addi	sp,sp,64
    80002134:	8082                	ret

0000000080002136 <reparent>:
{
    80002136:	7179                	addi	sp,sp,-48
    80002138:	f406                	sd	ra,40(sp)
    8000213a:	f022                	sd	s0,32(sp)
    8000213c:	ec26                	sd	s1,24(sp)
    8000213e:	e84a                	sd	s2,16(sp)
    80002140:	e44e                	sd	s3,8(sp)
    80002142:	e052                	sd	s4,0(sp)
    80002144:	1800                	addi	s0,sp,48
    80002146:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002148:	0000f497          	auipc	s1,0xf
    8000214c:	e7848493          	addi	s1,s1,-392 # 80010fc0 <proc>
      pp->parent = initproc;
    80002150:	00006a17          	auipc	s4,0x6
    80002154:	7c8a0a13          	addi	s4,s4,1992 # 80008918 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002158:	00015997          	auipc	s3,0x15
    8000215c:	86898993          	addi	s3,s3,-1944 # 800169c0 <tickslock>
    80002160:	a029                	j	8000216a <reparent+0x34>
    80002162:	16848493          	addi	s1,s1,360
    80002166:	01348d63          	beq	s1,s3,80002180 <reparent+0x4a>
    if(pp->parent == p){
    8000216a:	7c9c                	ld	a5,56(s1)
    8000216c:	ff279be3          	bne	a5,s2,80002162 <reparent+0x2c>
      pp->parent = initproc;
    80002170:	000a3503          	ld	a0,0(s4)
    80002174:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002176:	00000097          	auipc	ra,0x0
    8000217a:	f4a080e7          	jalr	-182(ra) # 800020c0 <wakeup>
    8000217e:	b7d5                	j	80002162 <reparent+0x2c>
}
    80002180:	70a2                	ld	ra,40(sp)
    80002182:	7402                	ld	s0,32(sp)
    80002184:	64e2                	ld	s1,24(sp)
    80002186:	6942                	ld	s2,16(sp)
    80002188:	69a2                	ld	s3,8(sp)
    8000218a:	6a02                	ld	s4,0(sp)
    8000218c:	6145                	addi	sp,sp,48
    8000218e:	8082                	ret

0000000080002190 <exit>:
{
    80002190:	7179                	addi	sp,sp,-48
    80002192:	f406                	sd	ra,40(sp)
    80002194:	f022                	sd	s0,32(sp)
    80002196:	ec26                	sd	s1,24(sp)
    80002198:	e84a                	sd	s2,16(sp)
    8000219a:	e44e                	sd	s3,8(sp)
    8000219c:	e052                	sd	s4,0(sp)
    8000219e:	1800                	addi	s0,sp,48
    800021a0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021a2:	00000097          	auipc	ra,0x0
    800021a6:	812080e7          	jalr	-2030(ra) # 800019b4 <myproc>
    800021aa:	89aa                	mv	s3,a0
  if(p == initproc)
    800021ac:	00006797          	auipc	a5,0x6
    800021b0:	76c7b783          	ld	a5,1900(a5) # 80008918 <initproc>
    800021b4:	0d050493          	addi	s1,a0,208
    800021b8:	15050913          	addi	s2,a0,336
    800021bc:	02a79363          	bne	a5,a0,800021e2 <exit+0x52>
    panic("init exiting");
    800021c0:	00006517          	auipc	a0,0x6
    800021c4:	0a050513          	addi	a0,a0,160 # 80008260 <digits+0x220>
    800021c8:	ffffe097          	auipc	ra,0xffffe
    800021cc:	378080e7          	jalr	888(ra) # 80000540 <panic>
      fileclose(f);
    800021d0:	00002097          	auipc	ra,0x2
    800021d4:	5d2080e7          	jalr	1490(ra) # 800047a2 <fileclose>
      p->ofile[fd] = 0;
    800021d8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021dc:	04a1                	addi	s1,s1,8
    800021de:	01248563          	beq	s1,s2,800021e8 <exit+0x58>
    if(p->ofile[fd]){
    800021e2:	6088                	ld	a0,0(s1)
    800021e4:	f575                	bnez	a0,800021d0 <exit+0x40>
    800021e6:	bfdd                	j	800021dc <exit+0x4c>
  begin_op();
    800021e8:	00002097          	auipc	ra,0x2
    800021ec:	0f2080e7          	jalr	242(ra) # 800042da <begin_op>
  iput(p->cwd);
    800021f0:	1509b503          	ld	a0,336(s3)
    800021f4:	00002097          	auipc	ra,0x2
    800021f8:	8d4080e7          	jalr	-1836(ra) # 80003ac8 <iput>
  end_op();
    800021fc:	00002097          	auipc	ra,0x2
    80002200:	15c080e7          	jalr	348(ra) # 80004358 <end_op>
  p->cwd = 0;
    80002204:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002208:	0000f497          	auipc	s1,0xf
    8000220c:	9a048493          	addi	s1,s1,-1632 # 80010ba8 <wait_lock>
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	9c4080e7          	jalr	-1596(ra) # 80000bd6 <acquire>
  reparent(p);
    8000221a:	854e                	mv	a0,s3
    8000221c:	00000097          	auipc	ra,0x0
    80002220:	f1a080e7          	jalr	-230(ra) # 80002136 <reparent>
  wakeup(p->parent);
    80002224:	0389b503          	ld	a0,56(s3)
    80002228:	00000097          	auipc	ra,0x0
    8000222c:	e98080e7          	jalr	-360(ra) # 800020c0 <wakeup>
  acquire(&p->lock);
    80002230:	854e                	mv	a0,s3
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	9a4080e7          	jalr	-1628(ra) # 80000bd6 <acquire>
  p->xstate = status;
    8000223a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000223e:	4795                	li	a5,5
    80002240:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002244:	8526                	mv	a0,s1
    80002246:	fffff097          	auipc	ra,0xfffff
    8000224a:	a44080e7          	jalr	-1468(ra) # 80000c8a <release>
  sched();
    8000224e:	00000097          	auipc	ra,0x0
    80002252:	cfc080e7          	jalr	-772(ra) # 80001f4a <sched>
  panic("zombie exit");
    80002256:	00006517          	auipc	a0,0x6
    8000225a:	01a50513          	addi	a0,a0,26 # 80008270 <digits+0x230>
    8000225e:	ffffe097          	auipc	ra,0xffffe
    80002262:	2e2080e7          	jalr	738(ra) # 80000540 <panic>

0000000080002266 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002266:	7179                	addi	sp,sp,-48
    80002268:	f406                	sd	ra,40(sp)
    8000226a:	f022                	sd	s0,32(sp)
    8000226c:	ec26                	sd	s1,24(sp)
    8000226e:	e84a                	sd	s2,16(sp)
    80002270:	e44e                	sd	s3,8(sp)
    80002272:	1800                	addi	s0,sp,48
    80002274:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002276:	0000f497          	auipc	s1,0xf
    8000227a:	d4a48493          	addi	s1,s1,-694 # 80010fc0 <proc>
    8000227e:	00014997          	auipc	s3,0x14
    80002282:	74298993          	addi	s3,s3,1858 # 800169c0 <tickslock>
    acquire(&p->lock);
    80002286:	8526                	mv	a0,s1
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	94e080e7          	jalr	-1714(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002290:	589c                	lw	a5,48(s1)
    80002292:	01278d63          	beq	a5,s2,800022ac <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002296:	8526                	mv	a0,s1
    80002298:	fffff097          	auipc	ra,0xfffff
    8000229c:	9f2080e7          	jalr	-1550(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022a0:	16848493          	addi	s1,s1,360
    800022a4:	ff3491e3          	bne	s1,s3,80002286 <kill+0x20>
  }
  return -1;
    800022a8:	557d                	li	a0,-1
    800022aa:	a829                	j	800022c4 <kill+0x5e>
      p->killed = 1;
    800022ac:	4785                	li	a5,1
    800022ae:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022b0:	4c98                	lw	a4,24(s1)
    800022b2:	4789                	li	a5,2
    800022b4:	00f70f63          	beq	a4,a5,800022d2 <kill+0x6c>
      release(&p->lock);
    800022b8:	8526                	mv	a0,s1
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	9d0080e7          	jalr	-1584(ra) # 80000c8a <release>
      return 0;
    800022c2:	4501                	li	a0,0
}
    800022c4:	70a2                	ld	ra,40(sp)
    800022c6:	7402                	ld	s0,32(sp)
    800022c8:	64e2                	ld	s1,24(sp)
    800022ca:	6942                	ld	s2,16(sp)
    800022cc:	69a2                	ld	s3,8(sp)
    800022ce:	6145                	addi	sp,sp,48
    800022d0:	8082                	ret
        p->state = RUNNABLE;
    800022d2:	478d                	li	a5,3
    800022d4:	cc9c                	sw	a5,24(s1)
    800022d6:	b7cd                	j	800022b8 <kill+0x52>

00000000800022d8 <setkilled>:

void
setkilled(struct proc *p)
{
    800022d8:	1101                	addi	sp,sp,-32
    800022da:	ec06                	sd	ra,24(sp)
    800022dc:	e822                	sd	s0,16(sp)
    800022de:	e426                	sd	s1,8(sp)
    800022e0:	1000                	addi	s0,sp,32
    800022e2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	8f2080e7          	jalr	-1806(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800022ec:	4785                	li	a5,1
    800022ee:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022f0:	8526                	mv	a0,s1
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	998080e7          	jalr	-1640(ra) # 80000c8a <release>
}
    800022fa:	60e2                	ld	ra,24(sp)
    800022fc:	6442                	ld	s0,16(sp)
    800022fe:	64a2                	ld	s1,8(sp)
    80002300:	6105                	addi	sp,sp,32
    80002302:	8082                	ret

0000000080002304 <killed>:

int
killed(struct proc *p)
{
    80002304:	1101                	addi	sp,sp,-32
    80002306:	ec06                	sd	ra,24(sp)
    80002308:	e822                	sd	s0,16(sp)
    8000230a:	e426                	sd	s1,8(sp)
    8000230c:	e04a                	sd	s2,0(sp)
    8000230e:	1000                	addi	s0,sp,32
    80002310:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	8c4080e7          	jalr	-1852(ra) # 80000bd6 <acquire>
  k = p->killed;
    8000231a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	96a080e7          	jalr	-1686(ra) # 80000c8a <release>
  return k;
}
    80002328:	854a                	mv	a0,s2
    8000232a:	60e2                	ld	ra,24(sp)
    8000232c:	6442                	ld	s0,16(sp)
    8000232e:	64a2                	ld	s1,8(sp)
    80002330:	6902                	ld	s2,0(sp)
    80002332:	6105                	addi	sp,sp,32
    80002334:	8082                	ret

0000000080002336 <wait>:
{
    80002336:	715d                	addi	sp,sp,-80
    80002338:	e486                	sd	ra,72(sp)
    8000233a:	e0a2                	sd	s0,64(sp)
    8000233c:	fc26                	sd	s1,56(sp)
    8000233e:	f84a                	sd	s2,48(sp)
    80002340:	f44e                	sd	s3,40(sp)
    80002342:	f052                	sd	s4,32(sp)
    80002344:	ec56                	sd	s5,24(sp)
    80002346:	e85a                	sd	s6,16(sp)
    80002348:	e45e                	sd	s7,8(sp)
    8000234a:	e062                	sd	s8,0(sp)
    8000234c:	0880                	addi	s0,sp,80
    8000234e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	664080e7          	jalr	1636(ra) # 800019b4 <myproc>
    80002358:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000235a:	0000f517          	auipc	a0,0xf
    8000235e:	84e50513          	addi	a0,a0,-1970 # 80010ba8 <wait_lock>
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	874080e7          	jalr	-1932(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000236a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000236c:	4a15                	li	s4,5
        havekids = 1;
    8000236e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002370:	00014997          	auipc	s3,0x14
    80002374:	65098993          	addi	s3,s3,1616 # 800169c0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002378:	0000fc17          	auipc	s8,0xf
    8000237c:	830c0c13          	addi	s8,s8,-2000 # 80010ba8 <wait_lock>
    havekids = 0;
    80002380:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002382:	0000f497          	auipc	s1,0xf
    80002386:	c3e48493          	addi	s1,s1,-962 # 80010fc0 <proc>
    8000238a:	a0bd                	j	800023f8 <wait+0xc2>
          pid = pp->pid;
    8000238c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002390:	000b0e63          	beqz	s6,800023ac <wait+0x76>
    80002394:	4691                	li	a3,4
    80002396:	02c48613          	addi	a2,s1,44
    8000239a:	85da                	mv	a1,s6
    8000239c:	05093503          	ld	a0,80(s2)
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	2d4080e7          	jalr	724(ra) # 80001674 <copyout>
    800023a8:	02054563          	bltz	a0,800023d2 <wait+0x9c>
          freeproc(pp);
    800023ac:	8526                	mv	a0,s1
    800023ae:	fffff097          	auipc	ra,0xfffff
    800023b2:	7b8080e7          	jalr	1976(ra) # 80001b66 <freeproc>
          release(&pp->lock);
    800023b6:	8526                	mv	a0,s1
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	8d2080e7          	jalr	-1838(ra) # 80000c8a <release>
          release(&wait_lock);
    800023c0:	0000e517          	auipc	a0,0xe
    800023c4:	7e850513          	addi	a0,a0,2024 # 80010ba8 <wait_lock>
    800023c8:	fffff097          	auipc	ra,0xfffff
    800023cc:	8c2080e7          	jalr	-1854(ra) # 80000c8a <release>
          return pid;
    800023d0:	a0b5                	j	8000243c <wait+0x106>
            release(&pp->lock);
    800023d2:	8526                	mv	a0,s1
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	8b6080e7          	jalr	-1866(ra) # 80000c8a <release>
            release(&wait_lock);
    800023dc:	0000e517          	auipc	a0,0xe
    800023e0:	7cc50513          	addi	a0,a0,1996 # 80010ba8 <wait_lock>
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	8a6080e7          	jalr	-1882(ra) # 80000c8a <release>
            return -1;
    800023ec:	59fd                	li	s3,-1
    800023ee:	a0b9                	j	8000243c <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f0:	16848493          	addi	s1,s1,360
    800023f4:	03348463          	beq	s1,s3,8000241c <wait+0xe6>
      if(pp->parent == p){
    800023f8:	7c9c                	ld	a5,56(s1)
    800023fa:	ff279be3          	bne	a5,s2,800023f0 <wait+0xba>
        acquire(&pp->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	7d6080e7          	jalr	2006(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002408:	4c9c                	lw	a5,24(s1)
    8000240a:	f94781e3          	beq	a5,s4,8000238c <wait+0x56>
        release(&pp->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	87a080e7          	jalr	-1926(ra) # 80000c8a <release>
        havekids = 1;
    80002418:	8756                	mv	a4,s5
    8000241a:	bfd9                	j	800023f0 <wait+0xba>
    if(!havekids || killed(p)){
    8000241c:	c719                	beqz	a4,8000242a <wait+0xf4>
    8000241e:	854a                	mv	a0,s2
    80002420:	00000097          	auipc	ra,0x0
    80002424:	ee4080e7          	jalr	-284(ra) # 80002304 <killed>
    80002428:	c51d                	beqz	a0,80002456 <wait+0x120>
      release(&wait_lock);
    8000242a:	0000e517          	auipc	a0,0xe
    8000242e:	77e50513          	addi	a0,a0,1918 # 80010ba8 <wait_lock>
    80002432:	fffff097          	auipc	ra,0xfffff
    80002436:	858080e7          	jalr	-1960(ra) # 80000c8a <release>
      return -1;
    8000243a:	59fd                	li	s3,-1
}
    8000243c:	854e                	mv	a0,s3
    8000243e:	60a6                	ld	ra,72(sp)
    80002440:	6406                	ld	s0,64(sp)
    80002442:	74e2                	ld	s1,56(sp)
    80002444:	7942                	ld	s2,48(sp)
    80002446:	79a2                	ld	s3,40(sp)
    80002448:	7a02                	ld	s4,32(sp)
    8000244a:	6ae2                	ld	s5,24(sp)
    8000244c:	6b42                	ld	s6,16(sp)
    8000244e:	6ba2                	ld	s7,8(sp)
    80002450:	6c02                	ld	s8,0(sp)
    80002452:	6161                	addi	sp,sp,80
    80002454:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002456:	85e2                	mv	a1,s8
    80002458:	854a                	mv	a0,s2
    8000245a:	00000097          	auipc	ra,0x0
    8000245e:	c02080e7          	jalr	-1022(ra) # 8000205c <sleep>
    havekids = 0;
    80002462:	bf39                	j	80002380 <wait+0x4a>

0000000080002464 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002464:	7179                	addi	sp,sp,-48
    80002466:	f406                	sd	ra,40(sp)
    80002468:	f022                	sd	s0,32(sp)
    8000246a:	ec26                	sd	s1,24(sp)
    8000246c:	e84a                	sd	s2,16(sp)
    8000246e:	e44e                	sd	s3,8(sp)
    80002470:	e052                	sd	s4,0(sp)
    80002472:	1800                	addi	s0,sp,48
    80002474:	84aa                	mv	s1,a0
    80002476:	892e                	mv	s2,a1
    80002478:	89b2                	mv	s3,a2
    8000247a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000247c:	fffff097          	auipc	ra,0xfffff
    80002480:	538080e7          	jalr	1336(ra) # 800019b4 <myproc>
  if(user_dst){
    80002484:	c08d                	beqz	s1,800024a6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002486:	86d2                	mv	a3,s4
    80002488:	864e                	mv	a2,s3
    8000248a:	85ca                	mv	a1,s2
    8000248c:	6928                	ld	a0,80(a0)
    8000248e:	fffff097          	auipc	ra,0xfffff
    80002492:	1e6080e7          	jalr	486(ra) # 80001674 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002496:	70a2                	ld	ra,40(sp)
    80002498:	7402                	ld	s0,32(sp)
    8000249a:	64e2                	ld	s1,24(sp)
    8000249c:	6942                	ld	s2,16(sp)
    8000249e:	69a2                	ld	s3,8(sp)
    800024a0:	6a02                	ld	s4,0(sp)
    800024a2:	6145                	addi	sp,sp,48
    800024a4:	8082                	ret
    memmove((char *)dst, src, len);
    800024a6:	000a061b          	sext.w	a2,s4
    800024aa:	85ce                	mv	a1,s3
    800024ac:	854a                	mv	a0,s2
    800024ae:	fffff097          	auipc	ra,0xfffff
    800024b2:	880080e7          	jalr	-1920(ra) # 80000d2e <memmove>
    return 0;
    800024b6:	8526                	mv	a0,s1
    800024b8:	bff9                	j	80002496 <either_copyout+0x32>

00000000800024ba <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024ba:	7179                	addi	sp,sp,-48
    800024bc:	f406                	sd	ra,40(sp)
    800024be:	f022                	sd	s0,32(sp)
    800024c0:	ec26                	sd	s1,24(sp)
    800024c2:	e84a                	sd	s2,16(sp)
    800024c4:	e44e                	sd	s3,8(sp)
    800024c6:	e052                	sd	s4,0(sp)
    800024c8:	1800                	addi	s0,sp,48
    800024ca:	892a                	mv	s2,a0
    800024cc:	84ae                	mv	s1,a1
    800024ce:	89b2                	mv	s3,a2
    800024d0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024d2:	fffff097          	auipc	ra,0xfffff
    800024d6:	4e2080e7          	jalr	1250(ra) # 800019b4 <myproc>
  if(user_src){
    800024da:	c08d                	beqz	s1,800024fc <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024dc:	86d2                	mv	a3,s4
    800024de:	864e                	mv	a2,s3
    800024e0:	85ca                	mv	a1,s2
    800024e2:	6928                	ld	a0,80(a0)
    800024e4:	fffff097          	auipc	ra,0xfffff
    800024e8:	21c080e7          	jalr	540(ra) # 80001700 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024ec:	70a2                	ld	ra,40(sp)
    800024ee:	7402                	ld	s0,32(sp)
    800024f0:	64e2                	ld	s1,24(sp)
    800024f2:	6942                	ld	s2,16(sp)
    800024f4:	69a2                	ld	s3,8(sp)
    800024f6:	6a02                	ld	s4,0(sp)
    800024f8:	6145                	addi	sp,sp,48
    800024fa:	8082                	ret
    memmove(dst, (char*)src, len);
    800024fc:	000a061b          	sext.w	a2,s4
    80002500:	85ce                	mv	a1,s3
    80002502:	854a                	mv	a0,s2
    80002504:	fffff097          	auipc	ra,0xfffff
    80002508:	82a080e7          	jalr	-2006(ra) # 80000d2e <memmove>
    return 0;
    8000250c:	8526                	mv	a0,s1
    8000250e:	bff9                	j	800024ec <either_copyin+0x32>

0000000080002510 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002510:	715d                	addi	sp,sp,-80
    80002512:	e486                	sd	ra,72(sp)
    80002514:	e0a2                	sd	s0,64(sp)
    80002516:	fc26                	sd	s1,56(sp)
    80002518:	f84a                	sd	s2,48(sp)
    8000251a:	f44e                	sd	s3,40(sp)
    8000251c:	f052                	sd	s4,32(sp)
    8000251e:	ec56                	sd	s5,24(sp)
    80002520:	e85a                	sd	s6,16(sp)
    80002522:	e45e                	sd	s7,8(sp)
    80002524:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002526:	00006517          	auipc	a0,0x6
    8000252a:	ba250513          	addi	a0,a0,-1118 # 800080c8 <digits+0x88>
    8000252e:	ffffe097          	auipc	ra,0xffffe
    80002532:	05c080e7          	jalr	92(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002536:	0000f497          	auipc	s1,0xf
    8000253a:	be248493          	addi	s1,s1,-1054 # 80011118 <proc+0x158>
    8000253e:	00014917          	auipc	s2,0x14
    80002542:	5da90913          	addi	s2,s2,1498 # 80016b18 <s+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002546:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002548:	00006997          	auipc	s3,0x6
    8000254c:	d3898993          	addi	s3,s3,-712 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002550:	00006a97          	auipc	s5,0x6
    80002554:	d38a8a93          	addi	s5,s5,-712 # 80008288 <digits+0x248>
    printf("\n");
    80002558:	00006a17          	auipc	s4,0x6
    8000255c:	b70a0a13          	addi	s4,s4,-1168 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002560:	00006b97          	auipc	s7,0x6
    80002564:	d68b8b93          	addi	s7,s7,-664 # 800082c8 <states.0>
    80002568:	a00d                	j	8000258a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000256a:	ed86a583          	lw	a1,-296(a3)
    8000256e:	8556                	mv	a0,s5
    80002570:	ffffe097          	auipc	ra,0xffffe
    80002574:	01a080e7          	jalr	26(ra) # 8000058a <printf>
    printf("\n");
    80002578:	8552                	mv	a0,s4
    8000257a:	ffffe097          	auipc	ra,0xffffe
    8000257e:	010080e7          	jalr	16(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002582:	16848493          	addi	s1,s1,360
    80002586:	03248263          	beq	s1,s2,800025aa <procdump+0x9a>
    if(p->state == UNUSED)
    8000258a:	86a6                	mv	a3,s1
    8000258c:	ec04a783          	lw	a5,-320(s1)
    80002590:	dbed                	beqz	a5,80002582 <procdump+0x72>
      state = "???";
    80002592:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002594:	fcfb6be3          	bltu	s6,a5,8000256a <procdump+0x5a>
    80002598:	02079713          	slli	a4,a5,0x20
    8000259c:	01d75793          	srli	a5,a4,0x1d
    800025a0:	97de                	add	a5,a5,s7
    800025a2:	6390                	ld	a2,0(a5)
    800025a4:	f279                	bnez	a2,8000256a <procdump+0x5a>
      state = "???";
    800025a6:	864e                	mv	a2,s3
    800025a8:	b7c9                	j	8000256a <procdump+0x5a>
  }
}
    800025aa:	60a6                	ld	ra,72(sp)
    800025ac:	6406                	ld	s0,64(sp)
    800025ae:	74e2                	ld	s1,56(sp)
    800025b0:	7942                	ld	s2,48(sp)
    800025b2:	79a2                	ld	s3,40(sp)
    800025b4:	7a02                	ld	s4,32(sp)
    800025b6:	6ae2                	ld	s5,24(sp)
    800025b8:	6b42                	ld	s6,16(sp)
    800025ba:	6ba2                	ld	s7,8(sp)
    800025bc:	6161                	addi	sp,sp,80
    800025be:	8082                	ret

00000000800025c0 <swtch>:
    800025c0:	00153023          	sd	ra,0(a0)
    800025c4:	00253423          	sd	sp,8(a0)
    800025c8:	e900                	sd	s0,16(a0)
    800025ca:	ed04                	sd	s1,24(a0)
    800025cc:	03253023          	sd	s2,32(a0)
    800025d0:	03353423          	sd	s3,40(a0)
    800025d4:	03453823          	sd	s4,48(a0)
    800025d8:	03553c23          	sd	s5,56(a0)
    800025dc:	05653023          	sd	s6,64(a0)
    800025e0:	05753423          	sd	s7,72(a0)
    800025e4:	05853823          	sd	s8,80(a0)
    800025e8:	05953c23          	sd	s9,88(a0)
    800025ec:	07a53023          	sd	s10,96(a0)
    800025f0:	07b53423          	sd	s11,104(a0)
    800025f4:	0005b083          	ld	ra,0(a1)
    800025f8:	0085b103          	ld	sp,8(a1)
    800025fc:	6980                	ld	s0,16(a1)
    800025fe:	6d84                	ld	s1,24(a1)
    80002600:	0205b903          	ld	s2,32(a1)
    80002604:	0285b983          	ld	s3,40(a1)
    80002608:	0305ba03          	ld	s4,48(a1)
    8000260c:	0385ba83          	ld	s5,56(a1)
    80002610:	0405bb03          	ld	s6,64(a1)
    80002614:	0485bb83          	ld	s7,72(a1)
    80002618:	0505bc03          	ld	s8,80(a1)
    8000261c:	0585bc83          	ld	s9,88(a1)
    80002620:	0605bd03          	ld	s10,96(a1)
    80002624:	0685bd83          	ld	s11,104(a1)
    80002628:	8082                	ret

000000008000262a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000262a:	1141                	addi	sp,sp,-16
    8000262c:	e406                	sd	ra,8(sp)
    8000262e:	e022                	sd	s0,0(sp)
    80002630:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002632:	00006597          	auipc	a1,0x6
    80002636:	cc658593          	addi	a1,a1,-826 # 800082f8 <states.0+0x30>
    8000263a:	00014517          	auipc	a0,0x14
    8000263e:	38650513          	addi	a0,a0,902 # 800169c0 <tickslock>
    80002642:	ffffe097          	auipc	ra,0xffffe
    80002646:	504080e7          	jalr	1284(ra) # 80000b46 <initlock>
}
    8000264a:	60a2                	ld	ra,8(sp)
    8000264c:	6402                	ld	s0,0(sp)
    8000264e:	0141                	addi	sp,sp,16
    80002650:	8082                	ret

0000000080002652 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002652:	1141                	addi	sp,sp,-16
    80002654:	e422                	sd	s0,8(sp)
    80002656:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002658:	00003797          	auipc	a5,0x3
    8000265c:	79878793          	addi	a5,a5,1944 # 80005df0 <kernelvec>
    80002660:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002664:	6422                	ld	s0,8(sp)
    80002666:	0141                	addi	sp,sp,16
    80002668:	8082                	ret

000000008000266a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000266a:	1141                	addi	sp,sp,-16
    8000266c:	e406                	sd	ra,8(sp)
    8000266e:	e022                	sd	s0,0(sp)
    80002670:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002672:	fffff097          	auipc	ra,0xfffff
    80002676:	342080e7          	jalr	834(ra) # 800019b4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000267a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000267e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002680:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002684:	00005697          	auipc	a3,0x5
    80002688:	97c68693          	addi	a3,a3,-1668 # 80007000 <_trampoline>
    8000268c:	00005717          	auipc	a4,0x5
    80002690:	97470713          	addi	a4,a4,-1676 # 80007000 <_trampoline>
    80002694:	8f15                	sub	a4,a4,a3
    80002696:	040007b7          	lui	a5,0x4000
    8000269a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000269c:	07b2                	slli	a5,a5,0xc
    8000269e:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026a0:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026a4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026a6:	18002673          	csrr	a2,satp
    800026aa:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026ac:	6d30                	ld	a2,88(a0)
    800026ae:	6138                	ld	a4,64(a0)
    800026b0:	6585                	lui	a1,0x1
    800026b2:	972e                	add	a4,a4,a1
    800026b4:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026b6:	6d38                	ld	a4,88(a0)
    800026b8:	00000617          	auipc	a2,0x0
    800026bc:	13060613          	addi	a2,a2,304 # 800027e8 <usertrap>
    800026c0:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026c2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026c4:	8612                	mv	a2,tp
    800026c6:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c8:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026cc:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026d0:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026d4:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026d8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026da:	6f18                	ld	a4,24(a4)
    800026dc:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026e0:	6928                	ld	a0,80(a0)
    800026e2:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026e4:	00005717          	auipc	a4,0x5
    800026e8:	9b870713          	addi	a4,a4,-1608 # 8000709c <userret>
    800026ec:	8f15                	sub	a4,a4,a3
    800026ee:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026f0:	577d                	li	a4,-1
    800026f2:	177e                	slli	a4,a4,0x3f
    800026f4:	8d59                	or	a0,a0,a4
    800026f6:	9782                	jalr	a5
}
    800026f8:	60a2                	ld	ra,8(sp)
    800026fa:	6402                	ld	s0,0(sp)
    800026fc:	0141                	addi	sp,sp,16
    800026fe:	8082                	ret

0000000080002700 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002700:	1101                	addi	sp,sp,-32
    80002702:	ec06                	sd	ra,24(sp)
    80002704:	e822                	sd	s0,16(sp)
    80002706:	e426                	sd	s1,8(sp)
    80002708:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000270a:	00014497          	auipc	s1,0x14
    8000270e:	2b648493          	addi	s1,s1,694 # 800169c0 <tickslock>
    80002712:	8526                	mv	a0,s1
    80002714:	ffffe097          	auipc	ra,0xffffe
    80002718:	4c2080e7          	jalr	1218(ra) # 80000bd6 <acquire>
  ticks++;
    8000271c:	00006517          	auipc	a0,0x6
    80002720:	20450513          	addi	a0,a0,516 # 80008920 <ticks>
    80002724:	411c                	lw	a5,0(a0)
    80002726:	2785                	addiw	a5,a5,1
    80002728:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000272a:	00000097          	auipc	ra,0x0
    8000272e:	996080e7          	jalr	-1642(ra) # 800020c0 <wakeup>
  release(&tickslock);
    80002732:	8526                	mv	a0,s1
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	556080e7          	jalr	1366(ra) # 80000c8a <release>
}
    8000273c:	60e2                	ld	ra,24(sp)
    8000273e:	6442                	ld	s0,16(sp)
    80002740:	64a2                	ld	s1,8(sp)
    80002742:	6105                	addi	sp,sp,32
    80002744:	8082                	ret

0000000080002746 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002746:	1101                	addi	sp,sp,-32
    80002748:	ec06                	sd	ra,24(sp)
    8000274a:	e822                	sd	s0,16(sp)
    8000274c:	e426                	sd	s1,8(sp)
    8000274e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002750:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002754:	00074d63          	bltz	a4,8000276e <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002758:	57fd                	li	a5,-1
    8000275a:	17fe                	slli	a5,a5,0x3f
    8000275c:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000275e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002760:	06f70363          	beq	a4,a5,800027c6 <devintr+0x80>
  }
}
    80002764:	60e2                	ld	ra,24(sp)
    80002766:	6442                	ld	s0,16(sp)
    80002768:	64a2                	ld	s1,8(sp)
    8000276a:	6105                	addi	sp,sp,32
    8000276c:	8082                	ret
     (scause & 0xff) == 9){
    8000276e:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002772:	46a5                	li	a3,9
    80002774:	fed792e3          	bne	a5,a3,80002758 <devintr+0x12>
    int irq = plic_claim();
    80002778:	00003097          	auipc	ra,0x3
    8000277c:	780080e7          	jalr	1920(ra) # 80005ef8 <plic_claim>
    80002780:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002782:	47a9                	li	a5,10
    80002784:	02f50763          	beq	a0,a5,800027b2 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002788:	4785                	li	a5,1
    8000278a:	02f50963          	beq	a0,a5,800027bc <devintr+0x76>
    return 1;
    8000278e:	4505                	li	a0,1
    } else if(irq){
    80002790:	d8f1                	beqz	s1,80002764 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002792:	85a6                	mv	a1,s1
    80002794:	00006517          	auipc	a0,0x6
    80002798:	b6c50513          	addi	a0,a0,-1172 # 80008300 <states.0+0x38>
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	dee080e7          	jalr	-530(ra) # 8000058a <printf>
      plic_complete(irq);
    800027a4:	8526                	mv	a0,s1
    800027a6:	00003097          	auipc	ra,0x3
    800027aa:	776080e7          	jalr	1910(ra) # 80005f1c <plic_complete>
    return 1;
    800027ae:	4505                	li	a0,1
    800027b0:	bf55                	j	80002764 <devintr+0x1e>
      uartintr();
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	1e6080e7          	jalr	486(ra) # 80000998 <uartintr>
    800027ba:	b7ed                	j	800027a4 <devintr+0x5e>
      virtio_disk_intr();
    800027bc:	00004097          	auipc	ra,0x4
    800027c0:	c28080e7          	jalr	-984(ra) # 800063e4 <virtio_disk_intr>
    800027c4:	b7c5                	j	800027a4 <devintr+0x5e>
    if(cpuid() == 0){
    800027c6:	fffff097          	auipc	ra,0xfffff
    800027ca:	1c2080e7          	jalr	450(ra) # 80001988 <cpuid>
    800027ce:	c901                	beqz	a0,800027de <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027d0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027d4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027d6:	14479073          	csrw	sip,a5
    return 2;
    800027da:	4509                	li	a0,2
    800027dc:	b761                	j	80002764 <devintr+0x1e>
      clockintr();
    800027de:	00000097          	auipc	ra,0x0
    800027e2:	f22080e7          	jalr	-222(ra) # 80002700 <clockintr>
    800027e6:	b7ed                	j	800027d0 <devintr+0x8a>

00000000800027e8 <usertrap>:
{
    800027e8:	1101                	addi	sp,sp,-32
    800027ea:	ec06                	sd	ra,24(sp)
    800027ec:	e822                	sd	s0,16(sp)
    800027ee:	e426                	sd	s1,8(sp)
    800027f0:	e04a                	sd	s2,0(sp)
    800027f2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027f8:	1007f793          	andi	a5,a5,256
    800027fc:	e3b1                	bnez	a5,80002840 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027fe:	00003797          	auipc	a5,0x3
    80002802:	5f278793          	addi	a5,a5,1522 # 80005df0 <kernelvec>
    80002806:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000280a:	fffff097          	auipc	ra,0xfffff
    8000280e:	1aa080e7          	jalr	426(ra) # 800019b4 <myproc>
    80002812:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002814:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002816:	14102773          	csrr	a4,sepc
    8000281a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000281c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002820:	47a1                	li	a5,8
    80002822:	02f70763          	beq	a4,a5,80002850 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002826:	00000097          	auipc	ra,0x0
    8000282a:	f20080e7          	jalr	-224(ra) # 80002746 <devintr>
    8000282e:	892a                	mv	s2,a0
    80002830:	c151                	beqz	a0,800028b4 <usertrap+0xcc>
  if(killed(p))
    80002832:	8526                	mv	a0,s1
    80002834:	00000097          	auipc	ra,0x0
    80002838:	ad0080e7          	jalr	-1328(ra) # 80002304 <killed>
    8000283c:	c929                	beqz	a0,8000288e <usertrap+0xa6>
    8000283e:	a099                	j	80002884 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002840:	00006517          	auipc	a0,0x6
    80002844:	ae050513          	addi	a0,a0,-1312 # 80008320 <states.0+0x58>
    80002848:	ffffe097          	auipc	ra,0xffffe
    8000284c:	cf8080e7          	jalr	-776(ra) # 80000540 <panic>
    if(killed(p))
    80002850:	00000097          	auipc	ra,0x0
    80002854:	ab4080e7          	jalr	-1356(ra) # 80002304 <killed>
    80002858:	e921                	bnez	a0,800028a8 <usertrap+0xc0>
    p->trapframe->epc += 4;
    8000285a:	6cb8                	ld	a4,88(s1)
    8000285c:	6f1c                	ld	a5,24(a4)
    8000285e:	0791                	addi	a5,a5,4
    80002860:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002862:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002866:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000286a:	10079073          	csrw	sstatus,a5
    syscall();
    8000286e:	00000097          	auipc	ra,0x0
    80002872:	2d4080e7          	jalr	724(ra) # 80002b42 <syscall>
  if(killed(p))
    80002876:	8526                	mv	a0,s1
    80002878:	00000097          	auipc	ra,0x0
    8000287c:	a8c080e7          	jalr	-1396(ra) # 80002304 <killed>
    80002880:	c911                	beqz	a0,80002894 <usertrap+0xac>
    80002882:	4901                	li	s2,0
    exit(-1);
    80002884:	557d                	li	a0,-1
    80002886:	00000097          	auipc	ra,0x0
    8000288a:	90a080e7          	jalr	-1782(ra) # 80002190 <exit>
  if(which_dev == 2)
    8000288e:	4789                	li	a5,2
    80002890:	04f90f63          	beq	s2,a5,800028ee <usertrap+0x106>
  usertrapret();
    80002894:	00000097          	auipc	ra,0x0
    80002898:	dd6080e7          	jalr	-554(ra) # 8000266a <usertrapret>
}
    8000289c:	60e2                	ld	ra,24(sp)
    8000289e:	6442                	ld	s0,16(sp)
    800028a0:	64a2                	ld	s1,8(sp)
    800028a2:	6902                	ld	s2,0(sp)
    800028a4:	6105                	addi	sp,sp,32
    800028a6:	8082                	ret
      exit(-1);
    800028a8:	557d                	li	a0,-1
    800028aa:	00000097          	auipc	ra,0x0
    800028ae:	8e6080e7          	jalr	-1818(ra) # 80002190 <exit>
    800028b2:	b765                	j	8000285a <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028b8:	5890                	lw	a2,48(s1)
    800028ba:	00006517          	auipc	a0,0x6
    800028be:	a8650513          	addi	a0,a0,-1402 # 80008340 <states.0+0x78>
    800028c2:	ffffe097          	auipc	ra,0xffffe
    800028c6:	cc8080e7          	jalr	-824(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028ca:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028ce:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028d2:	00006517          	auipc	a0,0x6
    800028d6:	a9e50513          	addi	a0,a0,-1378 # 80008370 <states.0+0xa8>
    800028da:	ffffe097          	auipc	ra,0xffffe
    800028de:	cb0080e7          	jalr	-848(ra) # 8000058a <printf>
    setkilled(p);
    800028e2:	8526                	mv	a0,s1
    800028e4:	00000097          	auipc	ra,0x0
    800028e8:	9f4080e7          	jalr	-1548(ra) # 800022d8 <setkilled>
    800028ec:	b769                	j	80002876 <usertrap+0x8e>
    yield();
    800028ee:	fffff097          	auipc	ra,0xfffff
    800028f2:	732080e7          	jalr	1842(ra) # 80002020 <yield>
    800028f6:	bf79                	j	80002894 <usertrap+0xac>

00000000800028f8 <kerneltrap>:
{
    800028f8:	7179                	addi	sp,sp,-48
    800028fa:	f406                	sd	ra,40(sp)
    800028fc:	f022                	sd	s0,32(sp)
    800028fe:	ec26                	sd	s1,24(sp)
    80002900:	e84a                	sd	s2,16(sp)
    80002902:	e44e                	sd	s3,8(sp)
    80002904:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002906:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000290a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000290e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002912:	1004f793          	andi	a5,s1,256
    80002916:	cb85                	beqz	a5,80002946 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002918:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000291c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000291e:	ef85                	bnez	a5,80002956 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002920:	00000097          	auipc	ra,0x0
    80002924:	e26080e7          	jalr	-474(ra) # 80002746 <devintr>
    80002928:	cd1d                	beqz	a0,80002966 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000292a:	4789                	li	a5,2
    8000292c:	06f50a63          	beq	a0,a5,800029a0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002930:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002934:	10049073          	csrw	sstatus,s1
}
    80002938:	70a2                	ld	ra,40(sp)
    8000293a:	7402                	ld	s0,32(sp)
    8000293c:	64e2                	ld	s1,24(sp)
    8000293e:	6942                	ld	s2,16(sp)
    80002940:	69a2                	ld	s3,8(sp)
    80002942:	6145                	addi	sp,sp,48
    80002944:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002946:	00006517          	auipc	a0,0x6
    8000294a:	a4a50513          	addi	a0,a0,-1462 # 80008390 <states.0+0xc8>
    8000294e:	ffffe097          	auipc	ra,0xffffe
    80002952:	bf2080e7          	jalr	-1038(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002956:	00006517          	auipc	a0,0x6
    8000295a:	a6250513          	addi	a0,a0,-1438 # 800083b8 <states.0+0xf0>
    8000295e:	ffffe097          	auipc	ra,0xffffe
    80002962:	be2080e7          	jalr	-1054(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002966:	85ce                	mv	a1,s3
    80002968:	00006517          	auipc	a0,0x6
    8000296c:	a7050513          	addi	a0,a0,-1424 # 800083d8 <states.0+0x110>
    80002970:	ffffe097          	auipc	ra,0xffffe
    80002974:	c1a080e7          	jalr	-998(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002978:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000297c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002980:	00006517          	auipc	a0,0x6
    80002984:	a6850513          	addi	a0,a0,-1432 # 800083e8 <states.0+0x120>
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	c02080e7          	jalr	-1022(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002990:	00006517          	auipc	a0,0x6
    80002994:	a7050513          	addi	a0,a0,-1424 # 80008400 <states.0+0x138>
    80002998:	ffffe097          	auipc	ra,0xffffe
    8000299c:	ba8080e7          	jalr	-1112(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029a0:	fffff097          	auipc	ra,0xfffff
    800029a4:	014080e7          	jalr	20(ra) # 800019b4 <myproc>
    800029a8:	d541                	beqz	a0,80002930 <kerneltrap+0x38>
    800029aa:	fffff097          	auipc	ra,0xfffff
    800029ae:	00a080e7          	jalr	10(ra) # 800019b4 <myproc>
    800029b2:	4d18                	lw	a4,24(a0)
    800029b4:	4791                	li	a5,4
    800029b6:	f6f71de3          	bne	a4,a5,80002930 <kerneltrap+0x38>
    yield();
    800029ba:	fffff097          	auipc	ra,0xfffff
    800029be:	666080e7          	jalr	1638(ra) # 80002020 <yield>
    800029c2:	b7bd                	j	80002930 <kerneltrap+0x38>

00000000800029c4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029c4:	1101                	addi	sp,sp,-32
    800029c6:	ec06                	sd	ra,24(sp)
    800029c8:	e822                	sd	s0,16(sp)
    800029ca:	e426                	sd	s1,8(sp)
    800029cc:	1000                	addi	s0,sp,32
    800029ce:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029d0:	fffff097          	auipc	ra,0xfffff
    800029d4:	fe4080e7          	jalr	-28(ra) # 800019b4 <myproc>
  switch (n) {
    800029d8:	4795                	li	a5,5
    800029da:	0497e163          	bltu	a5,s1,80002a1c <argraw+0x58>
    800029de:	048a                	slli	s1,s1,0x2
    800029e0:	00006717          	auipc	a4,0x6
    800029e4:	a5870713          	addi	a4,a4,-1448 # 80008438 <states.0+0x170>
    800029e8:	94ba                	add	s1,s1,a4
    800029ea:	409c                	lw	a5,0(s1)
    800029ec:	97ba                	add	a5,a5,a4
    800029ee:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029f0:	6d3c                	ld	a5,88(a0)
    800029f2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029f4:	60e2                	ld	ra,24(sp)
    800029f6:	6442                	ld	s0,16(sp)
    800029f8:	64a2                	ld	s1,8(sp)
    800029fa:	6105                	addi	sp,sp,32
    800029fc:	8082                	ret
    return p->trapframe->a1;
    800029fe:	6d3c                	ld	a5,88(a0)
    80002a00:	7fa8                	ld	a0,120(a5)
    80002a02:	bfcd                	j	800029f4 <argraw+0x30>
    return p->trapframe->a2;
    80002a04:	6d3c                	ld	a5,88(a0)
    80002a06:	63c8                	ld	a0,128(a5)
    80002a08:	b7f5                	j	800029f4 <argraw+0x30>
    return p->trapframe->a3;
    80002a0a:	6d3c                	ld	a5,88(a0)
    80002a0c:	67c8                	ld	a0,136(a5)
    80002a0e:	b7dd                	j	800029f4 <argraw+0x30>
    return p->trapframe->a4;
    80002a10:	6d3c                	ld	a5,88(a0)
    80002a12:	6bc8                	ld	a0,144(a5)
    80002a14:	b7c5                	j	800029f4 <argraw+0x30>
    return p->trapframe->a5;
    80002a16:	6d3c                	ld	a5,88(a0)
    80002a18:	6fc8                	ld	a0,152(a5)
    80002a1a:	bfe9                	j	800029f4 <argraw+0x30>
  panic("argraw");
    80002a1c:	00006517          	auipc	a0,0x6
    80002a20:	9f450513          	addi	a0,a0,-1548 # 80008410 <states.0+0x148>
    80002a24:	ffffe097          	auipc	ra,0xffffe
    80002a28:	b1c080e7          	jalr	-1252(ra) # 80000540 <panic>

0000000080002a2c <fetchaddr>:
{
    80002a2c:	1101                	addi	sp,sp,-32
    80002a2e:	ec06                	sd	ra,24(sp)
    80002a30:	e822                	sd	s0,16(sp)
    80002a32:	e426                	sd	s1,8(sp)
    80002a34:	e04a                	sd	s2,0(sp)
    80002a36:	1000                	addi	s0,sp,32
    80002a38:	84aa                	mv	s1,a0
    80002a3a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a3c:	fffff097          	auipc	ra,0xfffff
    80002a40:	f78080e7          	jalr	-136(ra) # 800019b4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a44:	653c                	ld	a5,72(a0)
    80002a46:	02f4f863          	bgeu	s1,a5,80002a76 <fetchaddr+0x4a>
    80002a4a:	00848713          	addi	a4,s1,8
    80002a4e:	02e7e663          	bltu	a5,a4,80002a7a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a52:	46a1                	li	a3,8
    80002a54:	8626                	mv	a2,s1
    80002a56:	85ca                	mv	a1,s2
    80002a58:	6928                	ld	a0,80(a0)
    80002a5a:	fffff097          	auipc	ra,0xfffff
    80002a5e:	ca6080e7          	jalr	-858(ra) # 80001700 <copyin>
    80002a62:	00a03533          	snez	a0,a0
    80002a66:	40a00533          	neg	a0,a0
}
    80002a6a:	60e2                	ld	ra,24(sp)
    80002a6c:	6442                	ld	s0,16(sp)
    80002a6e:	64a2                	ld	s1,8(sp)
    80002a70:	6902                	ld	s2,0(sp)
    80002a72:	6105                	addi	sp,sp,32
    80002a74:	8082                	ret
    return -1;
    80002a76:	557d                	li	a0,-1
    80002a78:	bfcd                	j	80002a6a <fetchaddr+0x3e>
    80002a7a:	557d                	li	a0,-1
    80002a7c:	b7fd                	j	80002a6a <fetchaddr+0x3e>

0000000080002a7e <fetchstr>:
{
    80002a7e:	7179                	addi	sp,sp,-48
    80002a80:	f406                	sd	ra,40(sp)
    80002a82:	f022                	sd	s0,32(sp)
    80002a84:	ec26                	sd	s1,24(sp)
    80002a86:	e84a                	sd	s2,16(sp)
    80002a88:	e44e                	sd	s3,8(sp)
    80002a8a:	1800                	addi	s0,sp,48
    80002a8c:	892a                	mv	s2,a0
    80002a8e:	84ae                	mv	s1,a1
    80002a90:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a92:	fffff097          	auipc	ra,0xfffff
    80002a96:	f22080e7          	jalr	-222(ra) # 800019b4 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a9a:	86ce                	mv	a3,s3
    80002a9c:	864a                	mv	a2,s2
    80002a9e:	85a6                	mv	a1,s1
    80002aa0:	6928                	ld	a0,80(a0)
    80002aa2:	fffff097          	auipc	ra,0xfffff
    80002aa6:	cec080e7          	jalr	-788(ra) # 8000178e <copyinstr>
    80002aaa:	00054e63          	bltz	a0,80002ac6 <fetchstr+0x48>
  return strlen(buf);
    80002aae:	8526                	mv	a0,s1
    80002ab0:	ffffe097          	auipc	ra,0xffffe
    80002ab4:	39e080e7          	jalr	926(ra) # 80000e4e <strlen>
}
    80002ab8:	70a2                	ld	ra,40(sp)
    80002aba:	7402                	ld	s0,32(sp)
    80002abc:	64e2                	ld	s1,24(sp)
    80002abe:	6942                	ld	s2,16(sp)
    80002ac0:	69a2                	ld	s3,8(sp)
    80002ac2:	6145                	addi	sp,sp,48
    80002ac4:	8082                	ret
    return -1;
    80002ac6:	557d                	li	a0,-1
    80002ac8:	bfc5                	j	80002ab8 <fetchstr+0x3a>

0000000080002aca <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002aca:	1101                	addi	sp,sp,-32
    80002acc:	ec06                	sd	ra,24(sp)
    80002ace:	e822                	sd	s0,16(sp)
    80002ad0:	e426                	sd	s1,8(sp)
    80002ad2:	1000                	addi	s0,sp,32
    80002ad4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	eee080e7          	jalr	-274(ra) # 800029c4 <argraw>
    80002ade:	c088                	sw	a0,0(s1)
}
    80002ae0:	60e2                	ld	ra,24(sp)
    80002ae2:	6442                	ld	s0,16(sp)
    80002ae4:	64a2                	ld	s1,8(sp)
    80002ae6:	6105                	addi	sp,sp,32
    80002ae8:	8082                	ret

0000000080002aea <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002aea:	1101                	addi	sp,sp,-32
    80002aec:	ec06                	sd	ra,24(sp)
    80002aee:	e822                	sd	s0,16(sp)
    80002af0:	e426                	sd	s1,8(sp)
    80002af2:	1000                	addi	s0,sp,32
    80002af4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002af6:	00000097          	auipc	ra,0x0
    80002afa:	ece080e7          	jalr	-306(ra) # 800029c4 <argraw>
    80002afe:	e088                	sd	a0,0(s1)
}
    80002b00:	60e2                	ld	ra,24(sp)
    80002b02:	6442                	ld	s0,16(sp)
    80002b04:	64a2                	ld	s1,8(sp)
    80002b06:	6105                	addi	sp,sp,32
    80002b08:	8082                	ret

0000000080002b0a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b0a:	7179                	addi	sp,sp,-48
    80002b0c:	f406                	sd	ra,40(sp)
    80002b0e:	f022                	sd	s0,32(sp)
    80002b10:	ec26                	sd	s1,24(sp)
    80002b12:	e84a                	sd	s2,16(sp)
    80002b14:	1800                	addi	s0,sp,48
    80002b16:	84ae                	mv	s1,a1
    80002b18:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b1a:	fd840593          	addi	a1,s0,-40
    80002b1e:	00000097          	auipc	ra,0x0
    80002b22:	fcc080e7          	jalr	-52(ra) # 80002aea <argaddr>
  return fetchstr(addr, buf, max);
    80002b26:	864a                	mv	a2,s2
    80002b28:	85a6                	mv	a1,s1
    80002b2a:	fd843503          	ld	a0,-40(s0)
    80002b2e:	00000097          	auipc	ra,0x0
    80002b32:	f50080e7          	jalr	-176(ra) # 80002a7e <fetchstr>
}
    80002b36:	70a2                	ld	ra,40(sp)
    80002b38:	7402                	ld	s0,32(sp)
    80002b3a:	64e2                	ld	s1,24(sp)
    80002b3c:	6942                	ld	s2,16(sp)
    80002b3e:	6145                	addi	sp,sp,48
    80002b40:	8082                	ret

0000000080002b42 <syscall>:
[SYS_sem_close] sys_sem_close,
};

void
syscall(void)
{
    80002b42:	1101                	addi	sp,sp,-32
    80002b44:	ec06                	sd	ra,24(sp)
    80002b46:	e822                	sd	s0,16(sp)
    80002b48:	e426                	sd	s1,8(sp)
    80002b4a:	e04a                	sd	s2,0(sp)
    80002b4c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b4e:	fffff097          	auipc	ra,0xfffff
    80002b52:	e66080e7          	jalr	-410(ra) # 800019b4 <myproc>
    80002b56:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b58:	05853903          	ld	s2,88(a0)
    80002b5c:	0a893783          	ld	a5,168(s2)
    80002b60:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b64:	37fd                	addiw	a5,a5,-1
    80002b66:	4765                	li	a4,25
    80002b68:	00f76f63          	bltu	a4,a5,80002b86 <syscall+0x44>
    80002b6c:	00369713          	slli	a4,a3,0x3
    80002b70:	00006797          	auipc	a5,0x6
    80002b74:	8e078793          	addi	a5,a5,-1824 # 80008450 <syscalls>
    80002b78:	97ba                	add	a5,a5,a4
    80002b7a:	639c                	ld	a5,0(a5)
    80002b7c:	c789                	beqz	a5,80002b86 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b7e:	9782                	jalr	a5
    80002b80:	06a93823          	sd	a0,112(s2)
    80002b84:	a839                	j	80002ba2 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b86:	15848613          	addi	a2,s1,344
    80002b8a:	588c                	lw	a1,48(s1)
    80002b8c:	00006517          	auipc	a0,0x6
    80002b90:	88c50513          	addi	a0,a0,-1908 # 80008418 <states.0+0x150>
    80002b94:	ffffe097          	auipc	ra,0xffffe
    80002b98:	9f6080e7          	jalr	-1546(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b9c:	6cbc                	ld	a5,88(s1)
    80002b9e:	577d                	li	a4,-1
    80002ba0:	fbb8                	sd	a4,112(a5)
  }
}
    80002ba2:	60e2                	ld	ra,24(sp)
    80002ba4:	6442                	ld	s0,16(sp)
    80002ba6:	64a2                	ld	s1,8(sp)
    80002ba8:	6902                	ld	s2,0(sp)
    80002baa:	6105                	addi	sp,sp,32
    80002bac:	8082                	ret

0000000080002bae <sys_exit>:
#define false 0


uint64
sys_exit(void)
{
    80002bae:	1101                	addi	sp,sp,-32
    80002bb0:	ec06                	sd	ra,24(sp)
    80002bb2:	e822                	sd	s0,16(sp)
    80002bb4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bb6:	fec40593          	addi	a1,s0,-20
    80002bba:	4501                	li	a0,0
    80002bbc:	00000097          	auipc	ra,0x0
    80002bc0:	f0e080e7          	jalr	-242(ra) # 80002aca <argint>
  exit(n);
    80002bc4:	fec42503          	lw	a0,-20(s0)
    80002bc8:	fffff097          	auipc	ra,0xfffff
    80002bcc:	5c8080e7          	jalr	1480(ra) # 80002190 <exit>
  return 0;  // not reached
}
    80002bd0:	4501                	li	a0,0
    80002bd2:	60e2                	ld	ra,24(sp)
    80002bd4:	6442                	ld	s0,16(sp)
    80002bd6:	6105                	addi	sp,sp,32
    80002bd8:	8082                	ret

0000000080002bda <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bda:	1141                	addi	sp,sp,-16
    80002bdc:	e406                	sd	ra,8(sp)
    80002bde:	e022                	sd	s0,0(sp)
    80002be0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002be2:	fffff097          	auipc	ra,0xfffff
    80002be6:	dd2080e7          	jalr	-558(ra) # 800019b4 <myproc>
}
    80002bea:	5908                	lw	a0,48(a0)
    80002bec:	60a2                	ld	ra,8(sp)
    80002bee:	6402                	ld	s0,0(sp)
    80002bf0:	0141                	addi	sp,sp,16
    80002bf2:	8082                	ret

0000000080002bf4 <sys_fork>:

uint64
sys_fork(void)
{
    80002bf4:	1141                	addi	sp,sp,-16
    80002bf6:	e406                	sd	ra,8(sp)
    80002bf8:	e022                	sd	s0,0(sp)
    80002bfa:	0800                	addi	s0,sp,16
  return fork();
    80002bfc:	fffff097          	auipc	ra,0xfffff
    80002c00:	16e080e7          	jalr	366(ra) # 80001d6a <fork>
}
    80002c04:	60a2                	ld	ra,8(sp)
    80002c06:	6402                	ld	s0,0(sp)
    80002c08:	0141                	addi	sp,sp,16
    80002c0a:	8082                	ret

0000000080002c0c <sys_wait>:

uint64
sys_wait(void)
{
    80002c0c:	1101                	addi	sp,sp,-32
    80002c0e:	ec06                	sd	ra,24(sp)
    80002c10:	e822                	sd	s0,16(sp)
    80002c12:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c14:	fe840593          	addi	a1,s0,-24
    80002c18:	4501                	li	a0,0
    80002c1a:	00000097          	auipc	ra,0x0
    80002c1e:	ed0080e7          	jalr	-304(ra) # 80002aea <argaddr>
  return wait(p);
    80002c22:	fe843503          	ld	a0,-24(s0)
    80002c26:	fffff097          	auipc	ra,0xfffff
    80002c2a:	710080e7          	jalr	1808(ra) # 80002336 <wait>
}
    80002c2e:	60e2                	ld	ra,24(sp)
    80002c30:	6442                	ld	s0,16(sp)
    80002c32:	6105                	addi	sp,sp,32
    80002c34:	8082                	ret

0000000080002c36 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c36:	7179                	addi	sp,sp,-48
    80002c38:	f406                	sd	ra,40(sp)
    80002c3a:	f022                	sd	s0,32(sp)
    80002c3c:	ec26                	sd	s1,24(sp)
    80002c3e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c40:	fdc40593          	addi	a1,s0,-36
    80002c44:	4501                	li	a0,0
    80002c46:	00000097          	auipc	ra,0x0
    80002c4a:	e84080e7          	jalr	-380(ra) # 80002aca <argint>
  addr = myproc()->sz;
    80002c4e:	fffff097          	auipc	ra,0xfffff
    80002c52:	d66080e7          	jalr	-666(ra) # 800019b4 <myproc>
    80002c56:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c58:	fdc42503          	lw	a0,-36(s0)
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	0b2080e7          	jalr	178(ra) # 80001d0e <growproc>
    80002c64:	00054863          	bltz	a0,80002c74 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002c68:	8526                	mv	a0,s1
    80002c6a:	70a2                	ld	ra,40(sp)
    80002c6c:	7402                	ld	s0,32(sp)
    80002c6e:	64e2                	ld	s1,24(sp)
    80002c70:	6145                	addi	sp,sp,48
    80002c72:	8082                	ret
    return -1;
    80002c74:	54fd                	li	s1,-1
    80002c76:	bfcd                	j	80002c68 <sys_sbrk+0x32>

0000000080002c78 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c78:	7139                	addi	sp,sp,-64
    80002c7a:	fc06                	sd	ra,56(sp)
    80002c7c:	f822                	sd	s0,48(sp)
    80002c7e:	f426                	sd	s1,40(sp)
    80002c80:	f04a                	sd	s2,32(sp)
    80002c82:	ec4e                	sd	s3,24(sp)
    80002c84:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c86:	fcc40593          	addi	a1,s0,-52
    80002c8a:	4501                	li	a0,0
    80002c8c:	00000097          	auipc	ra,0x0
    80002c90:	e3e080e7          	jalr	-450(ra) # 80002aca <argint>
  acquire(&tickslock);
    80002c94:	00014517          	auipc	a0,0x14
    80002c98:	d2c50513          	addi	a0,a0,-724 # 800169c0 <tickslock>
    80002c9c:	ffffe097          	auipc	ra,0xffffe
    80002ca0:	f3a080e7          	jalr	-198(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002ca4:	00006917          	auipc	s2,0x6
    80002ca8:	c7c92903          	lw	s2,-900(s2) # 80008920 <ticks>
  while(ticks - ticks0 < n){
    80002cac:	fcc42783          	lw	a5,-52(s0)
    80002cb0:	cf9d                	beqz	a5,80002cee <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cb2:	00014997          	auipc	s3,0x14
    80002cb6:	d0e98993          	addi	s3,s3,-754 # 800169c0 <tickslock>
    80002cba:	00006497          	auipc	s1,0x6
    80002cbe:	c6648493          	addi	s1,s1,-922 # 80008920 <ticks>
    if(killed(myproc())){
    80002cc2:	fffff097          	auipc	ra,0xfffff
    80002cc6:	cf2080e7          	jalr	-782(ra) # 800019b4 <myproc>
    80002cca:	fffff097          	auipc	ra,0xfffff
    80002cce:	63a080e7          	jalr	1594(ra) # 80002304 <killed>
    80002cd2:	ed15                	bnez	a0,80002d0e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002cd4:	85ce                	mv	a1,s3
    80002cd6:	8526                	mv	a0,s1
    80002cd8:	fffff097          	auipc	ra,0xfffff
    80002cdc:	384080e7          	jalr	900(ra) # 8000205c <sleep>
  while(ticks - ticks0 < n){
    80002ce0:	409c                	lw	a5,0(s1)
    80002ce2:	412787bb          	subw	a5,a5,s2
    80002ce6:	fcc42703          	lw	a4,-52(s0)
    80002cea:	fce7ece3          	bltu	a5,a4,80002cc2 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002cee:	00014517          	auipc	a0,0x14
    80002cf2:	cd250513          	addi	a0,a0,-814 # 800169c0 <tickslock>
    80002cf6:	ffffe097          	auipc	ra,0xffffe
    80002cfa:	f94080e7          	jalr	-108(ra) # 80000c8a <release>
  return 0;
    80002cfe:	4501                	li	a0,0
}
    80002d00:	70e2                	ld	ra,56(sp)
    80002d02:	7442                	ld	s0,48(sp)
    80002d04:	74a2                	ld	s1,40(sp)
    80002d06:	7902                	ld	s2,32(sp)
    80002d08:	69e2                	ld	s3,24(sp)
    80002d0a:	6121                	addi	sp,sp,64
    80002d0c:	8082                	ret
      release(&tickslock);
    80002d0e:	00014517          	auipc	a0,0x14
    80002d12:	cb250513          	addi	a0,a0,-846 # 800169c0 <tickslock>
    80002d16:	ffffe097          	auipc	ra,0xffffe
    80002d1a:	f74080e7          	jalr	-140(ra) # 80000c8a <release>
      return -1;
    80002d1e:	557d                	li	a0,-1
    80002d20:	b7c5                	j	80002d00 <sys_sleep+0x88>

0000000080002d22 <sys_kill>:

uint64
sys_kill(void)
{
    80002d22:	1101                	addi	sp,sp,-32
    80002d24:	ec06                	sd	ra,24(sp)
    80002d26:	e822                	sd	s0,16(sp)
    80002d28:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d2a:	fec40593          	addi	a1,s0,-20
    80002d2e:	4501                	li	a0,0
    80002d30:	00000097          	auipc	ra,0x0
    80002d34:	d9a080e7          	jalr	-614(ra) # 80002aca <argint>
  return kill(pid);
    80002d38:	fec42503          	lw	a0,-20(s0)
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	52a080e7          	jalr	1322(ra) # 80002266 <kill>
}
    80002d44:	60e2                	ld	ra,24(sp)
    80002d46:	6442                	ld	s0,16(sp)
    80002d48:	6105                	addi	sp,sp,32
    80002d4a:	8082                	ret

0000000080002d4c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d4c:	1101                	addi	sp,sp,-32
    80002d4e:	ec06                	sd	ra,24(sp)
    80002d50:	e822                	sd	s0,16(sp)
    80002d52:	e426                	sd	s1,8(sp)
    80002d54:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d56:	00014517          	auipc	a0,0x14
    80002d5a:	c6a50513          	addi	a0,a0,-918 # 800169c0 <tickslock>
    80002d5e:	ffffe097          	auipc	ra,0xffffe
    80002d62:	e78080e7          	jalr	-392(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002d66:	00006497          	auipc	s1,0x6
    80002d6a:	bba4a483          	lw	s1,-1094(s1) # 80008920 <ticks>
  release(&tickslock);
    80002d6e:	00014517          	auipc	a0,0x14
    80002d72:	c5250513          	addi	a0,a0,-942 # 800169c0 <tickslock>
    80002d76:	ffffe097          	auipc	ra,0xffffe
    80002d7a:	f14080e7          	jalr	-236(ra) # 80000c8a <release>
  return xticks;
}
    80002d7e:	02049513          	slli	a0,s1,0x20
    80002d82:	9101                	srli	a0,a0,0x20
    80002d84:	60e2                	ld	ra,24(sp)
    80002d86:	6442                	ld	s0,16(sp)
    80002d88:	64a2                	ld	s1,8(sp)
    80002d8a:	6105                	addi	sp,sp,32
    80002d8c:	8082                	ret

0000000080002d8e <sys_hello>:

// sycall simple de hello-world
uint64
sys_hello(void)
{   
    80002d8e:	1141                	addi	sp,sp,-16
    80002d90:	e422                	sd	s0,8(sp)
    80002d92:	0800                	addi	s0,sp,16
    return 0;
}
    80002d94:	4501                	li	a0,0
    80002d96:	6422                	ld	s0,8(sp)
    80002d98:	0141                	addi	sp,sp,16
    80002d9a:	8082                	ret

0000000080002d9c <init_sem>:
    struct spinlock lock;
} semaphore;

semaphore s[MAX_SEM_VALUE];

void init_sem(void) {
    80002d9c:	7179                	addi	sp,sp,-48
    80002d9e:	f406                	sd	ra,40(sp)
    80002da0:	f022                	sd	s0,32(sp)
    80002da2:	ec26                	sd	s1,24(sp)
    80002da4:	e84a                	sd	s2,16(sp)
    80002da6:	e44e                	sd	s3,8(sp)
    80002da8:	1800                	addi	s0,sp,48
    for (unsigned int i = 0; i < MAX_SEM_VALUE; i++) {
    80002daa:	00014497          	auipc	s1,0x14
    80002dae:	c3e48493          	addi	s1,s1,-962 # 800169e8 <s+0x10>
    80002db2:	00014997          	auipc	s3,0x14
    80002db6:	f5698993          	addi	s3,s3,-170 # 80016d08 <bcache+0x10>
        s[i].inuse = false;
        initlock(&s[i].lock, "sem_lock");
    80002dba:	00005917          	auipc	s2,0x5
    80002dbe:	76e90913          	addi	s2,s2,1902 # 80008528 <syscalls+0xd8>
        s[i].inuse = false;
    80002dc2:	fe04ac23          	sw	zero,-8(s1)
        initlock(&s[i].lock, "sem_lock");
    80002dc6:	85ca                	mv	a1,s2
    80002dc8:	8526                	mv	a0,s1
    80002dca:	ffffe097          	auipc	ra,0xffffe
    80002dce:	d7c080e7          	jalr	-644(ra) # 80000b46 <initlock>
    for (unsigned int i = 0; i < MAX_SEM_VALUE; i++) {
    80002dd2:	02848493          	addi	s1,s1,40
    80002dd6:	ff3496e3          	bne	s1,s3,80002dc2 <init_sem+0x26>
    }
}
    80002dda:	70a2                	ld	ra,40(sp)
    80002ddc:	7402                	ld	s0,32(sp)
    80002dde:	64e2                	ld	s1,24(sp)
    80002de0:	6942                	ld	s2,16(sp)
    80002de2:	69a2                	ld	s3,8(sp)
    80002de4:	6145                	addi	sp,sp,48
    80002de6:	8082                	ret

0000000080002de8 <sys_sem_open>:


// Abre y/o inicializa el semáforo “sem” con un valor arbitrario “value”
uint64
sys_sem_open(void) 
{   
    80002de8:	7179                	addi	sp,sp,-48
    80002dea:	f406                	sd	ra,40(sp)
    80002dec:	f022                	sd	s0,32(sp)
    80002dee:	ec26                	sd	s1,24(sp)
    80002df0:	1800                	addi	s0,sp,48
    int sem, value;
    argint(0, &sem);
    80002df2:	fdc40593          	addi	a1,s0,-36
    80002df6:	4501                	li	a0,0
    80002df8:	00000097          	auipc	ra,0x0
    80002dfc:	cd2080e7          	jalr	-814(ra) # 80002aca <argint>
    argint(1, &value);
    80002e00:	fd840593          	addi	a1,s0,-40
    80002e04:	4505                	li	a0,1
    80002e06:	00000097          	auipc	ra,0x0
    80002e0a:	cc4080e7          	jalr	-828(ra) # 80002aca <argint>
    if (sem < 0 || sem >= MAX_SEM_VALUE) {
    80002e0e:	fdc42703          	lw	a4,-36(s0)
    80002e12:	0007069b          	sext.w	a3,a4
    80002e16:	47cd                	li	a5,19
        return -1; 
    80002e18:	557d                	li	a0,-1
    if (sem < 0 || sem >= MAX_SEM_VALUE) {
    80002e1a:	06d7e063          	bltu	a5,a3,80002e7a <sys_sem_open+0x92>
    }
    if (s[sem].inuse){
    80002e1e:	00271793          	slli	a5,a4,0x2
    80002e22:	97ba                	add	a5,a5,a4
    80002e24:	078e                	slli	a5,a5,0x3
    80002e26:	00014697          	auipc	a3,0x14
    80002e2a:	bb268693          	addi	a3,a3,-1102 # 800169d8 <s>
    80002e2e:	97b6                	add	a5,a5,a3
    80002e30:	479c                	lw	a5,8(a5)
      return -2;
    80002e32:	5579                	li	a0,-2
    if (s[sem].inuse){
    80002e34:	e3b9                	bnez	a5,80002e7a <sys_sem_open+0x92>
    }
    // init_sem(sem);
    acquire(&s[sem].lock);
    80002e36:	84b6                	mv	s1,a3
    80002e38:	00271513          	slli	a0,a4,0x2
    80002e3c:	953a                	add	a0,a0,a4
    80002e3e:	050e                	slli	a0,a0,0x3
    80002e40:	0541                	addi	a0,a0,16
    80002e42:	9536                	add	a0,a0,a3
    80002e44:	ffffe097          	auipc	ra,0xffffe
    80002e48:	d92080e7          	jalr	-622(ra) # 80000bd6 <acquire>
    s[sem].count = value;
    80002e4c:	fdc42703          	lw	a4,-36(s0)
    80002e50:	fd842683          	lw	a3,-40(s0)
    80002e54:	00271513          	slli	a0,a4,0x2
    80002e58:	00e507b3          	add	a5,a0,a4
    80002e5c:	078e                	slli	a5,a5,0x3
    80002e5e:	97a6                	add	a5,a5,s1
    80002e60:	c394                	sw	a3,0(a5)
    s[sem].start = value;
    80002e62:	c3d4                	sw	a3,4(a5)
    s[sem].inuse = true;
    80002e64:	4685                	li	a3,1
    80002e66:	c794                	sw	a3,8(a5)
    release(&s[sem].lock);
    80002e68:	953a                	add	a0,a0,a4
    80002e6a:	050e                	slli	a0,a0,0x3
    80002e6c:	0541                	addi	a0,a0,16
    80002e6e:	9526                	add	a0,a0,s1
    80002e70:	ffffe097          	auipc	ra,0xffffe
    80002e74:	e1a080e7          	jalr	-486(ra) # 80000c8a <release>
    return 0;
    80002e78:	4501                	li	a0,0
}
    80002e7a:	70a2                	ld	ra,40(sp)
    80002e7c:	7402                	ld	s0,32(sp)
    80002e7e:	64e2                	ld	s1,24(sp)
    80002e80:	6145                	addi	sp,sp,48
    80002e82:	8082                	ret

0000000080002e84 <sys_sem_close>:

// Libera el semáforo “sem”
uint64
sys_sem_close(void)  
{   
    80002e84:	7179                	addi	sp,sp,-48
    80002e86:	f406                	sd	ra,40(sp)
    80002e88:	f022                	sd	s0,32(sp)
    80002e8a:	ec26                	sd	s1,24(sp)
    80002e8c:	1800                	addi	s0,sp,48
    int sem;
    argint(0, &sem);
    80002e8e:	fdc40593          	addi	a1,s0,-36
    80002e92:	4501                	li	a0,0
    80002e94:	00000097          	auipc	ra,0x0
    80002e98:	c36080e7          	jalr	-970(ra) # 80002aca <argint>
    if (sem < 0||sem >= MAX_SEM_VALUE) {
    80002e9c:	fdc42703          	lw	a4,-36(s0)
    80002ea0:	0007069b          	sext.w	a3,a4
    80002ea4:	47cd                	li	a5,19
        return -1;
    80002ea6:	557d                	li	a0,-1
    if (sem < 0||sem >= MAX_SEM_VALUE) {
    80002ea8:	06d7e063          	bltu	a5,a3,80002f08 <sys_sem_close+0x84>
    }
    
    if (s[sem].inuse) { 
    80002eac:	00271793          	slli	a5,a4,0x2
    80002eb0:	97ba                	add	a5,a5,a4
    80002eb2:	078e                	slli	a5,a5,0x3
    80002eb4:	00014697          	auipc	a3,0x14
    80002eb8:	b2468693          	addi	a3,a3,-1244 # 800169d8 <s>
    80002ebc:	97b6                	add	a5,a5,a3
    80002ebe:	479c                	lw	a5,8(a5)
        s[sem].start = 0; 
        s[sem].inuse = false;   
        release(&s[sem].lock);
    }
    else {
        return -2;
    80002ec0:	5579                	li	a0,-2
    if (s[sem].inuse) { 
    80002ec2:	c3b9                	beqz	a5,80002f08 <sys_sem_close+0x84>
        acquire(&s[sem].lock);
    80002ec4:	84b6                	mv	s1,a3
    80002ec6:	00271513          	slli	a0,a4,0x2
    80002eca:	953a                	add	a0,a0,a4
    80002ecc:	050e                	slli	a0,a0,0x3
    80002ece:	0541                	addi	a0,a0,16
    80002ed0:	9536                	add	a0,a0,a3
    80002ed2:	ffffe097          	auipc	ra,0xffffe
    80002ed6:	d04080e7          	jalr	-764(ra) # 80000bd6 <acquire>
        s[sem].count = 0;
    80002eda:	fdc42703          	lw	a4,-36(s0)
    80002ede:	00271513          	slli	a0,a4,0x2
    80002ee2:	00e507b3          	add	a5,a0,a4
    80002ee6:	078e                	slli	a5,a5,0x3
    80002ee8:	97a6                	add	a5,a5,s1
    80002eea:	0007a023          	sw	zero,0(a5)
        s[sem].start = 0; 
    80002eee:	0007a223          	sw	zero,4(a5)
        s[sem].inuse = false;   
    80002ef2:	0007a423          	sw	zero,8(a5)
        release(&s[sem].lock);
    80002ef6:	953a                	add	a0,a0,a4
    80002ef8:	050e                	slli	a0,a0,0x3
    80002efa:	0541                	addi	a0,a0,16
    80002efc:	9526                	add	a0,a0,s1
    80002efe:	ffffe097          	auipc	ra,0xffffe
    80002f02:	d8c080e7          	jalr	-628(ra) # 80000c8a <release>
    }
    return 0;
    80002f06:	4501                	li	a0,0
}
    80002f08:	70a2                	ld	ra,40(sp)
    80002f0a:	7402                	ld	s0,32(sp)
    80002f0c:	64e2                	ld	s1,24(sp)
    80002f0e:	6145                	addi	sp,sp,48
    80002f10:	8082                	ret

0000000080002f12 <sys_sem_up>:

// Incrementa el semáforo ”sem” desbloqueando los procesos cuando su valor es 0
uint64
sys_sem_up(void)  
{   
    80002f12:	7179                	addi	sp,sp,-48
    80002f14:	f406                	sd	ra,40(sp)
    80002f16:	f022                	sd	s0,32(sp)
    80002f18:	ec26                	sd	s1,24(sp)
    80002f1a:	1800                	addi	s0,sp,48
    int sem;
    argint(0, &sem);
    80002f1c:	fdc40593          	addi	a1,s0,-36
    80002f20:	4501                	li	a0,0
    80002f22:	00000097          	auipc	ra,0x0
    80002f26:	ba8080e7          	jalr	-1112(ra) # 80002aca <argint>
    if (sem < 0||sem >= MAX_SEM_VALUE) {
    80002f2a:	fdc42783          	lw	a5,-36(s0)
    80002f2e:	0007869b          	sext.w	a3,a5
    80002f32:	474d                	li	a4,19
        return -1; 
    80002f34:	557d                	li	a0,-1
    if (sem < 0||sem >= MAX_SEM_VALUE) {
    80002f36:	04d76f63          	bltu	a4,a3,80002f94 <sys_sem_up+0x82>
    }
    acquire(&s[sem].lock);
    80002f3a:	00014497          	auipc	s1,0x14
    80002f3e:	a9e48493          	addi	s1,s1,-1378 # 800169d8 <s>
    80002f42:	00279513          	slli	a0,a5,0x2
    80002f46:	953e                	add	a0,a0,a5
    80002f48:	050e                	slli	a0,a0,0x3
    80002f4a:	0541                	addi	a0,a0,16
    80002f4c:	9526                	add	a0,a0,s1
    80002f4e:	ffffe097          	auipc	ra,0xffffe
    80002f52:	c88080e7          	jalr	-888(ra) # 80000bd6 <acquire>
    s[sem].count++;
    80002f56:	fdc42703          	lw	a4,-36(s0)
    80002f5a:	00271513          	slli	a0,a4,0x2
    80002f5e:	00e507b3          	add	a5,a0,a4
    80002f62:	078e                	slli	a5,a5,0x3
    80002f64:	97a6                	add	a5,a5,s1
    80002f66:	4394                	lw	a3,0(a5)
    80002f68:	2685                	addiw	a3,a3,1
    80002f6a:	c394                	sw	a3,0(a5)
    release(&s[sem].lock);
    80002f6c:	953a                	add	a0,a0,a4
    80002f6e:	050e                	slli	a0,a0,0x3
    80002f70:	0541                	addi	a0,a0,16
    80002f72:	9526                	add	a0,a0,s1
    80002f74:	ffffe097          	auipc	ra,0xffffe
    80002f78:	d16080e7          	jalr	-746(ra) # 80000c8a <release>

    if (s[sem].count == 1){
    80002f7c:	fdc42703          	lw	a4,-36(s0)
    80002f80:	00271793          	slli	a5,a4,0x2
    80002f84:	97ba                	add	a5,a5,a4
    80002f86:	078e                	slli	a5,a5,0x3
    80002f88:	94be                	add	s1,s1,a5
    80002f8a:	4094                	lw	a3,0(s1)
    80002f8c:	4785                	li	a5,1
      wakeup(&s[sem]);
    }
    return 0;
    80002f8e:	4501                	li	a0,0
    if (s[sem].count == 1){
    80002f90:	00f68763          	beq	a3,a5,80002f9e <sys_sem_up+0x8c>
}
    80002f94:	70a2                	ld	ra,40(sp)
    80002f96:	7402                	ld	s0,32(sp)
    80002f98:	64e2                	ld	s1,24(sp)
    80002f9a:	6145                	addi	sp,sp,48
    80002f9c:	8082                	ret
      wakeup(&s[sem]);
    80002f9e:	8526                	mv	a0,s1
    80002fa0:	fffff097          	auipc	ra,0xfffff
    80002fa4:	120080e7          	jalr	288(ra) # 800020c0 <wakeup>
    return 0;
    80002fa8:	4501                	li	a0,0
    80002faa:	b7ed                	j	80002f94 <sys_sem_up+0x82>

0000000080002fac <sys_sem_down>:

// Decrementa el semáforo ”sem” bloqueando los procesos cuando su valor es 0. El valor del semaforo nunca puede ser menor a 0
uint64
sys_sem_down(void)  
{   
    80002fac:	7179                	addi	sp,sp,-48
    80002fae:	f406                	sd	ra,40(sp)
    80002fb0:	f022                	sd	s0,32(sp)
    80002fb2:	ec26                	sd	s1,24(sp)
    80002fb4:	1800                	addi	s0,sp,48
    int sem;
    argint(0, &sem);
    80002fb6:	fdc40593          	addi	a1,s0,-36
    80002fba:	4501                	li	a0,0
    80002fbc:	00000097          	auipc	ra,0x0
    80002fc0:	b0e080e7          	jalr	-1266(ra) # 80002aca <argint>
    if (sem < 0|| sem >= MAX_SEM_VALUE) {
    80002fc4:	fdc42783          	lw	a5,-36(s0)
    80002fc8:	0007869b          	sext.w	a3,a5
    80002fcc:	474d                	li	a4,19
        return -1;
    80002fce:	557d                	li	a0,-1
    if (sem < 0|| sem >= MAX_SEM_VALUE) {
    80002fd0:	08d76763          	bltu	a4,a3,8000305e <sys_sem_down+0xb2>
    }

    acquire(&s[sem].lock);
    80002fd4:	00014497          	auipc	s1,0x14
    80002fd8:	a0448493          	addi	s1,s1,-1532 # 800169d8 <s>
    80002fdc:	00279513          	slli	a0,a5,0x2
    80002fe0:	953e                	add	a0,a0,a5
    80002fe2:	050e                	slli	a0,a0,0x3
    80002fe4:	0541                	addi	a0,a0,16
    80002fe6:	9526                	add	a0,a0,s1
    80002fe8:	ffffe097          	auipc	ra,0xffffe
    80002fec:	bee080e7          	jalr	-1042(ra) # 80000bd6 <acquire>
    while (s[sem].count == 0){
    80002ff0:	fdc42703          	lw	a4,-36(s0)
    80002ff4:	00271793          	slli	a5,a4,0x2
    80002ff8:	97ba                	add	a5,a5,a4
    80002ffa:	078e                	slli	a5,a5,0x3
    80002ffc:	94be                	add	s1,s1,a5
    80002ffe:	409c                	lw	a5,0(s1)
    80003000:	eb95                	bnez	a5,80003034 <sys_sem_down+0x88>
      sleep(&s[sem], &s[sem].lock);
    80003002:	00014497          	auipc	s1,0x14
    80003006:	9d648493          	addi	s1,s1,-1578 # 800169d8 <s>
    8000300a:	00271513          	slli	a0,a4,0x2
    8000300e:	953a                	add	a0,a0,a4
    80003010:	050e                	slli	a0,a0,0x3
    80003012:	01050593          	addi	a1,a0,16
    80003016:	95a6                	add	a1,a1,s1
    80003018:	9526                	add	a0,a0,s1
    8000301a:	fffff097          	auipc	ra,0xfffff
    8000301e:	042080e7          	jalr	66(ra) # 8000205c <sleep>
    while (s[sem].count == 0){
    80003022:	fdc42703          	lw	a4,-36(s0)
    80003026:	00271793          	slli	a5,a4,0x2
    8000302a:	97ba                	add	a5,a5,a4
    8000302c:	078e                	slli	a5,a5,0x3
    8000302e:	97a6                	add	a5,a5,s1
    80003030:	439c                	lw	a5,0(a5)
    80003032:	dfe1                	beqz	a5,8000300a <sys_sem_down+0x5e>
      }
    s[sem].count--;
    80003034:	00014517          	auipc	a0,0x14
    80003038:	9a450513          	addi	a0,a0,-1628 # 800169d8 <s>
    8000303c:	00271693          	slli	a3,a4,0x2
    80003040:	00e68633          	add	a2,a3,a4
    80003044:	060e                	slli	a2,a2,0x3
    80003046:	962a                	add	a2,a2,a0
    80003048:	37fd                	addiw	a5,a5,-1
    8000304a:	c21c                	sw	a5,0(a2)
    release(&s[sem].lock);
    8000304c:	96ba                	add	a3,a3,a4
    8000304e:	068e                	slli	a3,a3,0x3
    80003050:	06c1                	addi	a3,a3,16
    80003052:	9536                	add	a0,a0,a3
    80003054:	ffffe097          	auipc	ra,0xffffe
    80003058:	c36080e7          	jalr	-970(ra) # 80000c8a <release>
    return 0;
    8000305c:	4501                	li	a0,0
    8000305e:	70a2                	ld	ra,40(sp)
    80003060:	7402                	ld	s0,32(sp)
    80003062:	64e2                	ld	s1,24(sp)
    80003064:	6145                	addi	sp,sp,48
    80003066:	8082                	ret

0000000080003068 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003068:	7179                	addi	sp,sp,-48
    8000306a:	f406                	sd	ra,40(sp)
    8000306c:	f022                	sd	s0,32(sp)
    8000306e:	ec26                	sd	s1,24(sp)
    80003070:	e84a                	sd	s2,16(sp)
    80003072:	e44e                	sd	s3,8(sp)
    80003074:	e052                	sd	s4,0(sp)
    80003076:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003078:	00005597          	auipc	a1,0x5
    8000307c:	4c058593          	addi	a1,a1,1216 # 80008538 <syscalls+0xe8>
    80003080:	00014517          	auipc	a0,0x14
    80003084:	c7850513          	addi	a0,a0,-904 # 80016cf8 <bcache>
    80003088:	ffffe097          	auipc	ra,0xffffe
    8000308c:	abe080e7          	jalr	-1346(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003090:	0001c797          	auipc	a5,0x1c
    80003094:	c6878793          	addi	a5,a5,-920 # 8001ecf8 <bcache+0x8000>
    80003098:	0001c717          	auipc	a4,0x1c
    8000309c:	ec870713          	addi	a4,a4,-312 # 8001ef60 <bcache+0x8268>
    800030a0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030a4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030a8:	00014497          	auipc	s1,0x14
    800030ac:	c6848493          	addi	s1,s1,-920 # 80016d10 <bcache+0x18>
    b->next = bcache.head.next;
    800030b0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030b2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030b4:	00005a17          	auipc	s4,0x5
    800030b8:	48ca0a13          	addi	s4,s4,1164 # 80008540 <syscalls+0xf0>
    b->next = bcache.head.next;
    800030bc:	2b893783          	ld	a5,696(s2)
    800030c0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030c2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030c6:	85d2                	mv	a1,s4
    800030c8:	01048513          	addi	a0,s1,16
    800030cc:	00001097          	auipc	ra,0x1
    800030d0:	4c8080e7          	jalr	1224(ra) # 80004594 <initsleeplock>
    bcache.head.next->prev = b;
    800030d4:	2b893783          	ld	a5,696(s2)
    800030d8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030da:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030de:	45848493          	addi	s1,s1,1112
    800030e2:	fd349de3          	bne	s1,s3,800030bc <binit+0x54>
  }
}
    800030e6:	70a2                	ld	ra,40(sp)
    800030e8:	7402                	ld	s0,32(sp)
    800030ea:	64e2                	ld	s1,24(sp)
    800030ec:	6942                	ld	s2,16(sp)
    800030ee:	69a2                	ld	s3,8(sp)
    800030f0:	6a02                	ld	s4,0(sp)
    800030f2:	6145                	addi	sp,sp,48
    800030f4:	8082                	ret

00000000800030f6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030f6:	7179                	addi	sp,sp,-48
    800030f8:	f406                	sd	ra,40(sp)
    800030fa:	f022                	sd	s0,32(sp)
    800030fc:	ec26                	sd	s1,24(sp)
    800030fe:	e84a                	sd	s2,16(sp)
    80003100:	e44e                	sd	s3,8(sp)
    80003102:	1800                	addi	s0,sp,48
    80003104:	892a                	mv	s2,a0
    80003106:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003108:	00014517          	auipc	a0,0x14
    8000310c:	bf050513          	addi	a0,a0,-1040 # 80016cf8 <bcache>
    80003110:	ffffe097          	auipc	ra,0xffffe
    80003114:	ac6080e7          	jalr	-1338(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003118:	0001c497          	auipc	s1,0x1c
    8000311c:	e984b483          	ld	s1,-360(s1) # 8001efb0 <bcache+0x82b8>
    80003120:	0001c797          	auipc	a5,0x1c
    80003124:	e4078793          	addi	a5,a5,-448 # 8001ef60 <bcache+0x8268>
    80003128:	02f48f63          	beq	s1,a5,80003166 <bread+0x70>
    8000312c:	873e                	mv	a4,a5
    8000312e:	a021                	j	80003136 <bread+0x40>
    80003130:	68a4                	ld	s1,80(s1)
    80003132:	02e48a63          	beq	s1,a4,80003166 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003136:	449c                	lw	a5,8(s1)
    80003138:	ff279ce3          	bne	a5,s2,80003130 <bread+0x3a>
    8000313c:	44dc                	lw	a5,12(s1)
    8000313e:	ff3799e3          	bne	a5,s3,80003130 <bread+0x3a>
      b->refcnt++;
    80003142:	40bc                	lw	a5,64(s1)
    80003144:	2785                	addiw	a5,a5,1
    80003146:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003148:	00014517          	auipc	a0,0x14
    8000314c:	bb050513          	addi	a0,a0,-1104 # 80016cf8 <bcache>
    80003150:	ffffe097          	auipc	ra,0xffffe
    80003154:	b3a080e7          	jalr	-1222(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003158:	01048513          	addi	a0,s1,16
    8000315c:	00001097          	auipc	ra,0x1
    80003160:	472080e7          	jalr	1138(ra) # 800045ce <acquiresleep>
      return b;
    80003164:	a8b9                	j	800031c2 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003166:	0001c497          	auipc	s1,0x1c
    8000316a:	e424b483          	ld	s1,-446(s1) # 8001efa8 <bcache+0x82b0>
    8000316e:	0001c797          	auipc	a5,0x1c
    80003172:	df278793          	addi	a5,a5,-526 # 8001ef60 <bcache+0x8268>
    80003176:	00f48863          	beq	s1,a5,80003186 <bread+0x90>
    8000317a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000317c:	40bc                	lw	a5,64(s1)
    8000317e:	cf81                	beqz	a5,80003196 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003180:	64a4                	ld	s1,72(s1)
    80003182:	fee49de3          	bne	s1,a4,8000317c <bread+0x86>
  panic("bget: no buffers");
    80003186:	00005517          	auipc	a0,0x5
    8000318a:	3c250513          	addi	a0,a0,962 # 80008548 <syscalls+0xf8>
    8000318e:	ffffd097          	auipc	ra,0xffffd
    80003192:	3b2080e7          	jalr	946(ra) # 80000540 <panic>
      b->dev = dev;
    80003196:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000319a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000319e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031a2:	4785                	li	a5,1
    800031a4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031a6:	00014517          	auipc	a0,0x14
    800031aa:	b5250513          	addi	a0,a0,-1198 # 80016cf8 <bcache>
    800031ae:	ffffe097          	auipc	ra,0xffffe
    800031b2:	adc080e7          	jalr	-1316(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800031b6:	01048513          	addi	a0,s1,16
    800031ba:	00001097          	auipc	ra,0x1
    800031be:	414080e7          	jalr	1044(ra) # 800045ce <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031c2:	409c                	lw	a5,0(s1)
    800031c4:	cb89                	beqz	a5,800031d6 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031c6:	8526                	mv	a0,s1
    800031c8:	70a2                	ld	ra,40(sp)
    800031ca:	7402                	ld	s0,32(sp)
    800031cc:	64e2                	ld	s1,24(sp)
    800031ce:	6942                	ld	s2,16(sp)
    800031d0:	69a2                	ld	s3,8(sp)
    800031d2:	6145                	addi	sp,sp,48
    800031d4:	8082                	ret
    virtio_disk_rw(b, 0);
    800031d6:	4581                	li	a1,0
    800031d8:	8526                	mv	a0,s1
    800031da:	00003097          	auipc	ra,0x3
    800031de:	fd8080e7          	jalr	-40(ra) # 800061b2 <virtio_disk_rw>
    b->valid = 1;
    800031e2:	4785                	li	a5,1
    800031e4:	c09c                	sw	a5,0(s1)
  return b;
    800031e6:	b7c5                	j	800031c6 <bread+0xd0>

00000000800031e8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031e8:	1101                	addi	sp,sp,-32
    800031ea:	ec06                	sd	ra,24(sp)
    800031ec:	e822                	sd	s0,16(sp)
    800031ee:	e426                	sd	s1,8(sp)
    800031f0:	1000                	addi	s0,sp,32
    800031f2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031f4:	0541                	addi	a0,a0,16
    800031f6:	00001097          	auipc	ra,0x1
    800031fa:	472080e7          	jalr	1138(ra) # 80004668 <holdingsleep>
    800031fe:	cd01                	beqz	a0,80003216 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003200:	4585                	li	a1,1
    80003202:	8526                	mv	a0,s1
    80003204:	00003097          	auipc	ra,0x3
    80003208:	fae080e7          	jalr	-82(ra) # 800061b2 <virtio_disk_rw>
}
    8000320c:	60e2                	ld	ra,24(sp)
    8000320e:	6442                	ld	s0,16(sp)
    80003210:	64a2                	ld	s1,8(sp)
    80003212:	6105                	addi	sp,sp,32
    80003214:	8082                	ret
    panic("bwrite");
    80003216:	00005517          	auipc	a0,0x5
    8000321a:	34a50513          	addi	a0,a0,842 # 80008560 <syscalls+0x110>
    8000321e:	ffffd097          	auipc	ra,0xffffd
    80003222:	322080e7          	jalr	802(ra) # 80000540 <panic>

0000000080003226 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003226:	1101                	addi	sp,sp,-32
    80003228:	ec06                	sd	ra,24(sp)
    8000322a:	e822                	sd	s0,16(sp)
    8000322c:	e426                	sd	s1,8(sp)
    8000322e:	e04a                	sd	s2,0(sp)
    80003230:	1000                	addi	s0,sp,32
    80003232:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003234:	01050913          	addi	s2,a0,16
    80003238:	854a                	mv	a0,s2
    8000323a:	00001097          	auipc	ra,0x1
    8000323e:	42e080e7          	jalr	1070(ra) # 80004668 <holdingsleep>
    80003242:	c92d                	beqz	a0,800032b4 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003244:	854a                	mv	a0,s2
    80003246:	00001097          	auipc	ra,0x1
    8000324a:	3de080e7          	jalr	990(ra) # 80004624 <releasesleep>

  acquire(&bcache.lock);
    8000324e:	00014517          	auipc	a0,0x14
    80003252:	aaa50513          	addi	a0,a0,-1366 # 80016cf8 <bcache>
    80003256:	ffffe097          	auipc	ra,0xffffe
    8000325a:	980080e7          	jalr	-1664(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000325e:	40bc                	lw	a5,64(s1)
    80003260:	37fd                	addiw	a5,a5,-1
    80003262:	0007871b          	sext.w	a4,a5
    80003266:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003268:	eb05                	bnez	a4,80003298 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000326a:	68bc                	ld	a5,80(s1)
    8000326c:	64b8                	ld	a4,72(s1)
    8000326e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003270:	64bc                	ld	a5,72(s1)
    80003272:	68b8                	ld	a4,80(s1)
    80003274:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003276:	0001c797          	auipc	a5,0x1c
    8000327a:	a8278793          	addi	a5,a5,-1406 # 8001ecf8 <bcache+0x8000>
    8000327e:	2b87b703          	ld	a4,696(a5)
    80003282:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003284:	0001c717          	auipc	a4,0x1c
    80003288:	cdc70713          	addi	a4,a4,-804 # 8001ef60 <bcache+0x8268>
    8000328c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000328e:	2b87b703          	ld	a4,696(a5)
    80003292:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003294:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003298:	00014517          	auipc	a0,0x14
    8000329c:	a6050513          	addi	a0,a0,-1440 # 80016cf8 <bcache>
    800032a0:	ffffe097          	auipc	ra,0xffffe
    800032a4:	9ea080e7          	jalr	-1558(ra) # 80000c8a <release>
}
    800032a8:	60e2                	ld	ra,24(sp)
    800032aa:	6442                	ld	s0,16(sp)
    800032ac:	64a2                	ld	s1,8(sp)
    800032ae:	6902                	ld	s2,0(sp)
    800032b0:	6105                	addi	sp,sp,32
    800032b2:	8082                	ret
    panic("brelse");
    800032b4:	00005517          	auipc	a0,0x5
    800032b8:	2b450513          	addi	a0,a0,692 # 80008568 <syscalls+0x118>
    800032bc:	ffffd097          	auipc	ra,0xffffd
    800032c0:	284080e7          	jalr	644(ra) # 80000540 <panic>

00000000800032c4 <bpin>:

void
bpin(struct buf *b) {
    800032c4:	1101                	addi	sp,sp,-32
    800032c6:	ec06                	sd	ra,24(sp)
    800032c8:	e822                	sd	s0,16(sp)
    800032ca:	e426                	sd	s1,8(sp)
    800032cc:	1000                	addi	s0,sp,32
    800032ce:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032d0:	00014517          	auipc	a0,0x14
    800032d4:	a2850513          	addi	a0,a0,-1496 # 80016cf8 <bcache>
    800032d8:	ffffe097          	auipc	ra,0xffffe
    800032dc:	8fe080e7          	jalr	-1794(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800032e0:	40bc                	lw	a5,64(s1)
    800032e2:	2785                	addiw	a5,a5,1
    800032e4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032e6:	00014517          	auipc	a0,0x14
    800032ea:	a1250513          	addi	a0,a0,-1518 # 80016cf8 <bcache>
    800032ee:	ffffe097          	auipc	ra,0xffffe
    800032f2:	99c080e7          	jalr	-1636(ra) # 80000c8a <release>
}
    800032f6:	60e2                	ld	ra,24(sp)
    800032f8:	6442                	ld	s0,16(sp)
    800032fa:	64a2                	ld	s1,8(sp)
    800032fc:	6105                	addi	sp,sp,32
    800032fe:	8082                	ret

0000000080003300 <bunpin>:

void
bunpin(struct buf *b) {
    80003300:	1101                	addi	sp,sp,-32
    80003302:	ec06                	sd	ra,24(sp)
    80003304:	e822                	sd	s0,16(sp)
    80003306:	e426                	sd	s1,8(sp)
    80003308:	1000                	addi	s0,sp,32
    8000330a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000330c:	00014517          	auipc	a0,0x14
    80003310:	9ec50513          	addi	a0,a0,-1556 # 80016cf8 <bcache>
    80003314:	ffffe097          	auipc	ra,0xffffe
    80003318:	8c2080e7          	jalr	-1854(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000331c:	40bc                	lw	a5,64(s1)
    8000331e:	37fd                	addiw	a5,a5,-1
    80003320:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003322:	00014517          	auipc	a0,0x14
    80003326:	9d650513          	addi	a0,a0,-1578 # 80016cf8 <bcache>
    8000332a:	ffffe097          	auipc	ra,0xffffe
    8000332e:	960080e7          	jalr	-1696(ra) # 80000c8a <release>
}
    80003332:	60e2                	ld	ra,24(sp)
    80003334:	6442                	ld	s0,16(sp)
    80003336:	64a2                	ld	s1,8(sp)
    80003338:	6105                	addi	sp,sp,32
    8000333a:	8082                	ret

000000008000333c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000333c:	1101                	addi	sp,sp,-32
    8000333e:	ec06                	sd	ra,24(sp)
    80003340:	e822                	sd	s0,16(sp)
    80003342:	e426                	sd	s1,8(sp)
    80003344:	e04a                	sd	s2,0(sp)
    80003346:	1000                	addi	s0,sp,32
    80003348:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000334a:	00d5d59b          	srliw	a1,a1,0xd
    8000334e:	0001c797          	auipc	a5,0x1c
    80003352:	0867a783          	lw	a5,134(a5) # 8001f3d4 <sb+0x1c>
    80003356:	9dbd                	addw	a1,a1,a5
    80003358:	00000097          	auipc	ra,0x0
    8000335c:	d9e080e7          	jalr	-610(ra) # 800030f6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003360:	0074f713          	andi	a4,s1,7
    80003364:	4785                	li	a5,1
    80003366:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000336a:	14ce                	slli	s1,s1,0x33
    8000336c:	90d9                	srli	s1,s1,0x36
    8000336e:	00950733          	add	a4,a0,s1
    80003372:	05874703          	lbu	a4,88(a4)
    80003376:	00e7f6b3          	and	a3,a5,a4
    8000337a:	c69d                	beqz	a3,800033a8 <bfree+0x6c>
    8000337c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000337e:	94aa                	add	s1,s1,a0
    80003380:	fff7c793          	not	a5,a5
    80003384:	8f7d                	and	a4,a4,a5
    80003386:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000338a:	00001097          	auipc	ra,0x1
    8000338e:	126080e7          	jalr	294(ra) # 800044b0 <log_write>
  brelse(bp);
    80003392:	854a                	mv	a0,s2
    80003394:	00000097          	auipc	ra,0x0
    80003398:	e92080e7          	jalr	-366(ra) # 80003226 <brelse>
}
    8000339c:	60e2                	ld	ra,24(sp)
    8000339e:	6442                	ld	s0,16(sp)
    800033a0:	64a2                	ld	s1,8(sp)
    800033a2:	6902                	ld	s2,0(sp)
    800033a4:	6105                	addi	sp,sp,32
    800033a6:	8082                	ret
    panic("freeing free block");
    800033a8:	00005517          	auipc	a0,0x5
    800033ac:	1c850513          	addi	a0,a0,456 # 80008570 <syscalls+0x120>
    800033b0:	ffffd097          	auipc	ra,0xffffd
    800033b4:	190080e7          	jalr	400(ra) # 80000540 <panic>

00000000800033b8 <balloc>:
{
    800033b8:	711d                	addi	sp,sp,-96
    800033ba:	ec86                	sd	ra,88(sp)
    800033bc:	e8a2                	sd	s0,80(sp)
    800033be:	e4a6                	sd	s1,72(sp)
    800033c0:	e0ca                	sd	s2,64(sp)
    800033c2:	fc4e                	sd	s3,56(sp)
    800033c4:	f852                	sd	s4,48(sp)
    800033c6:	f456                	sd	s5,40(sp)
    800033c8:	f05a                	sd	s6,32(sp)
    800033ca:	ec5e                	sd	s7,24(sp)
    800033cc:	e862                	sd	s8,16(sp)
    800033ce:	e466                	sd	s9,8(sp)
    800033d0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033d2:	0001c797          	auipc	a5,0x1c
    800033d6:	fea7a783          	lw	a5,-22(a5) # 8001f3bc <sb+0x4>
    800033da:	cff5                	beqz	a5,800034d6 <balloc+0x11e>
    800033dc:	8baa                	mv	s7,a0
    800033de:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033e0:	0001cb17          	auipc	s6,0x1c
    800033e4:	fd8b0b13          	addi	s6,s6,-40 # 8001f3b8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033e8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033ea:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033ec:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033ee:	6c89                	lui	s9,0x2
    800033f0:	a061                	j	80003478 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033f2:	97ca                	add	a5,a5,s2
    800033f4:	8e55                	or	a2,a2,a3
    800033f6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800033fa:	854a                	mv	a0,s2
    800033fc:	00001097          	auipc	ra,0x1
    80003400:	0b4080e7          	jalr	180(ra) # 800044b0 <log_write>
        brelse(bp);
    80003404:	854a                	mv	a0,s2
    80003406:	00000097          	auipc	ra,0x0
    8000340a:	e20080e7          	jalr	-480(ra) # 80003226 <brelse>
  bp = bread(dev, bno);
    8000340e:	85a6                	mv	a1,s1
    80003410:	855e                	mv	a0,s7
    80003412:	00000097          	auipc	ra,0x0
    80003416:	ce4080e7          	jalr	-796(ra) # 800030f6 <bread>
    8000341a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000341c:	40000613          	li	a2,1024
    80003420:	4581                	li	a1,0
    80003422:	05850513          	addi	a0,a0,88
    80003426:	ffffe097          	auipc	ra,0xffffe
    8000342a:	8ac080e7          	jalr	-1876(ra) # 80000cd2 <memset>
  log_write(bp);
    8000342e:	854a                	mv	a0,s2
    80003430:	00001097          	auipc	ra,0x1
    80003434:	080080e7          	jalr	128(ra) # 800044b0 <log_write>
  brelse(bp);
    80003438:	854a                	mv	a0,s2
    8000343a:	00000097          	auipc	ra,0x0
    8000343e:	dec080e7          	jalr	-532(ra) # 80003226 <brelse>
}
    80003442:	8526                	mv	a0,s1
    80003444:	60e6                	ld	ra,88(sp)
    80003446:	6446                	ld	s0,80(sp)
    80003448:	64a6                	ld	s1,72(sp)
    8000344a:	6906                	ld	s2,64(sp)
    8000344c:	79e2                	ld	s3,56(sp)
    8000344e:	7a42                	ld	s4,48(sp)
    80003450:	7aa2                	ld	s5,40(sp)
    80003452:	7b02                	ld	s6,32(sp)
    80003454:	6be2                	ld	s7,24(sp)
    80003456:	6c42                	ld	s8,16(sp)
    80003458:	6ca2                	ld	s9,8(sp)
    8000345a:	6125                	addi	sp,sp,96
    8000345c:	8082                	ret
    brelse(bp);
    8000345e:	854a                	mv	a0,s2
    80003460:	00000097          	auipc	ra,0x0
    80003464:	dc6080e7          	jalr	-570(ra) # 80003226 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003468:	015c87bb          	addw	a5,s9,s5
    8000346c:	00078a9b          	sext.w	s5,a5
    80003470:	004b2703          	lw	a4,4(s6)
    80003474:	06eaf163          	bgeu	s5,a4,800034d6 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003478:	41fad79b          	sraiw	a5,s5,0x1f
    8000347c:	0137d79b          	srliw	a5,a5,0x13
    80003480:	015787bb          	addw	a5,a5,s5
    80003484:	40d7d79b          	sraiw	a5,a5,0xd
    80003488:	01cb2583          	lw	a1,28(s6)
    8000348c:	9dbd                	addw	a1,a1,a5
    8000348e:	855e                	mv	a0,s7
    80003490:	00000097          	auipc	ra,0x0
    80003494:	c66080e7          	jalr	-922(ra) # 800030f6 <bread>
    80003498:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000349a:	004b2503          	lw	a0,4(s6)
    8000349e:	000a849b          	sext.w	s1,s5
    800034a2:	8762                	mv	a4,s8
    800034a4:	faa4fde3          	bgeu	s1,a0,8000345e <balloc+0xa6>
      m = 1 << (bi % 8);
    800034a8:	00777693          	andi	a3,a4,7
    800034ac:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034b0:	41f7579b          	sraiw	a5,a4,0x1f
    800034b4:	01d7d79b          	srliw	a5,a5,0x1d
    800034b8:	9fb9                	addw	a5,a5,a4
    800034ba:	4037d79b          	sraiw	a5,a5,0x3
    800034be:	00f90633          	add	a2,s2,a5
    800034c2:	05864603          	lbu	a2,88(a2)
    800034c6:	00c6f5b3          	and	a1,a3,a2
    800034ca:	d585                	beqz	a1,800033f2 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034cc:	2705                	addiw	a4,a4,1
    800034ce:	2485                	addiw	s1,s1,1
    800034d0:	fd471ae3          	bne	a4,s4,800034a4 <balloc+0xec>
    800034d4:	b769                	j	8000345e <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800034d6:	00005517          	auipc	a0,0x5
    800034da:	0b250513          	addi	a0,a0,178 # 80008588 <syscalls+0x138>
    800034de:	ffffd097          	auipc	ra,0xffffd
    800034e2:	0ac080e7          	jalr	172(ra) # 8000058a <printf>
  return 0;
    800034e6:	4481                	li	s1,0
    800034e8:	bfa9                	j	80003442 <balloc+0x8a>

00000000800034ea <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800034ea:	7179                	addi	sp,sp,-48
    800034ec:	f406                	sd	ra,40(sp)
    800034ee:	f022                	sd	s0,32(sp)
    800034f0:	ec26                	sd	s1,24(sp)
    800034f2:	e84a                	sd	s2,16(sp)
    800034f4:	e44e                	sd	s3,8(sp)
    800034f6:	e052                	sd	s4,0(sp)
    800034f8:	1800                	addi	s0,sp,48
    800034fa:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034fc:	47ad                	li	a5,11
    800034fe:	02b7e863          	bltu	a5,a1,8000352e <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003502:	02059793          	slli	a5,a1,0x20
    80003506:	01e7d593          	srli	a1,a5,0x1e
    8000350a:	00b504b3          	add	s1,a0,a1
    8000350e:	0504a903          	lw	s2,80(s1)
    80003512:	06091e63          	bnez	s2,8000358e <bmap+0xa4>
      addr = balloc(ip->dev);
    80003516:	4108                	lw	a0,0(a0)
    80003518:	00000097          	auipc	ra,0x0
    8000351c:	ea0080e7          	jalr	-352(ra) # 800033b8 <balloc>
    80003520:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003524:	06090563          	beqz	s2,8000358e <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003528:	0524a823          	sw	s2,80(s1)
    8000352c:	a08d                	j	8000358e <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000352e:	ff45849b          	addiw	s1,a1,-12
    80003532:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003536:	0ff00793          	li	a5,255
    8000353a:	08e7e563          	bltu	a5,a4,800035c4 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000353e:	08052903          	lw	s2,128(a0)
    80003542:	00091d63          	bnez	s2,8000355c <bmap+0x72>
      addr = balloc(ip->dev);
    80003546:	4108                	lw	a0,0(a0)
    80003548:	00000097          	auipc	ra,0x0
    8000354c:	e70080e7          	jalr	-400(ra) # 800033b8 <balloc>
    80003550:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003554:	02090d63          	beqz	s2,8000358e <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003558:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000355c:	85ca                	mv	a1,s2
    8000355e:	0009a503          	lw	a0,0(s3)
    80003562:	00000097          	auipc	ra,0x0
    80003566:	b94080e7          	jalr	-1132(ra) # 800030f6 <bread>
    8000356a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000356c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003570:	02049713          	slli	a4,s1,0x20
    80003574:	01e75593          	srli	a1,a4,0x1e
    80003578:	00b784b3          	add	s1,a5,a1
    8000357c:	0004a903          	lw	s2,0(s1)
    80003580:	02090063          	beqz	s2,800035a0 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003584:	8552                	mv	a0,s4
    80003586:	00000097          	auipc	ra,0x0
    8000358a:	ca0080e7          	jalr	-864(ra) # 80003226 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000358e:	854a                	mv	a0,s2
    80003590:	70a2                	ld	ra,40(sp)
    80003592:	7402                	ld	s0,32(sp)
    80003594:	64e2                	ld	s1,24(sp)
    80003596:	6942                	ld	s2,16(sp)
    80003598:	69a2                	ld	s3,8(sp)
    8000359a:	6a02                	ld	s4,0(sp)
    8000359c:	6145                	addi	sp,sp,48
    8000359e:	8082                	ret
      addr = balloc(ip->dev);
    800035a0:	0009a503          	lw	a0,0(s3)
    800035a4:	00000097          	auipc	ra,0x0
    800035a8:	e14080e7          	jalr	-492(ra) # 800033b8 <balloc>
    800035ac:	0005091b          	sext.w	s2,a0
      if(addr){
    800035b0:	fc090ae3          	beqz	s2,80003584 <bmap+0x9a>
        a[bn] = addr;
    800035b4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800035b8:	8552                	mv	a0,s4
    800035ba:	00001097          	auipc	ra,0x1
    800035be:	ef6080e7          	jalr	-266(ra) # 800044b0 <log_write>
    800035c2:	b7c9                	j	80003584 <bmap+0x9a>
  panic("bmap: out of range");
    800035c4:	00005517          	auipc	a0,0x5
    800035c8:	fdc50513          	addi	a0,a0,-36 # 800085a0 <syscalls+0x150>
    800035cc:	ffffd097          	auipc	ra,0xffffd
    800035d0:	f74080e7          	jalr	-140(ra) # 80000540 <panic>

00000000800035d4 <iget>:
{
    800035d4:	7179                	addi	sp,sp,-48
    800035d6:	f406                	sd	ra,40(sp)
    800035d8:	f022                	sd	s0,32(sp)
    800035da:	ec26                	sd	s1,24(sp)
    800035dc:	e84a                	sd	s2,16(sp)
    800035de:	e44e                	sd	s3,8(sp)
    800035e0:	e052                	sd	s4,0(sp)
    800035e2:	1800                	addi	s0,sp,48
    800035e4:	89aa                	mv	s3,a0
    800035e6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800035e8:	0001c517          	auipc	a0,0x1c
    800035ec:	df050513          	addi	a0,a0,-528 # 8001f3d8 <itable>
    800035f0:	ffffd097          	auipc	ra,0xffffd
    800035f4:	5e6080e7          	jalr	1510(ra) # 80000bd6 <acquire>
  empty = 0;
    800035f8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035fa:	0001c497          	auipc	s1,0x1c
    800035fe:	df648493          	addi	s1,s1,-522 # 8001f3f0 <itable+0x18>
    80003602:	0001e697          	auipc	a3,0x1e
    80003606:	87e68693          	addi	a3,a3,-1922 # 80020e80 <log>
    8000360a:	a039                	j	80003618 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000360c:	02090b63          	beqz	s2,80003642 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003610:	08848493          	addi	s1,s1,136
    80003614:	02d48a63          	beq	s1,a3,80003648 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003618:	449c                	lw	a5,8(s1)
    8000361a:	fef059e3          	blez	a5,8000360c <iget+0x38>
    8000361e:	4098                	lw	a4,0(s1)
    80003620:	ff3716e3          	bne	a4,s3,8000360c <iget+0x38>
    80003624:	40d8                	lw	a4,4(s1)
    80003626:	ff4713e3          	bne	a4,s4,8000360c <iget+0x38>
      ip->ref++;
    8000362a:	2785                	addiw	a5,a5,1
    8000362c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000362e:	0001c517          	auipc	a0,0x1c
    80003632:	daa50513          	addi	a0,a0,-598 # 8001f3d8 <itable>
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	654080e7          	jalr	1620(ra) # 80000c8a <release>
      return ip;
    8000363e:	8926                	mv	s2,s1
    80003640:	a03d                	j	8000366e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003642:	f7f9                	bnez	a5,80003610 <iget+0x3c>
    80003644:	8926                	mv	s2,s1
    80003646:	b7e9                	j	80003610 <iget+0x3c>
  if(empty == 0)
    80003648:	02090c63          	beqz	s2,80003680 <iget+0xac>
  ip->dev = dev;
    8000364c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003650:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003654:	4785                	li	a5,1
    80003656:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000365a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000365e:	0001c517          	auipc	a0,0x1c
    80003662:	d7a50513          	addi	a0,a0,-646 # 8001f3d8 <itable>
    80003666:	ffffd097          	auipc	ra,0xffffd
    8000366a:	624080e7          	jalr	1572(ra) # 80000c8a <release>
}
    8000366e:	854a                	mv	a0,s2
    80003670:	70a2                	ld	ra,40(sp)
    80003672:	7402                	ld	s0,32(sp)
    80003674:	64e2                	ld	s1,24(sp)
    80003676:	6942                	ld	s2,16(sp)
    80003678:	69a2                	ld	s3,8(sp)
    8000367a:	6a02                	ld	s4,0(sp)
    8000367c:	6145                	addi	sp,sp,48
    8000367e:	8082                	ret
    panic("iget: no inodes");
    80003680:	00005517          	auipc	a0,0x5
    80003684:	f3850513          	addi	a0,a0,-200 # 800085b8 <syscalls+0x168>
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	eb8080e7          	jalr	-328(ra) # 80000540 <panic>

0000000080003690 <fsinit>:
fsinit(int dev) {
    80003690:	7179                	addi	sp,sp,-48
    80003692:	f406                	sd	ra,40(sp)
    80003694:	f022                	sd	s0,32(sp)
    80003696:	ec26                	sd	s1,24(sp)
    80003698:	e84a                	sd	s2,16(sp)
    8000369a:	e44e                	sd	s3,8(sp)
    8000369c:	1800                	addi	s0,sp,48
    8000369e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036a0:	4585                	li	a1,1
    800036a2:	00000097          	auipc	ra,0x0
    800036a6:	a54080e7          	jalr	-1452(ra) # 800030f6 <bread>
    800036aa:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036ac:	0001c997          	auipc	s3,0x1c
    800036b0:	d0c98993          	addi	s3,s3,-756 # 8001f3b8 <sb>
    800036b4:	02000613          	li	a2,32
    800036b8:	05850593          	addi	a1,a0,88
    800036bc:	854e                	mv	a0,s3
    800036be:	ffffd097          	auipc	ra,0xffffd
    800036c2:	670080e7          	jalr	1648(ra) # 80000d2e <memmove>
  brelse(bp);
    800036c6:	8526                	mv	a0,s1
    800036c8:	00000097          	auipc	ra,0x0
    800036cc:	b5e080e7          	jalr	-1186(ra) # 80003226 <brelse>
  if(sb.magic != FSMAGIC)
    800036d0:	0009a703          	lw	a4,0(s3)
    800036d4:	102037b7          	lui	a5,0x10203
    800036d8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036dc:	02f71263          	bne	a4,a5,80003700 <fsinit+0x70>
  initlog(dev, &sb);
    800036e0:	0001c597          	auipc	a1,0x1c
    800036e4:	cd858593          	addi	a1,a1,-808 # 8001f3b8 <sb>
    800036e8:	854a                	mv	a0,s2
    800036ea:	00001097          	auipc	ra,0x1
    800036ee:	b4a080e7          	jalr	-1206(ra) # 80004234 <initlog>
}
    800036f2:	70a2                	ld	ra,40(sp)
    800036f4:	7402                	ld	s0,32(sp)
    800036f6:	64e2                	ld	s1,24(sp)
    800036f8:	6942                	ld	s2,16(sp)
    800036fa:	69a2                	ld	s3,8(sp)
    800036fc:	6145                	addi	sp,sp,48
    800036fe:	8082                	ret
    panic("invalid file system");
    80003700:	00005517          	auipc	a0,0x5
    80003704:	ec850513          	addi	a0,a0,-312 # 800085c8 <syscalls+0x178>
    80003708:	ffffd097          	auipc	ra,0xffffd
    8000370c:	e38080e7          	jalr	-456(ra) # 80000540 <panic>

0000000080003710 <iinit>:
{
    80003710:	7179                	addi	sp,sp,-48
    80003712:	f406                	sd	ra,40(sp)
    80003714:	f022                	sd	s0,32(sp)
    80003716:	ec26                	sd	s1,24(sp)
    80003718:	e84a                	sd	s2,16(sp)
    8000371a:	e44e                	sd	s3,8(sp)
    8000371c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000371e:	00005597          	auipc	a1,0x5
    80003722:	ec258593          	addi	a1,a1,-318 # 800085e0 <syscalls+0x190>
    80003726:	0001c517          	auipc	a0,0x1c
    8000372a:	cb250513          	addi	a0,a0,-846 # 8001f3d8 <itable>
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	418080e7          	jalr	1048(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003736:	0001c497          	auipc	s1,0x1c
    8000373a:	cca48493          	addi	s1,s1,-822 # 8001f400 <itable+0x28>
    8000373e:	0001d997          	auipc	s3,0x1d
    80003742:	75298993          	addi	s3,s3,1874 # 80020e90 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003746:	00005917          	auipc	s2,0x5
    8000374a:	ea290913          	addi	s2,s2,-350 # 800085e8 <syscalls+0x198>
    8000374e:	85ca                	mv	a1,s2
    80003750:	8526                	mv	a0,s1
    80003752:	00001097          	auipc	ra,0x1
    80003756:	e42080e7          	jalr	-446(ra) # 80004594 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000375a:	08848493          	addi	s1,s1,136
    8000375e:	ff3498e3          	bne	s1,s3,8000374e <iinit+0x3e>
}
    80003762:	70a2                	ld	ra,40(sp)
    80003764:	7402                	ld	s0,32(sp)
    80003766:	64e2                	ld	s1,24(sp)
    80003768:	6942                	ld	s2,16(sp)
    8000376a:	69a2                	ld	s3,8(sp)
    8000376c:	6145                	addi	sp,sp,48
    8000376e:	8082                	ret

0000000080003770 <ialloc>:
{
    80003770:	715d                	addi	sp,sp,-80
    80003772:	e486                	sd	ra,72(sp)
    80003774:	e0a2                	sd	s0,64(sp)
    80003776:	fc26                	sd	s1,56(sp)
    80003778:	f84a                	sd	s2,48(sp)
    8000377a:	f44e                	sd	s3,40(sp)
    8000377c:	f052                	sd	s4,32(sp)
    8000377e:	ec56                	sd	s5,24(sp)
    80003780:	e85a                	sd	s6,16(sp)
    80003782:	e45e                	sd	s7,8(sp)
    80003784:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003786:	0001c717          	auipc	a4,0x1c
    8000378a:	c3e72703          	lw	a4,-962(a4) # 8001f3c4 <sb+0xc>
    8000378e:	4785                	li	a5,1
    80003790:	04e7fa63          	bgeu	a5,a4,800037e4 <ialloc+0x74>
    80003794:	8aaa                	mv	s5,a0
    80003796:	8bae                	mv	s7,a1
    80003798:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000379a:	0001ca17          	auipc	s4,0x1c
    8000379e:	c1ea0a13          	addi	s4,s4,-994 # 8001f3b8 <sb>
    800037a2:	00048b1b          	sext.w	s6,s1
    800037a6:	0044d593          	srli	a1,s1,0x4
    800037aa:	018a2783          	lw	a5,24(s4)
    800037ae:	9dbd                	addw	a1,a1,a5
    800037b0:	8556                	mv	a0,s5
    800037b2:	00000097          	auipc	ra,0x0
    800037b6:	944080e7          	jalr	-1724(ra) # 800030f6 <bread>
    800037ba:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037bc:	05850993          	addi	s3,a0,88
    800037c0:	00f4f793          	andi	a5,s1,15
    800037c4:	079a                	slli	a5,a5,0x6
    800037c6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037c8:	00099783          	lh	a5,0(s3)
    800037cc:	c3a1                	beqz	a5,8000380c <ialloc+0x9c>
    brelse(bp);
    800037ce:	00000097          	auipc	ra,0x0
    800037d2:	a58080e7          	jalr	-1448(ra) # 80003226 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037d6:	0485                	addi	s1,s1,1
    800037d8:	00ca2703          	lw	a4,12(s4)
    800037dc:	0004879b          	sext.w	a5,s1
    800037e0:	fce7e1e3          	bltu	a5,a4,800037a2 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800037e4:	00005517          	auipc	a0,0x5
    800037e8:	e0c50513          	addi	a0,a0,-500 # 800085f0 <syscalls+0x1a0>
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	d9e080e7          	jalr	-610(ra) # 8000058a <printf>
  return 0;
    800037f4:	4501                	li	a0,0
}
    800037f6:	60a6                	ld	ra,72(sp)
    800037f8:	6406                	ld	s0,64(sp)
    800037fa:	74e2                	ld	s1,56(sp)
    800037fc:	7942                	ld	s2,48(sp)
    800037fe:	79a2                	ld	s3,40(sp)
    80003800:	7a02                	ld	s4,32(sp)
    80003802:	6ae2                	ld	s5,24(sp)
    80003804:	6b42                	ld	s6,16(sp)
    80003806:	6ba2                	ld	s7,8(sp)
    80003808:	6161                	addi	sp,sp,80
    8000380a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000380c:	04000613          	li	a2,64
    80003810:	4581                	li	a1,0
    80003812:	854e                	mv	a0,s3
    80003814:	ffffd097          	auipc	ra,0xffffd
    80003818:	4be080e7          	jalr	1214(ra) # 80000cd2 <memset>
      dip->type = type;
    8000381c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003820:	854a                	mv	a0,s2
    80003822:	00001097          	auipc	ra,0x1
    80003826:	c8e080e7          	jalr	-882(ra) # 800044b0 <log_write>
      brelse(bp);
    8000382a:	854a                	mv	a0,s2
    8000382c:	00000097          	auipc	ra,0x0
    80003830:	9fa080e7          	jalr	-1542(ra) # 80003226 <brelse>
      return iget(dev, inum);
    80003834:	85da                	mv	a1,s6
    80003836:	8556                	mv	a0,s5
    80003838:	00000097          	auipc	ra,0x0
    8000383c:	d9c080e7          	jalr	-612(ra) # 800035d4 <iget>
    80003840:	bf5d                	j	800037f6 <ialloc+0x86>

0000000080003842 <iupdate>:
{
    80003842:	1101                	addi	sp,sp,-32
    80003844:	ec06                	sd	ra,24(sp)
    80003846:	e822                	sd	s0,16(sp)
    80003848:	e426                	sd	s1,8(sp)
    8000384a:	e04a                	sd	s2,0(sp)
    8000384c:	1000                	addi	s0,sp,32
    8000384e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003850:	415c                	lw	a5,4(a0)
    80003852:	0047d79b          	srliw	a5,a5,0x4
    80003856:	0001c597          	auipc	a1,0x1c
    8000385a:	b7a5a583          	lw	a1,-1158(a1) # 8001f3d0 <sb+0x18>
    8000385e:	9dbd                	addw	a1,a1,a5
    80003860:	4108                	lw	a0,0(a0)
    80003862:	00000097          	auipc	ra,0x0
    80003866:	894080e7          	jalr	-1900(ra) # 800030f6 <bread>
    8000386a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000386c:	05850793          	addi	a5,a0,88
    80003870:	40d8                	lw	a4,4(s1)
    80003872:	8b3d                	andi	a4,a4,15
    80003874:	071a                	slli	a4,a4,0x6
    80003876:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003878:	04449703          	lh	a4,68(s1)
    8000387c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003880:	04649703          	lh	a4,70(s1)
    80003884:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003888:	04849703          	lh	a4,72(s1)
    8000388c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003890:	04a49703          	lh	a4,74(s1)
    80003894:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003898:	44f8                	lw	a4,76(s1)
    8000389a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000389c:	03400613          	li	a2,52
    800038a0:	05048593          	addi	a1,s1,80
    800038a4:	00c78513          	addi	a0,a5,12
    800038a8:	ffffd097          	auipc	ra,0xffffd
    800038ac:	486080e7          	jalr	1158(ra) # 80000d2e <memmove>
  log_write(bp);
    800038b0:	854a                	mv	a0,s2
    800038b2:	00001097          	auipc	ra,0x1
    800038b6:	bfe080e7          	jalr	-1026(ra) # 800044b0 <log_write>
  brelse(bp);
    800038ba:	854a                	mv	a0,s2
    800038bc:	00000097          	auipc	ra,0x0
    800038c0:	96a080e7          	jalr	-1686(ra) # 80003226 <brelse>
}
    800038c4:	60e2                	ld	ra,24(sp)
    800038c6:	6442                	ld	s0,16(sp)
    800038c8:	64a2                	ld	s1,8(sp)
    800038ca:	6902                	ld	s2,0(sp)
    800038cc:	6105                	addi	sp,sp,32
    800038ce:	8082                	ret

00000000800038d0 <idup>:
{
    800038d0:	1101                	addi	sp,sp,-32
    800038d2:	ec06                	sd	ra,24(sp)
    800038d4:	e822                	sd	s0,16(sp)
    800038d6:	e426                	sd	s1,8(sp)
    800038d8:	1000                	addi	s0,sp,32
    800038da:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038dc:	0001c517          	auipc	a0,0x1c
    800038e0:	afc50513          	addi	a0,a0,-1284 # 8001f3d8 <itable>
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	2f2080e7          	jalr	754(ra) # 80000bd6 <acquire>
  ip->ref++;
    800038ec:	449c                	lw	a5,8(s1)
    800038ee:	2785                	addiw	a5,a5,1
    800038f0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038f2:	0001c517          	auipc	a0,0x1c
    800038f6:	ae650513          	addi	a0,a0,-1306 # 8001f3d8 <itable>
    800038fa:	ffffd097          	auipc	ra,0xffffd
    800038fe:	390080e7          	jalr	912(ra) # 80000c8a <release>
}
    80003902:	8526                	mv	a0,s1
    80003904:	60e2                	ld	ra,24(sp)
    80003906:	6442                	ld	s0,16(sp)
    80003908:	64a2                	ld	s1,8(sp)
    8000390a:	6105                	addi	sp,sp,32
    8000390c:	8082                	ret

000000008000390e <ilock>:
{
    8000390e:	1101                	addi	sp,sp,-32
    80003910:	ec06                	sd	ra,24(sp)
    80003912:	e822                	sd	s0,16(sp)
    80003914:	e426                	sd	s1,8(sp)
    80003916:	e04a                	sd	s2,0(sp)
    80003918:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000391a:	c115                	beqz	a0,8000393e <ilock+0x30>
    8000391c:	84aa                	mv	s1,a0
    8000391e:	451c                	lw	a5,8(a0)
    80003920:	00f05f63          	blez	a5,8000393e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003924:	0541                	addi	a0,a0,16
    80003926:	00001097          	auipc	ra,0x1
    8000392a:	ca8080e7          	jalr	-856(ra) # 800045ce <acquiresleep>
  if(ip->valid == 0){
    8000392e:	40bc                	lw	a5,64(s1)
    80003930:	cf99                	beqz	a5,8000394e <ilock+0x40>
}
    80003932:	60e2                	ld	ra,24(sp)
    80003934:	6442                	ld	s0,16(sp)
    80003936:	64a2                	ld	s1,8(sp)
    80003938:	6902                	ld	s2,0(sp)
    8000393a:	6105                	addi	sp,sp,32
    8000393c:	8082                	ret
    panic("ilock");
    8000393e:	00005517          	auipc	a0,0x5
    80003942:	cca50513          	addi	a0,a0,-822 # 80008608 <syscalls+0x1b8>
    80003946:	ffffd097          	auipc	ra,0xffffd
    8000394a:	bfa080e7          	jalr	-1030(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000394e:	40dc                	lw	a5,4(s1)
    80003950:	0047d79b          	srliw	a5,a5,0x4
    80003954:	0001c597          	auipc	a1,0x1c
    80003958:	a7c5a583          	lw	a1,-1412(a1) # 8001f3d0 <sb+0x18>
    8000395c:	9dbd                	addw	a1,a1,a5
    8000395e:	4088                	lw	a0,0(s1)
    80003960:	fffff097          	auipc	ra,0xfffff
    80003964:	796080e7          	jalr	1942(ra) # 800030f6 <bread>
    80003968:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000396a:	05850593          	addi	a1,a0,88
    8000396e:	40dc                	lw	a5,4(s1)
    80003970:	8bbd                	andi	a5,a5,15
    80003972:	079a                	slli	a5,a5,0x6
    80003974:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003976:	00059783          	lh	a5,0(a1)
    8000397a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000397e:	00259783          	lh	a5,2(a1)
    80003982:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003986:	00459783          	lh	a5,4(a1)
    8000398a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000398e:	00659783          	lh	a5,6(a1)
    80003992:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003996:	459c                	lw	a5,8(a1)
    80003998:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000399a:	03400613          	li	a2,52
    8000399e:	05b1                	addi	a1,a1,12
    800039a0:	05048513          	addi	a0,s1,80
    800039a4:	ffffd097          	auipc	ra,0xffffd
    800039a8:	38a080e7          	jalr	906(ra) # 80000d2e <memmove>
    brelse(bp);
    800039ac:	854a                	mv	a0,s2
    800039ae:	00000097          	auipc	ra,0x0
    800039b2:	878080e7          	jalr	-1928(ra) # 80003226 <brelse>
    ip->valid = 1;
    800039b6:	4785                	li	a5,1
    800039b8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039ba:	04449783          	lh	a5,68(s1)
    800039be:	fbb5                	bnez	a5,80003932 <ilock+0x24>
      panic("ilock: no type");
    800039c0:	00005517          	auipc	a0,0x5
    800039c4:	c5050513          	addi	a0,a0,-944 # 80008610 <syscalls+0x1c0>
    800039c8:	ffffd097          	auipc	ra,0xffffd
    800039cc:	b78080e7          	jalr	-1160(ra) # 80000540 <panic>

00000000800039d0 <iunlock>:
{
    800039d0:	1101                	addi	sp,sp,-32
    800039d2:	ec06                	sd	ra,24(sp)
    800039d4:	e822                	sd	s0,16(sp)
    800039d6:	e426                	sd	s1,8(sp)
    800039d8:	e04a                	sd	s2,0(sp)
    800039da:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039dc:	c905                	beqz	a0,80003a0c <iunlock+0x3c>
    800039de:	84aa                	mv	s1,a0
    800039e0:	01050913          	addi	s2,a0,16
    800039e4:	854a                	mv	a0,s2
    800039e6:	00001097          	auipc	ra,0x1
    800039ea:	c82080e7          	jalr	-894(ra) # 80004668 <holdingsleep>
    800039ee:	cd19                	beqz	a0,80003a0c <iunlock+0x3c>
    800039f0:	449c                	lw	a5,8(s1)
    800039f2:	00f05d63          	blez	a5,80003a0c <iunlock+0x3c>
  releasesleep(&ip->lock);
    800039f6:	854a                	mv	a0,s2
    800039f8:	00001097          	auipc	ra,0x1
    800039fc:	c2c080e7          	jalr	-980(ra) # 80004624 <releasesleep>
}
    80003a00:	60e2                	ld	ra,24(sp)
    80003a02:	6442                	ld	s0,16(sp)
    80003a04:	64a2                	ld	s1,8(sp)
    80003a06:	6902                	ld	s2,0(sp)
    80003a08:	6105                	addi	sp,sp,32
    80003a0a:	8082                	ret
    panic("iunlock");
    80003a0c:	00005517          	auipc	a0,0x5
    80003a10:	c1450513          	addi	a0,a0,-1004 # 80008620 <syscalls+0x1d0>
    80003a14:	ffffd097          	auipc	ra,0xffffd
    80003a18:	b2c080e7          	jalr	-1236(ra) # 80000540 <panic>

0000000080003a1c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a1c:	7179                	addi	sp,sp,-48
    80003a1e:	f406                	sd	ra,40(sp)
    80003a20:	f022                	sd	s0,32(sp)
    80003a22:	ec26                	sd	s1,24(sp)
    80003a24:	e84a                	sd	s2,16(sp)
    80003a26:	e44e                	sd	s3,8(sp)
    80003a28:	e052                	sd	s4,0(sp)
    80003a2a:	1800                	addi	s0,sp,48
    80003a2c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a2e:	05050493          	addi	s1,a0,80
    80003a32:	08050913          	addi	s2,a0,128
    80003a36:	a021                	j	80003a3e <itrunc+0x22>
    80003a38:	0491                	addi	s1,s1,4
    80003a3a:	01248d63          	beq	s1,s2,80003a54 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a3e:	408c                	lw	a1,0(s1)
    80003a40:	dde5                	beqz	a1,80003a38 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a42:	0009a503          	lw	a0,0(s3)
    80003a46:	00000097          	auipc	ra,0x0
    80003a4a:	8f6080e7          	jalr	-1802(ra) # 8000333c <bfree>
      ip->addrs[i] = 0;
    80003a4e:	0004a023          	sw	zero,0(s1)
    80003a52:	b7dd                	j	80003a38 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a54:	0809a583          	lw	a1,128(s3)
    80003a58:	e185                	bnez	a1,80003a78 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a5a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a5e:	854e                	mv	a0,s3
    80003a60:	00000097          	auipc	ra,0x0
    80003a64:	de2080e7          	jalr	-542(ra) # 80003842 <iupdate>
}
    80003a68:	70a2                	ld	ra,40(sp)
    80003a6a:	7402                	ld	s0,32(sp)
    80003a6c:	64e2                	ld	s1,24(sp)
    80003a6e:	6942                	ld	s2,16(sp)
    80003a70:	69a2                	ld	s3,8(sp)
    80003a72:	6a02                	ld	s4,0(sp)
    80003a74:	6145                	addi	sp,sp,48
    80003a76:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a78:	0009a503          	lw	a0,0(s3)
    80003a7c:	fffff097          	auipc	ra,0xfffff
    80003a80:	67a080e7          	jalr	1658(ra) # 800030f6 <bread>
    80003a84:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a86:	05850493          	addi	s1,a0,88
    80003a8a:	45850913          	addi	s2,a0,1112
    80003a8e:	a021                	j	80003a96 <itrunc+0x7a>
    80003a90:	0491                	addi	s1,s1,4
    80003a92:	01248b63          	beq	s1,s2,80003aa8 <itrunc+0x8c>
      if(a[j])
    80003a96:	408c                	lw	a1,0(s1)
    80003a98:	dde5                	beqz	a1,80003a90 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003a9a:	0009a503          	lw	a0,0(s3)
    80003a9e:	00000097          	auipc	ra,0x0
    80003aa2:	89e080e7          	jalr	-1890(ra) # 8000333c <bfree>
    80003aa6:	b7ed                	j	80003a90 <itrunc+0x74>
    brelse(bp);
    80003aa8:	8552                	mv	a0,s4
    80003aaa:	fffff097          	auipc	ra,0xfffff
    80003aae:	77c080e7          	jalr	1916(ra) # 80003226 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ab2:	0809a583          	lw	a1,128(s3)
    80003ab6:	0009a503          	lw	a0,0(s3)
    80003aba:	00000097          	auipc	ra,0x0
    80003abe:	882080e7          	jalr	-1918(ra) # 8000333c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ac2:	0809a023          	sw	zero,128(s3)
    80003ac6:	bf51                	j	80003a5a <itrunc+0x3e>

0000000080003ac8 <iput>:
{
    80003ac8:	1101                	addi	sp,sp,-32
    80003aca:	ec06                	sd	ra,24(sp)
    80003acc:	e822                	sd	s0,16(sp)
    80003ace:	e426                	sd	s1,8(sp)
    80003ad0:	e04a                	sd	s2,0(sp)
    80003ad2:	1000                	addi	s0,sp,32
    80003ad4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ad6:	0001c517          	auipc	a0,0x1c
    80003ada:	90250513          	addi	a0,a0,-1790 # 8001f3d8 <itable>
    80003ade:	ffffd097          	auipc	ra,0xffffd
    80003ae2:	0f8080e7          	jalr	248(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ae6:	4498                	lw	a4,8(s1)
    80003ae8:	4785                	li	a5,1
    80003aea:	02f70363          	beq	a4,a5,80003b10 <iput+0x48>
  ip->ref--;
    80003aee:	449c                	lw	a5,8(s1)
    80003af0:	37fd                	addiw	a5,a5,-1
    80003af2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003af4:	0001c517          	auipc	a0,0x1c
    80003af8:	8e450513          	addi	a0,a0,-1820 # 8001f3d8 <itable>
    80003afc:	ffffd097          	auipc	ra,0xffffd
    80003b00:	18e080e7          	jalr	398(ra) # 80000c8a <release>
}
    80003b04:	60e2                	ld	ra,24(sp)
    80003b06:	6442                	ld	s0,16(sp)
    80003b08:	64a2                	ld	s1,8(sp)
    80003b0a:	6902                	ld	s2,0(sp)
    80003b0c:	6105                	addi	sp,sp,32
    80003b0e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b10:	40bc                	lw	a5,64(s1)
    80003b12:	dff1                	beqz	a5,80003aee <iput+0x26>
    80003b14:	04a49783          	lh	a5,74(s1)
    80003b18:	fbf9                	bnez	a5,80003aee <iput+0x26>
    acquiresleep(&ip->lock);
    80003b1a:	01048913          	addi	s2,s1,16
    80003b1e:	854a                	mv	a0,s2
    80003b20:	00001097          	auipc	ra,0x1
    80003b24:	aae080e7          	jalr	-1362(ra) # 800045ce <acquiresleep>
    release(&itable.lock);
    80003b28:	0001c517          	auipc	a0,0x1c
    80003b2c:	8b050513          	addi	a0,a0,-1872 # 8001f3d8 <itable>
    80003b30:	ffffd097          	auipc	ra,0xffffd
    80003b34:	15a080e7          	jalr	346(ra) # 80000c8a <release>
    itrunc(ip);
    80003b38:	8526                	mv	a0,s1
    80003b3a:	00000097          	auipc	ra,0x0
    80003b3e:	ee2080e7          	jalr	-286(ra) # 80003a1c <itrunc>
    ip->type = 0;
    80003b42:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b46:	8526                	mv	a0,s1
    80003b48:	00000097          	auipc	ra,0x0
    80003b4c:	cfa080e7          	jalr	-774(ra) # 80003842 <iupdate>
    ip->valid = 0;
    80003b50:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b54:	854a                	mv	a0,s2
    80003b56:	00001097          	auipc	ra,0x1
    80003b5a:	ace080e7          	jalr	-1330(ra) # 80004624 <releasesleep>
    acquire(&itable.lock);
    80003b5e:	0001c517          	auipc	a0,0x1c
    80003b62:	87a50513          	addi	a0,a0,-1926 # 8001f3d8 <itable>
    80003b66:	ffffd097          	auipc	ra,0xffffd
    80003b6a:	070080e7          	jalr	112(ra) # 80000bd6 <acquire>
    80003b6e:	b741                	j	80003aee <iput+0x26>

0000000080003b70 <iunlockput>:
{
    80003b70:	1101                	addi	sp,sp,-32
    80003b72:	ec06                	sd	ra,24(sp)
    80003b74:	e822                	sd	s0,16(sp)
    80003b76:	e426                	sd	s1,8(sp)
    80003b78:	1000                	addi	s0,sp,32
    80003b7a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b7c:	00000097          	auipc	ra,0x0
    80003b80:	e54080e7          	jalr	-428(ra) # 800039d0 <iunlock>
  iput(ip);
    80003b84:	8526                	mv	a0,s1
    80003b86:	00000097          	auipc	ra,0x0
    80003b8a:	f42080e7          	jalr	-190(ra) # 80003ac8 <iput>
}
    80003b8e:	60e2                	ld	ra,24(sp)
    80003b90:	6442                	ld	s0,16(sp)
    80003b92:	64a2                	ld	s1,8(sp)
    80003b94:	6105                	addi	sp,sp,32
    80003b96:	8082                	ret

0000000080003b98 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b98:	1141                	addi	sp,sp,-16
    80003b9a:	e422                	sd	s0,8(sp)
    80003b9c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b9e:	411c                	lw	a5,0(a0)
    80003ba0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ba2:	415c                	lw	a5,4(a0)
    80003ba4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ba6:	04451783          	lh	a5,68(a0)
    80003baa:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bae:	04a51783          	lh	a5,74(a0)
    80003bb2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bb6:	04c56783          	lwu	a5,76(a0)
    80003bba:	e99c                	sd	a5,16(a1)
}
    80003bbc:	6422                	ld	s0,8(sp)
    80003bbe:	0141                	addi	sp,sp,16
    80003bc0:	8082                	ret

0000000080003bc2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bc2:	457c                	lw	a5,76(a0)
    80003bc4:	0ed7e963          	bltu	a5,a3,80003cb6 <readi+0xf4>
{
    80003bc8:	7159                	addi	sp,sp,-112
    80003bca:	f486                	sd	ra,104(sp)
    80003bcc:	f0a2                	sd	s0,96(sp)
    80003bce:	eca6                	sd	s1,88(sp)
    80003bd0:	e8ca                	sd	s2,80(sp)
    80003bd2:	e4ce                	sd	s3,72(sp)
    80003bd4:	e0d2                	sd	s4,64(sp)
    80003bd6:	fc56                	sd	s5,56(sp)
    80003bd8:	f85a                	sd	s6,48(sp)
    80003bda:	f45e                	sd	s7,40(sp)
    80003bdc:	f062                	sd	s8,32(sp)
    80003bde:	ec66                	sd	s9,24(sp)
    80003be0:	e86a                	sd	s10,16(sp)
    80003be2:	e46e                	sd	s11,8(sp)
    80003be4:	1880                	addi	s0,sp,112
    80003be6:	8b2a                	mv	s6,a0
    80003be8:	8bae                	mv	s7,a1
    80003bea:	8a32                	mv	s4,a2
    80003bec:	84b6                	mv	s1,a3
    80003bee:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003bf0:	9f35                	addw	a4,a4,a3
    return 0;
    80003bf2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bf4:	0ad76063          	bltu	a4,a3,80003c94 <readi+0xd2>
  if(off + n > ip->size)
    80003bf8:	00e7f463          	bgeu	a5,a4,80003c00 <readi+0x3e>
    n = ip->size - off;
    80003bfc:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c00:	0a0a8963          	beqz	s5,80003cb2 <readi+0xf0>
    80003c04:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c06:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c0a:	5c7d                	li	s8,-1
    80003c0c:	a82d                	j	80003c46 <readi+0x84>
    80003c0e:	020d1d93          	slli	s11,s10,0x20
    80003c12:	020ddd93          	srli	s11,s11,0x20
    80003c16:	05890613          	addi	a2,s2,88
    80003c1a:	86ee                	mv	a3,s11
    80003c1c:	963a                	add	a2,a2,a4
    80003c1e:	85d2                	mv	a1,s4
    80003c20:	855e                	mv	a0,s7
    80003c22:	fffff097          	auipc	ra,0xfffff
    80003c26:	842080e7          	jalr	-1982(ra) # 80002464 <either_copyout>
    80003c2a:	05850d63          	beq	a0,s8,80003c84 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c2e:	854a                	mv	a0,s2
    80003c30:	fffff097          	auipc	ra,0xfffff
    80003c34:	5f6080e7          	jalr	1526(ra) # 80003226 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c38:	013d09bb          	addw	s3,s10,s3
    80003c3c:	009d04bb          	addw	s1,s10,s1
    80003c40:	9a6e                	add	s4,s4,s11
    80003c42:	0559f763          	bgeu	s3,s5,80003c90 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003c46:	00a4d59b          	srliw	a1,s1,0xa
    80003c4a:	855a                	mv	a0,s6
    80003c4c:	00000097          	auipc	ra,0x0
    80003c50:	89e080e7          	jalr	-1890(ra) # 800034ea <bmap>
    80003c54:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c58:	cd85                	beqz	a1,80003c90 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c5a:	000b2503          	lw	a0,0(s6)
    80003c5e:	fffff097          	auipc	ra,0xfffff
    80003c62:	498080e7          	jalr	1176(ra) # 800030f6 <bread>
    80003c66:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c68:	3ff4f713          	andi	a4,s1,1023
    80003c6c:	40ec87bb          	subw	a5,s9,a4
    80003c70:	413a86bb          	subw	a3,s5,s3
    80003c74:	8d3e                	mv	s10,a5
    80003c76:	2781                	sext.w	a5,a5
    80003c78:	0006861b          	sext.w	a2,a3
    80003c7c:	f8f679e3          	bgeu	a2,a5,80003c0e <readi+0x4c>
    80003c80:	8d36                	mv	s10,a3
    80003c82:	b771                	j	80003c0e <readi+0x4c>
      brelse(bp);
    80003c84:	854a                	mv	a0,s2
    80003c86:	fffff097          	auipc	ra,0xfffff
    80003c8a:	5a0080e7          	jalr	1440(ra) # 80003226 <brelse>
      tot = -1;
    80003c8e:	59fd                	li	s3,-1
  }
  return tot;
    80003c90:	0009851b          	sext.w	a0,s3
}
    80003c94:	70a6                	ld	ra,104(sp)
    80003c96:	7406                	ld	s0,96(sp)
    80003c98:	64e6                	ld	s1,88(sp)
    80003c9a:	6946                	ld	s2,80(sp)
    80003c9c:	69a6                	ld	s3,72(sp)
    80003c9e:	6a06                	ld	s4,64(sp)
    80003ca0:	7ae2                	ld	s5,56(sp)
    80003ca2:	7b42                	ld	s6,48(sp)
    80003ca4:	7ba2                	ld	s7,40(sp)
    80003ca6:	7c02                	ld	s8,32(sp)
    80003ca8:	6ce2                	ld	s9,24(sp)
    80003caa:	6d42                	ld	s10,16(sp)
    80003cac:	6da2                	ld	s11,8(sp)
    80003cae:	6165                	addi	sp,sp,112
    80003cb0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cb2:	89d6                	mv	s3,s5
    80003cb4:	bff1                	j	80003c90 <readi+0xce>
    return 0;
    80003cb6:	4501                	li	a0,0
}
    80003cb8:	8082                	ret

0000000080003cba <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cba:	457c                	lw	a5,76(a0)
    80003cbc:	10d7e863          	bltu	a5,a3,80003dcc <writei+0x112>
{
    80003cc0:	7159                	addi	sp,sp,-112
    80003cc2:	f486                	sd	ra,104(sp)
    80003cc4:	f0a2                	sd	s0,96(sp)
    80003cc6:	eca6                	sd	s1,88(sp)
    80003cc8:	e8ca                	sd	s2,80(sp)
    80003cca:	e4ce                	sd	s3,72(sp)
    80003ccc:	e0d2                	sd	s4,64(sp)
    80003cce:	fc56                	sd	s5,56(sp)
    80003cd0:	f85a                	sd	s6,48(sp)
    80003cd2:	f45e                	sd	s7,40(sp)
    80003cd4:	f062                	sd	s8,32(sp)
    80003cd6:	ec66                	sd	s9,24(sp)
    80003cd8:	e86a                	sd	s10,16(sp)
    80003cda:	e46e                	sd	s11,8(sp)
    80003cdc:	1880                	addi	s0,sp,112
    80003cde:	8aaa                	mv	s5,a0
    80003ce0:	8bae                	mv	s7,a1
    80003ce2:	8a32                	mv	s4,a2
    80003ce4:	8936                	mv	s2,a3
    80003ce6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ce8:	00e687bb          	addw	a5,a3,a4
    80003cec:	0ed7e263          	bltu	a5,a3,80003dd0 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cf0:	00043737          	lui	a4,0x43
    80003cf4:	0ef76063          	bltu	a4,a5,80003dd4 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cf8:	0c0b0863          	beqz	s6,80003dc8 <writei+0x10e>
    80003cfc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cfe:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d02:	5c7d                	li	s8,-1
    80003d04:	a091                	j	80003d48 <writei+0x8e>
    80003d06:	020d1d93          	slli	s11,s10,0x20
    80003d0a:	020ddd93          	srli	s11,s11,0x20
    80003d0e:	05848513          	addi	a0,s1,88
    80003d12:	86ee                	mv	a3,s11
    80003d14:	8652                	mv	a2,s4
    80003d16:	85de                	mv	a1,s7
    80003d18:	953a                	add	a0,a0,a4
    80003d1a:	ffffe097          	auipc	ra,0xffffe
    80003d1e:	7a0080e7          	jalr	1952(ra) # 800024ba <either_copyin>
    80003d22:	07850263          	beq	a0,s8,80003d86 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d26:	8526                	mv	a0,s1
    80003d28:	00000097          	auipc	ra,0x0
    80003d2c:	788080e7          	jalr	1928(ra) # 800044b0 <log_write>
    brelse(bp);
    80003d30:	8526                	mv	a0,s1
    80003d32:	fffff097          	auipc	ra,0xfffff
    80003d36:	4f4080e7          	jalr	1268(ra) # 80003226 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d3a:	013d09bb          	addw	s3,s10,s3
    80003d3e:	012d093b          	addw	s2,s10,s2
    80003d42:	9a6e                	add	s4,s4,s11
    80003d44:	0569f663          	bgeu	s3,s6,80003d90 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003d48:	00a9559b          	srliw	a1,s2,0xa
    80003d4c:	8556                	mv	a0,s5
    80003d4e:	fffff097          	auipc	ra,0xfffff
    80003d52:	79c080e7          	jalr	1948(ra) # 800034ea <bmap>
    80003d56:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d5a:	c99d                	beqz	a1,80003d90 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003d5c:	000aa503          	lw	a0,0(s5)
    80003d60:	fffff097          	auipc	ra,0xfffff
    80003d64:	396080e7          	jalr	918(ra) # 800030f6 <bread>
    80003d68:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d6a:	3ff97713          	andi	a4,s2,1023
    80003d6e:	40ec87bb          	subw	a5,s9,a4
    80003d72:	413b06bb          	subw	a3,s6,s3
    80003d76:	8d3e                	mv	s10,a5
    80003d78:	2781                	sext.w	a5,a5
    80003d7a:	0006861b          	sext.w	a2,a3
    80003d7e:	f8f674e3          	bgeu	a2,a5,80003d06 <writei+0x4c>
    80003d82:	8d36                	mv	s10,a3
    80003d84:	b749                	j	80003d06 <writei+0x4c>
      brelse(bp);
    80003d86:	8526                	mv	a0,s1
    80003d88:	fffff097          	auipc	ra,0xfffff
    80003d8c:	49e080e7          	jalr	1182(ra) # 80003226 <brelse>
  }

  if(off > ip->size)
    80003d90:	04caa783          	lw	a5,76(s5)
    80003d94:	0127f463          	bgeu	a5,s2,80003d9c <writei+0xe2>
    ip->size = off;
    80003d98:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d9c:	8556                	mv	a0,s5
    80003d9e:	00000097          	auipc	ra,0x0
    80003da2:	aa4080e7          	jalr	-1372(ra) # 80003842 <iupdate>

  return tot;
    80003da6:	0009851b          	sext.w	a0,s3
}
    80003daa:	70a6                	ld	ra,104(sp)
    80003dac:	7406                	ld	s0,96(sp)
    80003dae:	64e6                	ld	s1,88(sp)
    80003db0:	6946                	ld	s2,80(sp)
    80003db2:	69a6                	ld	s3,72(sp)
    80003db4:	6a06                	ld	s4,64(sp)
    80003db6:	7ae2                	ld	s5,56(sp)
    80003db8:	7b42                	ld	s6,48(sp)
    80003dba:	7ba2                	ld	s7,40(sp)
    80003dbc:	7c02                	ld	s8,32(sp)
    80003dbe:	6ce2                	ld	s9,24(sp)
    80003dc0:	6d42                	ld	s10,16(sp)
    80003dc2:	6da2                	ld	s11,8(sp)
    80003dc4:	6165                	addi	sp,sp,112
    80003dc6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dc8:	89da                	mv	s3,s6
    80003dca:	bfc9                	j	80003d9c <writei+0xe2>
    return -1;
    80003dcc:	557d                	li	a0,-1
}
    80003dce:	8082                	ret
    return -1;
    80003dd0:	557d                	li	a0,-1
    80003dd2:	bfe1                	j	80003daa <writei+0xf0>
    return -1;
    80003dd4:	557d                	li	a0,-1
    80003dd6:	bfd1                	j	80003daa <writei+0xf0>

0000000080003dd8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003dd8:	1141                	addi	sp,sp,-16
    80003dda:	e406                	sd	ra,8(sp)
    80003ddc:	e022                	sd	s0,0(sp)
    80003dde:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003de0:	4639                	li	a2,14
    80003de2:	ffffd097          	auipc	ra,0xffffd
    80003de6:	fc0080e7          	jalr	-64(ra) # 80000da2 <strncmp>
}
    80003dea:	60a2                	ld	ra,8(sp)
    80003dec:	6402                	ld	s0,0(sp)
    80003dee:	0141                	addi	sp,sp,16
    80003df0:	8082                	ret

0000000080003df2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003df2:	7139                	addi	sp,sp,-64
    80003df4:	fc06                	sd	ra,56(sp)
    80003df6:	f822                	sd	s0,48(sp)
    80003df8:	f426                	sd	s1,40(sp)
    80003dfa:	f04a                	sd	s2,32(sp)
    80003dfc:	ec4e                	sd	s3,24(sp)
    80003dfe:	e852                	sd	s4,16(sp)
    80003e00:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e02:	04451703          	lh	a4,68(a0)
    80003e06:	4785                	li	a5,1
    80003e08:	00f71a63          	bne	a4,a5,80003e1c <dirlookup+0x2a>
    80003e0c:	892a                	mv	s2,a0
    80003e0e:	89ae                	mv	s3,a1
    80003e10:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e12:	457c                	lw	a5,76(a0)
    80003e14:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e16:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e18:	e79d                	bnez	a5,80003e46 <dirlookup+0x54>
    80003e1a:	a8a5                	j	80003e92 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e1c:	00005517          	auipc	a0,0x5
    80003e20:	80c50513          	addi	a0,a0,-2036 # 80008628 <syscalls+0x1d8>
    80003e24:	ffffc097          	auipc	ra,0xffffc
    80003e28:	71c080e7          	jalr	1820(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003e2c:	00005517          	auipc	a0,0x5
    80003e30:	81450513          	addi	a0,a0,-2028 # 80008640 <syscalls+0x1f0>
    80003e34:	ffffc097          	auipc	ra,0xffffc
    80003e38:	70c080e7          	jalr	1804(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e3c:	24c1                	addiw	s1,s1,16
    80003e3e:	04c92783          	lw	a5,76(s2)
    80003e42:	04f4f763          	bgeu	s1,a5,80003e90 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e46:	4741                	li	a4,16
    80003e48:	86a6                	mv	a3,s1
    80003e4a:	fc040613          	addi	a2,s0,-64
    80003e4e:	4581                	li	a1,0
    80003e50:	854a                	mv	a0,s2
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	d70080e7          	jalr	-656(ra) # 80003bc2 <readi>
    80003e5a:	47c1                	li	a5,16
    80003e5c:	fcf518e3          	bne	a0,a5,80003e2c <dirlookup+0x3a>
    if(de.inum == 0)
    80003e60:	fc045783          	lhu	a5,-64(s0)
    80003e64:	dfe1                	beqz	a5,80003e3c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e66:	fc240593          	addi	a1,s0,-62
    80003e6a:	854e                	mv	a0,s3
    80003e6c:	00000097          	auipc	ra,0x0
    80003e70:	f6c080e7          	jalr	-148(ra) # 80003dd8 <namecmp>
    80003e74:	f561                	bnez	a0,80003e3c <dirlookup+0x4a>
      if(poff)
    80003e76:	000a0463          	beqz	s4,80003e7e <dirlookup+0x8c>
        *poff = off;
    80003e7a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e7e:	fc045583          	lhu	a1,-64(s0)
    80003e82:	00092503          	lw	a0,0(s2)
    80003e86:	fffff097          	auipc	ra,0xfffff
    80003e8a:	74e080e7          	jalr	1870(ra) # 800035d4 <iget>
    80003e8e:	a011                	j	80003e92 <dirlookup+0xa0>
  return 0;
    80003e90:	4501                	li	a0,0
}
    80003e92:	70e2                	ld	ra,56(sp)
    80003e94:	7442                	ld	s0,48(sp)
    80003e96:	74a2                	ld	s1,40(sp)
    80003e98:	7902                	ld	s2,32(sp)
    80003e9a:	69e2                	ld	s3,24(sp)
    80003e9c:	6a42                	ld	s4,16(sp)
    80003e9e:	6121                	addi	sp,sp,64
    80003ea0:	8082                	ret

0000000080003ea2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ea2:	711d                	addi	sp,sp,-96
    80003ea4:	ec86                	sd	ra,88(sp)
    80003ea6:	e8a2                	sd	s0,80(sp)
    80003ea8:	e4a6                	sd	s1,72(sp)
    80003eaa:	e0ca                	sd	s2,64(sp)
    80003eac:	fc4e                	sd	s3,56(sp)
    80003eae:	f852                	sd	s4,48(sp)
    80003eb0:	f456                	sd	s5,40(sp)
    80003eb2:	f05a                	sd	s6,32(sp)
    80003eb4:	ec5e                	sd	s7,24(sp)
    80003eb6:	e862                	sd	s8,16(sp)
    80003eb8:	e466                	sd	s9,8(sp)
    80003eba:	e06a                	sd	s10,0(sp)
    80003ebc:	1080                	addi	s0,sp,96
    80003ebe:	84aa                	mv	s1,a0
    80003ec0:	8b2e                	mv	s6,a1
    80003ec2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ec4:	00054703          	lbu	a4,0(a0)
    80003ec8:	02f00793          	li	a5,47
    80003ecc:	02f70363          	beq	a4,a5,80003ef2 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ed0:	ffffe097          	auipc	ra,0xffffe
    80003ed4:	ae4080e7          	jalr	-1308(ra) # 800019b4 <myproc>
    80003ed8:	15053503          	ld	a0,336(a0)
    80003edc:	00000097          	auipc	ra,0x0
    80003ee0:	9f4080e7          	jalr	-1548(ra) # 800038d0 <idup>
    80003ee4:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003ee6:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003eea:	4cb5                	li	s9,13
  len = path - s;
    80003eec:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003eee:	4c05                	li	s8,1
    80003ef0:	a87d                	j	80003fae <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003ef2:	4585                	li	a1,1
    80003ef4:	4505                	li	a0,1
    80003ef6:	fffff097          	auipc	ra,0xfffff
    80003efa:	6de080e7          	jalr	1758(ra) # 800035d4 <iget>
    80003efe:	8a2a                	mv	s4,a0
    80003f00:	b7dd                	j	80003ee6 <namex+0x44>
      iunlockput(ip);
    80003f02:	8552                	mv	a0,s4
    80003f04:	00000097          	auipc	ra,0x0
    80003f08:	c6c080e7          	jalr	-916(ra) # 80003b70 <iunlockput>
      return 0;
    80003f0c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f0e:	8552                	mv	a0,s4
    80003f10:	60e6                	ld	ra,88(sp)
    80003f12:	6446                	ld	s0,80(sp)
    80003f14:	64a6                	ld	s1,72(sp)
    80003f16:	6906                	ld	s2,64(sp)
    80003f18:	79e2                	ld	s3,56(sp)
    80003f1a:	7a42                	ld	s4,48(sp)
    80003f1c:	7aa2                	ld	s5,40(sp)
    80003f1e:	7b02                	ld	s6,32(sp)
    80003f20:	6be2                	ld	s7,24(sp)
    80003f22:	6c42                	ld	s8,16(sp)
    80003f24:	6ca2                	ld	s9,8(sp)
    80003f26:	6d02                	ld	s10,0(sp)
    80003f28:	6125                	addi	sp,sp,96
    80003f2a:	8082                	ret
      iunlock(ip);
    80003f2c:	8552                	mv	a0,s4
    80003f2e:	00000097          	auipc	ra,0x0
    80003f32:	aa2080e7          	jalr	-1374(ra) # 800039d0 <iunlock>
      return ip;
    80003f36:	bfe1                	j	80003f0e <namex+0x6c>
      iunlockput(ip);
    80003f38:	8552                	mv	a0,s4
    80003f3a:	00000097          	auipc	ra,0x0
    80003f3e:	c36080e7          	jalr	-970(ra) # 80003b70 <iunlockput>
      return 0;
    80003f42:	8a4e                	mv	s4,s3
    80003f44:	b7e9                	j	80003f0e <namex+0x6c>
  len = path - s;
    80003f46:	40998633          	sub	a2,s3,s1
    80003f4a:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003f4e:	09acd863          	bge	s9,s10,80003fde <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003f52:	4639                	li	a2,14
    80003f54:	85a6                	mv	a1,s1
    80003f56:	8556                	mv	a0,s5
    80003f58:	ffffd097          	auipc	ra,0xffffd
    80003f5c:	dd6080e7          	jalr	-554(ra) # 80000d2e <memmove>
    80003f60:	84ce                	mv	s1,s3
  while(*path == '/')
    80003f62:	0004c783          	lbu	a5,0(s1)
    80003f66:	01279763          	bne	a5,s2,80003f74 <namex+0xd2>
    path++;
    80003f6a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f6c:	0004c783          	lbu	a5,0(s1)
    80003f70:	ff278de3          	beq	a5,s2,80003f6a <namex+0xc8>
    ilock(ip);
    80003f74:	8552                	mv	a0,s4
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	998080e7          	jalr	-1640(ra) # 8000390e <ilock>
    if(ip->type != T_DIR){
    80003f7e:	044a1783          	lh	a5,68(s4)
    80003f82:	f98790e3          	bne	a5,s8,80003f02 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003f86:	000b0563          	beqz	s6,80003f90 <namex+0xee>
    80003f8a:	0004c783          	lbu	a5,0(s1)
    80003f8e:	dfd9                	beqz	a5,80003f2c <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f90:	865e                	mv	a2,s7
    80003f92:	85d6                	mv	a1,s5
    80003f94:	8552                	mv	a0,s4
    80003f96:	00000097          	auipc	ra,0x0
    80003f9a:	e5c080e7          	jalr	-420(ra) # 80003df2 <dirlookup>
    80003f9e:	89aa                	mv	s3,a0
    80003fa0:	dd41                	beqz	a0,80003f38 <namex+0x96>
    iunlockput(ip);
    80003fa2:	8552                	mv	a0,s4
    80003fa4:	00000097          	auipc	ra,0x0
    80003fa8:	bcc080e7          	jalr	-1076(ra) # 80003b70 <iunlockput>
    ip = next;
    80003fac:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003fae:	0004c783          	lbu	a5,0(s1)
    80003fb2:	01279763          	bne	a5,s2,80003fc0 <namex+0x11e>
    path++;
    80003fb6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fb8:	0004c783          	lbu	a5,0(s1)
    80003fbc:	ff278de3          	beq	a5,s2,80003fb6 <namex+0x114>
  if(*path == 0)
    80003fc0:	cb9d                	beqz	a5,80003ff6 <namex+0x154>
  while(*path != '/' && *path != 0)
    80003fc2:	0004c783          	lbu	a5,0(s1)
    80003fc6:	89a6                	mv	s3,s1
  len = path - s;
    80003fc8:	8d5e                	mv	s10,s7
    80003fca:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003fcc:	01278963          	beq	a5,s2,80003fde <namex+0x13c>
    80003fd0:	dbbd                	beqz	a5,80003f46 <namex+0xa4>
    path++;
    80003fd2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003fd4:	0009c783          	lbu	a5,0(s3)
    80003fd8:	ff279ce3          	bne	a5,s2,80003fd0 <namex+0x12e>
    80003fdc:	b7ad                	j	80003f46 <namex+0xa4>
    memmove(name, s, len);
    80003fde:	2601                	sext.w	a2,a2
    80003fe0:	85a6                	mv	a1,s1
    80003fe2:	8556                	mv	a0,s5
    80003fe4:	ffffd097          	auipc	ra,0xffffd
    80003fe8:	d4a080e7          	jalr	-694(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003fec:	9d56                	add	s10,s10,s5
    80003fee:	000d0023          	sb	zero,0(s10)
    80003ff2:	84ce                	mv	s1,s3
    80003ff4:	b7bd                	j	80003f62 <namex+0xc0>
  if(nameiparent){
    80003ff6:	f00b0ce3          	beqz	s6,80003f0e <namex+0x6c>
    iput(ip);
    80003ffa:	8552                	mv	a0,s4
    80003ffc:	00000097          	auipc	ra,0x0
    80004000:	acc080e7          	jalr	-1332(ra) # 80003ac8 <iput>
    return 0;
    80004004:	4a01                	li	s4,0
    80004006:	b721                	j	80003f0e <namex+0x6c>

0000000080004008 <dirlink>:
{
    80004008:	7139                	addi	sp,sp,-64
    8000400a:	fc06                	sd	ra,56(sp)
    8000400c:	f822                	sd	s0,48(sp)
    8000400e:	f426                	sd	s1,40(sp)
    80004010:	f04a                	sd	s2,32(sp)
    80004012:	ec4e                	sd	s3,24(sp)
    80004014:	e852                	sd	s4,16(sp)
    80004016:	0080                	addi	s0,sp,64
    80004018:	892a                	mv	s2,a0
    8000401a:	8a2e                	mv	s4,a1
    8000401c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000401e:	4601                	li	a2,0
    80004020:	00000097          	auipc	ra,0x0
    80004024:	dd2080e7          	jalr	-558(ra) # 80003df2 <dirlookup>
    80004028:	e93d                	bnez	a0,8000409e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000402a:	04c92483          	lw	s1,76(s2)
    8000402e:	c49d                	beqz	s1,8000405c <dirlink+0x54>
    80004030:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004032:	4741                	li	a4,16
    80004034:	86a6                	mv	a3,s1
    80004036:	fc040613          	addi	a2,s0,-64
    8000403a:	4581                	li	a1,0
    8000403c:	854a                	mv	a0,s2
    8000403e:	00000097          	auipc	ra,0x0
    80004042:	b84080e7          	jalr	-1148(ra) # 80003bc2 <readi>
    80004046:	47c1                	li	a5,16
    80004048:	06f51163          	bne	a0,a5,800040aa <dirlink+0xa2>
    if(de.inum == 0)
    8000404c:	fc045783          	lhu	a5,-64(s0)
    80004050:	c791                	beqz	a5,8000405c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004052:	24c1                	addiw	s1,s1,16
    80004054:	04c92783          	lw	a5,76(s2)
    80004058:	fcf4ede3          	bltu	s1,a5,80004032 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000405c:	4639                	li	a2,14
    8000405e:	85d2                	mv	a1,s4
    80004060:	fc240513          	addi	a0,s0,-62
    80004064:	ffffd097          	auipc	ra,0xffffd
    80004068:	d7a080e7          	jalr	-646(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000406c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004070:	4741                	li	a4,16
    80004072:	86a6                	mv	a3,s1
    80004074:	fc040613          	addi	a2,s0,-64
    80004078:	4581                	li	a1,0
    8000407a:	854a                	mv	a0,s2
    8000407c:	00000097          	auipc	ra,0x0
    80004080:	c3e080e7          	jalr	-962(ra) # 80003cba <writei>
    80004084:	1541                	addi	a0,a0,-16
    80004086:	00a03533          	snez	a0,a0
    8000408a:	40a00533          	neg	a0,a0
}
    8000408e:	70e2                	ld	ra,56(sp)
    80004090:	7442                	ld	s0,48(sp)
    80004092:	74a2                	ld	s1,40(sp)
    80004094:	7902                	ld	s2,32(sp)
    80004096:	69e2                	ld	s3,24(sp)
    80004098:	6a42                	ld	s4,16(sp)
    8000409a:	6121                	addi	sp,sp,64
    8000409c:	8082                	ret
    iput(ip);
    8000409e:	00000097          	auipc	ra,0x0
    800040a2:	a2a080e7          	jalr	-1494(ra) # 80003ac8 <iput>
    return -1;
    800040a6:	557d                	li	a0,-1
    800040a8:	b7dd                	j	8000408e <dirlink+0x86>
      panic("dirlink read");
    800040aa:	00004517          	auipc	a0,0x4
    800040ae:	5a650513          	addi	a0,a0,1446 # 80008650 <syscalls+0x200>
    800040b2:	ffffc097          	auipc	ra,0xffffc
    800040b6:	48e080e7          	jalr	1166(ra) # 80000540 <panic>

00000000800040ba <namei>:

struct inode*
namei(char *path)
{
    800040ba:	1101                	addi	sp,sp,-32
    800040bc:	ec06                	sd	ra,24(sp)
    800040be:	e822                	sd	s0,16(sp)
    800040c0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040c2:	fe040613          	addi	a2,s0,-32
    800040c6:	4581                	li	a1,0
    800040c8:	00000097          	auipc	ra,0x0
    800040cc:	dda080e7          	jalr	-550(ra) # 80003ea2 <namex>
}
    800040d0:	60e2                	ld	ra,24(sp)
    800040d2:	6442                	ld	s0,16(sp)
    800040d4:	6105                	addi	sp,sp,32
    800040d6:	8082                	ret

00000000800040d8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040d8:	1141                	addi	sp,sp,-16
    800040da:	e406                	sd	ra,8(sp)
    800040dc:	e022                	sd	s0,0(sp)
    800040de:	0800                	addi	s0,sp,16
    800040e0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040e2:	4585                	li	a1,1
    800040e4:	00000097          	auipc	ra,0x0
    800040e8:	dbe080e7          	jalr	-578(ra) # 80003ea2 <namex>
}
    800040ec:	60a2                	ld	ra,8(sp)
    800040ee:	6402                	ld	s0,0(sp)
    800040f0:	0141                	addi	sp,sp,16
    800040f2:	8082                	ret

00000000800040f4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040f4:	1101                	addi	sp,sp,-32
    800040f6:	ec06                	sd	ra,24(sp)
    800040f8:	e822                	sd	s0,16(sp)
    800040fa:	e426                	sd	s1,8(sp)
    800040fc:	e04a                	sd	s2,0(sp)
    800040fe:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004100:	0001d917          	auipc	s2,0x1d
    80004104:	d8090913          	addi	s2,s2,-640 # 80020e80 <log>
    80004108:	01892583          	lw	a1,24(s2)
    8000410c:	02892503          	lw	a0,40(s2)
    80004110:	fffff097          	auipc	ra,0xfffff
    80004114:	fe6080e7          	jalr	-26(ra) # 800030f6 <bread>
    80004118:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000411a:	02c92683          	lw	a3,44(s2)
    8000411e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004120:	02d05863          	blez	a3,80004150 <write_head+0x5c>
    80004124:	0001d797          	auipc	a5,0x1d
    80004128:	d8c78793          	addi	a5,a5,-628 # 80020eb0 <log+0x30>
    8000412c:	05c50713          	addi	a4,a0,92
    80004130:	36fd                	addiw	a3,a3,-1
    80004132:	02069613          	slli	a2,a3,0x20
    80004136:	01e65693          	srli	a3,a2,0x1e
    8000413a:	0001d617          	auipc	a2,0x1d
    8000413e:	d7a60613          	addi	a2,a2,-646 # 80020eb4 <log+0x34>
    80004142:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004144:	4390                	lw	a2,0(a5)
    80004146:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004148:	0791                	addi	a5,a5,4
    8000414a:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000414c:	fed79ce3          	bne	a5,a3,80004144 <write_head+0x50>
  }
  bwrite(buf);
    80004150:	8526                	mv	a0,s1
    80004152:	fffff097          	auipc	ra,0xfffff
    80004156:	096080e7          	jalr	150(ra) # 800031e8 <bwrite>
  brelse(buf);
    8000415a:	8526                	mv	a0,s1
    8000415c:	fffff097          	auipc	ra,0xfffff
    80004160:	0ca080e7          	jalr	202(ra) # 80003226 <brelse>
}
    80004164:	60e2                	ld	ra,24(sp)
    80004166:	6442                	ld	s0,16(sp)
    80004168:	64a2                	ld	s1,8(sp)
    8000416a:	6902                	ld	s2,0(sp)
    8000416c:	6105                	addi	sp,sp,32
    8000416e:	8082                	ret

0000000080004170 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004170:	0001d797          	auipc	a5,0x1d
    80004174:	d3c7a783          	lw	a5,-708(a5) # 80020eac <log+0x2c>
    80004178:	0af05d63          	blez	a5,80004232 <install_trans+0xc2>
{
    8000417c:	7139                	addi	sp,sp,-64
    8000417e:	fc06                	sd	ra,56(sp)
    80004180:	f822                	sd	s0,48(sp)
    80004182:	f426                	sd	s1,40(sp)
    80004184:	f04a                	sd	s2,32(sp)
    80004186:	ec4e                	sd	s3,24(sp)
    80004188:	e852                	sd	s4,16(sp)
    8000418a:	e456                	sd	s5,8(sp)
    8000418c:	e05a                	sd	s6,0(sp)
    8000418e:	0080                	addi	s0,sp,64
    80004190:	8b2a                	mv	s6,a0
    80004192:	0001da97          	auipc	s5,0x1d
    80004196:	d1ea8a93          	addi	s5,s5,-738 # 80020eb0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000419a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000419c:	0001d997          	auipc	s3,0x1d
    800041a0:	ce498993          	addi	s3,s3,-796 # 80020e80 <log>
    800041a4:	a00d                	j	800041c6 <install_trans+0x56>
    brelse(lbuf);
    800041a6:	854a                	mv	a0,s2
    800041a8:	fffff097          	auipc	ra,0xfffff
    800041ac:	07e080e7          	jalr	126(ra) # 80003226 <brelse>
    brelse(dbuf);
    800041b0:	8526                	mv	a0,s1
    800041b2:	fffff097          	auipc	ra,0xfffff
    800041b6:	074080e7          	jalr	116(ra) # 80003226 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041ba:	2a05                	addiw	s4,s4,1
    800041bc:	0a91                	addi	s5,s5,4
    800041be:	02c9a783          	lw	a5,44(s3)
    800041c2:	04fa5e63          	bge	s4,a5,8000421e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041c6:	0189a583          	lw	a1,24(s3)
    800041ca:	014585bb          	addw	a1,a1,s4
    800041ce:	2585                	addiw	a1,a1,1
    800041d0:	0289a503          	lw	a0,40(s3)
    800041d4:	fffff097          	auipc	ra,0xfffff
    800041d8:	f22080e7          	jalr	-222(ra) # 800030f6 <bread>
    800041dc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041de:	000aa583          	lw	a1,0(s5)
    800041e2:	0289a503          	lw	a0,40(s3)
    800041e6:	fffff097          	auipc	ra,0xfffff
    800041ea:	f10080e7          	jalr	-240(ra) # 800030f6 <bread>
    800041ee:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041f0:	40000613          	li	a2,1024
    800041f4:	05890593          	addi	a1,s2,88
    800041f8:	05850513          	addi	a0,a0,88
    800041fc:	ffffd097          	auipc	ra,0xffffd
    80004200:	b32080e7          	jalr	-1230(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004204:	8526                	mv	a0,s1
    80004206:	fffff097          	auipc	ra,0xfffff
    8000420a:	fe2080e7          	jalr	-30(ra) # 800031e8 <bwrite>
    if(recovering == 0)
    8000420e:	f80b1ce3          	bnez	s6,800041a6 <install_trans+0x36>
      bunpin(dbuf);
    80004212:	8526                	mv	a0,s1
    80004214:	fffff097          	auipc	ra,0xfffff
    80004218:	0ec080e7          	jalr	236(ra) # 80003300 <bunpin>
    8000421c:	b769                	j	800041a6 <install_trans+0x36>
}
    8000421e:	70e2                	ld	ra,56(sp)
    80004220:	7442                	ld	s0,48(sp)
    80004222:	74a2                	ld	s1,40(sp)
    80004224:	7902                	ld	s2,32(sp)
    80004226:	69e2                	ld	s3,24(sp)
    80004228:	6a42                	ld	s4,16(sp)
    8000422a:	6aa2                	ld	s5,8(sp)
    8000422c:	6b02                	ld	s6,0(sp)
    8000422e:	6121                	addi	sp,sp,64
    80004230:	8082                	ret
    80004232:	8082                	ret

0000000080004234 <initlog>:
{
    80004234:	7179                	addi	sp,sp,-48
    80004236:	f406                	sd	ra,40(sp)
    80004238:	f022                	sd	s0,32(sp)
    8000423a:	ec26                	sd	s1,24(sp)
    8000423c:	e84a                	sd	s2,16(sp)
    8000423e:	e44e                	sd	s3,8(sp)
    80004240:	1800                	addi	s0,sp,48
    80004242:	892a                	mv	s2,a0
    80004244:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004246:	0001d497          	auipc	s1,0x1d
    8000424a:	c3a48493          	addi	s1,s1,-966 # 80020e80 <log>
    8000424e:	00004597          	auipc	a1,0x4
    80004252:	41258593          	addi	a1,a1,1042 # 80008660 <syscalls+0x210>
    80004256:	8526                	mv	a0,s1
    80004258:	ffffd097          	auipc	ra,0xffffd
    8000425c:	8ee080e7          	jalr	-1810(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004260:	0149a583          	lw	a1,20(s3)
    80004264:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004266:	0109a783          	lw	a5,16(s3)
    8000426a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000426c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004270:	854a                	mv	a0,s2
    80004272:	fffff097          	auipc	ra,0xfffff
    80004276:	e84080e7          	jalr	-380(ra) # 800030f6 <bread>
  log.lh.n = lh->n;
    8000427a:	4d34                	lw	a3,88(a0)
    8000427c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000427e:	02d05663          	blez	a3,800042aa <initlog+0x76>
    80004282:	05c50793          	addi	a5,a0,92
    80004286:	0001d717          	auipc	a4,0x1d
    8000428a:	c2a70713          	addi	a4,a4,-982 # 80020eb0 <log+0x30>
    8000428e:	36fd                	addiw	a3,a3,-1
    80004290:	02069613          	slli	a2,a3,0x20
    80004294:	01e65693          	srli	a3,a2,0x1e
    80004298:	06050613          	addi	a2,a0,96
    8000429c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000429e:	4390                	lw	a2,0(a5)
    800042a0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042a2:	0791                	addi	a5,a5,4
    800042a4:	0711                	addi	a4,a4,4
    800042a6:	fed79ce3          	bne	a5,a3,8000429e <initlog+0x6a>
  brelse(buf);
    800042aa:	fffff097          	auipc	ra,0xfffff
    800042ae:	f7c080e7          	jalr	-132(ra) # 80003226 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042b2:	4505                	li	a0,1
    800042b4:	00000097          	auipc	ra,0x0
    800042b8:	ebc080e7          	jalr	-324(ra) # 80004170 <install_trans>
  log.lh.n = 0;
    800042bc:	0001d797          	auipc	a5,0x1d
    800042c0:	be07a823          	sw	zero,-1040(a5) # 80020eac <log+0x2c>
  write_head(); // clear the log
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	e30080e7          	jalr	-464(ra) # 800040f4 <write_head>
}
    800042cc:	70a2                	ld	ra,40(sp)
    800042ce:	7402                	ld	s0,32(sp)
    800042d0:	64e2                	ld	s1,24(sp)
    800042d2:	6942                	ld	s2,16(sp)
    800042d4:	69a2                	ld	s3,8(sp)
    800042d6:	6145                	addi	sp,sp,48
    800042d8:	8082                	ret

00000000800042da <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042da:	1101                	addi	sp,sp,-32
    800042dc:	ec06                	sd	ra,24(sp)
    800042de:	e822                	sd	s0,16(sp)
    800042e0:	e426                	sd	s1,8(sp)
    800042e2:	e04a                	sd	s2,0(sp)
    800042e4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042e6:	0001d517          	auipc	a0,0x1d
    800042ea:	b9a50513          	addi	a0,a0,-1126 # 80020e80 <log>
    800042ee:	ffffd097          	auipc	ra,0xffffd
    800042f2:	8e8080e7          	jalr	-1816(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800042f6:	0001d497          	auipc	s1,0x1d
    800042fa:	b8a48493          	addi	s1,s1,-1142 # 80020e80 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042fe:	4979                	li	s2,30
    80004300:	a039                	j	8000430e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004302:	85a6                	mv	a1,s1
    80004304:	8526                	mv	a0,s1
    80004306:	ffffe097          	auipc	ra,0xffffe
    8000430a:	d56080e7          	jalr	-682(ra) # 8000205c <sleep>
    if(log.committing){
    8000430e:	50dc                	lw	a5,36(s1)
    80004310:	fbed                	bnez	a5,80004302 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004312:	5098                	lw	a4,32(s1)
    80004314:	2705                	addiw	a4,a4,1
    80004316:	0007069b          	sext.w	a3,a4
    8000431a:	0027179b          	slliw	a5,a4,0x2
    8000431e:	9fb9                	addw	a5,a5,a4
    80004320:	0017979b          	slliw	a5,a5,0x1
    80004324:	54d8                	lw	a4,44(s1)
    80004326:	9fb9                	addw	a5,a5,a4
    80004328:	00f95963          	bge	s2,a5,8000433a <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000432c:	85a6                	mv	a1,s1
    8000432e:	8526                	mv	a0,s1
    80004330:	ffffe097          	auipc	ra,0xffffe
    80004334:	d2c080e7          	jalr	-724(ra) # 8000205c <sleep>
    80004338:	bfd9                	j	8000430e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000433a:	0001d517          	auipc	a0,0x1d
    8000433e:	b4650513          	addi	a0,a0,-1210 # 80020e80 <log>
    80004342:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004344:	ffffd097          	auipc	ra,0xffffd
    80004348:	946080e7          	jalr	-1722(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000434c:	60e2                	ld	ra,24(sp)
    8000434e:	6442                	ld	s0,16(sp)
    80004350:	64a2                	ld	s1,8(sp)
    80004352:	6902                	ld	s2,0(sp)
    80004354:	6105                	addi	sp,sp,32
    80004356:	8082                	ret

0000000080004358 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004358:	7139                	addi	sp,sp,-64
    8000435a:	fc06                	sd	ra,56(sp)
    8000435c:	f822                	sd	s0,48(sp)
    8000435e:	f426                	sd	s1,40(sp)
    80004360:	f04a                	sd	s2,32(sp)
    80004362:	ec4e                	sd	s3,24(sp)
    80004364:	e852                	sd	s4,16(sp)
    80004366:	e456                	sd	s5,8(sp)
    80004368:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000436a:	0001d497          	auipc	s1,0x1d
    8000436e:	b1648493          	addi	s1,s1,-1258 # 80020e80 <log>
    80004372:	8526                	mv	a0,s1
    80004374:	ffffd097          	auipc	ra,0xffffd
    80004378:	862080e7          	jalr	-1950(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000437c:	509c                	lw	a5,32(s1)
    8000437e:	37fd                	addiw	a5,a5,-1
    80004380:	0007891b          	sext.w	s2,a5
    80004384:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004386:	50dc                	lw	a5,36(s1)
    80004388:	e7b9                	bnez	a5,800043d6 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000438a:	04091e63          	bnez	s2,800043e6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000438e:	0001d497          	auipc	s1,0x1d
    80004392:	af248493          	addi	s1,s1,-1294 # 80020e80 <log>
    80004396:	4785                	li	a5,1
    80004398:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000439a:	8526                	mv	a0,s1
    8000439c:	ffffd097          	auipc	ra,0xffffd
    800043a0:	8ee080e7          	jalr	-1810(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043a4:	54dc                	lw	a5,44(s1)
    800043a6:	06f04763          	bgtz	a5,80004414 <end_op+0xbc>
    acquire(&log.lock);
    800043aa:	0001d497          	auipc	s1,0x1d
    800043ae:	ad648493          	addi	s1,s1,-1322 # 80020e80 <log>
    800043b2:	8526                	mv	a0,s1
    800043b4:	ffffd097          	auipc	ra,0xffffd
    800043b8:	822080e7          	jalr	-2014(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800043bc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043c0:	8526                	mv	a0,s1
    800043c2:	ffffe097          	auipc	ra,0xffffe
    800043c6:	cfe080e7          	jalr	-770(ra) # 800020c0 <wakeup>
    release(&log.lock);
    800043ca:	8526                	mv	a0,s1
    800043cc:	ffffd097          	auipc	ra,0xffffd
    800043d0:	8be080e7          	jalr	-1858(ra) # 80000c8a <release>
}
    800043d4:	a03d                	j	80004402 <end_op+0xaa>
    panic("log.committing");
    800043d6:	00004517          	auipc	a0,0x4
    800043da:	29250513          	addi	a0,a0,658 # 80008668 <syscalls+0x218>
    800043de:	ffffc097          	auipc	ra,0xffffc
    800043e2:	162080e7          	jalr	354(ra) # 80000540 <panic>
    wakeup(&log);
    800043e6:	0001d497          	auipc	s1,0x1d
    800043ea:	a9a48493          	addi	s1,s1,-1382 # 80020e80 <log>
    800043ee:	8526                	mv	a0,s1
    800043f0:	ffffe097          	auipc	ra,0xffffe
    800043f4:	cd0080e7          	jalr	-816(ra) # 800020c0 <wakeup>
  release(&log.lock);
    800043f8:	8526                	mv	a0,s1
    800043fa:	ffffd097          	auipc	ra,0xffffd
    800043fe:	890080e7          	jalr	-1904(ra) # 80000c8a <release>
}
    80004402:	70e2                	ld	ra,56(sp)
    80004404:	7442                	ld	s0,48(sp)
    80004406:	74a2                	ld	s1,40(sp)
    80004408:	7902                	ld	s2,32(sp)
    8000440a:	69e2                	ld	s3,24(sp)
    8000440c:	6a42                	ld	s4,16(sp)
    8000440e:	6aa2                	ld	s5,8(sp)
    80004410:	6121                	addi	sp,sp,64
    80004412:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004414:	0001da97          	auipc	s5,0x1d
    80004418:	a9ca8a93          	addi	s5,s5,-1380 # 80020eb0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000441c:	0001da17          	auipc	s4,0x1d
    80004420:	a64a0a13          	addi	s4,s4,-1436 # 80020e80 <log>
    80004424:	018a2583          	lw	a1,24(s4)
    80004428:	012585bb          	addw	a1,a1,s2
    8000442c:	2585                	addiw	a1,a1,1
    8000442e:	028a2503          	lw	a0,40(s4)
    80004432:	fffff097          	auipc	ra,0xfffff
    80004436:	cc4080e7          	jalr	-828(ra) # 800030f6 <bread>
    8000443a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000443c:	000aa583          	lw	a1,0(s5)
    80004440:	028a2503          	lw	a0,40(s4)
    80004444:	fffff097          	auipc	ra,0xfffff
    80004448:	cb2080e7          	jalr	-846(ra) # 800030f6 <bread>
    8000444c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000444e:	40000613          	li	a2,1024
    80004452:	05850593          	addi	a1,a0,88
    80004456:	05848513          	addi	a0,s1,88
    8000445a:	ffffd097          	auipc	ra,0xffffd
    8000445e:	8d4080e7          	jalr	-1836(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004462:	8526                	mv	a0,s1
    80004464:	fffff097          	auipc	ra,0xfffff
    80004468:	d84080e7          	jalr	-636(ra) # 800031e8 <bwrite>
    brelse(from);
    8000446c:	854e                	mv	a0,s3
    8000446e:	fffff097          	auipc	ra,0xfffff
    80004472:	db8080e7          	jalr	-584(ra) # 80003226 <brelse>
    brelse(to);
    80004476:	8526                	mv	a0,s1
    80004478:	fffff097          	auipc	ra,0xfffff
    8000447c:	dae080e7          	jalr	-594(ra) # 80003226 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004480:	2905                	addiw	s2,s2,1
    80004482:	0a91                	addi	s5,s5,4
    80004484:	02ca2783          	lw	a5,44(s4)
    80004488:	f8f94ee3          	blt	s2,a5,80004424 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000448c:	00000097          	auipc	ra,0x0
    80004490:	c68080e7          	jalr	-920(ra) # 800040f4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004494:	4501                	li	a0,0
    80004496:	00000097          	auipc	ra,0x0
    8000449a:	cda080e7          	jalr	-806(ra) # 80004170 <install_trans>
    log.lh.n = 0;
    8000449e:	0001d797          	auipc	a5,0x1d
    800044a2:	a007a723          	sw	zero,-1522(a5) # 80020eac <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044a6:	00000097          	auipc	ra,0x0
    800044aa:	c4e080e7          	jalr	-946(ra) # 800040f4 <write_head>
    800044ae:	bdf5                	j	800043aa <end_op+0x52>

00000000800044b0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044b0:	1101                	addi	sp,sp,-32
    800044b2:	ec06                	sd	ra,24(sp)
    800044b4:	e822                	sd	s0,16(sp)
    800044b6:	e426                	sd	s1,8(sp)
    800044b8:	e04a                	sd	s2,0(sp)
    800044ba:	1000                	addi	s0,sp,32
    800044bc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044be:	0001d917          	auipc	s2,0x1d
    800044c2:	9c290913          	addi	s2,s2,-1598 # 80020e80 <log>
    800044c6:	854a                	mv	a0,s2
    800044c8:	ffffc097          	auipc	ra,0xffffc
    800044cc:	70e080e7          	jalr	1806(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044d0:	02c92603          	lw	a2,44(s2)
    800044d4:	47f5                	li	a5,29
    800044d6:	06c7c563          	blt	a5,a2,80004540 <log_write+0x90>
    800044da:	0001d797          	auipc	a5,0x1d
    800044de:	9c27a783          	lw	a5,-1598(a5) # 80020e9c <log+0x1c>
    800044e2:	37fd                	addiw	a5,a5,-1
    800044e4:	04f65e63          	bge	a2,a5,80004540 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044e8:	0001d797          	auipc	a5,0x1d
    800044ec:	9b87a783          	lw	a5,-1608(a5) # 80020ea0 <log+0x20>
    800044f0:	06f05063          	blez	a5,80004550 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800044f4:	4781                	li	a5,0
    800044f6:	06c05563          	blez	a2,80004560 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044fa:	44cc                	lw	a1,12(s1)
    800044fc:	0001d717          	auipc	a4,0x1d
    80004500:	9b470713          	addi	a4,a4,-1612 # 80020eb0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004504:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004506:	4314                	lw	a3,0(a4)
    80004508:	04b68c63          	beq	a3,a1,80004560 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000450c:	2785                	addiw	a5,a5,1
    8000450e:	0711                	addi	a4,a4,4
    80004510:	fef61be3          	bne	a2,a5,80004506 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004514:	0621                	addi	a2,a2,8
    80004516:	060a                	slli	a2,a2,0x2
    80004518:	0001d797          	auipc	a5,0x1d
    8000451c:	96878793          	addi	a5,a5,-1688 # 80020e80 <log>
    80004520:	97b2                	add	a5,a5,a2
    80004522:	44d8                	lw	a4,12(s1)
    80004524:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004526:	8526                	mv	a0,s1
    80004528:	fffff097          	auipc	ra,0xfffff
    8000452c:	d9c080e7          	jalr	-612(ra) # 800032c4 <bpin>
    log.lh.n++;
    80004530:	0001d717          	auipc	a4,0x1d
    80004534:	95070713          	addi	a4,a4,-1712 # 80020e80 <log>
    80004538:	575c                	lw	a5,44(a4)
    8000453a:	2785                	addiw	a5,a5,1
    8000453c:	d75c                	sw	a5,44(a4)
    8000453e:	a82d                	j	80004578 <log_write+0xc8>
    panic("too big a transaction");
    80004540:	00004517          	auipc	a0,0x4
    80004544:	13850513          	addi	a0,a0,312 # 80008678 <syscalls+0x228>
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	ff8080e7          	jalr	-8(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004550:	00004517          	auipc	a0,0x4
    80004554:	14050513          	addi	a0,a0,320 # 80008690 <syscalls+0x240>
    80004558:	ffffc097          	auipc	ra,0xffffc
    8000455c:	fe8080e7          	jalr	-24(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004560:	00878693          	addi	a3,a5,8
    80004564:	068a                	slli	a3,a3,0x2
    80004566:	0001d717          	auipc	a4,0x1d
    8000456a:	91a70713          	addi	a4,a4,-1766 # 80020e80 <log>
    8000456e:	9736                	add	a4,a4,a3
    80004570:	44d4                	lw	a3,12(s1)
    80004572:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004574:	faf609e3          	beq	a2,a5,80004526 <log_write+0x76>
  }
  release(&log.lock);
    80004578:	0001d517          	auipc	a0,0x1d
    8000457c:	90850513          	addi	a0,a0,-1784 # 80020e80 <log>
    80004580:	ffffc097          	auipc	ra,0xffffc
    80004584:	70a080e7          	jalr	1802(ra) # 80000c8a <release>
}
    80004588:	60e2                	ld	ra,24(sp)
    8000458a:	6442                	ld	s0,16(sp)
    8000458c:	64a2                	ld	s1,8(sp)
    8000458e:	6902                	ld	s2,0(sp)
    80004590:	6105                	addi	sp,sp,32
    80004592:	8082                	ret

0000000080004594 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004594:	1101                	addi	sp,sp,-32
    80004596:	ec06                	sd	ra,24(sp)
    80004598:	e822                	sd	s0,16(sp)
    8000459a:	e426                	sd	s1,8(sp)
    8000459c:	e04a                	sd	s2,0(sp)
    8000459e:	1000                	addi	s0,sp,32
    800045a0:	84aa                	mv	s1,a0
    800045a2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045a4:	00004597          	auipc	a1,0x4
    800045a8:	10c58593          	addi	a1,a1,268 # 800086b0 <syscalls+0x260>
    800045ac:	0521                	addi	a0,a0,8
    800045ae:	ffffc097          	auipc	ra,0xffffc
    800045b2:	598080e7          	jalr	1432(ra) # 80000b46 <initlock>
  lk->name = name;
    800045b6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045ba:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045be:	0204a423          	sw	zero,40(s1)
}
    800045c2:	60e2                	ld	ra,24(sp)
    800045c4:	6442                	ld	s0,16(sp)
    800045c6:	64a2                	ld	s1,8(sp)
    800045c8:	6902                	ld	s2,0(sp)
    800045ca:	6105                	addi	sp,sp,32
    800045cc:	8082                	ret

00000000800045ce <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045ce:	1101                	addi	sp,sp,-32
    800045d0:	ec06                	sd	ra,24(sp)
    800045d2:	e822                	sd	s0,16(sp)
    800045d4:	e426                	sd	s1,8(sp)
    800045d6:	e04a                	sd	s2,0(sp)
    800045d8:	1000                	addi	s0,sp,32
    800045da:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045dc:	00850913          	addi	s2,a0,8
    800045e0:	854a                	mv	a0,s2
    800045e2:	ffffc097          	auipc	ra,0xffffc
    800045e6:	5f4080e7          	jalr	1524(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800045ea:	409c                	lw	a5,0(s1)
    800045ec:	cb89                	beqz	a5,800045fe <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045ee:	85ca                	mv	a1,s2
    800045f0:	8526                	mv	a0,s1
    800045f2:	ffffe097          	auipc	ra,0xffffe
    800045f6:	a6a080e7          	jalr	-1430(ra) # 8000205c <sleep>
  while (lk->locked) {
    800045fa:	409c                	lw	a5,0(s1)
    800045fc:	fbed                	bnez	a5,800045ee <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045fe:	4785                	li	a5,1
    80004600:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004602:	ffffd097          	auipc	ra,0xffffd
    80004606:	3b2080e7          	jalr	946(ra) # 800019b4 <myproc>
    8000460a:	591c                	lw	a5,48(a0)
    8000460c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000460e:	854a                	mv	a0,s2
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	67a080e7          	jalr	1658(ra) # 80000c8a <release>
}
    80004618:	60e2                	ld	ra,24(sp)
    8000461a:	6442                	ld	s0,16(sp)
    8000461c:	64a2                	ld	s1,8(sp)
    8000461e:	6902                	ld	s2,0(sp)
    80004620:	6105                	addi	sp,sp,32
    80004622:	8082                	ret

0000000080004624 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004624:	1101                	addi	sp,sp,-32
    80004626:	ec06                	sd	ra,24(sp)
    80004628:	e822                	sd	s0,16(sp)
    8000462a:	e426                	sd	s1,8(sp)
    8000462c:	e04a                	sd	s2,0(sp)
    8000462e:	1000                	addi	s0,sp,32
    80004630:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004632:	00850913          	addi	s2,a0,8
    80004636:	854a                	mv	a0,s2
    80004638:	ffffc097          	auipc	ra,0xffffc
    8000463c:	59e080e7          	jalr	1438(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004640:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004644:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004648:	8526                	mv	a0,s1
    8000464a:	ffffe097          	auipc	ra,0xffffe
    8000464e:	a76080e7          	jalr	-1418(ra) # 800020c0 <wakeup>
  release(&lk->lk);
    80004652:	854a                	mv	a0,s2
    80004654:	ffffc097          	auipc	ra,0xffffc
    80004658:	636080e7          	jalr	1590(ra) # 80000c8a <release>
}
    8000465c:	60e2                	ld	ra,24(sp)
    8000465e:	6442                	ld	s0,16(sp)
    80004660:	64a2                	ld	s1,8(sp)
    80004662:	6902                	ld	s2,0(sp)
    80004664:	6105                	addi	sp,sp,32
    80004666:	8082                	ret

0000000080004668 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004668:	7179                	addi	sp,sp,-48
    8000466a:	f406                	sd	ra,40(sp)
    8000466c:	f022                	sd	s0,32(sp)
    8000466e:	ec26                	sd	s1,24(sp)
    80004670:	e84a                	sd	s2,16(sp)
    80004672:	e44e                	sd	s3,8(sp)
    80004674:	1800                	addi	s0,sp,48
    80004676:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004678:	00850913          	addi	s2,a0,8
    8000467c:	854a                	mv	a0,s2
    8000467e:	ffffc097          	auipc	ra,0xffffc
    80004682:	558080e7          	jalr	1368(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004686:	409c                	lw	a5,0(s1)
    80004688:	ef99                	bnez	a5,800046a6 <holdingsleep+0x3e>
    8000468a:	4481                	li	s1,0
  release(&lk->lk);
    8000468c:	854a                	mv	a0,s2
    8000468e:	ffffc097          	auipc	ra,0xffffc
    80004692:	5fc080e7          	jalr	1532(ra) # 80000c8a <release>
  return r;
}
    80004696:	8526                	mv	a0,s1
    80004698:	70a2                	ld	ra,40(sp)
    8000469a:	7402                	ld	s0,32(sp)
    8000469c:	64e2                	ld	s1,24(sp)
    8000469e:	6942                	ld	s2,16(sp)
    800046a0:	69a2                	ld	s3,8(sp)
    800046a2:	6145                	addi	sp,sp,48
    800046a4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046a6:	0284a983          	lw	s3,40(s1)
    800046aa:	ffffd097          	auipc	ra,0xffffd
    800046ae:	30a080e7          	jalr	778(ra) # 800019b4 <myproc>
    800046b2:	5904                	lw	s1,48(a0)
    800046b4:	413484b3          	sub	s1,s1,s3
    800046b8:	0014b493          	seqz	s1,s1
    800046bc:	bfc1                	j	8000468c <holdingsleep+0x24>

00000000800046be <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046be:	1141                	addi	sp,sp,-16
    800046c0:	e406                	sd	ra,8(sp)
    800046c2:	e022                	sd	s0,0(sp)
    800046c4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046c6:	00004597          	auipc	a1,0x4
    800046ca:	ffa58593          	addi	a1,a1,-6 # 800086c0 <syscalls+0x270>
    800046ce:	0001d517          	auipc	a0,0x1d
    800046d2:	8fa50513          	addi	a0,a0,-1798 # 80020fc8 <ftable>
    800046d6:	ffffc097          	auipc	ra,0xffffc
    800046da:	470080e7          	jalr	1136(ra) # 80000b46 <initlock>
}
    800046de:	60a2                	ld	ra,8(sp)
    800046e0:	6402                	ld	s0,0(sp)
    800046e2:	0141                	addi	sp,sp,16
    800046e4:	8082                	ret

00000000800046e6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046e6:	1101                	addi	sp,sp,-32
    800046e8:	ec06                	sd	ra,24(sp)
    800046ea:	e822                	sd	s0,16(sp)
    800046ec:	e426                	sd	s1,8(sp)
    800046ee:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046f0:	0001d517          	auipc	a0,0x1d
    800046f4:	8d850513          	addi	a0,a0,-1832 # 80020fc8 <ftable>
    800046f8:	ffffc097          	auipc	ra,0xffffc
    800046fc:	4de080e7          	jalr	1246(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004700:	0001d497          	auipc	s1,0x1d
    80004704:	8e048493          	addi	s1,s1,-1824 # 80020fe0 <ftable+0x18>
    80004708:	0001e717          	auipc	a4,0x1e
    8000470c:	87870713          	addi	a4,a4,-1928 # 80021f80 <disk>
    if(f->ref == 0){
    80004710:	40dc                	lw	a5,4(s1)
    80004712:	cf99                	beqz	a5,80004730 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004714:	02848493          	addi	s1,s1,40
    80004718:	fee49ce3          	bne	s1,a4,80004710 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000471c:	0001d517          	auipc	a0,0x1d
    80004720:	8ac50513          	addi	a0,a0,-1876 # 80020fc8 <ftable>
    80004724:	ffffc097          	auipc	ra,0xffffc
    80004728:	566080e7          	jalr	1382(ra) # 80000c8a <release>
  return 0;
    8000472c:	4481                	li	s1,0
    8000472e:	a819                	j	80004744 <filealloc+0x5e>
      f->ref = 1;
    80004730:	4785                	li	a5,1
    80004732:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004734:	0001d517          	auipc	a0,0x1d
    80004738:	89450513          	addi	a0,a0,-1900 # 80020fc8 <ftable>
    8000473c:	ffffc097          	auipc	ra,0xffffc
    80004740:	54e080e7          	jalr	1358(ra) # 80000c8a <release>
}
    80004744:	8526                	mv	a0,s1
    80004746:	60e2                	ld	ra,24(sp)
    80004748:	6442                	ld	s0,16(sp)
    8000474a:	64a2                	ld	s1,8(sp)
    8000474c:	6105                	addi	sp,sp,32
    8000474e:	8082                	ret

0000000080004750 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004750:	1101                	addi	sp,sp,-32
    80004752:	ec06                	sd	ra,24(sp)
    80004754:	e822                	sd	s0,16(sp)
    80004756:	e426                	sd	s1,8(sp)
    80004758:	1000                	addi	s0,sp,32
    8000475a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000475c:	0001d517          	auipc	a0,0x1d
    80004760:	86c50513          	addi	a0,a0,-1940 # 80020fc8 <ftable>
    80004764:	ffffc097          	auipc	ra,0xffffc
    80004768:	472080e7          	jalr	1138(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000476c:	40dc                	lw	a5,4(s1)
    8000476e:	02f05263          	blez	a5,80004792 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004772:	2785                	addiw	a5,a5,1
    80004774:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004776:	0001d517          	auipc	a0,0x1d
    8000477a:	85250513          	addi	a0,a0,-1966 # 80020fc8 <ftable>
    8000477e:	ffffc097          	auipc	ra,0xffffc
    80004782:	50c080e7          	jalr	1292(ra) # 80000c8a <release>
  return f;
}
    80004786:	8526                	mv	a0,s1
    80004788:	60e2                	ld	ra,24(sp)
    8000478a:	6442                	ld	s0,16(sp)
    8000478c:	64a2                	ld	s1,8(sp)
    8000478e:	6105                	addi	sp,sp,32
    80004790:	8082                	ret
    panic("filedup");
    80004792:	00004517          	auipc	a0,0x4
    80004796:	f3650513          	addi	a0,a0,-202 # 800086c8 <syscalls+0x278>
    8000479a:	ffffc097          	auipc	ra,0xffffc
    8000479e:	da6080e7          	jalr	-602(ra) # 80000540 <panic>

00000000800047a2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047a2:	7139                	addi	sp,sp,-64
    800047a4:	fc06                	sd	ra,56(sp)
    800047a6:	f822                	sd	s0,48(sp)
    800047a8:	f426                	sd	s1,40(sp)
    800047aa:	f04a                	sd	s2,32(sp)
    800047ac:	ec4e                	sd	s3,24(sp)
    800047ae:	e852                	sd	s4,16(sp)
    800047b0:	e456                	sd	s5,8(sp)
    800047b2:	0080                	addi	s0,sp,64
    800047b4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047b6:	0001d517          	auipc	a0,0x1d
    800047ba:	81250513          	addi	a0,a0,-2030 # 80020fc8 <ftable>
    800047be:	ffffc097          	auipc	ra,0xffffc
    800047c2:	418080e7          	jalr	1048(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800047c6:	40dc                	lw	a5,4(s1)
    800047c8:	06f05163          	blez	a5,8000482a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047cc:	37fd                	addiw	a5,a5,-1
    800047ce:	0007871b          	sext.w	a4,a5
    800047d2:	c0dc                	sw	a5,4(s1)
    800047d4:	06e04363          	bgtz	a4,8000483a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047d8:	0004a903          	lw	s2,0(s1)
    800047dc:	0094ca83          	lbu	s5,9(s1)
    800047e0:	0104ba03          	ld	s4,16(s1)
    800047e4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047e8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047ec:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047f0:	0001c517          	auipc	a0,0x1c
    800047f4:	7d850513          	addi	a0,a0,2008 # 80020fc8 <ftable>
    800047f8:	ffffc097          	auipc	ra,0xffffc
    800047fc:	492080e7          	jalr	1170(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004800:	4785                	li	a5,1
    80004802:	04f90d63          	beq	s2,a5,8000485c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004806:	3979                	addiw	s2,s2,-2
    80004808:	4785                	li	a5,1
    8000480a:	0527e063          	bltu	a5,s2,8000484a <fileclose+0xa8>
    begin_op();
    8000480e:	00000097          	auipc	ra,0x0
    80004812:	acc080e7          	jalr	-1332(ra) # 800042da <begin_op>
    iput(ff.ip);
    80004816:	854e                	mv	a0,s3
    80004818:	fffff097          	auipc	ra,0xfffff
    8000481c:	2b0080e7          	jalr	688(ra) # 80003ac8 <iput>
    end_op();
    80004820:	00000097          	auipc	ra,0x0
    80004824:	b38080e7          	jalr	-1224(ra) # 80004358 <end_op>
    80004828:	a00d                	j	8000484a <fileclose+0xa8>
    panic("fileclose");
    8000482a:	00004517          	auipc	a0,0x4
    8000482e:	ea650513          	addi	a0,a0,-346 # 800086d0 <syscalls+0x280>
    80004832:	ffffc097          	auipc	ra,0xffffc
    80004836:	d0e080e7          	jalr	-754(ra) # 80000540 <panic>
    release(&ftable.lock);
    8000483a:	0001c517          	auipc	a0,0x1c
    8000483e:	78e50513          	addi	a0,a0,1934 # 80020fc8 <ftable>
    80004842:	ffffc097          	auipc	ra,0xffffc
    80004846:	448080e7          	jalr	1096(ra) # 80000c8a <release>
  }
}
    8000484a:	70e2                	ld	ra,56(sp)
    8000484c:	7442                	ld	s0,48(sp)
    8000484e:	74a2                	ld	s1,40(sp)
    80004850:	7902                	ld	s2,32(sp)
    80004852:	69e2                	ld	s3,24(sp)
    80004854:	6a42                	ld	s4,16(sp)
    80004856:	6aa2                	ld	s5,8(sp)
    80004858:	6121                	addi	sp,sp,64
    8000485a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000485c:	85d6                	mv	a1,s5
    8000485e:	8552                	mv	a0,s4
    80004860:	00000097          	auipc	ra,0x0
    80004864:	34c080e7          	jalr	844(ra) # 80004bac <pipeclose>
    80004868:	b7cd                	j	8000484a <fileclose+0xa8>

000000008000486a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000486a:	715d                	addi	sp,sp,-80
    8000486c:	e486                	sd	ra,72(sp)
    8000486e:	e0a2                	sd	s0,64(sp)
    80004870:	fc26                	sd	s1,56(sp)
    80004872:	f84a                	sd	s2,48(sp)
    80004874:	f44e                	sd	s3,40(sp)
    80004876:	0880                	addi	s0,sp,80
    80004878:	84aa                	mv	s1,a0
    8000487a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000487c:	ffffd097          	auipc	ra,0xffffd
    80004880:	138080e7          	jalr	312(ra) # 800019b4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004884:	409c                	lw	a5,0(s1)
    80004886:	37f9                	addiw	a5,a5,-2
    80004888:	4705                	li	a4,1
    8000488a:	04f76763          	bltu	a4,a5,800048d8 <filestat+0x6e>
    8000488e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004890:	6c88                	ld	a0,24(s1)
    80004892:	fffff097          	auipc	ra,0xfffff
    80004896:	07c080e7          	jalr	124(ra) # 8000390e <ilock>
    stati(f->ip, &st);
    8000489a:	fb840593          	addi	a1,s0,-72
    8000489e:	6c88                	ld	a0,24(s1)
    800048a0:	fffff097          	auipc	ra,0xfffff
    800048a4:	2f8080e7          	jalr	760(ra) # 80003b98 <stati>
    iunlock(f->ip);
    800048a8:	6c88                	ld	a0,24(s1)
    800048aa:	fffff097          	auipc	ra,0xfffff
    800048ae:	126080e7          	jalr	294(ra) # 800039d0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048b2:	46e1                	li	a3,24
    800048b4:	fb840613          	addi	a2,s0,-72
    800048b8:	85ce                	mv	a1,s3
    800048ba:	05093503          	ld	a0,80(s2)
    800048be:	ffffd097          	auipc	ra,0xffffd
    800048c2:	db6080e7          	jalr	-586(ra) # 80001674 <copyout>
    800048c6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048ca:	60a6                	ld	ra,72(sp)
    800048cc:	6406                	ld	s0,64(sp)
    800048ce:	74e2                	ld	s1,56(sp)
    800048d0:	7942                	ld	s2,48(sp)
    800048d2:	79a2                	ld	s3,40(sp)
    800048d4:	6161                	addi	sp,sp,80
    800048d6:	8082                	ret
  return -1;
    800048d8:	557d                	li	a0,-1
    800048da:	bfc5                	j	800048ca <filestat+0x60>

00000000800048dc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048dc:	7179                	addi	sp,sp,-48
    800048de:	f406                	sd	ra,40(sp)
    800048e0:	f022                	sd	s0,32(sp)
    800048e2:	ec26                	sd	s1,24(sp)
    800048e4:	e84a                	sd	s2,16(sp)
    800048e6:	e44e                	sd	s3,8(sp)
    800048e8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048ea:	00854783          	lbu	a5,8(a0)
    800048ee:	c3d5                	beqz	a5,80004992 <fileread+0xb6>
    800048f0:	84aa                	mv	s1,a0
    800048f2:	89ae                	mv	s3,a1
    800048f4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048f6:	411c                	lw	a5,0(a0)
    800048f8:	4705                	li	a4,1
    800048fa:	04e78963          	beq	a5,a4,8000494c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048fe:	470d                	li	a4,3
    80004900:	04e78d63          	beq	a5,a4,8000495a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004904:	4709                	li	a4,2
    80004906:	06e79e63          	bne	a5,a4,80004982 <fileread+0xa6>
    ilock(f->ip);
    8000490a:	6d08                	ld	a0,24(a0)
    8000490c:	fffff097          	auipc	ra,0xfffff
    80004910:	002080e7          	jalr	2(ra) # 8000390e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004914:	874a                	mv	a4,s2
    80004916:	5094                	lw	a3,32(s1)
    80004918:	864e                	mv	a2,s3
    8000491a:	4585                	li	a1,1
    8000491c:	6c88                	ld	a0,24(s1)
    8000491e:	fffff097          	auipc	ra,0xfffff
    80004922:	2a4080e7          	jalr	676(ra) # 80003bc2 <readi>
    80004926:	892a                	mv	s2,a0
    80004928:	00a05563          	blez	a0,80004932 <fileread+0x56>
      f->off += r;
    8000492c:	509c                	lw	a5,32(s1)
    8000492e:	9fa9                	addw	a5,a5,a0
    80004930:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004932:	6c88                	ld	a0,24(s1)
    80004934:	fffff097          	auipc	ra,0xfffff
    80004938:	09c080e7          	jalr	156(ra) # 800039d0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000493c:	854a                	mv	a0,s2
    8000493e:	70a2                	ld	ra,40(sp)
    80004940:	7402                	ld	s0,32(sp)
    80004942:	64e2                	ld	s1,24(sp)
    80004944:	6942                	ld	s2,16(sp)
    80004946:	69a2                	ld	s3,8(sp)
    80004948:	6145                	addi	sp,sp,48
    8000494a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000494c:	6908                	ld	a0,16(a0)
    8000494e:	00000097          	auipc	ra,0x0
    80004952:	3c6080e7          	jalr	966(ra) # 80004d14 <piperead>
    80004956:	892a                	mv	s2,a0
    80004958:	b7d5                	j	8000493c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000495a:	02451783          	lh	a5,36(a0)
    8000495e:	03079693          	slli	a3,a5,0x30
    80004962:	92c1                	srli	a3,a3,0x30
    80004964:	4725                	li	a4,9
    80004966:	02d76863          	bltu	a4,a3,80004996 <fileread+0xba>
    8000496a:	0792                	slli	a5,a5,0x4
    8000496c:	0001c717          	auipc	a4,0x1c
    80004970:	5bc70713          	addi	a4,a4,1468 # 80020f28 <devsw>
    80004974:	97ba                	add	a5,a5,a4
    80004976:	639c                	ld	a5,0(a5)
    80004978:	c38d                	beqz	a5,8000499a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000497a:	4505                	li	a0,1
    8000497c:	9782                	jalr	a5
    8000497e:	892a                	mv	s2,a0
    80004980:	bf75                	j	8000493c <fileread+0x60>
    panic("fileread");
    80004982:	00004517          	auipc	a0,0x4
    80004986:	d5e50513          	addi	a0,a0,-674 # 800086e0 <syscalls+0x290>
    8000498a:	ffffc097          	auipc	ra,0xffffc
    8000498e:	bb6080e7          	jalr	-1098(ra) # 80000540 <panic>
    return -1;
    80004992:	597d                	li	s2,-1
    80004994:	b765                	j	8000493c <fileread+0x60>
      return -1;
    80004996:	597d                	li	s2,-1
    80004998:	b755                	j	8000493c <fileread+0x60>
    8000499a:	597d                	li	s2,-1
    8000499c:	b745                	j	8000493c <fileread+0x60>

000000008000499e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000499e:	715d                	addi	sp,sp,-80
    800049a0:	e486                	sd	ra,72(sp)
    800049a2:	e0a2                	sd	s0,64(sp)
    800049a4:	fc26                	sd	s1,56(sp)
    800049a6:	f84a                	sd	s2,48(sp)
    800049a8:	f44e                	sd	s3,40(sp)
    800049aa:	f052                	sd	s4,32(sp)
    800049ac:	ec56                	sd	s5,24(sp)
    800049ae:	e85a                	sd	s6,16(sp)
    800049b0:	e45e                	sd	s7,8(sp)
    800049b2:	e062                	sd	s8,0(sp)
    800049b4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800049b6:	00954783          	lbu	a5,9(a0)
    800049ba:	10078663          	beqz	a5,80004ac6 <filewrite+0x128>
    800049be:	892a                	mv	s2,a0
    800049c0:	8b2e                	mv	s6,a1
    800049c2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049c4:	411c                	lw	a5,0(a0)
    800049c6:	4705                	li	a4,1
    800049c8:	02e78263          	beq	a5,a4,800049ec <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049cc:	470d                	li	a4,3
    800049ce:	02e78663          	beq	a5,a4,800049fa <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049d2:	4709                	li	a4,2
    800049d4:	0ee79163          	bne	a5,a4,80004ab6 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049d8:	0ac05d63          	blez	a2,80004a92 <filewrite+0xf4>
    int i = 0;
    800049dc:	4981                	li	s3,0
    800049de:	6b85                	lui	s7,0x1
    800049e0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800049e4:	6c05                	lui	s8,0x1
    800049e6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800049ea:	a861                	j	80004a82 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800049ec:	6908                	ld	a0,16(a0)
    800049ee:	00000097          	auipc	ra,0x0
    800049f2:	22e080e7          	jalr	558(ra) # 80004c1c <pipewrite>
    800049f6:	8a2a                	mv	s4,a0
    800049f8:	a045                	j	80004a98 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049fa:	02451783          	lh	a5,36(a0)
    800049fe:	03079693          	slli	a3,a5,0x30
    80004a02:	92c1                	srli	a3,a3,0x30
    80004a04:	4725                	li	a4,9
    80004a06:	0cd76263          	bltu	a4,a3,80004aca <filewrite+0x12c>
    80004a0a:	0792                	slli	a5,a5,0x4
    80004a0c:	0001c717          	auipc	a4,0x1c
    80004a10:	51c70713          	addi	a4,a4,1308 # 80020f28 <devsw>
    80004a14:	97ba                	add	a5,a5,a4
    80004a16:	679c                	ld	a5,8(a5)
    80004a18:	cbdd                	beqz	a5,80004ace <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a1a:	4505                	li	a0,1
    80004a1c:	9782                	jalr	a5
    80004a1e:	8a2a                	mv	s4,a0
    80004a20:	a8a5                	j	80004a98 <filewrite+0xfa>
    80004a22:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a26:	00000097          	auipc	ra,0x0
    80004a2a:	8b4080e7          	jalr	-1868(ra) # 800042da <begin_op>
      ilock(f->ip);
    80004a2e:	01893503          	ld	a0,24(s2)
    80004a32:	fffff097          	auipc	ra,0xfffff
    80004a36:	edc080e7          	jalr	-292(ra) # 8000390e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a3a:	8756                	mv	a4,s5
    80004a3c:	02092683          	lw	a3,32(s2)
    80004a40:	01698633          	add	a2,s3,s6
    80004a44:	4585                	li	a1,1
    80004a46:	01893503          	ld	a0,24(s2)
    80004a4a:	fffff097          	auipc	ra,0xfffff
    80004a4e:	270080e7          	jalr	624(ra) # 80003cba <writei>
    80004a52:	84aa                	mv	s1,a0
    80004a54:	00a05763          	blez	a0,80004a62 <filewrite+0xc4>
        f->off += r;
    80004a58:	02092783          	lw	a5,32(s2)
    80004a5c:	9fa9                	addw	a5,a5,a0
    80004a5e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a62:	01893503          	ld	a0,24(s2)
    80004a66:	fffff097          	auipc	ra,0xfffff
    80004a6a:	f6a080e7          	jalr	-150(ra) # 800039d0 <iunlock>
      end_op();
    80004a6e:	00000097          	auipc	ra,0x0
    80004a72:	8ea080e7          	jalr	-1814(ra) # 80004358 <end_op>

      if(r != n1){
    80004a76:	009a9f63          	bne	s5,s1,80004a94 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a7a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a7e:	0149db63          	bge	s3,s4,80004a94 <filewrite+0xf6>
      int n1 = n - i;
    80004a82:	413a04bb          	subw	s1,s4,s3
    80004a86:	0004879b          	sext.w	a5,s1
    80004a8a:	f8fbdce3          	bge	s7,a5,80004a22 <filewrite+0x84>
    80004a8e:	84e2                	mv	s1,s8
    80004a90:	bf49                	j	80004a22 <filewrite+0x84>
    int i = 0;
    80004a92:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a94:	013a1f63          	bne	s4,s3,80004ab2 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a98:	8552                	mv	a0,s4
    80004a9a:	60a6                	ld	ra,72(sp)
    80004a9c:	6406                	ld	s0,64(sp)
    80004a9e:	74e2                	ld	s1,56(sp)
    80004aa0:	7942                	ld	s2,48(sp)
    80004aa2:	79a2                	ld	s3,40(sp)
    80004aa4:	7a02                	ld	s4,32(sp)
    80004aa6:	6ae2                	ld	s5,24(sp)
    80004aa8:	6b42                	ld	s6,16(sp)
    80004aaa:	6ba2                	ld	s7,8(sp)
    80004aac:	6c02                	ld	s8,0(sp)
    80004aae:	6161                	addi	sp,sp,80
    80004ab0:	8082                	ret
    ret = (i == n ? n : -1);
    80004ab2:	5a7d                	li	s4,-1
    80004ab4:	b7d5                	j	80004a98 <filewrite+0xfa>
    panic("filewrite");
    80004ab6:	00004517          	auipc	a0,0x4
    80004aba:	c3a50513          	addi	a0,a0,-966 # 800086f0 <syscalls+0x2a0>
    80004abe:	ffffc097          	auipc	ra,0xffffc
    80004ac2:	a82080e7          	jalr	-1406(ra) # 80000540 <panic>
    return -1;
    80004ac6:	5a7d                	li	s4,-1
    80004ac8:	bfc1                	j	80004a98 <filewrite+0xfa>
      return -1;
    80004aca:	5a7d                	li	s4,-1
    80004acc:	b7f1                	j	80004a98 <filewrite+0xfa>
    80004ace:	5a7d                	li	s4,-1
    80004ad0:	b7e1                	j	80004a98 <filewrite+0xfa>

0000000080004ad2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ad2:	7179                	addi	sp,sp,-48
    80004ad4:	f406                	sd	ra,40(sp)
    80004ad6:	f022                	sd	s0,32(sp)
    80004ad8:	ec26                	sd	s1,24(sp)
    80004ada:	e84a                	sd	s2,16(sp)
    80004adc:	e44e                	sd	s3,8(sp)
    80004ade:	e052                	sd	s4,0(sp)
    80004ae0:	1800                	addi	s0,sp,48
    80004ae2:	84aa                	mv	s1,a0
    80004ae4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ae6:	0005b023          	sd	zero,0(a1)
    80004aea:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004aee:	00000097          	auipc	ra,0x0
    80004af2:	bf8080e7          	jalr	-1032(ra) # 800046e6 <filealloc>
    80004af6:	e088                	sd	a0,0(s1)
    80004af8:	c551                	beqz	a0,80004b84 <pipealloc+0xb2>
    80004afa:	00000097          	auipc	ra,0x0
    80004afe:	bec080e7          	jalr	-1044(ra) # 800046e6 <filealloc>
    80004b02:	00aa3023          	sd	a0,0(s4)
    80004b06:	c92d                	beqz	a0,80004b78 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b08:	ffffc097          	auipc	ra,0xffffc
    80004b0c:	fde080e7          	jalr	-34(ra) # 80000ae6 <kalloc>
    80004b10:	892a                	mv	s2,a0
    80004b12:	c125                	beqz	a0,80004b72 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b14:	4985                	li	s3,1
    80004b16:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b1a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b1e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b22:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b26:	00004597          	auipc	a1,0x4
    80004b2a:	bda58593          	addi	a1,a1,-1062 # 80008700 <syscalls+0x2b0>
    80004b2e:	ffffc097          	auipc	ra,0xffffc
    80004b32:	018080e7          	jalr	24(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004b36:	609c                	ld	a5,0(s1)
    80004b38:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b3c:	609c                	ld	a5,0(s1)
    80004b3e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b42:	609c                	ld	a5,0(s1)
    80004b44:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b48:	609c                	ld	a5,0(s1)
    80004b4a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b4e:	000a3783          	ld	a5,0(s4)
    80004b52:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b56:	000a3783          	ld	a5,0(s4)
    80004b5a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b5e:	000a3783          	ld	a5,0(s4)
    80004b62:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b66:	000a3783          	ld	a5,0(s4)
    80004b6a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b6e:	4501                	li	a0,0
    80004b70:	a025                	j	80004b98 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b72:	6088                	ld	a0,0(s1)
    80004b74:	e501                	bnez	a0,80004b7c <pipealloc+0xaa>
    80004b76:	a039                	j	80004b84 <pipealloc+0xb2>
    80004b78:	6088                	ld	a0,0(s1)
    80004b7a:	c51d                	beqz	a0,80004ba8 <pipealloc+0xd6>
    fileclose(*f0);
    80004b7c:	00000097          	auipc	ra,0x0
    80004b80:	c26080e7          	jalr	-986(ra) # 800047a2 <fileclose>
  if(*f1)
    80004b84:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b88:	557d                	li	a0,-1
  if(*f1)
    80004b8a:	c799                	beqz	a5,80004b98 <pipealloc+0xc6>
    fileclose(*f1);
    80004b8c:	853e                	mv	a0,a5
    80004b8e:	00000097          	auipc	ra,0x0
    80004b92:	c14080e7          	jalr	-1004(ra) # 800047a2 <fileclose>
  return -1;
    80004b96:	557d                	li	a0,-1
}
    80004b98:	70a2                	ld	ra,40(sp)
    80004b9a:	7402                	ld	s0,32(sp)
    80004b9c:	64e2                	ld	s1,24(sp)
    80004b9e:	6942                	ld	s2,16(sp)
    80004ba0:	69a2                	ld	s3,8(sp)
    80004ba2:	6a02                	ld	s4,0(sp)
    80004ba4:	6145                	addi	sp,sp,48
    80004ba6:	8082                	ret
  return -1;
    80004ba8:	557d                	li	a0,-1
    80004baa:	b7fd                	j	80004b98 <pipealloc+0xc6>

0000000080004bac <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bac:	1101                	addi	sp,sp,-32
    80004bae:	ec06                	sd	ra,24(sp)
    80004bb0:	e822                	sd	s0,16(sp)
    80004bb2:	e426                	sd	s1,8(sp)
    80004bb4:	e04a                	sd	s2,0(sp)
    80004bb6:	1000                	addi	s0,sp,32
    80004bb8:	84aa                	mv	s1,a0
    80004bba:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bbc:	ffffc097          	auipc	ra,0xffffc
    80004bc0:	01a080e7          	jalr	26(ra) # 80000bd6 <acquire>
  if(writable){
    80004bc4:	02090d63          	beqz	s2,80004bfe <pipeclose+0x52>
    pi->writeopen = 0;
    80004bc8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bcc:	21848513          	addi	a0,s1,536
    80004bd0:	ffffd097          	auipc	ra,0xffffd
    80004bd4:	4f0080e7          	jalr	1264(ra) # 800020c0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bd8:	2204b783          	ld	a5,544(s1)
    80004bdc:	eb95                	bnez	a5,80004c10 <pipeclose+0x64>
    release(&pi->lock);
    80004bde:	8526                	mv	a0,s1
    80004be0:	ffffc097          	auipc	ra,0xffffc
    80004be4:	0aa080e7          	jalr	170(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004be8:	8526                	mv	a0,s1
    80004bea:	ffffc097          	auipc	ra,0xffffc
    80004bee:	dfe080e7          	jalr	-514(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004bf2:	60e2                	ld	ra,24(sp)
    80004bf4:	6442                	ld	s0,16(sp)
    80004bf6:	64a2                	ld	s1,8(sp)
    80004bf8:	6902                	ld	s2,0(sp)
    80004bfa:	6105                	addi	sp,sp,32
    80004bfc:	8082                	ret
    pi->readopen = 0;
    80004bfe:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c02:	21c48513          	addi	a0,s1,540
    80004c06:	ffffd097          	auipc	ra,0xffffd
    80004c0a:	4ba080e7          	jalr	1210(ra) # 800020c0 <wakeup>
    80004c0e:	b7e9                	j	80004bd8 <pipeclose+0x2c>
    release(&pi->lock);
    80004c10:	8526                	mv	a0,s1
    80004c12:	ffffc097          	auipc	ra,0xffffc
    80004c16:	078080e7          	jalr	120(ra) # 80000c8a <release>
}
    80004c1a:	bfe1                	j	80004bf2 <pipeclose+0x46>

0000000080004c1c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c1c:	711d                	addi	sp,sp,-96
    80004c1e:	ec86                	sd	ra,88(sp)
    80004c20:	e8a2                	sd	s0,80(sp)
    80004c22:	e4a6                	sd	s1,72(sp)
    80004c24:	e0ca                	sd	s2,64(sp)
    80004c26:	fc4e                	sd	s3,56(sp)
    80004c28:	f852                	sd	s4,48(sp)
    80004c2a:	f456                	sd	s5,40(sp)
    80004c2c:	f05a                	sd	s6,32(sp)
    80004c2e:	ec5e                	sd	s7,24(sp)
    80004c30:	e862                	sd	s8,16(sp)
    80004c32:	1080                	addi	s0,sp,96
    80004c34:	84aa                	mv	s1,a0
    80004c36:	8aae                	mv	s5,a1
    80004c38:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c3a:	ffffd097          	auipc	ra,0xffffd
    80004c3e:	d7a080e7          	jalr	-646(ra) # 800019b4 <myproc>
    80004c42:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c44:	8526                	mv	a0,s1
    80004c46:	ffffc097          	auipc	ra,0xffffc
    80004c4a:	f90080e7          	jalr	-112(ra) # 80000bd6 <acquire>
  while(i < n){
    80004c4e:	0b405663          	blez	s4,80004cfa <pipewrite+0xde>
  int i = 0;
    80004c52:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c54:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c56:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c5a:	21c48b93          	addi	s7,s1,540
    80004c5e:	a089                	j	80004ca0 <pipewrite+0x84>
      release(&pi->lock);
    80004c60:	8526                	mv	a0,s1
    80004c62:	ffffc097          	auipc	ra,0xffffc
    80004c66:	028080e7          	jalr	40(ra) # 80000c8a <release>
      return -1;
    80004c6a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c6c:	854a                	mv	a0,s2
    80004c6e:	60e6                	ld	ra,88(sp)
    80004c70:	6446                	ld	s0,80(sp)
    80004c72:	64a6                	ld	s1,72(sp)
    80004c74:	6906                	ld	s2,64(sp)
    80004c76:	79e2                	ld	s3,56(sp)
    80004c78:	7a42                	ld	s4,48(sp)
    80004c7a:	7aa2                	ld	s5,40(sp)
    80004c7c:	7b02                	ld	s6,32(sp)
    80004c7e:	6be2                	ld	s7,24(sp)
    80004c80:	6c42                	ld	s8,16(sp)
    80004c82:	6125                	addi	sp,sp,96
    80004c84:	8082                	ret
      wakeup(&pi->nread);
    80004c86:	8562                	mv	a0,s8
    80004c88:	ffffd097          	auipc	ra,0xffffd
    80004c8c:	438080e7          	jalr	1080(ra) # 800020c0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c90:	85a6                	mv	a1,s1
    80004c92:	855e                	mv	a0,s7
    80004c94:	ffffd097          	auipc	ra,0xffffd
    80004c98:	3c8080e7          	jalr	968(ra) # 8000205c <sleep>
  while(i < n){
    80004c9c:	07495063          	bge	s2,s4,80004cfc <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004ca0:	2204a783          	lw	a5,544(s1)
    80004ca4:	dfd5                	beqz	a5,80004c60 <pipewrite+0x44>
    80004ca6:	854e                	mv	a0,s3
    80004ca8:	ffffd097          	auipc	ra,0xffffd
    80004cac:	65c080e7          	jalr	1628(ra) # 80002304 <killed>
    80004cb0:	f945                	bnez	a0,80004c60 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cb2:	2184a783          	lw	a5,536(s1)
    80004cb6:	21c4a703          	lw	a4,540(s1)
    80004cba:	2007879b          	addiw	a5,a5,512
    80004cbe:	fcf704e3          	beq	a4,a5,80004c86 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cc2:	4685                	li	a3,1
    80004cc4:	01590633          	add	a2,s2,s5
    80004cc8:	faf40593          	addi	a1,s0,-81
    80004ccc:	0509b503          	ld	a0,80(s3)
    80004cd0:	ffffd097          	auipc	ra,0xffffd
    80004cd4:	a30080e7          	jalr	-1488(ra) # 80001700 <copyin>
    80004cd8:	03650263          	beq	a0,s6,80004cfc <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cdc:	21c4a783          	lw	a5,540(s1)
    80004ce0:	0017871b          	addiw	a4,a5,1
    80004ce4:	20e4ae23          	sw	a4,540(s1)
    80004ce8:	1ff7f793          	andi	a5,a5,511
    80004cec:	97a6                	add	a5,a5,s1
    80004cee:	faf44703          	lbu	a4,-81(s0)
    80004cf2:	00e78c23          	sb	a4,24(a5)
      i++;
    80004cf6:	2905                	addiw	s2,s2,1
    80004cf8:	b755                	j	80004c9c <pipewrite+0x80>
  int i = 0;
    80004cfa:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004cfc:	21848513          	addi	a0,s1,536
    80004d00:	ffffd097          	auipc	ra,0xffffd
    80004d04:	3c0080e7          	jalr	960(ra) # 800020c0 <wakeup>
  release(&pi->lock);
    80004d08:	8526                	mv	a0,s1
    80004d0a:	ffffc097          	auipc	ra,0xffffc
    80004d0e:	f80080e7          	jalr	-128(ra) # 80000c8a <release>
  return i;
    80004d12:	bfa9                	j	80004c6c <pipewrite+0x50>

0000000080004d14 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d14:	715d                	addi	sp,sp,-80
    80004d16:	e486                	sd	ra,72(sp)
    80004d18:	e0a2                	sd	s0,64(sp)
    80004d1a:	fc26                	sd	s1,56(sp)
    80004d1c:	f84a                	sd	s2,48(sp)
    80004d1e:	f44e                	sd	s3,40(sp)
    80004d20:	f052                	sd	s4,32(sp)
    80004d22:	ec56                	sd	s5,24(sp)
    80004d24:	e85a                	sd	s6,16(sp)
    80004d26:	0880                	addi	s0,sp,80
    80004d28:	84aa                	mv	s1,a0
    80004d2a:	892e                	mv	s2,a1
    80004d2c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d2e:	ffffd097          	auipc	ra,0xffffd
    80004d32:	c86080e7          	jalr	-890(ra) # 800019b4 <myproc>
    80004d36:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d38:	8526                	mv	a0,s1
    80004d3a:	ffffc097          	auipc	ra,0xffffc
    80004d3e:	e9c080e7          	jalr	-356(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d42:	2184a703          	lw	a4,536(s1)
    80004d46:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d4a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d4e:	02f71763          	bne	a4,a5,80004d7c <piperead+0x68>
    80004d52:	2244a783          	lw	a5,548(s1)
    80004d56:	c39d                	beqz	a5,80004d7c <piperead+0x68>
    if(killed(pr)){
    80004d58:	8552                	mv	a0,s4
    80004d5a:	ffffd097          	auipc	ra,0xffffd
    80004d5e:	5aa080e7          	jalr	1450(ra) # 80002304 <killed>
    80004d62:	e949                	bnez	a0,80004df4 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d64:	85a6                	mv	a1,s1
    80004d66:	854e                	mv	a0,s3
    80004d68:	ffffd097          	auipc	ra,0xffffd
    80004d6c:	2f4080e7          	jalr	756(ra) # 8000205c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d70:	2184a703          	lw	a4,536(s1)
    80004d74:	21c4a783          	lw	a5,540(s1)
    80004d78:	fcf70de3          	beq	a4,a5,80004d52 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d7c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d7e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d80:	05505463          	blez	s5,80004dc8 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004d84:	2184a783          	lw	a5,536(s1)
    80004d88:	21c4a703          	lw	a4,540(s1)
    80004d8c:	02f70e63          	beq	a4,a5,80004dc8 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d90:	0017871b          	addiw	a4,a5,1
    80004d94:	20e4ac23          	sw	a4,536(s1)
    80004d98:	1ff7f793          	andi	a5,a5,511
    80004d9c:	97a6                	add	a5,a5,s1
    80004d9e:	0187c783          	lbu	a5,24(a5)
    80004da2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004da6:	4685                	li	a3,1
    80004da8:	fbf40613          	addi	a2,s0,-65
    80004dac:	85ca                	mv	a1,s2
    80004dae:	050a3503          	ld	a0,80(s4)
    80004db2:	ffffd097          	auipc	ra,0xffffd
    80004db6:	8c2080e7          	jalr	-1854(ra) # 80001674 <copyout>
    80004dba:	01650763          	beq	a0,s6,80004dc8 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dbe:	2985                	addiw	s3,s3,1
    80004dc0:	0905                	addi	s2,s2,1
    80004dc2:	fd3a91e3          	bne	s5,s3,80004d84 <piperead+0x70>
    80004dc6:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004dc8:	21c48513          	addi	a0,s1,540
    80004dcc:	ffffd097          	auipc	ra,0xffffd
    80004dd0:	2f4080e7          	jalr	756(ra) # 800020c0 <wakeup>
  release(&pi->lock);
    80004dd4:	8526                	mv	a0,s1
    80004dd6:	ffffc097          	auipc	ra,0xffffc
    80004dda:	eb4080e7          	jalr	-332(ra) # 80000c8a <release>
  return i;
}
    80004dde:	854e                	mv	a0,s3
    80004de0:	60a6                	ld	ra,72(sp)
    80004de2:	6406                	ld	s0,64(sp)
    80004de4:	74e2                	ld	s1,56(sp)
    80004de6:	7942                	ld	s2,48(sp)
    80004de8:	79a2                	ld	s3,40(sp)
    80004dea:	7a02                	ld	s4,32(sp)
    80004dec:	6ae2                	ld	s5,24(sp)
    80004dee:	6b42                	ld	s6,16(sp)
    80004df0:	6161                	addi	sp,sp,80
    80004df2:	8082                	ret
      release(&pi->lock);
    80004df4:	8526                	mv	a0,s1
    80004df6:	ffffc097          	auipc	ra,0xffffc
    80004dfa:	e94080e7          	jalr	-364(ra) # 80000c8a <release>
      return -1;
    80004dfe:	59fd                	li	s3,-1
    80004e00:	bff9                	j	80004dde <piperead+0xca>

0000000080004e02 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e02:	1141                	addi	sp,sp,-16
    80004e04:	e422                	sd	s0,8(sp)
    80004e06:	0800                	addi	s0,sp,16
    80004e08:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e0a:	8905                	andi	a0,a0,1
    80004e0c:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004e0e:	8b89                	andi	a5,a5,2
    80004e10:	c399                	beqz	a5,80004e16 <flags2perm+0x14>
      perm |= PTE_W;
    80004e12:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e16:	6422                	ld	s0,8(sp)
    80004e18:	0141                	addi	sp,sp,16
    80004e1a:	8082                	ret

0000000080004e1c <exec>:

int
exec(char *path, char **argv)
{
    80004e1c:	de010113          	addi	sp,sp,-544
    80004e20:	20113c23          	sd	ra,536(sp)
    80004e24:	20813823          	sd	s0,528(sp)
    80004e28:	20913423          	sd	s1,520(sp)
    80004e2c:	21213023          	sd	s2,512(sp)
    80004e30:	ffce                	sd	s3,504(sp)
    80004e32:	fbd2                	sd	s4,496(sp)
    80004e34:	f7d6                	sd	s5,488(sp)
    80004e36:	f3da                	sd	s6,480(sp)
    80004e38:	efde                	sd	s7,472(sp)
    80004e3a:	ebe2                	sd	s8,464(sp)
    80004e3c:	e7e6                	sd	s9,456(sp)
    80004e3e:	e3ea                	sd	s10,448(sp)
    80004e40:	ff6e                	sd	s11,440(sp)
    80004e42:	1400                	addi	s0,sp,544
    80004e44:	892a                	mv	s2,a0
    80004e46:	dea43423          	sd	a0,-536(s0)
    80004e4a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e4e:	ffffd097          	auipc	ra,0xffffd
    80004e52:	b66080e7          	jalr	-1178(ra) # 800019b4 <myproc>
    80004e56:	84aa                	mv	s1,a0

  begin_op();
    80004e58:	fffff097          	auipc	ra,0xfffff
    80004e5c:	482080e7          	jalr	1154(ra) # 800042da <begin_op>

  if((ip = namei(path)) == 0){
    80004e60:	854a                	mv	a0,s2
    80004e62:	fffff097          	auipc	ra,0xfffff
    80004e66:	258080e7          	jalr	600(ra) # 800040ba <namei>
    80004e6a:	c93d                	beqz	a0,80004ee0 <exec+0xc4>
    80004e6c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e6e:	fffff097          	auipc	ra,0xfffff
    80004e72:	aa0080e7          	jalr	-1376(ra) # 8000390e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e76:	04000713          	li	a4,64
    80004e7a:	4681                	li	a3,0
    80004e7c:	e5040613          	addi	a2,s0,-432
    80004e80:	4581                	li	a1,0
    80004e82:	8556                	mv	a0,s5
    80004e84:	fffff097          	auipc	ra,0xfffff
    80004e88:	d3e080e7          	jalr	-706(ra) # 80003bc2 <readi>
    80004e8c:	04000793          	li	a5,64
    80004e90:	00f51a63          	bne	a0,a5,80004ea4 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004e94:	e5042703          	lw	a4,-432(s0)
    80004e98:	464c47b7          	lui	a5,0x464c4
    80004e9c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ea0:	04f70663          	beq	a4,a5,80004eec <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ea4:	8556                	mv	a0,s5
    80004ea6:	fffff097          	auipc	ra,0xfffff
    80004eaa:	cca080e7          	jalr	-822(ra) # 80003b70 <iunlockput>
    end_op();
    80004eae:	fffff097          	auipc	ra,0xfffff
    80004eb2:	4aa080e7          	jalr	1194(ra) # 80004358 <end_op>
  }
  return -1;
    80004eb6:	557d                	li	a0,-1
}
    80004eb8:	21813083          	ld	ra,536(sp)
    80004ebc:	21013403          	ld	s0,528(sp)
    80004ec0:	20813483          	ld	s1,520(sp)
    80004ec4:	20013903          	ld	s2,512(sp)
    80004ec8:	79fe                	ld	s3,504(sp)
    80004eca:	7a5e                	ld	s4,496(sp)
    80004ecc:	7abe                	ld	s5,488(sp)
    80004ece:	7b1e                	ld	s6,480(sp)
    80004ed0:	6bfe                	ld	s7,472(sp)
    80004ed2:	6c5e                	ld	s8,464(sp)
    80004ed4:	6cbe                	ld	s9,456(sp)
    80004ed6:	6d1e                	ld	s10,448(sp)
    80004ed8:	7dfa                	ld	s11,440(sp)
    80004eda:	22010113          	addi	sp,sp,544
    80004ede:	8082                	ret
    end_op();
    80004ee0:	fffff097          	auipc	ra,0xfffff
    80004ee4:	478080e7          	jalr	1144(ra) # 80004358 <end_op>
    return -1;
    80004ee8:	557d                	li	a0,-1
    80004eea:	b7f9                	j	80004eb8 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004eec:	8526                	mv	a0,s1
    80004eee:	ffffd097          	auipc	ra,0xffffd
    80004ef2:	b8a080e7          	jalr	-1142(ra) # 80001a78 <proc_pagetable>
    80004ef6:	8b2a                	mv	s6,a0
    80004ef8:	d555                	beqz	a0,80004ea4 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004efa:	e7042783          	lw	a5,-400(s0)
    80004efe:	e8845703          	lhu	a4,-376(s0)
    80004f02:	c735                	beqz	a4,80004f6e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f04:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f06:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f0a:	6a05                	lui	s4,0x1
    80004f0c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f10:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f14:	6d85                	lui	s11,0x1
    80004f16:	7d7d                	lui	s10,0xfffff
    80004f18:	ac3d                	j	80005156 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f1a:	00003517          	auipc	a0,0x3
    80004f1e:	7ee50513          	addi	a0,a0,2030 # 80008708 <syscalls+0x2b8>
    80004f22:	ffffb097          	auipc	ra,0xffffb
    80004f26:	61e080e7          	jalr	1566(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f2a:	874a                	mv	a4,s2
    80004f2c:	009c86bb          	addw	a3,s9,s1
    80004f30:	4581                	li	a1,0
    80004f32:	8556                	mv	a0,s5
    80004f34:	fffff097          	auipc	ra,0xfffff
    80004f38:	c8e080e7          	jalr	-882(ra) # 80003bc2 <readi>
    80004f3c:	2501                	sext.w	a0,a0
    80004f3e:	1aa91963          	bne	s2,a0,800050f0 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80004f42:	009d84bb          	addw	s1,s11,s1
    80004f46:	013d09bb          	addw	s3,s10,s3
    80004f4a:	1f74f663          	bgeu	s1,s7,80005136 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80004f4e:	02049593          	slli	a1,s1,0x20
    80004f52:	9181                	srli	a1,a1,0x20
    80004f54:	95e2                	add	a1,a1,s8
    80004f56:	855a                	mv	a0,s6
    80004f58:	ffffc097          	auipc	ra,0xffffc
    80004f5c:	10c080e7          	jalr	268(ra) # 80001064 <walkaddr>
    80004f60:	862a                	mv	a2,a0
    if(pa == 0)
    80004f62:	dd45                	beqz	a0,80004f1a <exec+0xfe>
      n = PGSIZE;
    80004f64:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f66:	fd49f2e3          	bgeu	s3,s4,80004f2a <exec+0x10e>
      n = sz - i;
    80004f6a:	894e                	mv	s2,s3
    80004f6c:	bf7d                	j	80004f2a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f6e:	4901                	li	s2,0
  iunlockput(ip);
    80004f70:	8556                	mv	a0,s5
    80004f72:	fffff097          	auipc	ra,0xfffff
    80004f76:	bfe080e7          	jalr	-1026(ra) # 80003b70 <iunlockput>
  end_op();
    80004f7a:	fffff097          	auipc	ra,0xfffff
    80004f7e:	3de080e7          	jalr	990(ra) # 80004358 <end_op>
  p = myproc();
    80004f82:	ffffd097          	auipc	ra,0xffffd
    80004f86:	a32080e7          	jalr	-1486(ra) # 800019b4 <myproc>
    80004f8a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004f8c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f90:	6785                	lui	a5,0x1
    80004f92:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004f94:	97ca                	add	a5,a5,s2
    80004f96:	777d                	lui	a4,0xfffff
    80004f98:	8ff9                	and	a5,a5,a4
    80004f9a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f9e:	4691                	li	a3,4
    80004fa0:	6609                	lui	a2,0x2
    80004fa2:	963e                	add	a2,a2,a5
    80004fa4:	85be                	mv	a1,a5
    80004fa6:	855a                	mv	a0,s6
    80004fa8:	ffffc097          	auipc	ra,0xffffc
    80004fac:	470080e7          	jalr	1136(ra) # 80001418 <uvmalloc>
    80004fb0:	8c2a                	mv	s8,a0
  ip = 0;
    80004fb2:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fb4:	12050e63          	beqz	a0,800050f0 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fb8:	75f9                	lui	a1,0xffffe
    80004fba:	95aa                	add	a1,a1,a0
    80004fbc:	855a                	mv	a0,s6
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	684080e7          	jalr	1668(ra) # 80001642 <uvmclear>
  stackbase = sp - PGSIZE;
    80004fc6:	7afd                	lui	s5,0xfffff
    80004fc8:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004fca:	df043783          	ld	a5,-528(s0)
    80004fce:	6388                	ld	a0,0(a5)
    80004fd0:	c925                	beqz	a0,80005040 <exec+0x224>
    80004fd2:	e9040993          	addi	s3,s0,-368
    80004fd6:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004fda:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004fdc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fde:	ffffc097          	auipc	ra,0xffffc
    80004fe2:	e70080e7          	jalr	-400(ra) # 80000e4e <strlen>
    80004fe6:	0015079b          	addiw	a5,a0,1
    80004fea:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fee:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ff2:	13596663          	bltu	s2,s5,8000511e <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ff6:	df043d83          	ld	s11,-528(s0)
    80004ffa:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004ffe:	8552                	mv	a0,s4
    80005000:	ffffc097          	auipc	ra,0xffffc
    80005004:	e4e080e7          	jalr	-434(ra) # 80000e4e <strlen>
    80005008:	0015069b          	addiw	a3,a0,1
    8000500c:	8652                	mv	a2,s4
    8000500e:	85ca                	mv	a1,s2
    80005010:	855a                	mv	a0,s6
    80005012:	ffffc097          	auipc	ra,0xffffc
    80005016:	662080e7          	jalr	1634(ra) # 80001674 <copyout>
    8000501a:	10054663          	bltz	a0,80005126 <exec+0x30a>
    ustack[argc] = sp;
    8000501e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005022:	0485                	addi	s1,s1,1
    80005024:	008d8793          	addi	a5,s11,8
    80005028:	def43823          	sd	a5,-528(s0)
    8000502c:	008db503          	ld	a0,8(s11)
    80005030:	c911                	beqz	a0,80005044 <exec+0x228>
    if(argc >= MAXARG)
    80005032:	09a1                	addi	s3,s3,8
    80005034:	fb3c95e3          	bne	s9,s3,80004fde <exec+0x1c2>
  sz = sz1;
    80005038:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000503c:	4a81                	li	s5,0
    8000503e:	a84d                	j	800050f0 <exec+0x2d4>
  sp = sz;
    80005040:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005042:	4481                	li	s1,0
  ustack[argc] = 0;
    80005044:	00349793          	slli	a5,s1,0x3
    80005048:	f9078793          	addi	a5,a5,-112
    8000504c:	97a2                	add	a5,a5,s0
    8000504e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005052:	00148693          	addi	a3,s1,1
    80005056:	068e                	slli	a3,a3,0x3
    80005058:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000505c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005060:	01597663          	bgeu	s2,s5,8000506c <exec+0x250>
  sz = sz1;
    80005064:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005068:	4a81                	li	s5,0
    8000506a:	a059                	j	800050f0 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000506c:	e9040613          	addi	a2,s0,-368
    80005070:	85ca                	mv	a1,s2
    80005072:	855a                	mv	a0,s6
    80005074:	ffffc097          	auipc	ra,0xffffc
    80005078:	600080e7          	jalr	1536(ra) # 80001674 <copyout>
    8000507c:	0a054963          	bltz	a0,8000512e <exec+0x312>
  p->trapframe->a1 = sp;
    80005080:	058bb783          	ld	a5,88(s7)
    80005084:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005088:	de843783          	ld	a5,-536(s0)
    8000508c:	0007c703          	lbu	a4,0(a5)
    80005090:	cf11                	beqz	a4,800050ac <exec+0x290>
    80005092:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005094:	02f00693          	li	a3,47
    80005098:	a039                	j	800050a6 <exec+0x28a>
      last = s+1;
    8000509a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000509e:	0785                	addi	a5,a5,1
    800050a0:	fff7c703          	lbu	a4,-1(a5)
    800050a4:	c701                	beqz	a4,800050ac <exec+0x290>
    if(*s == '/')
    800050a6:	fed71ce3          	bne	a4,a3,8000509e <exec+0x282>
    800050aa:	bfc5                	j	8000509a <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800050ac:	4641                	li	a2,16
    800050ae:	de843583          	ld	a1,-536(s0)
    800050b2:	158b8513          	addi	a0,s7,344
    800050b6:	ffffc097          	auipc	ra,0xffffc
    800050ba:	d66080e7          	jalr	-666(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800050be:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800050c2:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800050c6:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050ca:	058bb783          	ld	a5,88(s7)
    800050ce:	e6843703          	ld	a4,-408(s0)
    800050d2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050d4:	058bb783          	ld	a5,88(s7)
    800050d8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050dc:	85ea                	mv	a1,s10
    800050de:	ffffd097          	auipc	ra,0xffffd
    800050e2:	a36080e7          	jalr	-1482(ra) # 80001b14 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050e6:	0004851b          	sext.w	a0,s1
    800050ea:	b3f9                	j	80004eb8 <exec+0x9c>
    800050ec:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800050f0:	df843583          	ld	a1,-520(s0)
    800050f4:	855a                	mv	a0,s6
    800050f6:	ffffd097          	auipc	ra,0xffffd
    800050fa:	a1e080e7          	jalr	-1506(ra) # 80001b14 <proc_freepagetable>
  if(ip){
    800050fe:	da0a93e3          	bnez	s5,80004ea4 <exec+0x88>
  return -1;
    80005102:	557d                	li	a0,-1
    80005104:	bb55                	j	80004eb8 <exec+0x9c>
    80005106:	df243c23          	sd	s2,-520(s0)
    8000510a:	b7dd                	j	800050f0 <exec+0x2d4>
    8000510c:	df243c23          	sd	s2,-520(s0)
    80005110:	b7c5                	j	800050f0 <exec+0x2d4>
    80005112:	df243c23          	sd	s2,-520(s0)
    80005116:	bfe9                	j	800050f0 <exec+0x2d4>
    80005118:	df243c23          	sd	s2,-520(s0)
    8000511c:	bfd1                	j	800050f0 <exec+0x2d4>
  sz = sz1;
    8000511e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005122:	4a81                	li	s5,0
    80005124:	b7f1                	j	800050f0 <exec+0x2d4>
  sz = sz1;
    80005126:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000512a:	4a81                	li	s5,0
    8000512c:	b7d1                	j	800050f0 <exec+0x2d4>
  sz = sz1;
    8000512e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005132:	4a81                	li	s5,0
    80005134:	bf75                	j	800050f0 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005136:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000513a:	e0843783          	ld	a5,-504(s0)
    8000513e:	0017869b          	addiw	a3,a5,1
    80005142:	e0d43423          	sd	a3,-504(s0)
    80005146:	e0043783          	ld	a5,-512(s0)
    8000514a:	0387879b          	addiw	a5,a5,56
    8000514e:	e8845703          	lhu	a4,-376(s0)
    80005152:	e0e6dfe3          	bge	a3,a4,80004f70 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005156:	2781                	sext.w	a5,a5
    80005158:	e0f43023          	sd	a5,-512(s0)
    8000515c:	03800713          	li	a4,56
    80005160:	86be                	mv	a3,a5
    80005162:	e1840613          	addi	a2,s0,-488
    80005166:	4581                	li	a1,0
    80005168:	8556                	mv	a0,s5
    8000516a:	fffff097          	auipc	ra,0xfffff
    8000516e:	a58080e7          	jalr	-1448(ra) # 80003bc2 <readi>
    80005172:	03800793          	li	a5,56
    80005176:	f6f51be3          	bne	a0,a5,800050ec <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    8000517a:	e1842783          	lw	a5,-488(s0)
    8000517e:	4705                	li	a4,1
    80005180:	fae79de3          	bne	a5,a4,8000513a <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005184:	e4043483          	ld	s1,-448(s0)
    80005188:	e3843783          	ld	a5,-456(s0)
    8000518c:	f6f4ede3          	bltu	s1,a5,80005106 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005190:	e2843783          	ld	a5,-472(s0)
    80005194:	94be                	add	s1,s1,a5
    80005196:	f6f4ebe3          	bltu	s1,a5,8000510c <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    8000519a:	de043703          	ld	a4,-544(s0)
    8000519e:	8ff9                	and	a5,a5,a4
    800051a0:	fbad                	bnez	a5,80005112 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051a2:	e1c42503          	lw	a0,-484(s0)
    800051a6:	00000097          	auipc	ra,0x0
    800051aa:	c5c080e7          	jalr	-932(ra) # 80004e02 <flags2perm>
    800051ae:	86aa                	mv	a3,a0
    800051b0:	8626                	mv	a2,s1
    800051b2:	85ca                	mv	a1,s2
    800051b4:	855a                	mv	a0,s6
    800051b6:	ffffc097          	auipc	ra,0xffffc
    800051ba:	262080e7          	jalr	610(ra) # 80001418 <uvmalloc>
    800051be:	dea43c23          	sd	a0,-520(s0)
    800051c2:	d939                	beqz	a0,80005118 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051c4:	e2843c03          	ld	s8,-472(s0)
    800051c8:	e2042c83          	lw	s9,-480(s0)
    800051cc:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051d0:	f60b83e3          	beqz	s7,80005136 <exec+0x31a>
    800051d4:	89de                	mv	s3,s7
    800051d6:	4481                	li	s1,0
    800051d8:	bb9d                	j	80004f4e <exec+0x132>

00000000800051da <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051da:	7179                	addi	sp,sp,-48
    800051dc:	f406                	sd	ra,40(sp)
    800051de:	f022                	sd	s0,32(sp)
    800051e0:	ec26                	sd	s1,24(sp)
    800051e2:	e84a                	sd	s2,16(sp)
    800051e4:	1800                	addi	s0,sp,48
    800051e6:	892e                	mv	s2,a1
    800051e8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800051ea:	fdc40593          	addi	a1,s0,-36
    800051ee:	ffffe097          	auipc	ra,0xffffe
    800051f2:	8dc080e7          	jalr	-1828(ra) # 80002aca <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051f6:	fdc42703          	lw	a4,-36(s0)
    800051fa:	47bd                	li	a5,15
    800051fc:	02e7eb63          	bltu	a5,a4,80005232 <argfd+0x58>
    80005200:	ffffc097          	auipc	ra,0xffffc
    80005204:	7b4080e7          	jalr	1972(ra) # 800019b4 <myproc>
    80005208:	fdc42703          	lw	a4,-36(s0)
    8000520c:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdcf5a>
    80005210:	078e                	slli	a5,a5,0x3
    80005212:	953e                	add	a0,a0,a5
    80005214:	611c                	ld	a5,0(a0)
    80005216:	c385                	beqz	a5,80005236 <argfd+0x5c>
    return -1;
  if(pfd)
    80005218:	00090463          	beqz	s2,80005220 <argfd+0x46>
    *pfd = fd;
    8000521c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005220:	4501                	li	a0,0
  if(pf)
    80005222:	c091                	beqz	s1,80005226 <argfd+0x4c>
    *pf = f;
    80005224:	e09c                	sd	a5,0(s1)
}
    80005226:	70a2                	ld	ra,40(sp)
    80005228:	7402                	ld	s0,32(sp)
    8000522a:	64e2                	ld	s1,24(sp)
    8000522c:	6942                	ld	s2,16(sp)
    8000522e:	6145                	addi	sp,sp,48
    80005230:	8082                	ret
    return -1;
    80005232:	557d                	li	a0,-1
    80005234:	bfcd                	j	80005226 <argfd+0x4c>
    80005236:	557d                	li	a0,-1
    80005238:	b7fd                	j	80005226 <argfd+0x4c>

000000008000523a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000523a:	1101                	addi	sp,sp,-32
    8000523c:	ec06                	sd	ra,24(sp)
    8000523e:	e822                	sd	s0,16(sp)
    80005240:	e426                	sd	s1,8(sp)
    80005242:	1000                	addi	s0,sp,32
    80005244:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005246:	ffffc097          	auipc	ra,0xffffc
    8000524a:	76e080e7          	jalr	1902(ra) # 800019b4 <myproc>
    8000524e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005250:	0d050793          	addi	a5,a0,208
    80005254:	4501                	li	a0,0
    80005256:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005258:	6398                	ld	a4,0(a5)
    8000525a:	cb19                	beqz	a4,80005270 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000525c:	2505                	addiw	a0,a0,1
    8000525e:	07a1                	addi	a5,a5,8
    80005260:	fed51ce3          	bne	a0,a3,80005258 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005264:	557d                	li	a0,-1
}
    80005266:	60e2                	ld	ra,24(sp)
    80005268:	6442                	ld	s0,16(sp)
    8000526a:	64a2                	ld	s1,8(sp)
    8000526c:	6105                	addi	sp,sp,32
    8000526e:	8082                	ret
      p->ofile[fd] = f;
    80005270:	01a50793          	addi	a5,a0,26
    80005274:	078e                	slli	a5,a5,0x3
    80005276:	963e                	add	a2,a2,a5
    80005278:	e204                	sd	s1,0(a2)
      return fd;
    8000527a:	b7f5                	j	80005266 <fdalloc+0x2c>

000000008000527c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000527c:	715d                	addi	sp,sp,-80
    8000527e:	e486                	sd	ra,72(sp)
    80005280:	e0a2                	sd	s0,64(sp)
    80005282:	fc26                	sd	s1,56(sp)
    80005284:	f84a                	sd	s2,48(sp)
    80005286:	f44e                	sd	s3,40(sp)
    80005288:	f052                	sd	s4,32(sp)
    8000528a:	ec56                	sd	s5,24(sp)
    8000528c:	e85a                	sd	s6,16(sp)
    8000528e:	0880                	addi	s0,sp,80
    80005290:	8b2e                	mv	s6,a1
    80005292:	89b2                	mv	s3,a2
    80005294:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005296:	fb040593          	addi	a1,s0,-80
    8000529a:	fffff097          	auipc	ra,0xfffff
    8000529e:	e3e080e7          	jalr	-450(ra) # 800040d8 <nameiparent>
    800052a2:	84aa                	mv	s1,a0
    800052a4:	14050f63          	beqz	a0,80005402 <create+0x186>
    return 0;

  ilock(dp);
    800052a8:	ffffe097          	auipc	ra,0xffffe
    800052ac:	666080e7          	jalr	1638(ra) # 8000390e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052b0:	4601                	li	a2,0
    800052b2:	fb040593          	addi	a1,s0,-80
    800052b6:	8526                	mv	a0,s1
    800052b8:	fffff097          	auipc	ra,0xfffff
    800052bc:	b3a080e7          	jalr	-1222(ra) # 80003df2 <dirlookup>
    800052c0:	8aaa                	mv	s5,a0
    800052c2:	c931                	beqz	a0,80005316 <create+0x9a>
    iunlockput(dp);
    800052c4:	8526                	mv	a0,s1
    800052c6:	fffff097          	auipc	ra,0xfffff
    800052ca:	8aa080e7          	jalr	-1878(ra) # 80003b70 <iunlockput>
    ilock(ip);
    800052ce:	8556                	mv	a0,s5
    800052d0:	ffffe097          	auipc	ra,0xffffe
    800052d4:	63e080e7          	jalr	1598(ra) # 8000390e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052d8:	000b059b          	sext.w	a1,s6
    800052dc:	4789                	li	a5,2
    800052de:	02f59563          	bne	a1,a5,80005308 <create+0x8c>
    800052e2:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdcf84>
    800052e6:	37f9                	addiw	a5,a5,-2
    800052e8:	17c2                	slli	a5,a5,0x30
    800052ea:	93c1                	srli	a5,a5,0x30
    800052ec:	4705                	li	a4,1
    800052ee:	00f76d63          	bltu	a4,a5,80005308 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800052f2:	8556                	mv	a0,s5
    800052f4:	60a6                	ld	ra,72(sp)
    800052f6:	6406                	ld	s0,64(sp)
    800052f8:	74e2                	ld	s1,56(sp)
    800052fa:	7942                	ld	s2,48(sp)
    800052fc:	79a2                	ld	s3,40(sp)
    800052fe:	7a02                	ld	s4,32(sp)
    80005300:	6ae2                	ld	s5,24(sp)
    80005302:	6b42                	ld	s6,16(sp)
    80005304:	6161                	addi	sp,sp,80
    80005306:	8082                	ret
    iunlockput(ip);
    80005308:	8556                	mv	a0,s5
    8000530a:	fffff097          	auipc	ra,0xfffff
    8000530e:	866080e7          	jalr	-1946(ra) # 80003b70 <iunlockput>
    return 0;
    80005312:	4a81                	li	s5,0
    80005314:	bff9                	j	800052f2 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005316:	85da                	mv	a1,s6
    80005318:	4088                	lw	a0,0(s1)
    8000531a:	ffffe097          	auipc	ra,0xffffe
    8000531e:	456080e7          	jalr	1110(ra) # 80003770 <ialloc>
    80005322:	8a2a                	mv	s4,a0
    80005324:	c539                	beqz	a0,80005372 <create+0xf6>
  ilock(ip);
    80005326:	ffffe097          	auipc	ra,0xffffe
    8000532a:	5e8080e7          	jalr	1512(ra) # 8000390e <ilock>
  ip->major = major;
    8000532e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005332:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005336:	4905                	li	s2,1
    80005338:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000533c:	8552                	mv	a0,s4
    8000533e:	ffffe097          	auipc	ra,0xffffe
    80005342:	504080e7          	jalr	1284(ra) # 80003842 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005346:	000b059b          	sext.w	a1,s6
    8000534a:	03258b63          	beq	a1,s2,80005380 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000534e:	004a2603          	lw	a2,4(s4)
    80005352:	fb040593          	addi	a1,s0,-80
    80005356:	8526                	mv	a0,s1
    80005358:	fffff097          	auipc	ra,0xfffff
    8000535c:	cb0080e7          	jalr	-848(ra) # 80004008 <dirlink>
    80005360:	06054f63          	bltz	a0,800053de <create+0x162>
  iunlockput(dp);
    80005364:	8526                	mv	a0,s1
    80005366:	fffff097          	auipc	ra,0xfffff
    8000536a:	80a080e7          	jalr	-2038(ra) # 80003b70 <iunlockput>
  return ip;
    8000536e:	8ad2                	mv	s5,s4
    80005370:	b749                	j	800052f2 <create+0x76>
    iunlockput(dp);
    80005372:	8526                	mv	a0,s1
    80005374:	ffffe097          	auipc	ra,0xffffe
    80005378:	7fc080e7          	jalr	2044(ra) # 80003b70 <iunlockput>
    return 0;
    8000537c:	8ad2                	mv	s5,s4
    8000537e:	bf95                	j	800052f2 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005380:	004a2603          	lw	a2,4(s4)
    80005384:	00003597          	auipc	a1,0x3
    80005388:	3a458593          	addi	a1,a1,932 # 80008728 <syscalls+0x2d8>
    8000538c:	8552                	mv	a0,s4
    8000538e:	fffff097          	auipc	ra,0xfffff
    80005392:	c7a080e7          	jalr	-902(ra) # 80004008 <dirlink>
    80005396:	04054463          	bltz	a0,800053de <create+0x162>
    8000539a:	40d0                	lw	a2,4(s1)
    8000539c:	00003597          	auipc	a1,0x3
    800053a0:	39458593          	addi	a1,a1,916 # 80008730 <syscalls+0x2e0>
    800053a4:	8552                	mv	a0,s4
    800053a6:	fffff097          	auipc	ra,0xfffff
    800053aa:	c62080e7          	jalr	-926(ra) # 80004008 <dirlink>
    800053ae:	02054863          	bltz	a0,800053de <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800053b2:	004a2603          	lw	a2,4(s4)
    800053b6:	fb040593          	addi	a1,s0,-80
    800053ba:	8526                	mv	a0,s1
    800053bc:	fffff097          	auipc	ra,0xfffff
    800053c0:	c4c080e7          	jalr	-948(ra) # 80004008 <dirlink>
    800053c4:	00054d63          	bltz	a0,800053de <create+0x162>
    dp->nlink++;  // for ".."
    800053c8:	04a4d783          	lhu	a5,74(s1)
    800053cc:	2785                	addiw	a5,a5,1
    800053ce:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800053d2:	8526                	mv	a0,s1
    800053d4:	ffffe097          	auipc	ra,0xffffe
    800053d8:	46e080e7          	jalr	1134(ra) # 80003842 <iupdate>
    800053dc:	b761                	j	80005364 <create+0xe8>
  ip->nlink = 0;
    800053de:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800053e2:	8552                	mv	a0,s4
    800053e4:	ffffe097          	auipc	ra,0xffffe
    800053e8:	45e080e7          	jalr	1118(ra) # 80003842 <iupdate>
  iunlockput(ip);
    800053ec:	8552                	mv	a0,s4
    800053ee:	ffffe097          	auipc	ra,0xffffe
    800053f2:	782080e7          	jalr	1922(ra) # 80003b70 <iunlockput>
  iunlockput(dp);
    800053f6:	8526                	mv	a0,s1
    800053f8:	ffffe097          	auipc	ra,0xffffe
    800053fc:	778080e7          	jalr	1912(ra) # 80003b70 <iunlockput>
  return 0;
    80005400:	bdcd                	j	800052f2 <create+0x76>
    return 0;
    80005402:	8aaa                	mv	s5,a0
    80005404:	b5fd                	j	800052f2 <create+0x76>

0000000080005406 <sys_dup>:
{
    80005406:	7179                	addi	sp,sp,-48
    80005408:	f406                	sd	ra,40(sp)
    8000540a:	f022                	sd	s0,32(sp)
    8000540c:	ec26                	sd	s1,24(sp)
    8000540e:	e84a                	sd	s2,16(sp)
    80005410:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005412:	fd840613          	addi	a2,s0,-40
    80005416:	4581                	li	a1,0
    80005418:	4501                	li	a0,0
    8000541a:	00000097          	auipc	ra,0x0
    8000541e:	dc0080e7          	jalr	-576(ra) # 800051da <argfd>
    return -1;
    80005422:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005424:	02054363          	bltz	a0,8000544a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005428:	fd843903          	ld	s2,-40(s0)
    8000542c:	854a                	mv	a0,s2
    8000542e:	00000097          	auipc	ra,0x0
    80005432:	e0c080e7          	jalr	-500(ra) # 8000523a <fdalloc>
    80005436:	84aa                	mv	s1,a0
    return -1;
    80005438:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000543a:	00054863          	bltz	a0,8000544a <sys_dup+0x44>
  filedup(f);
    8000543e:	854a                	mv	a0,s2
    80005440:	fffff097          	auipc	ra,0xfffff
    80005444:	310080e7          	jalr	784(ra) # 80004750 <filedup>
  return fd;
    80005448:	87a6                	mv	a5,s1
}
    8000544a:	853e                	mv	a0,a5
    8000544c:	70a2                	ld	ra,40(sp)
    8000544e:	7402                	ld	s0,32(sp)
    80005450:	64e2                	ld	s1,24(sp)
    80005452:	6942                	ld	s2,16(sp)
    80005454:	6145                	addi	sp,sp,48
    80005456:	8082                	ret

0000000080005458 <sys_read>:
{
    80005458:	7179                	addi	sp,sp,-48
    8000545a:	f406                	sd	ra,40(sp)
    8000545c:	f022                	sd	s0,32(sp)
    8000545e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005460:	fd840593          	addi	a1,s0,-40
    80005464:	4505                	li	a0,1
    80005466:	ffffd097          	auipc	ra,0xffffd
    8000546a:	684080e7          	jalr	1668(ra) # 80002aea <argaddr>
  argint(2, &n);
    8000546e:	fe440593          	addi	a1,s0,-28
    80005472:	4509                	li	a0,2
    80005474:	ffffd097          	auipc	ra,0xffffd
    80005478:	656080e7          	jalr	1622(ra) # 80002aca <argint>
  if(argfd(0, 0, &f) < 0)
    8000547c:	fe840613          	addi	a2,s0,-24
    80005480:	4581                	li	a1,0
    80005482:	4501                	li	a0,0
    80005484:	00000097          	auipc	ra,0x0
    80005488:	d56080e7          	jalr	-682(ra) # 800051da <argfd>
    8000548c:	87aa                	mv	a5,a0
    return -1;
    8000548e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005490:	0007cc63          	bltz	a5,800054a8 <sys_read+0x50>
  return fileread(f, p, n);
    80005494:	fe442603          	lw	a2,-28(s0)
    80005498:	fd843583          	ld	a1,-40(s0)
    8000549c:	fe843503          	ld	a0,-24(s0)
    800054a0:	fffff097          	auipc	ra,0xfffff
    800054a4:	43c080e7          	jalr	1084(ra) # 800048dc <fileread>
}
    800054a8:	70a2                	ld	ra,40(sp)
    800054aa:	7402                	ld	s0,32(sp)
    800054ac:	6145                	addi	sp,sp,48
    800054ae:	8082                	ret

00000000800054b0 <sys_write>:
{
    800054b0:	7179                	addi	sp,sp,-48
    800054b2:	f406                	sd	ra,40(sp)
    800054b4:	f022                	sd	s0,32(sp)
    800054b6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054b8:	fd840593          	addi	a1,s0,-40
    800054bc:	4505                	li	a0,1
    800054be:	ffffd097          	auipc	ra,0xffffd
    800054c2:	62c080e7          	jalr	1580(ra) # 80002aea <argaddr>
  argint(2, &n);
    800054c6:	fe440593          	addi	a1,s0,-28
    800054ca:	4509                	li	a0,2
    800054cc:	ffffd097          	auipc	ra,0xffffd
    800054d0:	5fe080e7          	jalr	1534(ra) # 80002aca <argint>
  if(argfd(0, 0, &f) < 0)
    800054d4:	fe840613          	addi	a2,s0,-24
    800054d8:	4581                	li	a1,0
    800054da:	4501                	li	a0,0
    800054dc:	00000097          	auipc	ra,0x0
    800054e0:	cfe080e7          	jalr	-770(ra) # 800051da <argfd>
    800054e4:	87aa                	mv	a5,a0
    return -1;
    800054e6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054e8:	0007cc63          	bltz	a5,80005500 <sys_write+0x50>
  return filewrite(f, p, n);
    800054ec:	fe442603          	lw	a2,-28(s0)
    800054f0:	fd843583          	ld	a1,-40(s0)
    800054f4:	fe843503          	ld	a0,-24(s0)
    800054f8:	fffff097          	auipc	ra,0xfffff
    800054fc:	4a6080e7          	jalr	1190(ra) # 8000499e <filewrite>
}
    80005500:	70a2                	ld	ra,40(sp)
    80005502:	7402                	ld	s0,32(sp)
    80005504:	6145                	addi	sp,sp,48
    80005506:	8082                	ret

0000000080005508 <sys_close>:
{
    80005508:	1101                	addi	sp,sp,-32
    8000550a:	ec06                	sd	ra,24(sp)
    8000550c:	e822                	sd	s0,16(sp)
    8000550e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005510:	fe040613          	addi	a2,s0,-32
    80005514:	fec40593          	addi	a1,s0,-20
    80005518:	4501                	li	a0,0
    8000551a:	00000097          	auipc	ra,0x0
    8000551e:	cc0080e7          	jalr	-832(ra) # 800051da <argfd>
    return -1;
    80005522:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005524:	02054463          	bltz	a0,8000554c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005528:	ffffc097          	auipc	ra,0xffffc
    8000552c:	48c080e7          	jalr	1164(ra) # 800019b4 <myproc>
    80005530:	fec42783          	lw	a5,-20(s0)
    80005534:	07e9                	addi	a5,a5,26
    80005536:	078e                	slli	a5,a5,0x3
    80005538:	953e                	add	a0,a0,a5
    8000553a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000553e:	fe043503          	ld	a0,-32(s0)
    80005542:	fffff097          	auipc	ra,0xfffff
    80005546:	260080e7          	jalr	608(ra) # 800047a2 <fileclose>
  return 0;
    8000554a:	4781                	li	a5,0
}
    8000554c:	853e                	mv	a0,a5
    8000554e:	60e2                	ld	ra,24(sp)
    80005550:	6442                	ld	s0,16(sp)
    80005552:	6105                	addi	sp,sp,32
    80005554:	8082                	ret

0000000080005556 <sys_fstat>:
{
    80005556:	1101                	addi	sp,sp,-32
    80005558:	ec06                	sd	ra,24(sp)
    8000555a:	e822                	sd	s0,16(sp)
    8000555c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000555e:	fe040593          	addi	a1,s0,-32
    80005562:	4505                	li	a0,1
    80005564:	ffffd097          	auipc	ra,0xffffd
    80005568:	586080e7          	jalr	1414(ra) # 80002aea <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000556c:	fe840613          	addi	a2,s0,-24
    80005570:	4581                	li	a1,0
    80005572:	4501                	li	a0,0
    80005574:	00000097          	auipc	ra,0x0
    80005578:	c66080e7          	jalr	-922(ra) # 800051da <argfd>
    8000557c:	87aa                	mv	a5,a0
    return -1;
    8000557e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005580:	0007ca63          	bltz	a5,80005594 <sys_fstat+0x3e>
  return filestat(f, st);
    80005584:	fe043583          	ld	a1,-32(s0)
    80005588:	fe843503          	ld	a0,-24(s0)
    8000558c:	fffff097          	auipc	ra,0xfffff
    80005590:	2de080e7          	jalr	734(ra) # 8000486a <filestat>
}
    80005594:	60e2                	ld	ra,24(sp)
    80005596:	6442                	ld	s0,16(sp)
    80005598:	6105                	addi	sp,sp,32
    8000559a:	8082                	ret

000000008000559c <sys_link>:
{
    8000559c:	7169                	addi	sp,sp,-304
    8000559e:	f606                	sd	ra,296(sp)
    800055a0:	f222                	sd	s0,288(sp)
    800055a2:	ee26                	sd	s1,280(sp)
    800055a4:	ea4a                	sd	s2,272(sp)
    800055a6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055a8:	08000613          	li	a2,128
    800055ac:	ed040593          	addi	a1,s0,-304
    800055b0:	4501                	li	a0,0
    800055b2:	ffffd097          	auipc	ra,0xffffd
    800055b6:	558080e7          	jalr	1368(ra) # 80002b0a <argstr>
    return -1;
    800055ba:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055bc:	10054e63          	bltz	a0,800056d8 <sys_link+0x13c>
    800055c0:	08000613          	li	a2,128
    800055c4:	f5040593          	addi	a1,s0,-176
    800055c8:	4505                	li	a0,1
    800055ca:	ffffd097          	auipc	ra,0xffffd
    800055ce:	540080e7          	jalr	1344(ra) # 80002b0a <argstr>
    return -1;
    800055d2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055d4:	10054263          	bltz	a0,800056d8 <sys_link+0x13c>
  begin_op();
    800055d8:	fffff097          	auipc	ra,0xfffff
    800055dc:	d02080e7          	jalr	-766(ra) # 800042da <begin_op>
  if((ip = namei(old)) == 0){
    800055e0:	ed040513          	addi	a0,s0,-304
    800055e4:	fffff097          	auipc	ra,0xfffff
    800055e8:	ad6080e7          	jalr	-1322(ra) # 800040ba <namei>
    800055ec:	84aa                	mv	s1,a0
    800055ee:	c551                	beqz	a0,8000567a <sys_link+0xde>
  ilock(ip);
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	31e080e7          	jalr	798(ra) # 8000390e <ilock>
  if(ip->type == T_DIR){
    800055f8:	04449703          	lh	a4,68(s1)
    800055fc:	4785                	li	a5,1
    800055fe:	08f70463          	beq	a4,a5,80005686 <sys_link+0xea>
  ip->nlink++;
    80005602:	04a4d783          	lhu	a5,74(s1)
    80005606:	2785                	addiw	a5,a5,1
    80005608:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000560c:	8526                	mv	a0,s1
    8000560e:	ffffe097          	auipc	ra,0xffffe
    80005612:	234080e7          	jalr	564(ra) # 80003842 <iupdate>
  iunlock(ip);
    80005616:	8526                	mv	a0,s1
    80005618:	ffffe097          	auipc	ra,0xffffe
    8000561c:	3b8080e7          	jalr	952(ra) # 800039d0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005620:	fd040593          	addi	a1,s0,-48
    80005624:	f5040513          	addi	a0,s0,-176
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	ab0080e7          	jalr	-1360(ra) # 800040d8 <nameiparent>
    80005630:	892a                	mv	s2,a0
    80005632:	c935                	beqz	a0,800056a6 <sys_link+0x10a>
  ilock(dp);
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	2da080e7          	jalr	730(ra) # 8000390e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000563c:	00092703          	lw	a4,0(s2)
    80005640:	409c                	lw	a5,0(s1)
    80005642:	04f71d63          	bne	a4,a5,8000569c <sys_link+0x100>
    80005646:	40d0                	lw	a2,4(s1)
    80005648:	fd040593          	addi	a1,s0,-48
    8000564c:	854a                	mv	a0,s2
    8000564e:	fffff097          	auipc	ra,0xfffff
    80005652:	9ba080e7          	jalr	-1606(ra) # 80004008 <dirlink>
    80005656:	04054363          	bltz	a0,8000569c <sys_link+0x100>
  iunlockput(dp);
    8000565a:	854a                	mv	a0,s2
    8000565c:	ffffe097          	auipc	ra,0xffffe
    80005660:	514080e7          	jalr	1300(ra) # 80003b70 <iunlockput>
  iput(ip);
    80005664:	8526                	mv	a0,s1
    80005666:	ffffe097          	auipc	ra,0xffffe
    8000566a:	462080e7          	jalr	1122(ra) # 80003ac8 <iput>
  end_op();
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	cea080e7          	jalr	-790(ra) # 80004358 <end_op>
  return 0;
    80005676:	4781                	li	a5,0
    80005678:	a085                	j	800056d8 <sys_link+0x13c>
    end_op();
    8000567a:	fffff097          	auipc	ra,0xfffff
    8000567e:	cde080e7          	jalr	-802(ra) # 80004358 <end_op>
    return -1;
    80005682:	57fd                	li	a5,-1
    80005684:	a891                	j	800056d8 <sys_link+0x13c>
    iunlockput(ip);
    80005686:	8526                	mv	a0,s1
    80005688:	ffffe097          	auipc	ra,0xffffe
    8000568c:	4e8080e7          	jalr	1256(ra) # 80003b70 <iunlockput>
    end_op();
    80005690:	fffff097          	auipc	ra,0xfffff
    80005694:	cc8080e7          	jalr	-824(ra) # 80004358 <end_op>
    return -1;
    80005698:	57fd                	li	a5,-1
    8000569a:	a83d                	j	800056d8 <sys_link+0x13c>
    iunlockput(dp);
    8000569c:	854a                	mv	a0,s2
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	4d2080e7          	jalr	1234(ra) # 80003b70 <iunlockput>
  ilock(ip);
    800056a6:	8526                	mv	a0,s1
    800056a8:	ffffe097          	auipc	ra,0xffffe
    800056ac:	266080e7          	jalr	614(ra) # 8000390e <ilock>
  ip->nlink--;
    800056b0:	04a4d783          	lhu	a5,74(s1)
    800056b4:	37fd                	addiw	a5,a5,-1
    800056b6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056ba:	8526                	mv	a0,s1
    800056bc:	ffffe097          	auipc	ra,0xffffe
    800056c0:	186080e7          	jalr	390(ra) # 80003842 <iupdate>
  iunlockput(ip);
    800056c4:	8526                	mv	a0,s1
    800056c6:	ffffe097          	auipc	ra,0xffffe
    800056ca:	4aa080e7          	jalr	1194(ra) # 80003b70 <iunlockput>
  end_op();
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	c8a080e7          	jalr	-886(ra) # 80004358 <end_op>
  return -1;
    800056d6:	57fd                	li	a5,-1
}
    800056d8:	853e                	mv	a0,a5
    800056da:	70b2                	ld	ra,296(sp)
    800056dc:	7412                	ld	s0,288(sp)
    800056de:	64f2                	ld	s1,280(sp)
    800056e0:	6952                	ld	s2,272(sp)
    800056e2:	6155                	addi	sp,sp,304
    800056e4:	8082                	ret

00000000800056e6 <sys_unlink>:
{
    800056e6:	7151                	addi	sp,sp,-240
    800056e8:	f586                	sd	ra,232(sp)
    800056ea:	f1a2                	sd	s0,224(sp)
    800056ec:	eda6                	sd	s1,216(sp)
    800056ee:	e9ca                	sd	s2,208(sp)
    800056f0:	e5ce                	sd	s3,200(sp)
    800056f2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056f4:	08000613          	li	a2,128
    800056f8:	f3040593          	addi	a1,s0,-208
    800056fc:	4501                	li	a0,0
    800056fe:	ffffd097          	auipc	ra,0xffffd
    80005702:	40c080e7          	jalr	1036(ra) # 80002b0a <argstr>
    80005706:	18054163          	bltz	a0,80005888 <sys_unlink+0x1a2>
  begin_op();
    8000570a:	fffff097          	auipc	ra,0xfffff
    8000570e:	bd0080e7          	jalr	-1072(ra) # 800042da <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005712:	fb040593          	addi	a1,s0,-80
    80005716:	f3040513          	addi	a0,s0,-208
    8000571a:	fffff097          	auipc	ra,0xfffff
    8000571e:	9be080e7          	jalr	-1602(ra) # 800040d8 <nameiparent>
    80005722:	84aa                	mv	s1,a0
    80005724:	c979                	beqz	a0,800057fa <sys_unlink+0x114>
  ilock(dp);
    80005726:	ffffe097          	auipc	ra,0xffffe
    8000572a:	1e8080e7          	jalr	488(ra) # 8000390e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000572e:	00003597          	auipc	a1,0x3
    80005732:	ffa58593          	addi	a1,a1,-6 # 80008728 <syscalls+0x2d8>
    80005736:	fb040513          	addi	a0,s0,-80
    8000573a:	ffffe097          	auipc	ra,0xffffe
    8000573e:	69e080e7          	jalr	1694(ra) # 80003dd8 <namecmp>
    80005742:	14050a63          	beqz	a0,80005896 <sys_unlink+0x1b0>
    80005746:	00003597          	auipc	a1,0x3
    8000574a:	fea58593          	addi	a1,a1,-22 # 80008730 <syscalls+0x2e0>
    8000574e:	fb040513          	addi	a0,s0,-80
    80005752:	ffffe097          	auipc	ra,0xffffe
    80005756:	686080e7          	jalr	1670(ra) # 80003dd8 <namecmp>
    8000575a:	12050e63          	beqz	a0,80005896 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000575e:	f2c40613          	addi	a2,s0,-212
    80005762:	fb040593          	addi	a1,s0,-80
    80005766:	8526                	mv	a0,s1
    80005768:	ffffe097          	auipc	ra,0xffffe
    8000576c:	68a080e7          	jalr	1674(ra) # 80003df2 <dirlookup>
    80005770:	892a                	mv	s2,a0
    80005772:	12050263          	beqz	a0,80005896 <sys_unlink+0x1b0>
  ilock(ip);
    80005776:	ffffe097          	auipc	ra,0xffffe
    8000577a:	198080e7          	jalr	408(ra) # 8000390e <ilock>
  if(ip->nlink < 1)
    8000577e:	04a91783          	lh	a5,74(s2)
    80005782:	08f05263          	blez	a5,80005806 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005786:	04491703          	lh	a4,68(s2)
    8000578a:	4785                	li	a5,1
    8000578c:	08f70563          	beq	a4,a5,80005816 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005790:	4641                	li	a2,16
    80005792:	4581                	li	a1,0
    80005794:	fc040513          	addi	a0,s0,-64
    80005798:	ffffb097          	auipc	ra,0xffffb
    8000579c:	53a080e7          	jalr	1338(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057a0:	4741                	li	a4,16
    800057a2:	f2c42683          	lw	a3,-212(s0)
    800057a6:	fc040613          	addi	a2,s0,-64
    800057aa:	4581                	li	a1,0
    800057ac:	8526                	mv	a0,s1
    800057ae:	ffffe097          	auipc	ra,0xffffe
    800057b2:	50c080e7          	jalr	1292(ra) # 80003cba <writei>
    800057b6:	47c1                	li	a5,16
    800057b8:	0af51563          	bne	a0,a5,80005862 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800057bc:	04491703          	lh	a4,68(s2)
    800057c0:	4785                	li	a5,1
    800057c2:	0af70863          	beq	a4,a5,80005872 <sys_unlink+0x18c>
  iunlockput(dp);
    800057c6:	8526                	mv	a0,s1
    800057c8:	ffffe097          	auipc	ra,0xffffe
    800057cc:	3a8080e7          	jalr	936(ra) # 80003b70 <iunlockput>
  ip->nlink--;
    800057d0:	04a95783          	lhu	a5,74(s2)
    800057d4:	37fd                	addiw	a5,a5,-1
    800057d6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057da:	854a                	mv	a0,s2
    800057dc:	ffffe097          	auipc	ra,0xffffe
    800057e0:	066080e7          	jalr	102(ra) # 80003842 <iupdate>
  iunlockput(ip);
    800057e4:	854a                	mv	a0,s2
    800057e6:	ffffe097          	auipc	ra,0xffffe
    800057ea:	38a080e7          	jalr	906(ra) # 80003b70 <iunlockput>
  end_op();
    800057ee:	fffff097          	auipc	ra,0xfffff
    800057f2:	b6a080e7          	jalr	-1174(ra) # 80004358 <end_op>
  return 0;
    800057f6:	4501                	li	a0,0
    800057f8:	a84d                	j	800058aa <sys_unlink+0x1c4>
    end_op();
    800057fa:	fffff097          	auipc	ra,0xfffff
    800057fe:	b5e080e7          	jalr	-1186(ra) # 80004358 <end_op>
    return -1;
    80005802:	557d                	li	a0,-1
    80005804:	a05d                	j	800058aa <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005806:	00003517          	auipc	a0,0x3
    8000580a:	f3250513          	addi	a0,a0,-206 # 80008738 <syscalls+0x2e8>
    8000580e:	ffffb097          	auipc	ra,0xffffb
    80005812:	d32080e7          	jalr	-718(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005816:	04c92703          	lw	a4,76(s2)
    8000581a:	02000793          	li	a5,32
    8000581e:	f6e7f9e3          	bgeu	a5,a4,80005790 <sys_unlink+0xaa>
    80005822:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005826:	4741                	li	a4,16
    80005828:	86ce                	mv	a3,s3
    8000582a:	f1840613          	addi	a2,s0,-232
    8000582e:	4581                	li	a1,0
    80005830:	854a                	mv	a0,s2
    80005832:	ffffe097          	auipc	ra,0xffffe
    80005836:	390080e7          	jalr	912(ra) # 80003bc2 <readi>
    8000583a:	47c1                	li	a5,16
    8000583c:	00f51b63          	bne	a0,a5,80005852 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005840:	f1845783          	lhu	a5,-232(s0)
    80005844:	e7a1                	bnez	a5,8000588c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005846:	29c1                	addiw	s3,s3,16
    80005848:	04c92783          	lw	a5,76(s2)
    8000584c:	fcf9ede3          	bltu	s3,a5,80005826 <sys_unlink+0x140>
    80005850:	b781                	j	80005790 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005852:	00003517          	auipc	a0,0x3
    80005856:	efe50513          	addi	a0,a0,-258 # 80008750 <syscalls+0x300>
    8000585a:	ffffb097          	auipc	ra,0xffffb
    8000585e:	ce6080e7          	jalr	-794(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005862:	00003517          	auipc	a0,0x3
    80005866:	f0650513          	addi	a0,a0,-250 # 80008768 <syscalls+0x318>
    8000586a:	ffffb097          	auipc	ra,0xffffb
    8000586e:	cd6080e7          	jalr	-810(ra) # 80000540 <panic>
    dp->nlink--;
    80005872:	04a4d783          	lhu	a5,74(s1)
    80005876:	37fd                	addiw	a5,a5,-1
    80005878:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000587c:	8526                	mv	a0,s1
    8000587e:	ffffe097          	auipc	ra,0xffffe
    80005882:	fc4080e7          	jalr	-60(ra) # 80003842 <iupdate>
    80005886:	b781                	j	800057c6 <sys_unlink+0xe0>
    return -1;
    80005888:	557d                	li	a0,-1
    8000588a:	a005                	j	800058aa <sys_unlink+0x1c4>
    iunlockput(ip);
    8000588c:	854a                	mv	a0,s2
    8000588e:	ffffe097          	auipc	ra,0xffffe
    80005892:	2e2080e7          	jalr	738(ra) # 80003b70 <iunlockput>
  iunlockput(dp);
    80005896:	8526                	mv	a0,s1
    80005898:	ffffe097          	auipc	ra,0xffffe
    8000589c:	2d8080e7          	jalr	728(ra) # 80003b70 <iunlockput>
  end_op();
    800058a0:	fffff097          	auipc	ra,0xfffff
    800058a4:	ab8080e7          	jalr	-1352(ra) # 80004358 <end_op>
  return -1;
    800058a8:	557d                	li	a0,-1
}
    800058aa:	70ae                	ld	ra,232(sp)
    800058ac:	740e                	ld	s0,224(sp)
    800058ae:	64ee                	ld	s1,216(sp)
    800058b0:	694e                	ld	s2,208(sp)
    800058b2:	69ae                	ld	s3,200(sp)
    800058b4:	616d                	addi	sp,sp,240
    800058b6:	8082                	ret

00000000800058b8 <sys_open>:

uint64
sys_open(void)
{
    800058b8:	7131                	addi	sp,sp,-192
    800058ba:	fd06                	sd	ra,184(sp)
    800058bc:	f922                	sd	s0,176(sp)
    800058be:	f526                	sd	s1,168(sp)
    800058c0:	f14a                	sd	s2,160(sp)
    800058c2:	ed4e                	sd	s3,152(sp)
    800058c4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800058c6:	f4c40593          	addi	a1,s0,-180
    800058ca:	4505                	li	a0,1
    800058cc:	ffffd097          	auipc	ra,0xffffd
    800058d0:	1fe080e7          	jalr	510(ra) # 80002aca <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058d4:	08000613          	li	a2,128
    800058d8:	f5040593          	addi	a1,s0,-176
    800058dc:	4501                	li	a0,0
    800058de:	ffffd097          	auipc	ra,0xffffd
    800058e2:	22c080e7          	jalr	556(ra) # 80002b0a <argstr>
    800058e6:	87aa                	mv	a5,a0
    return -1;
    800058e8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058ea:	0a07c963          	bltz	a5,8000599c <sys_open+0xe4>

  begin_op();
    800058ee:	fffff097          	auipc	ra,0xfffff
    800058f2:	9ec080e7          	jalr	-1556(ra) # 800042da <begin_op>

  if(omode & O_CREATE){
    800058f6:	f4c42783          	lw	a5,-180(s0)
    800058fa:	2007f793          	andi	a5,a5,512
    800058fe:	cfc5                	beqz	a5,800059b6 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005900:	4681                	li	a3,0
    80005902:	4601                	li	a2,0
    80005904:	4589                	li	a1,2
    80005906:	f5040513          	addi	a0,s0,-176
    8000590a:	00000097          	auipc	ra,0x0
    8000590e:	972080e7          	jalr	-1678(ra) # 8000527c <create>
    80005912:	84aa                	mv	s1,a0
    if(ip == 0){
    80005914:	c959                	beqz	a0,800059aa <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005916:	04449703          	lh	a4,68(s1)
    8000591a:	478d                	li	a5,3
    8000591c:	00f71763          	bne	a4,a5,8000592a <sys_open+0x72>
    80005920:	0464d703          	lhu	a4,70(s1)
    80005924:	47a5                	li	a5,9
    80005926:	0ce7ed63          	bltu	a5,a4,80005a00 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000592a:	fffff097          	auipc	ra,0xfffff
    8000592e:	dbc080e7          	jalr	-580(ra) # 800046e6 <filealloc>
    80005932:	89aa                	mv	s3,a0
    80005934:	10050363          	beqz	a0,80005a3a <sys_open+0x182>
    80005938:	00000097          	auipc	ra,0x0
    8000593c:	902080e7          	jalr	-1790(ra) # 8000523a <fdalloc>
    80005940:	892a                	mv	s2,a0
    80005942:	0e054763          	bltz	a0,80005a30 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005946:	04449703          	lh	a4,68(s1)
    8000594a:	478d                	li	a5,3
    8000594c:	0cf70563          	beq	a4,a5,80005a16 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005950:	4789                	li	a5,2
    80005952:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005956:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000595a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000595e:	f4c42783          	lw	a5,-180(s0)
    80005962:	0017c713          	xori	a4,a5,1
    80005966:	8b05                	andi	a4,a4,1
    80005968:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000596c:	0037f713          	andi	a4,a5,3
    80005970:	00e03733          	snez	a4,a4
    80005974:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005978:	4007f793          	andi	a5,a5,1024
    8000597c:	c791                	beqz	a5,80005988 <sys_open+0xd0>
    8000597e:	04449703          	lh	a4,68(s1)
    80005982:	4789                	li	a5,2
    80005984:	0af70063          	beq	a4,a5,80005a24 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005988:	8526                	mv	a0,s1
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	046080e7          	jalr	70(ra) # 800039d0 <iunlock>
  end_op();
    80005992:	fffff097          	auipc	ra,0xfffff
    80005996:	9c6080e7          	jalr	-1594(ra) # 80004358 <end_op>

  return fd;
    8000599a:	854a                	mv	a0,s2
}
    8000599c:	70ea                	ld	ra,184(sp)
    8000599e:	744a                	ld	s0,176(sp)
    800059a0:	74aa                	ld	s1,168(sp)
    800059a2:	790a                	ld	s2,160(sp)
    800059a4:	69ea                	ld	s3,152(sp)
    800059a6:	6129                	addi	sp,sp,192
    800059a8:	8082                	ret
      end_op();
    800059aa:	fffff097          	auipc	ra,0xfffff
    800059ae:	9ae080e7          	jalr	-1618(ra) # 80004358 <end_op>
      return -1;
    800059b2:	557d                	li	a0,-1
    800059b4:	b7e5                	j	8000599c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059b6:	f5040513          	addi	a0,s0,-176
    800059ba:	ffffe097          	auipc	ra,0xffffe
    800059be:	700080e7          	jalr	1792(ra) # 800040ba <namei>
    800059c2:	84aa                	mv	s1,a0
    800059c4:	c905                	beqz	a0,800059f4 <sys_open+0x13c>
    ilock(ip);
    800059c6:	ffffe097          	auipc	ra,0xffffe
    800059ca:	f48080e7          	jalr	-184(ra) # 8000390e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059ce:	04449703          	lh	a4,68(s1)
    800059d2:	4785                	li	a5,1
    800059d4:	f4f711e3          	bne	a4,a5,80005916 <sys_open+0x5e>
    800059d8:	f4c42783          	lw	a5,-180(s0)
    800059dc:	d7b9                	beqz	a5,8000592a <sys_open+0x72>
      iunlockput(ip);
    800059de:	8526                	mv	a0,s1
    800059e0:	ffffe097          	auipc	ra,0xffffe
    800059e4:	190080e7          	jalr	400(ra) # 80003b70 <iunlockput>
      end_op();
    800059e8:	fffff097          	auipc	ra,0xfffff
    800059ec:	970080e7          	jalr	-1680(ra) # 80004358 <end_op>
      return -1;
    800059f0:	557d                	li	a0,-1
    800059f2:	b76d                	j	8000599c <sys_open+0xe4>
      end_op();
    800059f4:	fffff097          	auipc	ra,0xfffff
    800059f8:	964080e7          	jalr	-1692(ra) # 80004358 <end_op>
      return -1;
    800059fc:	557d                	li	a0,-1
    800059fe:	bf79                	j	8000599c <sys_open+0xe4>
    iunlockput(ip);
    80005a00:	8526                	mv	a0,s1
    80005a02:	ffffe097          	auipc	ra,0xffffe
    80005a06:	16e080e7          	jalr	366(ra) # 80003b70 <iunlockput>
    end_op();
    80005a0a:	fffff097          	auipc	ra,0xfffff
    80005a0e:	94e080e7          	jalr	-1714(ra) # 80004358 <end_op>
    return -1;
    80005a12:	557d                	li	a0,-1
    80005a14:	b761                	j	8000599c <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a16:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a1a:	04649783          	lh	a5,70(s1)
    80005a1e:	02f99223          	sh	a5,36(s3)
    80005a22:	bf25                	j	8000595a <sys_open+0xa2>
    itrunc(ip);
    80005a24:	8526                	mv	a0,s1
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	ff6080e7          	jalr	-10(ra) # 80003a1c <itrunc>
    80005a2e:	bfa9                	j	80005988 <sys_open+0xd0>
      fileclose(f);
    80005a30:	854e                	mv	a0,s3
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	d70080e7          	jalr	-656(ra) # 800047a2 <fileclose>
    iunlockput(ip);
    80005a3a:	8526                	mv	a0,s1
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	134080e7          	jalr	308(ra) # 80003b70 <iunlockput>
    end_op();
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	914080e7          	jalr	-1772(ra) # 80004358 <end_op>
    return -1;
    80005a4c:	557d                	li	a0,-1
    80005a4e:	b7b9                	j	8000599c <sys_open+0xe4>

0000000080005a50 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a50:	7175                	addi	sp,sp,-144
    80005a52:	e506                	sd	ra,136(sp)
    80005a54:	e122                	sd	s0,128(sp)
    80005a56:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a58:	fffff097          	auipc	ra,0xfffff
    80005a5c:	882080e7          	jalr	-1918(ra) # 800042da <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a60:	08000613          	li	a2,128
    80005a64:	f7040593          	addi	a1,s0,-144
    80005a68:	4501                	li	a0,0
    80005a6a:	ffffd097          	auipc	ra,0xffffd
    80005a6e:	0a0080e7          	jalr	160(ra) # 80002b0a <argstr>
    80005a72:	02054963          	bltz	a0,80005aa4 <sys_mkdir+0x54>
    80005a76:	4681                	li	a3,0
    80005a78:	4601                	li	a2,0
    80005a7a:	4585                	li	a1,1
    80005a7c:	f7040513          	addi	a0,s0,-144
    80005a80:	fffff097          	auipc	ra,0xfffff
    80005a84:	7fc080e7          	jalr	2044(ra) # 8000527c <create>
    80005a88:	cd11                	beqz	a0,80005aa4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a8a:	ffffe097          	auipc	ra,0xffffe
    80005a8e:	0e6080e7          	jalr	230(ra) # 80003b70 <iunlockput>
  end_op();
    80005a92:	fffff097          	auipc	ra,0xfffff
    80005a96:	8c6080e7          	jalr	-1850(ra) # 80004358 <end_op>
  return 0;
    80005a9a:	4501                	li	a0,0
}
    80005a9c:	60aa                	ld	ra,136(sp)
    80005a9e:	640a                	ld	s0,128(sp)
    80005aa0:	6149                	addi	sp,sp,144
    80005aa2:	8082                	ret
    end_op();
    80005aa4:	fffff097          	auipc	ra,0xfffff
    80005aa8:	8b4080e7          	jalr	-1868(ra) # 80004358 <end_op>
    return -1;
    80005aac:	557d                	li	a0,-1
    80005aae:	b7fd                	j	80005a9c <sys_mkdir+0x4c>

0000000080005ab0 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ab0:	7135                	addi	sp,sp,-160
    80005ab2:	ed06                	sd	ra,152(sp)
    80005ab4:	e922                	sd	s0,144(sp)
    80005ab6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	822080e7          	jalr	-2014(ra) # 800042da <begin_op>
  argint(1, &major);
    80005ac0:	f6c40593          	addi	a1,s0,-148
    80005ac4:	4505                	li	a0,1
    80005ac6:	ffffd097          	auipc	ra,0xffffd
    80005aca:	004080e7          	jalr	4(ra) # 80002aca <argint>
  argint(2, &minor);
    80005ace:	f6840593          	addi	a1,s0,-152
    80005ad2:	4509                	li	a0,2
    80005ad4:	ffffd097          	auipc	ra,0xffffd
    80005ad8:	ff6080e7          	jalr	-10(ra) # 80002aca <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005adc:	08000613          	li	a2,128
    80005ae0:	f7040593          	addi	a1,s0,-144
    80005ae4:	4501                	li	a0,0
    80005ae6:	ffffd097          	auipc	ra,0xffffd
    80005aea:	024080e7          	jalr	36(ra) # 80002b0a <argstr>
    80005aee:	02054b63          	bltz	a0,80005b24 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005af2:	f6841683          	lh	a3,-152(s0)
    80005af6:	f6c41603          	lh	a2,-148(s0)
    80005afa:	458d                	li	a1,3
    80005afc:	f7040513          	addi	a0,s0,-144
    80005b00:	fffff097          	auipc	ra,0xfffff
    80005b04:	77c080e7          	jalr	1916(ra) # 8000527c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b08:	cd11                	beqz	a0,80005b24 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b0a:	ffffe097          	auipc	ra,0xffffe
    80005b0e:	066080e7          	jalr	102(ra) # 80003b70 <iunlockput>
  end_op();
    80005b12:	fffff097          	auipc	ra,0xfffff
    80005b16:	846080e7          	jalr	-1978(ra) # 80004358 <end_op>
  return 0;
    80005b1a:	4501                	li	a0,0
}
    80005b1c:	60ea                	ld	ra,152(sp)
    80005b1e:	644a                	ld	s0,144(sp)
    80005b20:	610d                	addi	sp,sp,160
    80005b22:	8082                	ret
    end_op();
    80005b24:	fffff097          	auipc	ra,0xfffff
    80005b28:	834080e7          	jalr	-1996(ra) # 80004358 <end_op>
    return -1;
    80005b2c:	557d                	li	a0,-1
    80005b2e:	b7fd                	j	80005b1c <sys_mknod+0x6c>

0000000080005b30 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b30:	7135                	addi	sp,sp,-160
    80005b32:	ed06                	sd	ra,152(sp)
    80005b34:	e922                	sd	s0,144(sp)
    80005b36:	e526                	sd	s1,136(sp)
    80005b38:	e14a                	sd	s2,128(sp)
    80005b3a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b3c:	ffffc097          	auipc	ra,0xffffc
    80005b40:	e78080e7          	jalr	-392(ra) # 800019b4 <myproc>
    80005b44:	892a                	mv	s2,a0
  
  begin_op();
    80005b46:	ffffe097          	auipc	ra,0xffffe
    80005b4a:	794080e7          	jalr	1940(ra) # 800042da <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b4e:	08000613          	li	a2,128
    80005b52:	f6040593          	addi	a1,s0,-160
    80005b56:	4501                	li	a0,0
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	fb2080e7          	jalr	-78(ra) # 80002b0a <argstr>
    80005b60:	04054b63          	bltz	a0,80005bb6 <sys_chdir+0x86>
    80005b64:	f6040513          	addi	a0,s0,-160
    80005b68:	ffffe097          	auipc	ra,0xffffe
    80005b6c:	552080e7          	jalr	1362(ra) # 800040ba <namei>
    80005b70:	84aa                	mv	s1,a0
    80005b72:	c131                	beqz	a0,80005bb6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b74:	ffffe097          	auipc	ra,0xffffe
    80005b78:	d9a080e7          	jalr	-614(ra) # 8000390e <ilock>
  if(ip->type != T_DIR){
    80005b7c:	04449703          	lh	a4,68(s1)
    80005b80:	4785                	li	a5,1
    80005b82:	04f71063          	bne	a4,a5,80005bc2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b86:	8526                	mv	a0,s1
    80005b88:	ffffe097          	auipc	ra,0xffffe
    80005b8c:	e48080e7          	jalr	-440(ra) # 800039d0 <iunlock>
  iput(p->cwd);
    80005b90:	15093503          	ld	a0,336(s2)
    80005b94:	ffffe097          	auipc	ra,0xffffe
    80005b98:	f34080e7          	jalr	-204(ra) # 80003ac8 <iput>
  end_op();
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	7bc080e7          	jalr	1980(ra) # 80004358 <end_op>
  p->cwd = ip;
    80005ba4:	14993823          	sd	s1,336(s2)
  return 0;
    80005ba8:	4501                	li	a0,0
}
    80005baa:	60ea                	ld	ra,152(sp)
    80005bac:	644a                	ld	s0,144(sp)
    80005bae:	64aa                	ld	s1,136(sp)
    80005bb0:	690a                	ld	s2,128(sp)
    80005bb2:	610d                	addi	sp,sp,160
    80005bb4:	8082                	ret
    end_op();
    80005bb6:	ffffe097          	auipc	ra,0xffffe
    80005bba:	7a2080e7          	jalr	1954(ra) # 80004358 <end_op>
    return -1;
    80005bbe:	557d                	li	a0,-1
    80005bc0:	b7ed                	j	80005baa <sys_chdir+0x7a>
    iunlockput(ip);
    80005bc2:	8526                	mv	a0,s1
    80005bc4:	ffffe097          	auipc	ra,0xffffe
    80005bc8:	fac080e7          	jalr	-84(ra) # 80003b70 <iunlockput>
    end_op();
    80005bcc:	ffffe097          	auipc	ra,0xffffe
    80005bd0:	78c080e7          	jalr	1932(ra) # 80004358 <end_op>
    return -1;
    80005bd4:	557d                	li	a0,-1
    80005bd6:	bfd1                	j	80005baa <sys_chdir+0x7a>

0000000080005bd8 <sys_exec>:

uint64
sys_exec(void)
{
    80005bd8:	7145                	addi	sp,sp,-464
    80005bda:	e786                	sd	ra,456(sp)
    80005bdc:	e3a2                	sd	s0,448(sp)
    80005bde:	ff26                	sd	s1,440(sp)
    80005be0:	fb4a                	sd	s2,432(sp)
    80005be2:	f74e                	sd	s3,424(sp)
    80005be4:	f352                	sd	s4,416(sp)
    80005be6:	ef56                	sd	s5,408(sp)
    80005be8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005bea:	e3840593          	addi	a1,s0,-456
    80005bee:	4505                	li	a0,1
    80005bf0:	ffffd097          	auipc	ra,0xffffd
    80005bf4:	efa080e7          	jalr	-262(ra) # 80002aea <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005bf8:	08000613          	li	a2,128
    80005bfc:	f4040593          	addi	a1,s0,-192
    80005c00:	4501                	li	a0,0
    80005c02:	ffffd097          	auipc	ra,0xffffd
    80005c06:	f08080e7          	jalr	-248(ra) # 80002b0a <argstr>
    80005c0a:	87aa                	mv	a5,a0
    return -1;
    80005c0c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c0e:	0c07c363          	bltz	a5,80005cd4 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005c12:	10000613          	li	a2,256
    80005c16:	4581                	li	a1,0
    80005c18:	e4040513          	addi	a0,s0,-448
    80005c1c:	ffffb097          	auipc	ra,0xffffb
    80005c20:	0b6080e7          	jalr	182(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c24:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c28:	89a6                	mv	s3,s1
    80005c2a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c2c:	02000a13          	li	s4,32
    80005c30:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c34:	00391513          	slli	a0,s2,0x3
    80005c38:	e3040593          	addi	a1,s0,-464
    80005c3c:	e3843783          	ld	a5,-456(s0)
    80005c40:	953e                	add	a0,a0,a5
    80005c42:	ffffd097          	auipc	ra,0xffffd
    80005c46:	dea080e7          	jalr	-534(ra) # 80002a2c <fetchaddr>
    80005c4a:	02054a63          	bltz	a0,80005c7e <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c4e:	e3043783          	ld	a5,-464(s0)
    80005c52:	c3b9                	beqz	a5,80005c98 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c54:	ffffb097          	auipc	ra,0xffffb
    80005c58:	e92080e7          	jalr	-366(ra) # 80000ae6 <kalloc>
    80005c5c:	85aa                	mv	a1,a0
    80005c5e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c62:	cd11                	beqz	a0,80005c7e <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c64:	6605                	lui	a2,0x1
    80005c66:	e3043503          	ld	a0,-464(s0)
    80005c6a:	ffffd097          	auipc	ra,0xffffd
    80005c6e:	e14080e7          	jalr	-492(ra) # 80002a7e <fetchstr>
    80005c72:	00054663          	bltz	a0,80005c7e <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c76:	0905                	addi	s2,s2,1
    80005c78:	09a1                	addi	s3,s3,8
    80005c7a:	fb491be3          	bne	s2,s4,80005c30 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c7e:	f4040913          	addi	s2,s0,-192
    80005c82:	6088                	ld	a0,0(s1)
    80005c84:	c539                	beqz	a0,80005cd2 <sys_exec+0xfa>
    kfree(argv[i]);
    80005c86:	ffffb097          	auipc	ra,0xffffb
    80005c8a:	d62080e7          	jalr	-670(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c8e:	04a1                	addi	s1,s1,8
    80005c90:	ff2499e3          	bne	s1,s2,80005c82 <sys_exec+0xaa>
  return -1;
    80005c94:	557d                	li	a0,-1
    80005c96:	a83d                	j	80005cd4 <sys_exec+0xfc>
      argv[i] = 0;
    80005c98:	0a8e                	slli	s5,s5,0x3
    80005c9a:	fc0a8793          	addi	a5,s5,-64
    80005c9e:	00878ab3          	add	s5,a5,s0
    80005ca2:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005ca6:	e4040593          	addi	a1,s0,-448
    80005caa:	f4040513          	addi	a0,s0,-192
    80005cae:	fffff097          	auipc	ra,0xfffff
    80005cb2:	16e080e7          	jalr	366(ra) # 80004e1c <exec>
    80005cb6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cb8:	f4040993          	addi	s3,s0,-192
    80005cbc:	6088                	ld	a0,0(s1)
    80005cbe:	c901                	beqz	a0,80005cce <sys_exec+0xf6>
    kfree(argv[i]);
    80005cc0:	ffffb097          	auipc	ra,0xffffb
    80005cc4:	d28080e7          	jalr	-728(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cc8:	04a1                	addi	s1,s1,8
    80005cca:	ff3499e3          	bne	s1,s3,80005cbc <sys_exec+0xe4>
  return ret;
    80005cce:	854a                	mv	a0,s2
    80005cd0:	a011                	j	80005cd4 <sys_exec+0xfc>
  return -1;
    80005cd2:	557d                	li	a0,-1
}
    80005cd4:	60be                	ld	ra,456(sp)
    80005cd6:	641e                	ld	s0,448(sp)
    80005cd8:	74fa                	ld	s1,440(sp)
    80005cda:	795a                	ld	s2,432(sp)
    80005cdc:	79ba                	ld	s3,424(sp)
    80005cde:	7a1a                	ld	s4,416(sp)
    80005ce0:	6afa                	ld	s5,408(sp)
    80005ce2:	6179                	addi	sp,sp,464
    80005ce4:	8082                	ret

0000000080005ce6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ce6:	7139                	addi	sp,sp,-64
    80005ce8:	fc06                	sd	ra,56(sp)
    80005cea:	f822                	sd	s0,48(sp)
    80005cec:	f426                	sd	s1,40(sp)
    80005cee:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cf0:	ffffc097          	auipc	ra,0xffffc
    80005cf4:	cc4080e7          	jalr	-828(ra) # 800019b4 <myproc>
    80005cf8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005cfa:	fd840593          	addi	a1,s0,-40
    80005cfe:	4501                	li	a0,0
    80005d00:	ffffd097          	auipc	ra,0xffffd
    80005d04:	dea080e7          	jalr	-534(ra) # 80002aea <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d08:	fc840593          	addi	a1,s0,-56
    80005d0c:	fd040513          	addi	a0,s0,-48
    80005d10:	fffff097          	auipc	ra,0xfffff
    80005d14:	dc2080e7          	jalr	-574(ra) # 80004ad2 <pipealloc>
    return -1;
    80005d18:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d1a:	0c054463          	bltz	a0,80005de2 <sys_pipe+0xfc>
  fd0 = -1;
    80005d1e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d22:	fd043503          	ld	a0,-48(s0)
    80005d26:	fffff097          	auipc	ra,0xfffff
    80005d2a:	514080e7          	jalr	1300(ra) # 8000523a <fdalloc>
    80005d2e:	fca42223          	sw	a0,-60(s0)
    80005d32:	08054b63          	bltz	a0,80005dc8 <sys_pipe+0xe2>
    80005d36:	fc843503          	ld	a0,-56(s0)
    80005d3a:	fffff097          	auipc	ra,0xfffff
    80005d3e:	500080e7          	jalr	1280(ra) # 8000523a <fdalloc>
    80005d42:	fca42023          	sw	a0,-64(s0)
    80005d46:	06054863          	bltz	a0,80005db6 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d4a:	4691                	li	a3,4
    80005d4c:	fc440613          	addi	a2,s0,-60
    80005d50:	fd843583          	ld	a1,-40(s0)
    80005d54:	68a8                	ld	a0,80(s1)
    80005d56:	ffffc097          	auipc	ra,0xffffc
    80005d5a:	91e080e7          	jalr	-1762(ra) # 80001674 <copyout>
    80005d5e:	02054063          	bltz	a0,80005d7e <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d62:	4691                	li	a3,4
    80005d64:	fc040613          	addi	a2,s0,-64
    80005d68:	fd843583          	ld	a1,-40(s0)
    80005d6c:	0591                	addi	a1,a1,4
    80005d6e:	68a8                	ld	a0,80(s1)
    80005d70:	ffffc097          	auipc	ra,0xffffc
    80005d74:	904080e7          	jalr	-1788(ra) # 80001674 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d78:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d7a:	06055463          	bgez	a0,80005de2 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005d7e:	fc442783          	lw	a5,-60(s0)
    80005d82:	07e9                	addi	a5,a5,26
    80005d84:	078e                	slli	a5,a5,0x3
    80005d86:	97a6                	add	a5,a5,s1
    80005d88:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d8c:	fc042783          	lw	a5,-64(s0)
    80005d90:	07e9                	addi	a5,a5,26
    80005d92:	078e                	slli	a5,a5,0x3
    80005d94:	94be                	add	s1,s1,a5
    80005d96:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d9a:	fd043503          	ld	a0,-48(s0)
    80005d9e:	fffff097          	auipc	ra,0xfffff
    80005da2:	a04080e7          	jalr	-1532(ra) # 800047a2 <fileclose>
    fileclose(wf);
    80005da6:	fc843503          	ld	a0,-56(s0)
    80005daa:	fffff097          	auipc	ra,0xfffff
    80005dae:	9f8080e7          	jalr	-1544(ra) # 800047a2 <fileclose>
    return -1;
    80005db2:	57fd                	li	a5,-1
    80005db4:	a03d                	j	80005de2 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005db6:	fc442783          	lw	a5,-60(s0)
    80005dba:	0007c763          	bltz	a5,80005dc8 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005dbe:	07e9                	addi	a5,a5,26
    80005dc0:	078e                	slli	a5,a5,0x3
    80005dc2:	97a6                	add	a5,a5,s1
    80005dc4:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005dc8:	fd043503          	ld	a0,-48(s0)
    80005dcc:	fffff097          	auipc	ra,0xfffff
    80005dd0:	9d6080e7          	jalr	-1578(ra) # 800047a2 <fileclose>
    fileclose(wf);
    80005dd4:	fc843503          	ld	a0,-56(s0)
    80005dd8:	fffff097          	auipc	ra,0xfffff
    80005ddc:	9ca080e7          	jalr	-1590(ra) # 800047a2 <fileclose>
    return -1;
    80005de0:	57fd                	li	a5,-1
}
    80005de2:	853e                	mv	a0,a5
    80005de4:	70e2                	ld	ra,56(sp)
    80005de6:	7442                	ld	s0,48(sp)
    80005de8:	74a2                	ld	s1,40(sp)
    80005dea:	6121                	addi	sp,sp,64
    80005dec:	8082                	ret
	...

0000000080005df0 <kernelvec>:
    80005df0:	7111                	addi	sp,sp,-256
    80005df2:	e006                	sd	ra,0(sp)
    80005df4:	e40a                	sd	sp,8(sp)
    80005df6:	e80e                	sd	gp,16(sp)
    80005df8:	ec12                	sd	tp,24(sp)
    80005dfa:	f016                	sd	t0,32(sp)
    80005dfc:	f41a                	sd	t1,40(sp)
    80005dfe:	f81e                	sd	t2,48(sp)
    80005e00:	fc22                	sd	s0,56(sp)
    80005e02:	e0a6                	sd	s1,64(sp)
    80005e04:	e4aa                	sd	a0,72(sp)
    80005e06:	e8ae                	sd	a1,80(sp)
    80005e08:	ecb2                	sd	a2,88(sp)
    80005e0a:	f0b6                	sd	a3,96(sp)
    80005e0c:	f4ba                	sd	a4,104(sp)
    80005e0e:	f8be                	sd	a5,112(sp)
    80005e10:	fcc2                	sd	a6,120(sp)
    80005e12:	e146                	sd	a7,128(sp)
    80005e14:	e54a                	sd	s2,136(sp)
    80005e16:	e94e                	sd	s3,144(sp)
    80005e18:	ed52                	sd	s4,152(sp)
    80005e1a:	f156                	sd	s5,160(sp)
    80005e1c:	f55a                	sd	s6,168(sp)
    80005e1e:	f95e                	sd	s7,176(sp)
    80005e20:	fd62                	sd	s8,184(sp)
    80005e22:	e1e6                	sd	s9,192(sp)
    80005e24:	e5ea                	sd	s10,200(sp)
    80005e26:	e9ee                	sd	s11,208(sp)
    80005e28:	edf2                	sd	t3,216(sp)
    80005e2a:	f1f6                	sd	t4,224(sp)
    80005e2c:	f5fa                	sd	t5,232(sp)
    80005e2e:	f9fe                	sd	t6,240(sp)
    80005e30:	ac9fc0ef          	jal	ra,800028f8 <kerneltrap>
    80005e34:	6082                	ld	ra,0(sp)
    80005e36:	6122                	ld	sp,8(sp)
    80005e38:	61c2                	ld	gp,16(sp)
    80005e3a:	7282                	ld	t0,32(sp)
    80005e3c:	7322                	ld	t1,40(sp)
    80005e3e:	73c2                	ld	t2,48(sp)
    80005e40:	7462                	ld	s0,56(sp)
    80005e42:	6486                	ld	s1,64(sp)
    80005e44:	6526                	ld	a0,72(sp)
    80005e46:	65c6                	ld	a1,80(sp)
    80005e48:	6666                	ld	a2,88(sp)
    80005e4a:	7686                	ld	a3,96(sp)
    80005e4c:	7726                	ld	a4,104(sp)
    80005e4e:	77c6                	ld	a5,112(sp)
    80005e50:	7866                	ld	a6,120(sp)
    80005e52:	688a                	ld	a7,128(sp)
    80005e54:	692a                	ld	s2,136(sp)
    80005e56:	69ca                	ld	s3,144(sp)
    80005e58:	6a6a                	ld	s4,152(sp)
    80005e5a:	7a8a                	ld	s5,160(sp)
    80005e5c:	7b2a                	ld	s6,168(sp)
    80005e5e:	7bca                	ld	s7,176(sp)
    80005e60:	7c6a                	ld	s8,184(sp)
    80005e62:	6c8e                	ld	s9,192(sp)
    80005e64:	6d2e                	ld	s10,200(sp)
    80005e66:	6dce                	ld	s11,208(sp)
    80005e68:	6e6e                	ld	t3,216(sp)
    80005e6a:	7e8e                	ld	t4,224(sp)
    80005e6c:	7f2e                	ld	t5,232(sp)
    80005e6e:	7fce                	ld	t6,240(sp)
    80005e70:	6111                	addi	sp,sp,256
    80005e72:	10200073          	sret
    80005e76:	00000013          	nop
    80005e7a:	00000013          	nop
    80005e7e:	0001                	nop

0000000080005e80 <timervec>:
    80005e80:	34051573          	csrrw	a0,mscratch,a0
    80005e84:	e10c                	sd	a1,0(a0)
    80005e86:	e510                	sd	a2,8(a0)
    80005e88:	e914                	sd	a3,16(a0)
    80005e8a:	6d0c                	ld	a1,24(a0)
    80005e8c:	7110                	ld	a2,32(a0)
    80005e8e:	6194                	ld	a3,0(a1)
    80005e90:	96b2                	add	a3,a3,a2
    80005e92:	e194                	sd	a3,0(a1)
    80005e94:	4589                	li	a1,2
    80005e96:	14459073          	csrw	sip,a1
    80005e9a:	6914                	ld	a3,16(a0)
    80005e9c:	6510                	ld	a2,8(a0)
    80005e9e:	610c                	ld	a1,0(a0)
    80005ea0:	34051573          	csrrw	a0,mscratch,a0
    80005ea4:	30200073          	mret
	...

0000000080005eaa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eaa:	1141                	addi	sp,sp,-16
    80005eac:	e422                	sd	s0,8(sp)
    80005eae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005eb0:	0c0007b7          	lui	a5,0xc000
    80005eb4:	4705                	li	a4,1
    80005eb6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005eb8:	c3d8                	sw	a4,4(a5)
}
    80005eba:	6422                	ld	s0,8(sp)
    80005ebc:	0141                	addi	sp,sp,16
    80005ebe:	8082                	ret

0000000080005ec0 <plicinithart>:

void
plicinithart(void)
{
    80005ec0:	1141                	addi	sp,sp,-16
    80005ec2:	e406                	sd	ra,8(sp)
    80005ec4:	e022                	sd	s0,0(sp)
    80005ec6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ec8:	ffffc097          	auipc	ra,0xffffc
    80005ecc:	ac0080e7          	jalr	-1344(ra) # 80001988 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ed0:	0085171b          	slliw	a4,a0,0x8
    80005ed4:	0c0027b7          	lui	a5,0xc002
    80005ed8:	97ba                	add	a5,a5,a4
    80005eda:	40200713          	li	a4,1026
    80005ede:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ee2:	00d5151b          	slliw	a0,a0,0xd
    80005ee6:	0c2017b7          	lui	a5,0xc201
    80005eea:	97aa                	add	a5,a5,a0
    80005eec:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005ef0:	60a2                	ld	ra,8(sp)
    80005ef2:	6402                	ld	s0,0(sp)
    80005ef4:	0141                	addi	sp,sp,16
    80005ef6:	8082                	ret

0000000080005ef8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ef8:	1141                	addi	sp,sp,-16
    80005efa:	e406                	sd	ra,8(sp)
    80005efc:	e022                	sd	s0,0(sp)
    80005efe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f00:	ffffc097          	auipc	ra,0xffffc
    80005f04:	a88080e7          	jalr	-1400(ra) # 80001988 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f08:	00d5151b          	slliw	a0,a0,0xd
    80005f0c:	0c2017b7          	lui	a5,0xc201
    80005f10:	97aa                	add	a5,a5,a0
  return irq;
}
    80005f12:	43c8                	lw	a0,4(a5)
    80005f14:	60a2                	ld	ra,8(sp)
    80005f16:	6402                	ld	s0,0(sp)
    80005f18:	0141                	addi	sp,sp,16
    80005f1a:	8082                	ret

0000000080005f1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f1c:	1101                	addi	sp,sp,-32
    80005f1e:	ec06                	sd	ra,24(sp)
    80005f20:	e822                	sd	s0,16(sp)
    80005f22:	e426                	sd	s1,8(sp)
    80005f24:	1000                	addi	s0,sp,32
    80005f26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f28:	ffffc097          	auipc	ra,0xffffc
    80005f2c:	a60080e7          	jalr	-1440(ra) # 80001988 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f30:	00d5151b          	slliw	a0,a0,0xd
    80005f34:	0c2017b7          	lui	a5,0xc201
    80005f38:	97aa                	add	a5,a5,a0
    80005f3a:	c3c4                	sw	s1,4(a5)
}
    80005f3c:	60e2                	ld	ra,24(sp)
    80005f3e:	6442                	ld	s0,16(sp)
    80005f40:	64a2                	ld	s1,8(sp)
    80005f42:	6105                	addi	sp,sp,32
    80005f44:	8082                	ret

0000000080005f46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f46:	1141                	addi	sp,sp,-16
    80005f48:	e406                	sd	ra,8(sp)
    80005f4a:	e022                	sd	s0,0(sp)
    80005f4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f4e:	479d                	li	a5,7
    80005f50:	04a7cc63          	blt	a5,a0,80005fa8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005f54:	0001c797          	auipc	a5,0x1c
    80005f58:	02c78793          	addi	a5,a5,44 # 80021f80 <disk>
    80005f5c:	97aa                	add	a5,a5,a0
    80005f5e:	0187c783          	lbu	a5,24(a5)
    80005f62:	ebb9                	bnez	a5,80005fb8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f64:	00451693          	slli	a3,a0,0x4
    80005f68:	0001c797          	auipc	a5,0x1c
    80005f6c:	01878793          	addi	a5,a5,24 # 80021f80 <disk>
    80005f70:	6398                	ld	a4,0(a5)
    80005f72:	9736                	add	a4,a4,a3
    80005f74:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005f78:	6398                	ld	a4,0(a5)
    80005f7a:	9736                	add	a4,a4,a3
    80005f7c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005f80:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005f84:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005f88:	97aa                	add	a5,a5,a0
    80005f8a:	4705                	li	a4,1
    80005f8c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005f90:	0001c517          	auipc	a0,0x1c
    80005f94:	00850513          	addi	a0,a0,8 # 80021f98 <disk+0x18>
    80005f98:	ffffc097          	auipc	ra,0xffffc
    80005f9c:	128080e7          	jalr	296(ra) # 800020c0 <wakeup>
}
    80005fa0:	60a2                	ld	ra,8(sp)
    80005fa2:	6402                	ld	s0,0(sp)
    80005fa4:	0141                	addi	sp,sp,16
    80005fa6:	8082                	ret
    panic("free_desc 1");
    80005fa8:	00002517          	auipc	a0,0x2
    80005fac:	7d050513          	addi	a0,a0,2000 # 80008778 <syscalls+0x328>
    80005fb0:	ffffa097          	auipc	ra,0xffffa
    80005fb4:	590080e7          	jalr	1424(ra) # 80000540 <panic>
    panic("free_desc 2");
    80005fb8:	00002517          	auipc	a0,0x2
    80005fbc:	7d050513          	addi	a0,a0,2000 # 80008788 <syscalls+0x338>
    80005fc0:	ffffa097          	auipc	ra,0xffffa
    80005fc4:	580080e7          	jalr	1408(ra) # 80000540 <panic>

0000000080005fc8 <virtio_disk_init>:
{
    80005fc8:	1101                	addi	sp,sp,-32
    80005fca:	ec06                	sd	ra,24(sp)
    80005fcc:	e822                	sd	s0,16(sp)
    80005fce:	e426                	sd	s1,8(sp)
    80005fd0:	e04a                	sd	s2,0(sp)
    80005fd2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fd4:	00002597          	auipc	a1,0x2
    80005fd8:	7c458593          	addi	a1,a1,1988 # 80008798 <syscalls+0x348>
    80005fdc:	0001c517          	auipc	a0,0x1c
    80005fe0:	0cc50513          	addi	a0,a0,204 # 800220a8 <disk+0x128>
    80005fe4:	ffffb097          	auipc	ra,0xffffb
    80005fe8:	b62080e7          	jalr	-1182(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fec:	100017b7          	lui	a5,0x10001
    80005ff0:	4398                	lw	a4,0(a5)
    80005ff2:	2701                	sext.w	a4,a4
    80005ff4:	747277b7          	lui	a5,0x74727
    80005ff8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ffc:	14f71b63          	bne	a4,a5,80006152 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006000:	100017b7          	lui	a5,0x10001
    80006004:	43dc                	lw	a5,4(a5)
    80006006:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006008:	4709                	li	a4,2
    8000600a:	14e79463          	bne	a5,a4,80006152 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000600e:	100017b7          	lui	a5,0x10001
    80006012:	479c                	lw	a5,8(a5)
    80006014:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006016:	12e79e63          	bne	a5,a4,80006152 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000601a:	100017b7          	lui	a5,0x10001
    8000601e:	47d8                	lw	a4,12(a5)
    80006020:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006022:	554d47b7          	lui	a5,0x554d4
    80006026:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000602a:	12f71463          	bne	a4,a5,80006152 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000602e:	100017b7          	lui	a5,0x10001
    80006032:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006036:	4705                	li	a4,1
    80006038:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000603a:	470d                	li	a4,3
    8000603c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000603e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006040:	c7ffe6b7          	lui	a3,0xc7ffe
    80006044:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc69f>
    80006048:	8f75                	and	a4,a4,a3
    8000604a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000604c:	472d                	li	a4,11
    8000604e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006050:	5bbc                	lw	a5,112(a5)
    80006052:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006056:	8ba1                	andi	a5,a5,8
    80006058:	10078563          	beqz	a5,80006162 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000605c:	100017b7          	lui	a5,0x10001
    80006060:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006064:	43fc                	lw	a5,68(a5)
    80006066:	2781                	sext.w	a5,a5
    80006068:	10079563          	bnez	a5,80006172 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000606c:	100017b7          	lui	a5,0x10001
    80006070:	5bdc                	lw	a5,52(a5)
    80006072:	2781                	sext.w	a5,a5
  if(max == 0)
    80006074:	10078763          	beqz	a5,80006182 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006078:	471d                	li	a4,7
    8000607a:	10f77c63          	bgeu	a4,a5,80006192 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000607e:	ffffb097          	auipc	ra,0xffffb
    80006082:	a68080e7          	jalr	-1432(ra) # 80000ae6 <kalloc>
    80006086:	0001c497          	auipc	s1,0x1c
    8000608a:	efa48493          	addi	s1,s1,-262 # 80021f80 <disk>
    8000608e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006090:	ffffb097          	auipc	ra,0xffffb
    80006094:	a56080e7          	jalr	-1450(ra) # 80000ae6 <kalloc>
    80006098:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000609a:	ffffb097          	auipc	ra,0xffffb
    8000609e:	a4c080e7          	jalr	-1460(ra) # 80000ae6 <kalloc>
    800060a2:	87aa                	mv	a5,a0
    800060a4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800060a6:	6088                	ld	a0,0(s1)
    800060a8:	cd6d                	beqz	a0,800061a2 <virtio_disk_init+0x1da>
    800060aa:	0001c717          	auipc	a4,0x1c
    800060ae:	ede73703          	ld	a4,-290(a4) # 80021f88 <disk+0x8>
    800060b2:	cb65                	beqz	a4,800061a2 <virtio_disk_init+0x1da>
    800060b4:	c7fd                	beqz	a5,800061a2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800060b6:	6605                	lui	a2,0x1
    800060b8:	4581                	li	a1,0
    800060ba:	ffffb097          	auipc	ra,0xffffb
    800060be:	c18080e7          	jalr	-1000(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800060c2:	0001c497          	auipc	s1,0x1c
    800060c6:	ebe48493          	addi	s1,s1,-322 # 80021f80 <disk>
    800060ca:	6605                	lui	a2,0x1
    800060cc:	4581                	li	a1,0
    800060ce:	6488                	ld	a0,8(s1)
    800060d0:	ffffb097          	auipc	ra,0xffffb
    800060d4:	c02080e7          	jalr	-1022(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800060d8:	6605                	lui	a2,0x1
    800060da:	4581                	li	a1,0
    800060dc:	6888                	ld	a0,16(s1)
    800060de:	ffffb097          	auipc	ra,0xffffb
    800060e2:	bf4080e7          	jalr	-1036(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800060e6:	100017b7          	lui	a5,0x10001
    800060ea:	4721                	li	a4,8
    800060ec:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800060ee:	4098                	lw	a4,0(s1)
    800060f0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800060f4:	40d8                	lw	a4,4(s1)
    800060f6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800060fa:	6498                	ld	a4,8(s1)
    800060fc:	0007069b          	sext.w	a3,a4
    80006100:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006104:	9701                	srai	a4,a4,0x20
    80006106:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000610a:	6898                	ld	a4,16(s1)
    8000610c:	0007069b          	sext.w	a3,a4
    80006110:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006114:	9701                	srai	a4,a4,0x20
    80006116:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000611a:	4705                	li	a4,1
    8000611c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000611e:	00e48c23          	sb	a4,24(s1)
    80006122:	00e48ca3          	sb	a4,25(s1)
    80006126:	00e48d23          	sb	a4,26(s1)
    8000612a:	00e48da3          	sb	a4,27(s1)
    8000612e:	00e48e23          	sb	a4,28(s1)
    80006132:	00e48ea3          	sb	a4,29(s1)
    80006136:	00e48f23          	sb	a4,30(s1)
    8000613a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000613e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006142:	0727a823          	sw	s2,112(a5)
}
    80006146:	60e2                	ld	ra,24(sp)
    80006148:	6442                	ld	s0,16(sp)
    8000614a:	64a2                	ld	s1,8(sp)
    8000614c:	6902                	ld	s2,0(sp)
    8000614e:	6105                	addi	sp,sp,32
    80006150:	8082                	ret
    panic("could not find virtio disk");
    80006152:	00002517          	auipc	a0,0x2
    80006156:	65650513          	addi	a0,a0,1622 # 800087a8 <syscalls+0x358>
    8000615a:	ffffa097          	auipc	ra,0xffffa
    8000615e:	3e6080e7          	jalr	998(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006162:	00002517          	auipc	a0,0x2
    80006166:	66650513          	addi	a0,a0,1638 # 800087c8 <syscalls+0x378>
    8000616a:	ffffa097          	auipc	ra,0xffffa
    8000616e:	3d6080e7          	jalr	982(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006172:	00002517          	auipc	a0,0x2
    80006176:	67650513          	addi	a0,a0,1654 # 800087e8 <syscalls+0x398>
    8000617a:	ffffa097          	auipc	ra,0xffffa
    8000617e:	3c6080e7          	jalr	966(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006182:	00002517          	auipc	a0,0x2
    80006186:	68650513          	addi	a0,a0,1670 # 80008808 <syscalls+0x3b8>
    8000618a:	ffffa097          	auipc	ra,0xffffa
    8000618e:	3b6080e7          	jalr	950(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006192:	00002517          	auipc	a0,0x2
    80006196:	69650513          	addi	a0,a0,1686 # 80008828 <syscalls+0x3d8>
    8000619a:	ffffa097          	auipc	ra,0xffffa
    8000619e:	3a6080e7          	jalr	934(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    800061a2:	00002517          	auipc	a0,0x2
    800061a6:	6a650513          	addi	a0,a0,1702 # 80008848 <syscalls+0x3f8>
    800061aa:	ffffa097          	auipc	ra,0xffffa
    800061ae:	396080e7          	jalr	918(ra) # 80000540 <panic>

00000000800061b2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061b2:	7119                	addi	sp,sp,-128
    800061b4:	fc86                	sd	ra,120(sp)
    800061b6:	f8a2                	sd	s0,112(sp)
    800061b8:	f4a6                	sd	s1,104(sp)
    800061ba:	f0ca                	sd	s2,96(sp)
    800061bc:	ecce                	sd	s3,88(sp)
    800061be:	e8d2                	sd	s4,80(sp)
    800061c0:	e4d6                	sd	s5,72(sp)
    800061c2:	e0da                	sd	s6,64(sp)
    800061c4:	fc5e                	sd	s7,56(sp)
    800061c6:	f862                	sd	s8,48(sp)
    800061c8:	f466                	sd	s9,40(sp)
    800061ca:	f06a                	sd	s10,32(sp)
    800061cc:	ec6e                	sd	s11,24(sp)
    800061ce:	0100                	addi	s0,sp,128
    800061d0:	8aaa                	mv	s5,a0
    800061d2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061d4:	00c52d03          	lw	s10,12(a0)
    800061d8:	001d1d1b          	slliw	s10,s10,0x1
    800061dc:	1d02                	slli	s10,s10,0x20
    800061de:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800061e2:	0001c517          	auipc	a0,0x1c
    800061e6:	ec650513          	addi	a0,a0,-314 # 800220a8 <disk+0x128>
    800061ea:	ffffb097          	auipc	ra,0xffffb
    800061ee:	9ec080e7          	jalr	-1556(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800061f2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800061f4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800061f6:	0001cb97          	auipc	s7,0x1c
    800061fa:	d8ab8b93          	addi	s7,s7,-630 # 80021f80 <disk>
  for(int i = 0; i < 3; i++){
    800061fe:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006200:	0001cc97          	auipc	s9,0x1c
    80006204:	ea8c8c93          	addi	s9,s9,-344 # 800220a8 <disk+0x128>
    80006208:	a08d                	j	8000626a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000620a:	00fb8733          	add	a4,s7,a5
    8000620e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006212:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006214:	0207c563          	bltz	a5,8000623e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80006218:	2905                	addiw	s2,s2,1
    8000621a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000621c:	05690c63          	beq	s2,s6,80006274 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006220:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006222:	0001c717          	auipc	a4,0x1c
    80006226:	d5e70713          	addi	a4,a4,-674 # 80021f80 <disk>
    8000622a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000622c:	01874683          	lbu	a3,24(a4)
    80006230:	fee9                	bnez	a3,8000620a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006232:	2785                	addiw	a5,a5,1
    80006234:	0705                	addi	a4,a4,1
    80006236:	fe979be3          	bne	a5,s1,8000622c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000623a:	57fd                	li	a5,-1
    8000623c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000623e:	01205d63          	blez	s2,80006258 <virtio_disk_rw+0xa6>
    80006242:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006244:	000a2503          	lw	a0,0(s4)
    80006248:	00000097          	auipc	ra,0x0
    8000624c:	cfe080e7          	jalr	-770(ra) # 80005f46 <free_desc>
      for(int j = 0; j < i; j++)
    80006250:	2d85                	addiw	s11,s11,1
    80006252:	0a11                	addi	s4,s4,4
    80006254:	ff2d98e3          	bne	s11,s2,80006244 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006258:	85e6                	mv	a1,s9
    8000625a:	0001c517          	auipc	a0,0x1c
    8000625e:	d3e50513          	addi	a0,a0,-706 # 80021f98 <disk+0x18>
    80006262:	ffffc097          	auipc	ra,0xffffc
    80006266:	dfa080e7          	jalr	-518(ra) # 8000205c <sleep>
  for(int i = 0; i < 3; i++){
    8000626a:	f8040a13          	addi	s4,s0,-128
{
    8000626e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006270:	894e                	mv	s2,s3
    80006272:	b77d                	j	80006220 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006274:	f8042503          	lw	a0,-128(s0)
    80006278:	00a50713          	addi	a4,a0,10
    8000627c:	0712                	slli	a4,a4,0x4

  if(write)
    8000627e:	0001c797          	auipc	a5,0x1c
    80006282:	d0278793          	addi	a5,a5,-766 # 80021f80 <disk>
    80006286:	00e786b3          	add	a3,a5,a4
    8000628a:	01803633          	snez	a2,s8
    8000628e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006290:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006294:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006298:	f6070613          	addi	a2,a4,-160
    8000629c:	6394                	ld	a3,0(a5)
    8000629e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062a0:	00870593          	addi	a1,a4,8
    800062a4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062a6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062a8:	0007b803          	ld	a6,0(a5)
    800062ac:	9642                	add	a2,a2,a6
    800062ae:	46c1                	li	a3,16
    800062b0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062b2:	4585                	li	a1,1
    800062b4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800062b8:	f8442683          	lw	a3,-124(s0)
    800062bc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062c0:	0692                	slli	a3,a3,0x4
    800062c2:	9836                	add	a6,a6,a3
    800062c4:	058a8613          	addi	a2,s5,88
    800062c8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800062cc:	0007b803          	ld	a6,0(a5)
    800062d0:	96c2                	add	a3,a3,a6
    800062d2:	40000613          	li	a2,1024
    800062d6:	c690                	sw	a2,8(a3)
  if(write)
    800062d8:	001c3613          	seqz	a2,s8
    800062dc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800062e0:	00166613          	ori	a2,a2,1
    800062e4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800062e8:	f8842603          	lw	a2,-120(s0)
    800062ec:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800062f0:	00250693          	addi	a3,a0,2
    800062f4:	0692                	slli	a3,a3,0x4
    800062f6:	96be                	add	a3,a3,a5
    800062f8:	58fd                	li	a7,-1
    800062fa:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800062fe:	0612                	slli	a2,a2,0x4
    80006300:	9832                	add	a6,a6,a2
    80006302:	f9070713          	addi	a4,a4,-112
    80006306:	973e                	add	a4,a4,a5
    80006308:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000630c:	6398                	ld	a4,0(a5)
    8000630e:	9732                	add	a4,a4,a2
    80006310:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006312:	4609                	li	a2,2
    80006314:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006318:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000631c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006320:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006324:	6794                	ld	a3,8(a5)
    80006326:	0026d703          	lhu	a4,2(a3)
    8000632a:	8b1d                	andi	a4,a4,7
    8000632c:	0706                	slli	a4,a4,0x1
    8000632e:	96ba                	add	a3,a3,a4
    80006330:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006334:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006338:	6798                	ld	a4,8(a5)
    8000633a:	00275783          	lhu	a5,2(a4)
    8000633e:	2785                	addiw	a5,a5,1
    80006340:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006344:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006348:	100017b7          	lui	a5,0x10001
    8000634c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006350:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006354:	0001c917          	auipc	s2,0x1c
    80006358:	d5490913          	addi	s2,s2,-684 # 800220a8 <disk+0x128>
  while(b->disk == 1) {
    8000635c:	4485                	li	s1,1
    8000635e:	00b79c63          	bne	a5,a1,80006376 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006362:	85ca                	mv	a1,s2
    80006364:	8556                	mv	a0,s5
    80006366:	ffffc097          	auipc	ra,0xffffc
    8000636a:	cf6080e7          	jalr	-778(ra) # 8000205c <sleep>
  while(b->disk == 1) {
    8000636e:	004aa783          	lw	a5,4(s5)
    80006372:	fe9788e3          	beq	a5,s1,80006362 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006376:	f8042903          	lw	s2,-128(s0)
    8000637a:	00290713          	addi	a4,s2,2
    8000637e:	0712                	slli	a4,a4,0x4
    80006380:	0001c797          	auipc	a5,0x1c
    80006384:	c0078793          	addi	a5,a5,-1024 # 80021f80 <disk>
    80006388:	97ba                	add	a5,a5,a4
    8000638a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000638e:	0001c997          	auipc	s3,0x1c
    80006392:	bf298993          	addi	s3,s3,-1038 # 80021f80 <disk>
    80006396:	00491713          	slli	a4,s2,0x4
    8000639a:	0009b783          	ld	a5,0(s3)
    8000639e:	97ba                	add	a5,a5,a4
    800063a0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063a4:	854a                	mv	a0,s2
    800063a6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063aa:	00000097          	auipc	ra,0x0
    800063ae:	b9c080e7          	jalr	-1124(ra) # 80005f46 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063b2:	8885                	andi	s1,s1,1
    800063b4:	f0ed                	bnez	s1,80006396 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063b6:	0001c517          	auipc	a0,0x1c
    800063ba:	cf250513          	addi	a0,a0,-782 # 800220a8 <disk+0x128>
    800063be:	ffffb097          	auipc	ra,0xffffb
    800063c2:	8cc080e7          	jalr	-1844(ra) # 80000c8a <release>
}
    800063c6:	70e6                	ld	ra,120(sp)
    800063c8:	7446                	ld	s0,112(sp)
    800063ca:	74a6                	ld	s1,104(sp)
    800063cc:	7906                	ld	s2,96(sp)
    800063ce:	69e6                	ld	s3,88(sp)
    800063d0:	6a46                	ld	s4,80(sp)
    800063d2:	6aa6                	ld	s5,72(sp)
    800063d4:	6b06                	ld	s6,64(sp)
    800063d6:	7be2                	ld	s7,56(sp)
    800063d8:	7c42                	ld	s8,48(sp)
    800063da:	7ca2                	ld	s9,40(sp)
    800063dc:	7d02                	ld	s10,32(sp)
    800063de:	6de2                	ld	s11,24(sp)
    800063e0:	6109                	addi	sp,sp,128
    800063e2:	8082                	ret

00000000800063e4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063e4:	1101                	addi	sp,sp,-32
    800063e6:	ec06                	sd	ra,24(sp)
    800063e8:	e822                	sd	s0,16(sp)
    800063ea:	e426                	sd	s1,8(sp)
    800063ec:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063ee:	0001c497          	auipc	s1,0x1c
    800063f2:	b9248493          	addi	s1,s1,-1134 # 80021f80 <disk>
    800063f6:	0001c517          	auipc	a0,0x1c
    800063fa:	cb250513          	addi	a0,a0,-846 # 800220a8 <disk+0x128>
    800063fe:	ffffa097          	auipc	ra,0xffffa
    80006402:	7d8080e7          	jalr	2008(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006406:	10001737          	lui	a4,0x10001
    8000640a:	533c                	lw	a5,96(a4)
    8000640c:	8b8d                	andi	a5,a5,3
    8000640e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006410:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006414:	689c                	ld	a5,16(s1)
    80006416:	0204d703          	lhu	a4,32(s1)
    8000641a:	0027d783          	lhu	a5,2(a5)
    8000641e:	04f70863          	beq	a4,a5,8000646e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006422:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006426:	6898                	ld	a4,16(s1)
    80006428:	0204d783          	lhu	a5,32(s1)
    8000642c:	8b9d                	andi	a5,a5,7
    8000642e:	078e                	slli	a5,a5,0x3
    80006430:	97ba                	add	a5,a5,a4
    80006432:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006434:	00278713          	addi	a4,a5,2
    80006438:	0712                	slli	a4,a4,0x4
    8000643a:	9726                	add	a4,a4,s1
    8000643c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006440:	e721                	bnez	a4,80006488 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006442:	0789                	addi	a5,a5,2
    80006444:	0792                	slli	a5,a5,0x4
    80006446:	97a6                	add	a5,a5,s1
    80006448:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000644a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000644e:	ffffc097          	auipc	ra,0xffffc
    80006452:	c72080e7          	jalr	-910(ra) # 800020c0 <wakeup>

    disk.used_idx += 1;
    80006456:	0204d783          	lhu	a5,32(s1)
    8000645a:	2785                	addiw	a5,a5,1
    8000645c:	17c2                	slli	a5,a5,0x30
    8000645e:	93c1                	srli	a5,a5,0x30
    80006460:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006464:	6898                	ld	a4,16(s1)
    80006466:	00275703          	lhu	a4,2(a4)
    8000646a:	faf71ce3          	bne	a4,a5,80006422 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000646e:	0001c517          	auipc	a0,0x1c
    80006472:	c3a50513          	addi	a0,a0,-966 # 800220a8 <disk+0x128>
    80006476:	ffffb097          	auipc	ra,0xffffb
    8000647a:	814080e7          	jalr	-2028(ra) # 80000c8a <release>
}
    8000647e:	60e2                	ld	ra,24(sp)
    80006480:	6442                	ld	s0,16(sp)
    80006482:	64a2                	ld	s1,8(sp)
    80006484:	6105                	addi	sp,sp,32
    80006486:	8082                	ret
      panic("virtio_disk_intr status");
    80006488:	00002517          	auipc	a0,0x2
    8000648c:	3d850513          	addi	a0,a0,984 # 80008860 <syscalls+0x410>
    80006490:	ffffa097          	auipc	ra,0xffffa
    80006494:	0b0080e7          	jalr	176(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
