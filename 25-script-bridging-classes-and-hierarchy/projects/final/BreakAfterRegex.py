#!/usr/bin/env python
# -*- coding: utf-8 -*-

import lldb

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand(
        'command script add -f BreakAfterRegex.breakAfterRegex bar')


def breakAfterRegex(debugger, command, result, internal_dict):
    '''Creates a regular expression breakpoint and adds it.
    Once the breakpoint is hit, control will step out of the current
    function and print the return value. Useful for stopping on
    getter/accessor/initialization methods
    '''

    target = debugger.GetSelectedTarget()
    breakpoint = target.BreakpointCreateByRegex(command)

    if not breakpoint.IsValid() or breakpoint.num_locations == 0:
        result.AppendWarning("Breakpoint isn't valid or hasn't found any hits")
    else:
        result.AppendMessage("{}".format(breakpoint))

    breakpoint.SetScriptCallbackFunction("BreakAfterRegex.breakpointHandler")


def breakpointHandler(frame, bp_loc, dict):
    '''The function called when the breakpoint 
    gets triggered
    '''
    thread = frame.GetThread()
    process = frame.GetThread().GetProcess()
    debugger = process.GetTarget().GetDebugger()
    function_name = frame.GetFunctionName()
    debugger.SetAsync(False)
    thread.StepOut()

    output = evaluateReturnedObject(debugger,
                                    thread, function_name)
    if output is not None:
        print(output)
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
