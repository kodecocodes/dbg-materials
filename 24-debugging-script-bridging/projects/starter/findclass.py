import lldb 

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f findclass.findclass findclass')


def findclass(debugger, command, result, internal_dict):
    """
    The findclass command will dump all the Objective-C runtime classes it knows about.
    Alternatively, if you supply an argument for it, it will do a case sensitive search
    looking only for the classes which contain the input. 

    Usage: findclass  # All Classes
    Usage: findclass UIViewController # Only classes that contain UIViewController in name
    """ 


    codeString = r'''
    @import Foundation;
    int numClasses;
    Class * classes = NULL;
    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    NSMutableString *returnString = [NSMutableString string];
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);

    for (int i = 0; i < numClasses; i++) {
      Class c = classes[i];
      [returnString appendFormat:@"%s,", class_getName(c)];
    }
    free(classes);
    
    returnString;
    '''

    res = lldb.SBCommandReturnObject()
    debugger.GetCommandInterpreter().HandleCommand("expression -lobjc -O -- " + codeString, res)
    if res.GetError(): 
        raise AssertionError("Uhoh... something went wrong, can you figure it out? :]")
    elif not res.HasResult():
        raise AssertionError("There's no result. Womp womp....")
        
    returnVal = res.GetOutput()
    resultArray = returnVal.split(",")
    if not command: # No input supplied 
        print returnVal.replace(",", "\n").replace("\n\n\n", "")
    else: 
        filteredArray = filter(lambda className: command in className, resultArray)
        filteredResult = "\n".join(filteredArray)
        result.AppendMessage(filteredResult)

