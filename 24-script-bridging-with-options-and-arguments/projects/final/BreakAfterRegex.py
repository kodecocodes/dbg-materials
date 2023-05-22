#!/usr/bin/env python
# -*- coding: utf-8 -*-

import lldb
import optparse
import shlex

class BarOptions(object):
    optdict = {}

    @staticmethod
    def addOptions(options, breakpoint):
        key = str(breakpoint.GetID())
        BarOptions.optdict[key] = options

        

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand(
        'command script add -f BreakAfterRegex.breakAfterRegex bar')


def breakAfterRegex(debugger, command, result, internal_dict):
    '''Creates a regular expression breakpoint and adds it.
    Once the breakpoint is hit, control will step out of the current
    function and print the return value. Useful for stopping on
    getter/accessor/initialization methods
    '''
    command_args = shlex.split(command.replace('\\', '\\\\'), posix=False)
    print (command_args)
    parser = generateOptionParser()
    try:
        (options, args) = parser.parse_args(command_args)
    except:
        result.SetError(parser.usage)
        return 

    if len(args) != 1:
        result.SetError(parser.usage)
        return 

    target = debugger.GetSelectedTarget()
    clean_command = args[0]

    if options.non_regex:
        breakpoint = target.BreakpointCreateByName(clean_command, options.module)
    else:
        breakpoint = target.BreakpointCreateByRegex(clean_command, options.module)


    if not breakpoint.IsValid() or breakpoint.num_locations == 0:
        result.AppendWarning("Breakpoint isn't valid or hasn't found any hits: " + clean_command)
    else:
        result.AppendMessage("{}".format(breakpoint))

    BarOptions.addOptions(options, breakpoint)
    breakpoint.SetScriptCallbackFunction("BreakAfterRegex.breakpointHandler")


def breakpointHandler(frame, bp_loc, dict):
    '''The function called when the breakpoint 
    gets triggered
    '''
    key = str(bp_loc.GetBreakpoint().GetID())
    options = BarOptions.optdict[key]
        
    thread = frame.GetThread()
    process = frame.GetThread().GetProcess()
    debugger = process.GetTarget().GetDebugger()
    function_name = frame.GetFunctionName()
    debugger.SetAsync(False)
    thread.StepOut()

    if options.condition:
        return evaluateCondition(debugger, options.condition, bp_loc)


    output = evaluateReturnedObject(debugger, thread, function_name)
    if output is not None:
        print(output)
    return False


def evaluateCondition(debugger, condition, bp_loc):
    '''Returns True or False based upon if the supplied condition.
    You can reference the NSObject through "obj"'''

    res = lldb.SBCommandReturnObject()
    interpreter = debugger.GetCommandInterpreter()
    target = debugger.GetSelectedTarget()
    expression = 'expression -lobjc -O -- id obj = ((id){}); ((BOOL){})'.format(getRegisterString(target), condition)
    interpreter.HandleCommand(expression, res)

    if res.GetError():
        print(str(bp_loc) + '\n')
        print('*' * 80 + '\n' + 'Error: unable to parse expression: ' + res.GetError())
        return False
    elif res.HasResult():
        retval = res.GetOutput()
        if 'YES' in retval:
            return True

    return False

def evaluateReturnedObject(debugger, thread, function_name):
    '''Grabs the reference from the return register
    and returns a string from the evaluated value. TODO ObjC only
    '''
    res = lldb.SBCommandReturnObject()
    interpreter = debugger.GetCommandInterpreter()
    target = debugger.GetSelectedTarget()
    frame = thread.GetSelectedFrame()
    parent_function_name = frame.GetFunctionName()

    expression = 'expression -lobjc -O -- {}'.format(
        getRegisterString(target))
    interpreter.HandleCommand(expression, res)

    if res.HasResult():
        output = '{}\nbreakpoint: '\
            '{}\nobject: {}\nstopped: {}'.format(
                '*' * 80,
                function_name,
                res.GetOutput().replace('\n', ''),
                parent_function_name)
        return output
    else:
        return None


def getRegisterString(target):
    '''Gets the return register as a string for lldb
    based upon the hardware
    '''
    triple_name = target.GetTriple()
    if 'x86_64' in triple_name:
        return '$rax'
    elif 'i386' in triple_name:
        return '$eax'
    elif 'arm64' in triple_name:
        return '$x0'
    elif 'arm' in triple_name:
        return '$r0'
    raise Exception('Unknown hardware. Womp womp')


def generateOptionParser():
    usage = "usage: %prog [options] breakpoint_query"
    parser = optparse.OptionParser(usage=usage, prog="bar")

    parser.add_option("-n", "--non_regex",
              action="store_true",
              default=False,
              dest="non_regex",
              help="Create a regex breakpoint based upon searching for source code")

    parser.add_option("-m", "--module",
              action="store",
              default=None,
              dest="module",
              help="Filter a breakpoint by only searching within a specified Module")

    parser.add_option("-c", "--condition",
              action="store",
              default=None,
              dest="condition",
              help="Only stop if the expression matches True. Can reference retrun value through 'obj'. Obj-C only")

    return parser
