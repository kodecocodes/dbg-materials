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

	.globl _RDX_register
	.globl _RBX_register
	.globl _RDI_register
	.globl _RAX_register
	.globl _RCX_register
	.globl _RSI_register
	.globl _RBP_register
	.globl _RSP_register
	.globl _R8_register
	.globl _R9_register
	.globl _R10_register
	.globl _R11_register
	.globl _R12_register
	.globl _R13_register
	.globl _R14_register
	.globl _R15_register


_RDX_register:
    movq %rdx, %rax
    ret

_RBX_register:
    movq %rbx, %rax
    ret

_RAX_register:
    movq %rax, %rax
    ret
_RCX_register:
    movq %rcx, %rax
    ret

_RSI_register:
    movq %rsi, %rax
    ret

_RDI_register:
    movq %rdi, %rax
    ret

_RBP_register:
    movq %rbp, %rax
    ret

_RSP_register:
    movq %rsp, %rax
    ret

_R8_register:
    movq %r8, %rax
    ret

_R9_register:
    movq %r9, %rax
    ret

_R10_register:
    movq %r10, %rax
    ret

_R11_register:
    movq %r11, %rax
    ret

_R12_register:
    movq %r12, %rax
    ret

_R13_register:
    movq %r13, %rax
    ret

_R14_register:
    movq %r14, %rax
    ret

_R15_register:
    movq %r15, %rax
    ret
