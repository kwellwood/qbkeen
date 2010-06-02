'$STATIC
DEFINT A-Z

DECLARE SUB multireturn (aseg&, aptr&, bseg&, bptr&, c&)

CLS

DIM d AS SINGLE

a = 277:  b! = 4.75: c& = 10: d = 17.2

PRINT a; d
multireturn VARSEG(a), VARPTR(a), VARSEG(d), VARPTR(d), c&

PRINT a: PRINT d: PRINT c&

SUB multireturn (aseg&, aptr&, bseg&, bptr&, c&)

PRINT "-------"
PRINT "aseg:"; aseg&
PRINT "aptr:"; aptr&
PRINT "bseg:"; bseg&
PRINT "bptr:"; bptr&
PRINT "-------"

newa = 0
DEF SEG = aseg&
byte1 = PEEK(aptr&)
byte2 = PEEK(aptr& + 1)
DEF SEG = VARSEG(newa)
POKE (VARPTR(newa)), byte1
POKE (VARPTR(newa) + 1), byte2

newb! = 0
DEF SEG = bseg&
byte1 = PEEK(bptr&)
byte2 = PEEK(bptr& + 1)
byte3 = PEEK(bptr& + 2)
byte4 = PEEK(bptr& + 3)
DEF SEG = VARSEG(newb!)
POKE (VARPTR(newb!)), byte1
POKE (VARPTR(newb!) + 1), byte2
POKE (VARPTR(newb!) + 2), byte3
POKE (VARPTR(newb!) + 3), byte4
DEF SEG

PRINT "found a:"; newa; "changing to 748": newa = 748
PRINT "found b:"; newb!; "changing to 9.3": newb! = 9.3

DEF SEG = VARSEG(newa)
byte1 = PEEK(VARPTR(newa))
byte2 = PEEK(VARPTR(newa) + 1)
DEF SEG = aseg&
POKE aptr&, byte1
POKE aptr& + 1, byte2

DEF SEG = VARSEG(newb!)
byte1 = PEEK(VARPTR(newb!))
byte2 = PEEK(VARPTR(newb!) + 1)
byte3 = PEEK(VARPTR(newb!) + 2)
byte4 = PEEK(VARPTR(newb!) + 3)
DEF SEG = bseg&
POKE bptr&, byte1
POKE bptr& + 1, byte2
POKE bptr& + 2, byte3
POKE bptr& + 3, byte4
DEF SEG

END SUB

