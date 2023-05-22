# MIT License
# 
# Copyright (c) 2018 Derek Selander

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import lldb
import os
import shlex
import optparse

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand(
    'command script add -f sbt.handle_command sbt')

def handle_command(debugger, command, result, internal_dict):
    '''
    Symbolicate backtrace. Will symbolicate a stripped backtrace
    from an executable if the backtrace is using Objective-C 
    code. Currently doesn't work on aarch64 stripped executables
    but works great on x64 :]
    '''
    target = debugger.GetSelectedTarget()
    process = target.GetProcess()
    thread = process.GetSelectedThread()
    if thread is None:
        result.SetError('LLDB must be paused to execute this command')
        return

    frameAddresses = [f.addr.GetLoadAddress(target) 
                      for f 
                      in thread.frames]

    frameString = processStackTraceStringFromAddresses(frameAddresses, target)
    result.AppendMessage(frameString)


def processStackTraceStringFromAddresses(frameAddresses, target):
    frame_string = ''
    startAddresses = [target.ResolveLoadAddress(f).symbol.addr.GetLoadAddress(target) 
                     for f
                     in frameAddresses]
    script = generateExecutableMethodsScript(startAddresses)

    # New content start 1
    methods = target.EvaluateExpression(script, generateOptions())
    methodsVal = lldb.value(methods.deref)
    # New content end 1


    # Enumerate each of the SBFrames in address list
    for index, frameAddr in enumerate(frameAddresses):
        addr = target.ResolveLoadAddress(frameAddr)
        symbol = addr.symbol

        # New content start 2
        if symbol.synthetic: # 1
            children = methodsVal.sbvalue.GetNumChildren() # 4
            name = symbol.name + r' ... unresolved womp womp' # 2

            loadAddr = symbol.addr.GetLoadAddress(target) # 3
            for i in range(children):
                key = long(methodsVal[i].key.sbvalue.description) # 5
                if key == loadAddr:
                    name = methodsVal[i].value.sbvalue.description # 6
                    break
        else:
            name = symbol.name # 7
        # New content end 2

        offset_str = ''
        offset = addr.GetLoadAddress(target) - addr.symbol.addr.GetLoadAddress(target)
        if offset > 0:
            offset_str = '+ {}'.format(offset)

        frame_string += 'frame #{:<2}: {} {}`{} {}\n'.format(index, hex(addr.GetLoadAddress(target)), addr.module.file.basename, name, offset_str)

    return frame_string

def generateOptions():
    expr_options = lldb.SBExpressionOptions()
    expr_options.SetUnwindOnError(True)
    expr_options.SetLanguage (lldb.eLanguageTypeObjC_plus_plus)
    expr_options.SetCoerceResultToId(False)
    return expr_options


def generateExecutableMethodsScript(frame_addresses):
    frame_addr_str = 'NSArray *ar = @['
    for f in frame_addresses:
        frame_addr_str += '@"' + str(f) + '",'

    frame_addr_str = frame_addr_str[:-1]
    frame_addr_str += '];'

    command_script = r'''
    @import ObjectiveC;
    @import Foundation;
  NSMutableDictionary *retdict = [NSMutableDictionary dictionary];
  unsigned int count = 0;
  const char *path = (char *)[[[NSBundle mainBundle] executablePath] UTF8String];
  const char **allClasses = (const char **)objc_copyClassNamesForImage(path, &count);
  for (int i = 0; i < count; i++) {
    Class cls = objc_getClass(allClasses[i]);
    if (!(Class)class_getSuperclass(cls)) {
      continue;
    }
    unsigned int methCount = 0;
    Method *methods = class_copyMethodList(cls, &methCount);
    for (int j = 0; j < methCount; j++) {
      Method meth = methods[j];
      id implementation = (id)method_getImplementation(meth);
      NSString *methodName = [[[[@"-[" stringByAppendingString:NSStringFromClass(cls)] stringByAppendingString:@" "] stringByAppendingString:NSStringFromSelector(method_getName(meth))] stringByAppendingString:@"]"];
      [retdict setObject:methodName forKey:(id)[@((uintptr_t)implementation) stringValue]];
    }
    
    unsigned int classMethCount = 0;
    
    Method *classMethods = class_copyMethodList(objc_getMetaClass(class_getName(cls)), &classMethCount);
    for (int j = 0; j < classMethCount; j++) {
      Method meth = classMethods[j];
      id implementation = (id)method_getImplementation(meth);
      NSString *methodName = [[[[@"+[" stringByAppendingString:NSStringFromClass(cls)] stringByAppendingString:@" "] stringByAppendingString:NSStringFromSelector(method_getName(meth))] stringByAppendingString:@"]"];
      [retdict setObject:methodName forKey:(id)[@((uintptr_t)implementation) stringValue]];
    }
    
    free(methods);
    free(classMethods);
  }
  free(allClasses);
  '''
    command_script += frame_addr_str
    command_script += r'''

  NSMutableDictionary *stackDict = [NSMutableDictionary dictionary];
  [retdict keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
    
    if ([ar containsObject:key]) {
      [stackDict setObject:obj forKey:key];
      return YES;
    }
    
    return NO;
  }];
  stackDict;
  '''
    return command_script
