#!/usr/sbin/dtrace -s
#pragma D option quiet  

dtrace:::BEGIN
{
  printf("Starting... Hit Ctrl-C to end.\n");
}

pid$target::objc_msgSend:entry 
{
  this->selector = copyinstr(arg1);
}

pid$target::objc_msgSend:entry / arg0 > 0x100000000 / && 
                    this->selector != "retain" && 
                    this->selector != "release" /                              
{
  /* 1 */
  this->selector = copyinstr(arg1); 
  /* 2 */
  size = sizeof(uintptr_t);  
  /* 3 */
  this->isa = *((uintptr_t *)copyin(arg0, size));

  /* 4 */
  this->rax = *((uintptr_t *)copyin((this->isa + 0x20), size)); 
  this->rax =  (this->rax & 0x7ffffffffff8); 

  /* 5 */
  this->rbx = *((uintptr_t *)copyin((this->rax + 0x38), size)); 
  
  this->rax = *((uintptr_t *)copyin((this->rax + 0x8),  size));  

  /* 6 */
  this->rax = *((uintptr_t *)copyin((this->rax + 0x18), size));  
  
  /* 7 */
  this->classname = copyinstr(this->rbx != 0 ? 
                               this->rbx  : this->rax);   
  printf("0x%016p +|-[%s %s]\n", arg0, this->classname, 
                                       this->selector);
}
