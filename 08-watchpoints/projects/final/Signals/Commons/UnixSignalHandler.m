/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

#import <signal.h>
#import <Commons/Commons-Swift.h>
#import "UnixSignalHandler.h"
#import "NSValue+siginfo_t.h"

NSString *const kSignalHandlerCountUpdatedNotification = @"com.razeware.breakpoints.contentupdated";

//*****************************************************************************/
#pragma mark - Sigaction Handler
//*****************************************************************************/

static void sigactionHandler(int sig, siginfo_t *siginfo, void *context)
{
  [[UnixSignalHandler sharedHandler] appendSignal:siginfo sig:sig];
}

//*****************************************************************************/
#pragma mark - UnixSignalHandler Interface
//*****************************************************************************/

@interface UnixSignalHandler () {
  struct sigaction act;
  dispatch_source_t source;
}
@property (nonatomic, strong, readwrite) NSMutableArray* signals;
@property (nonatomic, strong) NSUserDefaults* sharedUserDefaults;
@end

@interface UnixSignalHandler (Private)
-(instancetype _Nullable) init;
@end

//*****************************************************************************/
#pragma mark - UnixSignalHandler Implementation
//*****************************************************************************/

@implementation UnixSignalHandler

+ (instancetype)sharedHandler
{
  static UnixSignalHandler *sharedSignalHandler = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedSignalHandler = [[UnixSignalHandler alloc] initPrivate];
  });

  return sharedSignalHandler;
}

- (instancetype)initPrivate
{
  if (self = [super init]) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
      memset (&self->act, '\0', sizeof(self->act));
      self->act.sa_sigaction = &sigactionHandler;
      self->act.sa_flags = SA_SIGINFO;
      
      sigaction(SIGWINCH, &self->act, NULL);
      sigaction(SIGPROF, &self->act, NULL);
      sigaction(SIGVTALRM, &self->act, NULL);
      sigaction(SIGIO, &self->act, NULL);
      sigaction(SIGCHLD, &self->act, NULL);
      sigaction(SIGURG, &self->act, NULL);
      sigaction(SIGALRM, &self->act, NULL);
      sigaction(SIGCONT, &self->act, NULL);
    });
    
    self.sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.razeware.signalhandler.defaults"];
    
    
    NSArray *signalsArray = [self.sharedUserDefaults arrayForKey:@"signals"];
    if (signalsArray) {
      self.signals = [NSMutableArray arrayWithArray:signalsArray];
    } else {
      self.signals = [NSMutableArray array];
    }
    
    // SIGSTOP is special, won't work with sigaction, so dispatch sources are used instead.
    self->source = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGSTOP, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(self->source, ^{
      [self appendSignal:NULL sig:SIGSTOP];
    });
    dispatch_resume(self->source);
    
  }
  return self;
}

- (void)appendSignal:(siginfo_t *)siginfo sig:(int)sig {
  
  static int signalID = 0;
  static dispatch_queue_t queue = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    queue = dispatch_queue_create("SignalQueue", DISPATCH_QUEUE_SERIAL);
  });
  
  dispatch_async(queue, ^{
    
    NSLog(@"Appending new signal: %@", signalIntToName(sig));
    signalID++;
    UnixSignal *unixSignal = nil;
    if (siginfo == NULL) {
      unixSignal = [[UnixSignal alloc] initWithSignalValue:nil signum:SIGSTOP breakpointID:signalID];
    } else {
      unixSignal = [[UnixSignal alloc] initWithSignalValue:[NSValue valuewithSiginfo:*siginfo] signum:sig breakpointID:signalID];
    }
    
    [(NSMutableArray *)self.signals addObject:unixSignal];
    dispatch_async(dispatch_get_main_queue(), ^{
      [[NSNotificationCenter defaultCenter] postNotificationName:kSignalHandlerCountUpdatedNotification object:nil];
    });
  });
}

- (void)setShouldEnableSignalHandling:(BOOL)shouldEnableSignalHandling {
  self->_shouldEnableSignalHandling = shouldEnableSignalHandling;
  sigset_t signals;
  sigfillset(&signals);
  if (!shouldEnableSignalHandling) {
    sigprocmask(SIG_BLOCK, &signals, NULL);
  } else {
    sigprocmask(SIG_UNBLOCK, &signals, NULL);
  }
}

@end

//*****************************************************************************/
#pragma mark - Helpers
//*****************************************************************************/

int signalNameToInt(NSString *name) {
  if ([name isEqualToString:@"SIGWINCH"]) {
    return SIGWINCH;
  } else if ([name isEqualToString:@"SIGSTOP"]) {
    return SIGSTOP;
  } else if ([name isEqualToString:@"SIGPROF"]) {
    return SIGPROF;
  } else if ([name isEqualToString:@"SIGVTALRM"]) {
    return SIGVTALRM;
  } else if ([name isEqualToString:@"SIGIO"]) {
    return SIGIO;
  } else if ([name isEqualToString:@"SIGCHLD"]) {
    return SIGCHLD;
  } else if ([name isEqualToString:@"SIGALRM"]) {
    return SIGALRM;
  } else if ([name isEqualToString:@"SIGCONT"]) {
    return SIGCONT;
  }
  return -1;
}

NSString * signalIntToName(int sig) {
  switch (sig) {
    case SIGWINCH:
      return @"SIGWINCH";
    case SIGPROF:
      return @"SIGPROF";
    case SIGVTALRM:
      return @"SIGVTALRM";
    case SIGIO:
      return @"SIGIO";
    case SIGCHLD:
      return @"SIGCHLD";
    case SIGSTOP:
      return @"SIGSTOP";
    case SIGALRM:
      return @"SIGALRM";
    case SIGCONT:
      return @"SIGCONT";
    default:
      return @"Unknown Signal";
  }
}

NSArray<NSString *> * GetAllSignals() {
  return @[@"SIGWINCH", @"SIGPROF", @"SIGVTALRM", @"SIGIO", @"SIGCHLD", @"SIGSTOP", @"SIGALRM", @"SIGCONT"];
}
