/*
 * util.c - commonly used utility functions.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "util.h"

/*安全的分配内存*/
void* checked_malloc(int len) {
  void *p = malloc(len);
  
  if (!p) {
    fprintf(stderr, "\nRan out of memory!\n");
    exit(1);
  }
 
  return p;
}

/*根据传入的字符串字面值生成字符串变量*/
string String(char *s) {
  string p = checked_malloc(strlen(s) + 1);
  strcpy(p, s);
  
  return p;
}

/*生成布尔链表*/
U_boolList U_BoolList(bool head, U_boolList tail) {
  U_boolList list = checked_malloc(sizeof(*list));
  list->head = head;
  list->tail = tail;
  
return list;
}
