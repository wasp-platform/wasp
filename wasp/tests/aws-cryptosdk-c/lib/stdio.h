#ifndef STDIO_H
#define STDIO_H
#include <sys/types.h>

#define BUFSIZE 128

struct __stdio_file {
  int fd;
  int flags;
  uint32_t bs;	/* read: bytes in buffer */
  uint32_t bm;	/* position in buffer */
  uint32_t buflen;	/* length of buf */
  char *buf;
  struct __stdio_file *next;	/* for fflush */
  pid_t popen_kludge;
  unsigned char ungetbuf;
  char ungotten;
};

typedef struct __stdio_file FILE;

extern FILE *stdin, *stdout, *stderr;

#define ERRORINDICATOR 1
#define EOFINDICATOR 2
#define BUFINPUT 4
#define BUFLINEWISE 8
#define NOBUF 16
#define STATICBUF 32
#define FDPIPE 64
#define CANREAD 128
#define CANWRITE 256
#define CHECKLINEWISE 512

#define _IONBF 0
#define _IOLBF 1
#define _IOFBF 2

int printf(const char *format, ...);
int fprintf(FILE *stream, const char *format, ...);
int sprintf(char *str, const char *format, ...);
int snprintf(char *str, size_t size, const char *format, ...);
int asprintf(char **ptr, const char* format, ...);

int scanf(const char *format, ...);
int fscanf(FILE *stream, const char *format, ...);
int sscanf(const char *str, const char *format, ...);

/*
int vprintf(const char *format, va_list ap);
int vfprintf(FILE *stream, const char *format, va_list ap);
int vsprintf(char *str, const char *format, va_list ap);
int vsnprintf(char *str, size_t size, const char *format, va_list ap);

int fdprintf(int fd, const char *format, ...) __THROW __attribute__((__format__(__printf__,2,3)));
int vfdprintf(int fd, const char *format, va_list ap) __THROW __attribute__((__format__(__printf__,2,0)));

int vscanf(const char *format, va_list ap) __THROW __attribute__((__format__(__scanf__,1,0)));
int vsscanf(const char *str, const char *format, va_list ap) __THROW __attribute__((__format__(__scanf__,2,0)));
int vfscanf(FILE *stream, const char *format, va_list ap) __THROW __attribute__((__format__(__scanf__,2,0)));

*/
#endif