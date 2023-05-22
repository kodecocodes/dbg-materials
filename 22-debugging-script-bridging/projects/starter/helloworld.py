def your_first_command(debugger, command, result, internal_dict):
    print ("hello world")

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f helloworld.your_first_command yay')

