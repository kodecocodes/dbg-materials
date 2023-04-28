/// Copyright (c) 2023 Kodeco LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

	.globl _x0_register
	.globl _x1_register
	.globl _x2_register
	.globl _x3_register
	.globl _x4_register
	.globl _x5_register
	.globl _x6_register
	.globl _x7_register
	.globl _x8_register
	.globl _x9_register
	.globl _x10_register
	.globl _x11_register
	.globl _x12_register
	.globl _x13_register
	.globl _x14_register
	.globl _x15_register
  .globl _sp_register

.balign 4

_x0_register:
  mov x0, x0
  ret

_x1_register:
  mov x0, x1
  ret

_x2_register:
  mov x0, x2
  ret

_x3_register:
  mov x0, x3
  ret

_x4_register:
  mov x0, x4
  ret

_x5_register:
  mov x0, x5
  ret

_x6_register:
  mov x0, x6
  ret

_x7_register:
  mov x0, x7
  ret

_x8_register:
  mov x0, x8
  ret

_x9_register:
  mov x0, x9
  ret

_x10_register:
  mov x0, x10
  ret

_x11_register:
  mov x0, x11
  ret

_x12_register:
  mov x0, x12
  ret

_x13_register:
  mov x0, x13
  ret

_x14_register:
  mov x0, x14
  ret

_x15_register:
  mov x0, x15
  ret

_sp_register:
  mov x0, sp
  ret
