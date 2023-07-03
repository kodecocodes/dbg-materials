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

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f findclass.findclass findclass')


def findclass(debugger, command, result, internal_dict):
    """
    The findclass command dumps all the Objective-C runtime classes it knows about.
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
    numClasses = (int)objc_getClassList(NULL, 0);
    NSMutableString *returnString = [NSMutableString string];
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
    numClasses = (int)objc_getClassList(classes, numClasses);

    for (int i = 0; i < numClasses; i++) {
      Class c = classes[i];
      [returnString appendFormat:@"%s,", (char *)class_getName(c)];
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
        print (returnVal.replace(",", "\n").replace("\n\n\n", ""))
    else: 
        filteredArray = filter(lambda className: command in className, resultArray)
        filteredResult = "\n".join(filteredArray)
        result.AppendMessage(filteredResult)

