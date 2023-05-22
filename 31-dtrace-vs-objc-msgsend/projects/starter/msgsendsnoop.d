#!/usr/sbin/dtrace -s
#pragma D option quiet  

dtrace:::BEGIN
{
  printf("Starting... Hit Ctrl-C to end.\n");
}

pid$target::objc_msgSend:entry
{
  this->selector = copyinstr(arg1);
  printf("0x%016p, +|-[%s %s]\n", arg0, "__TODO__",
                                         this->selector);
}
