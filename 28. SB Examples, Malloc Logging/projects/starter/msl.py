import lldb
import os
import shlex
import optparse

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand(
    'command script add -f msl.handle_command msl')


def handle_command(debugger, command, result, internal_dict):
    '''
    msl will produce the stack trace of the most recent deallocations or allocations.
    Make sure to either call enable_logging or set MallocStackLogging environment variable
    '''



def processStackTraceStringFromAddresses(frameAddresses, target):

    frame_string = ''
    for index, frameAddr in enumerate(frameAddresses):
        addr = target.ResolveLoadAddress(frameAddr)
        symbol = addr.symbol
        name = symbol.name
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
    expr_options.SetCoerceResultToId(True)
    expr_options.SetGenerateDebugInfo(True)
    return expr_options

def generateScript(addr, options):
  script = '  mach_vm_address_t addr = (mach_vm_address_t)' + str(addr) + ';\n'
  script += r'''
typedef struct $LLDBStackAddress {
    mach_vm_address_t *addresses;
    uint32_t count = 0;
} $LLDBStackAddress;

  $LLDBStackAddress stackaddress;
  mach_vm_address_t address = (mach_vm_address_t)addr;
  void * task = mach_task_self_;
  stackaddress.addresses = (mach_vm_address_t *)calloc(100, sizeof(mach_vm_address_t));
  __mach_stack_logging_get_frames(task, address, stackaddress.addresses, 100, &stackaddress.count);
  stackaddress
  '''
  return script

def generateOptionParser():
    usage = "usage: %prog [options] 0xaddrE55"
    parser = optparse.OptionParser(usage=usage, prog="msl")
    parser.add_option("-r", "--resymbolicate",
                      action="store_true",
                      default=False,
                      dest="resymbolicate",
                      help="Resymbolicate Stripped out Objective-C code")
    return parser
    
