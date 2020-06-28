

import lldb
import os
import shlex
import optparse

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand(
    'command script add -f lookup.handle_command lookup')

def handle_command(debugger, command, result, internal_dict):
    '''
    Documentation for how to use lookup goes here 
    '''

    command_args = shlex.split(command.replace('\\', '\\\\'), posix=False)
    parser = generateOptionParser()
    try:
        (options, args) = parser.parse_args(command_args)
    except:
        result.SetError(parser.usage)
        return

    # Uncomment if you are expecting at least one argument
    #1
    clean_command = shlex.split(args[0])[0]
    # 2
    target = debugger.GetSelectedTarget()

    # 3
    contextlist = target.FindGlobalFunctions(clean_command, 0, lldb.eMatchTypeRegex)
    # old code above

    mdict = generateModuleDictionary(contextlist)
    output = generateOutput(mdict, options, target)

    result.AppendMessage(output)
    # final line in function

def generateModuleDictionary(contextlist):
    mdict = {}
    for context in contextlist:
        key = context.module.file.fullpath
        if not key in mdict:
            mdict[key] = []

        mdict[key].append(context)
    return mdict

def generateOutput(mdict, options, target):
    output = ''
    separator = '*' * 60 + '\n'

        

    for key in mdict:
        count = len(mdict[key])
        firstItem = mdict[key][0]
        moduleName = firstItem.module.file.basename
        if options.module_summary:
            output += '{} hits in {}\n'.format(count, moduleName)
            continue
            
        output += '{0}{1} hits in {2}\n{0}'.format(separator, count, moduleName)
        for context in mdict[key]:
            query = ''

            if options.load_address:
                start = context.symbol.addr.GetLoadAddress(target)
                end = context.symbol.end_addr.GetLoadAddress(target)
                startHex = '0x' + format(start, '012x')
                endHex = '0x' + format(end, '012x')
                query += '[{}-{}]\n'.format(startHex, endHex)

            query += context.symbol.name
            query += '\n\n'
            output += query
    return output
  


def generateOptionParser():
    usage = "usage: %prog [options] code_to_query"
    parser = optparse.OptionParser(usage=usage, prog="lookup")

    parser.add_option("-l", "--load_address",
                      action="store_true",
                      default=False,
                      dest="load_address",
                      help="Show the load addresses for a particular hit")

    parser.add_option("-s", "--module_summary",
                      action="store_true",
                      default=False,
                      dest="module_summary",
                      help="Only show the amount of queries in the module")
    return parser
    