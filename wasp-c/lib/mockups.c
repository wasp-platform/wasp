#include "assert.h"

int IFG(int cond, int id) {
  return cond;
}

void exit (int e) { assert(e == 0); }
void __assert_fail(const char *id, const char *file,
    unsigned int i, const char *func) {
  assert(0);
}
int __VERIFIER_nondet_bool(char *name) {
  int sym_var = sym_int(name);
  assume (sym_var == 0 || sym_var == 1);
  return sym_var;
}
char __VERIFIER_nondet_char(char *name) { 
  int sym_var = sym_int(name);
  //assume(sym_var >= -128 && sym_var <= 127);
  return (char) sym_var;
}
unsigned char __VERIFIER_nondet_uchar(char *name) { 
  int sym_var = sym_int(name);
  return (unsigned char) sym_var;
}
short __VERIFIER_nondet_short(char *name) { 
  int sym_var = sym_int(name);
  //assume(sym_var >= -32768 && sym_var <= 32767);
  return (short) sym_var;
}
unsigned short __VERIFIER_nondet_ushort(char *name) { 
  int sym_var = sym_int(name);
  // assume(sym_var >= 0U && sym_var <= 65535U);
  return (unsigned short) sym_var;
}

int __VERIFIER_nondet_int(char *name) { return sym_int(name); }

unsigned int __VERIFIER_nondet_uint(char *name) { 
  return (unsigned int) sym_int(name);
}

unsigned int __VERIFIER_nondet_charp(char *name) { return sym_int(name); }

int __VERIFIER_nondet_long(char *name) { return sym_long(name); }

unsigned int __VERIFIER_nondet_ulong(char *name) { 
  int sym_var = sym_long(name);
  return (unsigned int) sym_var;
}

float __VERIFIER_nondet_float(char *name) { return sym_float(name); }

double __VERIFIER_nondet_double(char *name) { return sym_double(name); }
