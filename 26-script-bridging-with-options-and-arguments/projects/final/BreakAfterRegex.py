# Copyright (c) 2023 Kodeco LLC
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
# distribute, sublicense, create a derivative work, and/or sell copies of the
# Software in any work that is designed, intended, or marketed for pedagogical or
# instructional purposes related to programming, coding, application development,
# or information technology.  Permission for such use, copying, modification,
# merger, publication, distribution, sublicensing, creation of derivative works,
# or sale is expressly withheld.
#
# This project and source code may use libraries or frameworks that are
# released under various Open-Source licenses. Use of those libraries and
# frameworks are governed by their own individual licenses.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

import lldb
import optparse
import shlex

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f BreakAfterRegex.breakAfterRegex bar')


def breakAfterRegex(debugger, command, result, internal_dict):
    '''Creates a regular expression breakpoint and adds it.
    Once the breakpoint is hit, control will step out of the current
    function and print the return value. Useful for stopping on
    getter/accessor/initialization methods
    '''

    command = command.replace('\\', '\\\\')
    command_args = shlex.split(command, posix=False)
    print(command_args)
    parser = generateOptionParser()

    try:
        (options, args) = parser.parse_args(command_args)
    except:
        result.SetError(parser.usage)
        return
    
    target = debugger.GetSelectedTarget()

    clean_command = shlex.split(args[0])[0]

    if options.non_regex:
        breakpoint = target.BreakpointCreateByName(clean_command, options.module)
    else:
        breakpoint = target.BreakpointCreateByRegex(clean_command, options.module)


    if not breakpoint.IsValid() or breakpoint.num_locations == 0:
        result.AppendWarning("Breakpoint isn't valid or hasn't found any hits.")
    else:
        result.AppendMessage("{}".format(breakpoint))
    
    breakpoint.SetScriptCallbackFunction("BreakAfterRegex.breakpointHandler")

def breakpointHandler(frame, bp_loc, dict):
    '''The function called when the regular
    expression breakpoint gets triggered
    '''

    thread = frame.GetThread()
    process = thread.GetProcess()
    debugger = process.GetTarget().GetDebugger()
    function_name = frame.GetFunctionName()
    
    debugger.SetAsync(False)

    thread.StepOut()

    output = evaluateReturnedObject(debugger, thread, function_name)

    if output is not None:
        print(output)

    return False

def evaluateReturnedObject(debugger, thread, function_name):
    '''Grabs the reference from the return register
    and returns a string from the evaluated value.
    TODO ObjcOnly
    '''
    
    res = lldb.SBCommandReturnObject()

    interpreter = debugger.GetCommandInterpreter()
    target = debugger.GetSelectedTarget()
    frame = thread.GetSelectedFrame()
    parent_function_name = frame.GetFunctionName()

    expression = 'expression -l objc -O -- $arg1'

    interpreter.HandleCommand(expression, res)

    if res.HasResult():
        output = '{}\nbreakpoint: '\
            '{}\nobject: {}\nstopped:{}'.format(
                '*' * 80,
                function_name,
                res.GetOutput().replace('\n', ''),
                parent_function_name
            )
        return output
    else:
        return None

def generateOptionParser(): 
    '''Gets the return register as a string for lldb
    based upon the hardware
    '''
    usage = "usage: %prog [options] breakpoint_query\n" +\
            "Use 'bar -h' for option desc"
    parser = optparse.OptionParser(usage=usage, prog='bar')
    parser.add_option("-n", "--non_regex",
                    action="store_true",
                    default=False,
                    dest="non_regex",
                    help="Use a non-regex breakpoint instead")
    
    parser.add_option("-m", "--module",
        action="store",
        default=None,
        dest="module",
        help="Filter a breakpoint by only searching within a specified Module.")

    parser.add_option("-c", "--condition",
        action="store",
        default=None,
        dest="condition",
        help="Only stop if the expression matches True. Can reference return value through 'obj'. Obj-C only.")

    return parser
