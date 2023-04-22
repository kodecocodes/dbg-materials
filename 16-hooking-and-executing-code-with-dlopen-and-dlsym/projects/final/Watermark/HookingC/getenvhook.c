//
//  getenvhook.c
//  HookingC
//
//  Created by Walter Tyree on 4/22/23.
//  Copyright © 2023 Kodeco. All rights reserved.
//

#include <stdio.h>
#include <dlfcn.h>
#include <assert.h>
#include <dispatch/dispatch.h>
#include <string.h>

char * getenv(const char *name) {
  static void *handle;
  static char * (*real_getenv)(const char *);

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    handle = dlopen("/usr/lib/system/libsystem_c.dylib", RTLD_NOW);
    assert(handle);
    real_getenv = dlsym(handle, "getenv");
  });

  if (strcmp(name, "HOME") == 0) {
    return "/W00T";
  }
  return real_getenv(name);
}
