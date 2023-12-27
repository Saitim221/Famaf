
user/_pingpong:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/spinlock.h"


int main(int argc, char *argv[]) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	892e                	mv	s2,a1
    int rally = atoi(argv[1]);
  10:	6588                	ld	a0,8(a1)
  12:	00000097          	auipc	ra,0x0
  16:	374080e7          	jalr	884(ra) # 386 <atoi>
  1a:	84aa                	mv	s1,a0
    int sem_code;

    int PING = 0;
    int PONG = 1;

    if (argv[1][0] == '-' || rally == 0) {
  1c:	00893783          	ld	a5,8(s2)
  20:	0007c703          	lbu	a4,0(a5)
  24:	02d00793          	li	a5,45
  28:	00f70363          	beq	a4,a5,2e <main+0x2e>
  2c:	e909                	bnez	a0,3e <main+0x3e>
        printf("ERROR: El número de rounds tiene que ser mayor a 1\n");
  2e:	00001517          	auipc	a0,0x1
  32:	99250513          	addi	a0,a0,-1646 # 9c0 <malloc+0xe6>
  36:	00000097          	auipc	ra,0x0
  3a:	7ec080e7          	jalr	2028(ra) # 822 <printf>
    }
    sem_code = sem_open(PING,1); // semáforo ping
  3e:	4585                	li	a1,1
  40:	4501                	li	a0,0
  42:	00000097          	auipc	ra,0x0
  46:	4e6080e7          	jalr	1254(ra) # 528 <sem_open>
    if (sem_code < 0) { 
  4a:	08054e63          	bltz	a0,e6 <main+0xe6>
        printf("ERROR: la cantidad máxima de semaforos es 5\n");
        exit(1);
    }
    sem_code = sem_open(PONG,0); // semáforo pong
  4e:	4581                	li	a1,0
  50:	4505                	li	a0,1
  52:	00000097          	auipc	ra,0x0
  56:	4d6080e7          	jalr	1238(ra) # 528 <sem_open>
    if (sem_code < 0) {  
  5a:	0a054363          	bltz	a0,100 <main+0x100>
        printf("ERROR: la cantidad máxima de semaforos es 5\n");
        exit(1);
    }
    
    
    rc = fork();
  5e:	00000097          	auipc	ra,0x0
  62:	41a080e7          	jalr	1050(ra) # 478 <fork>
    if (rc < 0) {
  66:	0a054a63          	bltz	a0,11a <main+0x11a>
        printf("Error haciendo fork\n");
        exit(1);
    }
    else if (rc == 0) { // hijo --> pong
  6a:	c569                	beqz	a0,134 <main+0x134>
                exit(1);
            }
        }
    }
    else { // padre --> ping
        for (unsigned int i = 0; i < rally; i++) {
  6c:	2481                	sext.w	s1,s1
  6e:	4901                	li	s2,0
            sem_code = sem_down(PING);
            if (sem_code < 0) {
                printf("ERROR: la cantidad máxima de semaforos es 5\n");
                exit(1);
            }
            printf("ping\n");
  70:	00001997          	auipc	s3,0x1
  74:	9e098993          	addi	s3,s3,-1568 # a50 <malloc+0x176>
        for (unsigned int i = 0; i < rally; i++) {
  78:	c49d                	beqz	s1,a6 <main+0xa6>
            sem_code = sem_down(PING);
  7a:	4501                	li	a0,0
  7c:	00000097          	auipc	ra,0x0
  80:	4c4080e7          	jalr	1220(ra) # 540 <sem_down>
            if (sem_code < 0) {
  84:	12054463          	bltz	a0,1ac <main+0x1ac>
            printf("ping\n");
  88:	854e                	mv	a0,s3
  8a:	00000097          	auipc	ra,0x0
  8e:	798080e7          	jalr	1944(ra) # 822 <printf>
            sem_code = sem_up(PONG);
  92:	4505                	li	a0,1
  94:	00000097          	auipc	ra,0x0
  98:	4a4080e7          	jalr	1188(ra) # 538 <sem_up>
            if (sem_code < 0) {
  9c:	12054563          	bltz	a0,1c6 <main+0x1c6>
        for (unsigned int i = 0; i < rally; i++) {
  a0:	2905                	addiw	s2,s2,1
  a2:	fc991ce3          	bne	s2,s1,7a <main+0x7a>
                printf("a pong\n");
                printf("ERROR: la cuenta no puede superar 1\n");
                exit(1);
            }
        }
        wait(0); // (int *)  ???
  a6:	4501                	li	a0,0
  a8:	00000097          	auipc	ra,0x0
  ac:	3e0080e7          	jalr	992(ra) # 488 <wait>
        sem_code = sem_close(PING);
  b0:	4501                	li	a0,0
  b2:	00000097          	auipc	ra,0x0
  b6:	47e080e7          	jalr	1150(ra) # 530 <sem_close>
        if (sem_code < 0) {
  ba:	12054363          	bltz	a0,1e0 <main+0x1e0>
        }
        else if (sem_code == -2) {
            printf("ERROR: no se puede cerrrar un semáforo que esta siendo usado\n");
            exit(1);
        }
        sem_code = sem_close(PONG);
  be:	4505                	li	a0,1
  c0:	00000097          	auipc	ra,0x0
  c4:	470080e7          	jalr	1136(ra) # 530 <sem_close>
        if (sem_code < 0) {
  c8:	0a055363          	bgez	a0,16e <main+0x16e>
            printf("ERROR: la cantidad máxima de semaforos es 5\n");
  cc:	00001517          	auipc	a0,0x1
  d0:	92c50513          	addi	a0,a0,-1748 # 9f8 <malloc+0x11e>
  d4:	00000097          	auipc	ra,0x0
  d8:	74e080e7          	jalr	1870(ra) # 822 <printf>
            exit(1);
  dc:	4505                	li	a0,1
  de:	00000097          	auipc	ra,0x0
  e2:	3a2080e7          	jalr	930(ra) # 480 <exit>
        printf("ERROR: la cantidad máxima de semaforos es 5\n");
  e6:	00001517          	auipc	a0,0x1
  ea:	91250513          	addi	a0,a0,-1774 # 9f8 <malloc+0x11e>
  ee:	00000097          	auipc	ra,0x0
  f2:	734080e7          	jalr	1844(ra) # 822 <printf>
        exit(1);
  f6:	4505                	li	a0,1
  f8:	00000097          	auipc	ra,0x0
  fc:	388080e7          	jalr	904(ra) # 480 <exit>
        printf("ERROR: la cantidad máxima de semaforos es 5\n");
 100:	00001517          	auipc	a0,0x1
 104:	8f850513          	addi	a0,a0,-1800 # 9f8 <malloc+0x11e>
 108:	00000097          	auipc	ra,0x0
 10c:	71a080e7          	jalr	1818(ra) # 822 <printf>
        exit(1);
 110:	4505                	li	a0,1
 112:	00000097          	auipc	ra,0x0
 116:	36e080e7          	jalr	878(ra) # 480 <exit>
        printf("Error haciendo fork\n");
 11a:	00001517          	auipc	a0,0x1
 11e:	90e50513          	addi	a0,a0,-1778 # a28 <malloc+0x14e>
 122:	00000097          	auipc	ra,0x0
 126:	700080e7          	jalr	1792(ra) # 822 <printf>
        exit(1);
 12a:	4505                	li	a0,1
 12c:	00000097          	auipc	ra,0x0
 130:	354080e7          	jalr	852(ra) # 480 <exit>
        for (unsigned int i = 0; i < rally; i++) {
 134:	2481                	sext.w	s1,s1
 136:	cc85                	beqz	s1,16e <main+0x16e>
 138:	4901                	li	s2,0
            printf("    pong\n");
 13a:	00001997          	auipc	s3,0x1
 13e:	90698993          	addi	s3,s3,-1786 # a40 <malloc+0x166>
            sem_code = sem_down(PONG);
 142:	4505                	li	a0,1
 144:	00000097          	auipc	ra,0x0
 148:	3fc080e7          	jalr	1020(ra) # 540 <sem_down>
            if (sem_code < 0) {
 14c:	02054663          	bltz	a0,178 <main+0x178>
            printf("    pong\n");
 150:	854e                	mv	a0,s3
 152:	00000097          	auipc	ra,0x0
 156:	6d0080e7          	jalr	1744(ra) # 822 <printf>
            sem_code = sem_up(PING);
 15a:	4501                	li	a0,0
 15c:	00000097          	auipc	ra,0x0
 160:	3dc080e7          	jalr	988(ra) # 538 <sem_up>
            if (sem_code < 0) {
 164:	02054763          	bltz	a0,192 <main+0x192>
        for (unsigned int i = 0; i < rally; i++) {
 168:	2905                	addiw	s2,s2,1
 16a:	fc991ce3          	bne	s2,s1,142 <main+0x142>
        else if (sem_code == -2) {
            printf("ERROR: no se puede cerrrar un semáforo que esta siendo usado\n");
            exit(1);
        }
    }
    exit(0);
 16e:	4501                	li	a0,0
 170:	00000097          	auipc	ra,0x0
 174:	310080e7          	jalr	784(ra) # 480 <exit>
                printf("ERROR: la cantidad máxima de semaforos es 5\n");
 178:	00001517          	auipc	a0,0x1
 17c:	88050513          	addi	a0,a0,-1920 # 9f8 <malloc+0x11e>
 180:	00000097          	auipc	ra,0x0
 184:	6a2080e7          	jalr	1698(ra) # 822 <printf>
                exit(1);
 188:	4505                	li	a0,1
 18a:	00000097          	auipc	ra,0x0
 18e:	2f6080e7          	jalr	758(ra) # 480 <exit>
                printf("ERROR: la cantidad máxima de semaforos es 5\n");
 192:	00001517          	auipc	a0,0x1
 196:	86650513          	addi	a0,a0,-1946 # 9f8 <malloc+0x11e>
 19a:	00000097          	auipc	ra,0x0
 19e:	688080e7          	jalr	1672(ra) # 822 <printf>
                exit(1);
 1a2:	4505                	li	a0,1
 1a4:	00000097          	auipc	ra,0x0
 1a8:	2dc080e7          	jalr	732(ra) # 480 <exit>
                printf("ERROR: la cantidad máxima de semaforos es 5\n");
 1ac:	00001517          	auipc	a0,0x1
 1b0:	84c50513          	addi	a0,a0,-1972 # 9f8 <malloc+0x11e>
 1b4:	00000097          	auipc	ra,0x0
 1b8:	66e080e7          	jalr	1646(ra) # 822 <printf>
                exit(1);
 1bc:	4505                	li	a0,1
 1be:	00000097          	auipc	ra,0x0
 1c2:	2c2080e7          	jalr	706(ra) # 480 <exit>
                printf("ERROR: la cantidad máxima de semaforos es 5\n");
 1c6:	00001517          	auipc	a0,0x1
 1ca:	83250513          	addi	a0,a0,-1998 # 9f8 <malloc+0x11e>
 1ce:	00000097          	auipc	ra,0x0
 1d2:	654080e7          	jalr	1620(ra) # 822 <printf>
                exit(1);
 1d6:	4505                	li	a0,1
 1d8:	00000097          	auipc	ra,0x0
 1dc:	2a8080e7          	jalr	680(ra) # 480 <exit>
            printf("ERROR: la cantidad máxima de semaforos es 5\n");
 1e0:	00001517          	auipc	a0,0x1
 1e4:	81850513          	addi	a0,a0,-2024 # 9f8 <malloc+0x11e>
 1e8:	00000097          	auipc	ra,0x0
 1ec:	63a080e7          	jalr	1594(ra) # 822 <printf>
            exit(1);
 1f0:	4505                	li	a0,1
 1f2:	00000097          	auipc	ra,0x0
 1f6:	28e080e7          	jalr	654(ra) # 480 <exit>

00000000000001fa <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e406                	sd	ra,8(sp)
 1fe:	e022                	sd	s0,0(sp)
 200:	0800                	addi	s0,sp,16
  extern int main();
  main();
 202:	00000097          	auipc	ra,0x0
 206:	dfe080e7          	jalr	-514(ra) # 0 <main>
  exit(0);
 20a:	4501                	li	a0,0
 20c:	00000097          	auipc	ra,0x0
 210:	274080e7          	jalr	628(ra) # 480 <exit>

0000000000000214 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 214:	1141                	addi	sp,sp,-16
 216:	e422                	sd	s0,8(sp)
 218:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 21a:	87aa                	mv	a5,a0
 21c:	0585                	addi	a1,a1,1
 21e:	0785                	addi	a5,a5,1
 220:	fff5c703          	lbu	a4,-1(a1)
 224:	fee78fa3          	sb	a4,-1(a5)
 228:	fb75                	bnez	a4,21c <strcpy+0x8>
    ;
  return os;
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret

0000000000000230 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 230:	1141                	addi	sp,sp,-16
 232:	e422                	sd	s0,8(sp)
 234:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 236:	00054783          	lbu	a5,0(a0)
 23a:	cb91                	beqz	a5,24e <strcmp+0x1e>
 23c:	0005c703          	lbu	a4,0(a1)
 240:	00f71763          	bne	a4,a5,24e <strcmp+0x1e>
    p++, q++;
 244:	0505                	addi	a0,a0,1
 246:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 248:	00054783          	lbu	a5,0(a0)
 24c:	fbe5                	bnez	a5,23c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 24e:	0005c503          	lbu	a0,0(a1)
}
 252:	40a7853b          	subw	a0,a5,a0
 256:	6422                	ld	s0,8(sp)
 258:	0141                	addi	sp,sp,16
 25a:	8082                	ret

000000000000025c <strlen>:

uint
strlen(const char *s)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e422                	sd	s0,8(sp)
 260:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 262:	00054783          	lbu	a5,0(a0)
 266:	cf91                	beqz	a5,282 <strlen+0x26>
 268:	0505                	addi	a0,a0,1
 26a:	87aa                	mv	a5,a0
 26c:	4685                	li	a3,1
 26e:	9e89                	subw	a3,a3,a0
 270:	00f6853b          	addw	a0,a3,a5
 274:	0785                	addi	a5,a5,1
 276:	fff7c703          	lbu	a4,-1(a5)
 27a:	fb7d                	bnez	a4,270 <strlen+0x14>
    ;
  return n;
}
 27c:	6422                	ld	s0,8(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret
  for(n = 0; s[n]; n++)
 282:	4501                	li	a0,0
 284:	bfe5                	j	27c <strlen+0x20>

0000000000000286 <memset>:

void*
memset(void *dst, int c, uint n)
{
 286:	1141                	addi	sp,sp,-16
 288:	e422                	sd	s0,8(sp)
 28a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 28c:	ca19                	beqz	a2,2a2 <memset+0x1c>
 28e:	87aa                	mv	a5,a0
 290:	1602                	slli	a2,a2,0x20
 292:	9201                	srli	a2,a2,0x20
 294:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 298:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 29c:	0785                	addi	a5,a5,1
 29e:	fee79de3          	bne	a5,a4,298 <memset+0x12>
  }
  return dst;
}
 2a2:	6422                	ld	s0,8(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret

00000000000002a8 <strchr>:

char*
strchr(const char *s, char c)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e422                	sd	s0,8(sp)
 2ac:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2ae:	00054783          	lbu	a5,0(a0)
 2b2:	cb99                	beqz	a5,2c8 <strchr+0x20>
    if(*s == c)
 2b4:	00f58763          	beq	a1,a5,2c2 <strchr+0x1a>
  for(; *s; s++)
 2b8:	0505                	addi	a0,a0,1
 2ba:	00054783          	lbu	a5,0(a0)
 2be:	fbfd                	bnez	a5,2b4 <strchr+0xc>
      return (char*)s;
  return 0;
 2c0:	4501                	li	a0,0
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret
  return 0;
 2c8:	4501                	li	a0,0
 2ca:	bfe5                	j	2c2 <strchr+0x1a>

00000000000002cc <gets>:

char*
gets(char *buf, int max)
{
 2cc:	711d                	addi	sp,sp,-96
 2ce:	ec86                	sd	ra,88(sp)
 2d0:	e8a2                	sd	s0,80(sp)
 2d2:	e4a6                	sd	s1,72(sp)
 2d4:	e0ca                	sd	s2,64(sp)
 2d6:	fc4e                	sd	s3,56(sp)
 2d8:	f852                	sd	s4,48(sp)
 2da:	f456                	sd	s5,40(sp)
 2dc:	f05a                	sd	s6,32(sp)
 2de:	ec5e                	sd	s7,24(sp)
 2e0:	1080                	addi	s0,sp,96
 2e2:	8baa                	mv	s7,a0
 2e4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e6:	892a                	mv	s2,a0
 2e8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ea:	4aa9                	li	s5,10
 2ec:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2ee:	89a6                	mv	s3,s1
 2f0:	2485                	addiw	s1,s1,1
 2f2:	0344d863          	bge	s1,s4,322 <gets+0x56>
    cc = read(0, &c, 1);
 2f6:	4605                	li	a2,1
 2f8:	faf40593          	addi	a1,s0,-81
 2fc:	4501                	li	a0,0
 2fe:	00000097          	auipc	ra,0x0
 302:	19a080e7          	jalr	410(ra) # 498 <read>
    if(cc < 1)
 306:	00a05e63          	blez	a0,322 <gets+0x56>
    buf[i++] = c;
 30a:	faf44783          	lbu	a5,-81(s0)
 30e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 312:	01578763          	beq	a5,s5,320 <gets+0x54>
 316:	0905                	addi	s2,s2,1
 318:	fd679be3          	bne	a5,s6,2ee <gets+0x22>
  for(i=0; i+1 < max; ){
 31c:	89a6                	mv	s3,s1
 31e:	a011                	j	322 <gets+0x56>
 320:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 322:	99de                	add	s3,s3,s7
 324:	00098023          	sb	zero,0(s3)
  return buf;
}
 328:	855e                	mv	a0,s7
 32a:	60e6                	ld	ra,88(sp)
 32c:	6446                	ld	s0,80(sp)
 32e:	64a6                	ld	s1,72(sp)
 330:	6906                	ld	s2,64(sp)
 332:	79e2                	ld	s3,56(sp)
 334:	7a42                	ld	s4,48(sp)
 336:	7aa2                	ld	s5,40(sp)
 338:	7b02                	ld	s6,32(sp)
 33a:	6be2                	ld	s7,24(sp)
 33c:	6125                	addi	sp,sp,96
 33e:	8082                	ret

0000000000000340 <stat>:

int
stat(const char *n, struct stat *st)
{
 340:	1101                	addi	sp,sp,-32
 342:	ec06                	sd	ra,24(sp)
 344:	e822                	sd	s0,16(sp)
 346:	e426                	sd	s1,8(sp)
 348:	e04a                	sd	s2,0(sp)
 34a:	1000                	addi	s0,sp,32
 34c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 34e:	4581                	li	a1,0
 350:	00000097          	auipc	ra,0x0
 354:	170080e7          	jalr	368(ra) # 4c0 <open>
  if(fd < 0)
 358:	02054563          	bltz	a0,382 <stat+0x42>
 35c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 35e:	85ca                	mv	a1,s2
 360:	00000097          	auipc	ra,0x0
 364:	178080e7          	jalr	376(ra) # 4d8 <fstat>
 368:	892a                	mv	s2,a0
  close(fd);
 36a:	8526                	mv	a0,s1
 36c:	00000097          	auipc	ra,0x0
 370:	13c080e7          	jalr	316(ra) # 4a8 <close>
  return r;
}
 374:	854a                	mv	a0,s2
 376:	60e2                	ld	ra,24(sp)
 378:	6442                	ld	s0,16(sp)
 37a:	64a2                	ld	s1,8(sp)
 37c:	6902                	ld	s2,0(sp)
 37e:	6105                	addi	sp,sp,32
 380:	8082                	ret
    return -1;
 382:	597d                	li	s2,-1
 384:	bfc5                	j	374 <stat+0x34>

0000000000000386 <atoi>:

int
atoi(const char *s)
{
 386:	1141                	addi	sp,sp,-16
 388:	e422                	sd	s0,8(sp)
 38a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 38c:	00054683          	lbu	a3,0(a0)
 390:	fd06879b          	addiw	a5,a3,-48
 394:	0ff7f793          	zext.b	a5,a5
 398:	4625                	li	a2,9
 39a:	02f66863          	bltu	a2,a5,3ca <atoi+0x44>
 39e:	872a                	mv	a4,a0
  n = 0;
 3a0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3a2:	0705                	addi	a4,a4,1
 3a4:	0025179b          	slliw	a5,a0,0x2
 3a8:	9fa9                	addw	a5,a5,a0
 3aa:	0017979b          	slliw	a5,a5,0x1
 3ae:	9fb5                	addw	a5,a5,a3
 3b0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3b4:	00074683          	lbu	a3,0(a4)
 3b8:	fd06879b          	addiw	a5,a3,-48
 3bc:	0ff7f793          	zext.b	a5,a5
 3c0:	fef671e3          	bgeu	a2,a5,3a2 <atoi+0x1c>
  return n;
}
 3c4:	6422                	ld	s0,8(sp)
 3c6:	0141                	addi	sp,sp,16
 3c8:	8082                	ret
  n = 0;
 3ca:	4501                	li	a0,0
 3cc:	bfe5                	j	3c4 <atoi+0x3e>

00000000000003ce <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3ce:	1141                	addi	sp,sp,-16
 3d0:	e422                	sd	s0,8(sp)
 3d2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3d4:	02b57463          	bgeu	a0,a1,3fc <memmove+0x2e>
    while(n-- > 0)
 3d8:	00c05f63          	blez	a2,3f6 <memmove+0x28>
 3dc:	1602                	slli	a2,a2,0x20
 3de:	9201                	srli	a2,a2,0x20
 3e0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3e4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3e6:	0585                	addi	a1,a1,1
 3e8:	0705                	addi	a4,a4,1
 3ea:	fff5c683          	lbu	a3,-1(a1)
 3ee:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3f2:	fee79ae3          	bne	a5,a4,3e6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3f6:	6422                	ld	s0,8(sp)
 3f8:	0141                	addi	sp,sp,16
 3fa:	8082                	ret
    dst += n;
 3fc:	00c50733          	add	a4,a0,a2
    src += n;
 400:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 402:	fec05ae3          	blez	a2,3f6 <memmove+0x28>
 406:	fff6079b          	addiw	a5,a2,-1
 40a:	1782                	slli	a5,a5,0x20
 40c:	9381                	srli	a5,a5,0x20
 40e:	fff7c793          	not	a5,a5
 412:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 414:	15fd                	addi	a1,a1,-1
 416:	177d                	addi	a4,a4,-1
 418:	0005c683          	lbu	a3,0(a1)
 41c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 420:	fee79ae3          	bne	a5,a4,414 <memmove+0x46>
 424:	bfc9                	j	3f6 <memmove+0x28>

0000000000000426 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 426:	1141                	addi	sp,sp,-16
 428:	e422                	sd	s0,8(sp)
 42a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 42c:	ca05                	beqz	a2,45c <memcmp+0x36>
 42e:	fff6069b          	addiw	a3,a2,-1
 432:	1682                	slli	a3,a3,0x20
 434:	9281                	srli	a3,a3,0x20
 436:	0685                	addi	a3,a3,1
 438:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 43a:	00054783          	lbu	a5,0(a0)
 43e:	0005c703          	lbu	a4,0(a1)
 442:	00e79863          	bne	a5,a4,452 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 446:	0505                	addi	a0,a0,1
    p2++;
 448:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 44a:	fed518e3          	bne	a0,a3,43a <memcmp+0x14>
  }
  return 0;
 44e:	4501                	li	a0,0
 450:	a019                	j	456 <memcmp+0x30>
      return *p1 - *p2;
 452:	40e7853b          	subw	a0,a5,a4
}
 456:	6422                	ld	s0,8(sp)
 458:	0141                	addi	sp,sp,16
 45a:	8082                	ret
  return 0;
 45c:	4501                	li	a0,0
 45e:	bfe5                	j	456 <memcmp+0x30>

0000000000000460 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 460:	1141                	addi	sp,sp,-16
 462:	e406                	sd	ra,8(sp)
 464:	e022                	sd	s0,0(sp)
 466:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 468:	00000097          	auipc	ra,0x0
 46c:	f66080e7          	jalr	-154(ra) # 3ce <memmove>
}
 470:	60a2                	ld	ra,8(sp)
 472:	6402                	ld	s0,0(sp)
 474:	0141                	addi	sp,sp,16
 476:	8082                	ret

0000000000000478 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 478:	4885                	li	a7,1
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <exit>:
.global exit
exit:
 li a7, SYS_exit
 480:	4889                	li	a7,2
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <wait>:
.global wait
wait:
 li a7, SYS_wait
 488:	488d                	li	a7,3
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 490:	4891                	li	a7,4
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <read>:
.global read
read:
 li a7, SYS_read
 498:	4895                	li	a7,5
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <write>:
.global write
write:
 li a7, SYS_write
 4a0:	48c1                	li	a7,16
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <close>:
.global close
close:
 li a7, SYS_close
 4a8:	48d5                	li	a7,21
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4b0:	4899                	li	a7,6
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4b8:	489d                	li	a7,7
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <open>:
.global open
open:
 li a7, SYS_open
 4c0:	48bd                	li	a7,15
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4c8:	48c5                	li	a7,17
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4d0:	48c9                	li	a7,18
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4d8:	48a1                	li	a7,8
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <link>:
.global link
link:
 li a7, SYS_link
 4e0:	48cd                	li	a7,19
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4e8:	48d1                	li	a7,20
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4f0:	48a5                	li	a7,9
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4f8:	48a9                	li	a7,10
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 500:	48ad                	li	a7,11
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 508:	48b1                	li	a7,12
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 510:	48b5                	li	a7,13
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 518:	48b9                	li	a7,14
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <hello>:
.global hello
hello:
 li a7, SYS_hello
 520:	48d9                	li	a7,22
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 528:	48dd                	li	a7,23
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <sem_close>:
.global sem_close
sem_close:
 li a7, SYS_sem_close
 530:	48e9                	li	a7,26
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <sem_up>:
.global sem_up
sem_up:
 li a7, SYS_sem_up
 538:	48e1                	li	a7,24
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <sem_down>:
.global sem_down
sem_down:
 li a7, SYS_sem_down
 540:	48e5                	li	a7,25
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 548:	1101                	addi	sp,sp,-32
 54a:	ec06                	sd	ra,24(sp)
 54c:	e822                	sd	s0,16(sp)
 54e:	1000                	addi	s0,sp,32
 550:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 554:	4605                	li	a2,1
 556:	fef40593          	addi	a1,s0,-17
 55a:	00000097          	auipc	ra,0x0
 55e:	f46080e7          	jalr	-186(ra) # 4a0 <write>
}
 562:	60e2                	ld	ra,24(sp)
 564:	6442                	ld	s0,16(sp)
 566:	6105                	addi	sp,sp,32
 568:	8082                	ret

000000000000056a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 56a:	7139                	addi	sp,sp,-64
 56c:	fc06                	sd	ra,56(sp)
 56e:	f822                	sd	s0,48(sp)
 570:	f426                	sd	s1,40(sp)
 572:	f04a                	sd	s2,32(sp)
 574:	ec4e                	sd	s3,24(sp)
 576:	0080                	addi	s0,sp,64
 578:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 57a:	c299                	beqz	a3,580 <printint+0x16>
 57c:	0805c963          	bltz	a1,60e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 580:	2581                	sext.w	a1,a1
  neg = 0;
 582:	4881                	li	a7,0
 584:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 588:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 58a:	2601                	sext.w	a2,a2
 58c:	00000517          	auipc	a0,0x0
 590:	52c50513          	addi	a0,a0,1324 # ab8 <digits>
 594:	883a                	mv	a6,a4
 596:	2705                	addiw	a4,a4,1
 598:	02c5f7bb          	remuw	a5,a1,a2
 59c:	1782                	slli	a5,a5,0x20
 59e:	9381                	srli	a5,a5,0x20
 5a0:	97aa                	add	a5,a5,a0
 5a2:	0007c783          	lbu	a5,0(a5)
 5a6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5aa:	0005879b          	sext.w	a5,a1
 5ae:	02c5d5bb          	divuw	a1,a1,a2
 5b2:	0685                	addi	a3,a3,1
 5b4:	fec7f0e3          	bgeu	a5,a2,594 <printint+0x2a>
  if(neg)
 5b8:	00088c63          	beqz	a7,5d0 <printint+0x66>
    buf[i++] = '-';
 5bc:	fd070793          	addi	a5,a4,-48
 5c0:	00878733          	add	a4,a5,s0
 5c4:	02d00793          	li	a5,45
 5c8:	fef70823          	sb	a5,-16(a4)
 5cc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5d0:	02e05863          	blez	a4,600 <printint+0x96>
 5d4:	fc040793          	addi	a5,s0,-64
 5d8:	00e78933          	add	s2,a5,a4
 5dc:	fff78993          	addi	s3,a5,-1
 5e0:	99ba                	add	s3,s3,a4
 5e2:	377d                	addiw	a4,a4,-1
 5e4:	1702                	slli	a4,a4,0x20
 5e6:	9301                	srli	a4,a4,0x20
 5e8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5ec:	fff94583          	lbu	a1,-1(s2)
 5f0:	8526                	mv	a0,s1
 5f2:	00000097          	auipc	ra,0x0
 5f6:	f56080e7          	jalr	-170(ra) # 548 <putc>
  while(--i >= 0)
 5fa:	197d                	addi	s2,s2,-1
 5fc:	ff3918e3          	bne	s2,s3,5ec <printint+0x82>
}
 600:	70e2                	ld	ra,56(sp)
 602:	7442                	ld	s0,48(sp)
 604:	74a2                	ld	s1,40(sp)
 606:	7902                	ld	s2,32(sp)
 608:	69e2                	ld	s3,24(sp)
 60a:	6121                	addi	sp,sp,64
 60c:	8082                	ret
    x = -xx;
 60e:	40b005bb          	negw	a1,a1
    neg = 1;
 612:	4885                	li	a7,1
    x = -xx;
 614:	bf85                	j	584 <printint+0x1a>

0000000000000616 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 616:	7119                	addi	sp,sp,-128
 618:	fc86                	sd	ra,120(sp)
 61a:	f8a2                	sd	s0,112(sp)
 61c:	f4a6                	sd	s1,104(sp)
 61e:	f0ca                	sd	s2,96(sp)
 620:	ecce                	sd	s3,88(sp)
 622:	e8d2                	sd	s4,80(sp)
 624:	e4d6                	sd	s5,72(sp)
 626:	e0da                	sd	s6,64(sp)
 628:	fc5e                	sd	s7,56(sp)
 62a:	f862                	sd	s8,48(sp)
 62c:	f466                	sd	s9,40(sp)
 62e:	f06a                	sd	s10,32(sp)
 630:	ec6e                	sd	s11,24(sp)
 632:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 634:	0005c903          	lbu	s2,0(a1)
 638:	18090f63          	beqz	s2,7d6 <vprintf+0x1c0>
 63c:	8aaa                	mv	s5,a0
 63e:	8b32                	mv	s6,a2
 640:	00158493          	addi	s1,a1,1
  state = 0;
 644:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 646:	02500a13          	li	s4,37
 64a:	4c55                	li	s8,21
 64c:	00000c97          	auipc	s9,0x0
 650:	414c8c93          	addi	s9,s9,1044 # a60 <malloc+0x186>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 654:	02800d93          	li	s11,40
  putc(fd, 'x');
 658:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65a:	00000b97          	auipc	s7,0x0
 65e:	45eb8b93          	addi	s7,s7,1118 # ab8 <digits>
 662:	a839                	j	680 <vprintf+0x6a>
        putc(fd, c);
 664:	85ca                	mv	a1,s2
 666:	8556                	mv	a0,s5
 668:	00000097          	auipc	ra,0x0
 66c:	ee0080e7          	jalr	-288(ra) # 548 <putc>
 670:	a019                	j	676 <vprintf+0x60>
    } else if(state == '%'){
 672:	01498d63          	beq	s3,s4,68c <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 676:	0485                	addi	s1,s1,1
 678:	fff4c903          	lbu	s2,-1(s1)
 67c:	14090d63          	beqz	s2,7d6 <vprintf+0x1c0>
    if(state == 0){
 680:	fe0999e3          	bnez	s3,672 <vprintf+0x5c>
      if(c == '%'){
 684:	ff4910e3          	bne	s2,s4,664 <vprintf+0x4e>
        state = '%';
 688:	89d2                	mv	s3,s4
 68a:	b7f5                	j	676 <vprintf+0x60>
      if(c == 'd'){
 68c:	11490c63          	beq	s2,s4,7a4 <vprintf+0x18e>
 690:	f9d9079b          	addiw	a5,s2,-99
 694:	0ff7f793          	zext.b	a5,a5
 698:	10fc6e63          	bltu	s8,a5,7b4 <vprintf+0x19e>
 69c:	f9d9079b          	addiw	a5,s2,-99
 6a0:	0ff7f713          	zext.b	a4,a5
 6a4:	10ec6863          	bltu	s8,a4,7b4 <vprintf+0x19e>
 6a8:	00271793          	slli	a5,a4,0x2
 6ac:	97e6                	add	a5,a5,s9
 6ae:	439c                	lw	a5,0(a5)
 6b0:	97e6                	add	a5,a5,s9
 6b2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6b4:	008b0913          	addi	s2,s6,8
 6b8:	4685                	li	a3,1
 6ba:	4629                	li	a2,10
 6bc:	000b2583          	lw	a1,0(s6)
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	ea8080e7          	jalr	-344(ra) # 56a <printint>
 6ca:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b765                	j	676 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d0:	008b0913          	addi	s2,s6,8
 6d4:	4681                	li	a3,0
 6d6:	4629                	li	a2,10
 6d8:	000b2583          	lw	a1,0(s6)
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	e8c080e7          	jalr	-372(ra) # 56a <printint>
 6e6:	8b4a                	mv	s6,s2
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	b771                	j	676 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6ec:	008b0913          	addi	s2,s6,8
 6f0:	4681                	li	a3,0
 6f2:	866a                	mv	a2,s10
 6f4:	000b2583          	lw	a1,0(s6)
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	e70080e7          	jalr	-400(ra) # 56a <printint>
 702:	8b4a                	mv	s6,s2
      state = 0;
 704:	4981                	li	s3,0
 706:	bf85                	j	676 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 708:	008b0793          	addi	a5,s6,8
 70c:	f8f43423          	sd	a5,-120(s0)
 710:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 714:	03000593          	li	a1,48
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	e2e080e7          	jalr	-466(ra) # 548 <putc>
  putc(fd, 'x');
 722:	07800593          	li	a1,120
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	e20080e7          	jalr	-480(ra) # 548 <putc>
 730:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 732:	03c9d793          	srli	a5,s3,0x3c
 736:	97de                	add	a5,a5,s7
 738:	0007c583          	lbu	a1,0(a5)
 73c:	8556                	mv	a0,s5
 73e:	00000097          	auipc	ra,0x0
 742:	e0a080e7          	jalr	-502(ra) # 548 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 746:	0992                	slli	s3,s3,0x4
 748:	397d                	addiw	s2,s2,-1
 74a:	fe0914e3          	bnez	s2,732 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 74e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 752:	4981                	li	s3,0
 754:	b70d                	j	676 <vprintf+0x60>
        s = va_arg(ap, char*);
 756:	008b0913          	addi	s2,s6,8
 75a:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 75e:	02098163          	beqz	s3,780 <vprintf+0x16a>
        while(*s != 0){
 762:	0009c583          	lbu	a1,0(s3)
 766:	c5ad                	beqz	a1,7d0 <vprintf+0x1ba>
          putc(fd, *s);
 768:	8556                	mv	a0,s5
 76a:	00000097          	auipc	ra,0x0
 76e:	dde080e7          	jalr	-546(ra) # 548 <putc>
          s++;
 772:	0985                	addi	s3,s3,1
        while(*s != 0){
 774:	0009c583          	lbu	a1,0(s3)
 778:	f9e5                	bnez	a1,768 <vprintf+0x152>
        s = va_arg(ap, char*);
 77a:	8b4a                	mv	s6,s2
      state = 0;
 77c:	4981                	li	s3,0
 77e:	bde5                	j	676 <vprintf+0x60>
          s = "(null)";
 780:	00000997          	auipc	s3,0x0
 784:	2d898993          	addi	s3,s3,728 # a58 <malloc+0x17e>
        while(*s != 0){
 788:	85ee                	mv	a1,s11
 78a:	bff9                	j	768 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 78c:	008b0913          	addi	s2,s6,8
 790:	000b4583          	lbu	a1,0(s6)
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	db2080e7          	jalr	-590(ra) # 548 <putc>
 79e:	8b4a                	mv	s6,s2
      state = 0;
 7a0:	4981                	li	s3,0
 7a2:	bdd1                	j	676 <vprintf+0x60>
        putc(fd, c);
 7a4:	85d2                	mv	a1,s4
 7a6:	8556                	mv	a0,s5
 7a8:	00000097          	auipc	ra,0x0
 7ac:	da0080e7          	jalr	-608(ra) # 548 <putc>
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	b5d1                	j	676 <vprintf+0x60>
        putc(fd, '%');
 7b4:	85d2                	mv	a1,s4
 7b6:	8556                	mv	a0,s5
 7b8:	00000097          	auipc	ra,0x0
 7bc:	d90080e7          	jalr	-624(ra) # 548 <putc>
        putc(fd, c);
 7c0:	85ca                	mv	a1,s2
 7c2:	8556                	mv	a0,s5
 7c4:	00000097          	auipc	ra,0x0
 7c8:	d84080e7          	jalr	-636(ra) # 548 <putc>
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	b565                	j	676 <vprintf+0x60>
        s = va_arg(ap, char*);
 7d0:	8b4a                	mv	s6,s2
      state = 0;
 7d2:	4981                	li	s3,0
 7d4:	b54d                	j	676 <vprintf+0x60>
    }
  }
}
 7d6:	70e6                	ld	ra,120(sp)
 7d8:	7446                	ld	s0,112(sp)
 7da:	74a6                	ld	s1,104(sp)
 7dc:	7906                	ld	s2,96(sp)
 7de:	69e6                	ld	s3,88(sp)
 7e0:	6a46                	ld	s4,80(sp)
 7e2:	6aa6                	ld	s5,72(sp)
 7e4:	6b06                	ld	s6,64(sp)
 7e6:	7be2                	ld	s7,56(sp)
 7e8:	7c42                	ld	s8,48(sp)
 7ea:	7ca2                	ld	s9,40(sp)
 7ec:	7d02                	ld	s10,32(sp)
 7ee:	6de2                	ld	s11,24(sp)
 7f0:	6109                	addi	sp,sp,128
 7f2:	8082                	ret

00000000000007f4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7f4:	715d                	addi	sp,sp,-80
 7f6:	ec06                	sd	ra,24(sp)
 7f8:	e822                	sd	s0,16(sp)
 7fa:	1000                	addi	s0,sp,32
 7fc:	e010                	sd	a2,0(s0)
 7fe:	e414                	sd	a3,8(s0)
 800:	e818                	sd	a4,16(s0)
 802:	ec1c                	sd	a5,24(s0)
 804:	03043023          	sd	a6,32(s0)
 808:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 80c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 810:	8622                	mv	a2,s0
 812:	00000097          	auipc	ra,0x0
 816:	e04080e7          	jalr	-508(ra) # 616 <vprintf>
}
 81a:	60e2                	ld	ra,24(sp)
 81c:	6442                	ld	s0,16(sp)
 81e:	6161                	addi	sp,sp,80
 820:	8082                	ret

0000000000000822 <printf>:

void
printf(const char *fmt, ...)
{
 822:	711d                	addi	sp,sp,-96
 824:	ec06                	sd	ra,24(sp)
 826:	e822                	sd	s0,16(sp)
 828:	1000                	addi	s0,sp,32
 82a:	e40c                	sd	a1,8(s0)
 82c:	e810                	sd	a2,16(s0)
 82e:	ec14                	sd	a3,24(s0)
 830:	f018                	sd	a4,32(s0)
 832:	f41c                	sd	a5,40(s0)
 834:	03043823          	sd	a6,48(s0)
 838:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 83c:	00840613          	addi	a2,s0,8
 840:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 844:	85aa                	mv	a1,a0
 846:	4505                	li	a0,1
 848:	00000097          	auipc	ra,0x0
 84c:	dce080e7          	jalr	-562(ra) # 616 <vprintf>
}
 850:	60e2                	ld	ra,24(sp)
 852:	6442                	ld	s0,16(sp)
 854:	6125                	addi	sp,sp,96
 856:	8082                	ret

0000000000000858 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 858:	1141                	addi	sp,sp,-16
 85a:	e422                	sd	s0,8(sp)
 85c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 85e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 862:	00000797          	auipc	a5,0x0
 866:	79e7b783          	ld	a5,1950(a5) # 1000 <freep>
 86a:	a02d                	j	894 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 86c:	4618                	lw	a4,8(a2)
 86e:	9f2d                	addw	a4,a4,a1
 870:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 874:	6398                	ld	a4,0(a5)
 876:	6310                	ld	a2,0(a4)
 878:	a83d                	j	8b6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 87a:	ff852703          	lw	a4,-8(a0)
 87e:	9f31                	addw	a4,a4,a2
 880:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 882:	ff053683          	ld	a3,-16(a0)
 886:	a091                	j	8ca <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 888:	6398                	ld	a4,0(a5)
 88a:	00e7e463          	bltu	a5,a4,892 <free+0x3a>
 88e:	00e6ea63          	bltu	a3,a4,8a2 <free+0x4a>
{
 892:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 894:	fed7fae3          	bgeu	a5,a3,888 <free+0x30>
 898:	6398                	ld	a4,0(a5)
 89a:	00e6e463          	bltu	a3,a4,8a2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 89e:	fee7eae3          	bltu	a5,a4,892 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8a2:	ff852583          	lw	a1,-8(a0)
 8a6:	6390                	ld	a2,0(a5)
 8a8:	02059813          	slli	a6,a1,0x20
 8ac:	01c85713          	srli	a4,a6,0x1c
 8b0:	9736                	add	a4,a4,a3
 8b2:	fae60de3          	beq	a2,a4,86c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8b6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8ba:	4790                	lw	a2,8(a5)
 8bc:	02061593          	slli	a1,a2,0x20
 8c0:	01c5d713          	srli	a4,a1,0x1c
 8c4:	973e                	add	a4,a4,a5
 8c6:	fae68ae3          	beq	a3,a4,87a <free+0x22>
    p->s.ptr = bp->s.ptr;
 8ca:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8cc:	00000717          	auipc	a4,0x0
 8d0:	72f73a23          	sd	a5,1844(a4) # 1000 <freep>
}
 8d4:	6422                	ld	s0,8(sp)
 8d6:	0141                	addi	sp,sp,16
 8d8:	8082                	ret

00000000000008da <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8da:	7139                	addi	sp,sp,-64
 8dc:	fc06                	sd	ra,56(sp)
 8de:	f822                	sd	s0,48(sp)
 8e0:	f426                	sd	s1,40(sp)
 8e2:	f04a                	sd	s2,32(sp)
 8e4:	ec4e                	sd	s3,24(sp)
 8e6:	e852                	sd	s4,16(sp)
 8e8:	e456                	sd	s5,8(sp)
 8ea:	e05a                	sd	s6,0(sp)
 8ec:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ee:	02051493          	slli	s1,a0,0x20
 8f2:	9081                	srli	s1,s1,0x20
 8f4:	04bd                	addi	s1,s1,15
 8f6:	8091                	srli	s1,s1,0x4
 8f8:	0014899b          	addiw	s3,s1,1
 8fc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8fe:	00000517          	auipc	a0,0x0
 902:	70253503          	ld	a0,1794(a0) # 1000 <freep>
 906:	c515                	beqz	a0,932 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 908:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90a:	4798                	lw	a4,8(a5)
 90c:	02977f63          	bgeu	a4,s1,94a <malloc+0x70>
 910:	8a4e                	mv	s4,s3
 912:	0009871b          	sext.w	a4,s3
 916:	6685                	lui	a3,0x1
 918:	00d77363          	bgeu	a4,a3,91e <malloc+0x44>
 91c:	6a05                	lui	s4,0x1
 91e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 922:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 926:	00000917          	auipc	s2,0x0
 92a:	6da90913          	addi	s2,s2,1754 # 1000 <freep>
  if(p == (char*)-1)
 92e:	5afd                	li	s5,-1
 930:	a895                	j	9a4 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 932:	00000797          	auipc	a5,0x0
 936:	6de78793          	addi	a5,a5,1758 # 1010 <base>
 93a:	00000717          	auipc	a4,0x0
 93e:	6cf73323          	sd	a5,1734(a4) # 1000 <freep>
 942:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 944:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 948:	b7e1                	j	910 <malloc+0x36>
      if(p->s.size == nunits)
 94a:	02e48c63          	beq	s1,a4,982 <malloc+0xa8>
        p->s.size -= nunits;
 94e:	4137073b          	subw	a4,a4,s3
 952:	c798                	sw	a4,8(a5)
        p += p->s.size;
 954:	02071693          	slli	a3,a4,0x20
 958:	01c6d713          	srli	a4,a3,0x1c
 95c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 95e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 962:	00000717          	auipc	a4,0x0
 966:	68a73f23          	sd	a0,1694(a4) # 1000 <freep>
      return (void*)(p + 1);
 96a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 96e:	70e2                	ld	ra,56(sp)
 970:	7442                	ld	s0,48(sp)
 972:	74a2                	ld	s1,40(sp)
 974:	7902                	ld	s2,32(sp)
 976:	69e2                	ld	s3,24(sp)
 978:	6a42                	ld	s4,16(sp)
 97a:	6aa2                	ld	s5,8(sp)
 97c:	6b02                	ld	s6,0(sp)
 97e:	6121                	addi	sp,sp,64
 980:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 982:	6398                	ld	a4,0(a5)
 984:	e118                	sd	a4,0(a0)
 986:	bff1                	j	962 <malloc+0x88>
  hp->s.size = nu;
 988:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 98c:	0541                	addi	a0,a0,16
 98e:	00000097          	auipc	ra,0x0
 992:	eca080e7          	jalr	-310(ra) # 858 <free>
  return freep;
 996:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 99a:	d971                	beqz	a0,96e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 99e:	4798                	lw	a4,8(a5)
 9a0:	fa9775e3          	bgeu	a4,s1,94a <malloc+0x70>
    if(p == freep)
 9a4:	00093703          	ld	a4,0(s2)
 9a8:	853e                	mv	a0,a5
 9aa:	fef719e3          	bne	a4,a5,99c <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9ae:	8552                	mv	a0,s4
 9b0:	00000097          	auipc	ra,0x0
 9b4:	b58080e7          	jalr	-1192(ra) # 508 <sbrk>
  if(p == (char*)-1)
 9b8:	fd5518e3          	bne	a0,s5,988 <malloc+0xae>
        return 0;
 9bc:	4501                	li	a0,0
 9be:	bf45                	j	96e <malloc+0x94>
