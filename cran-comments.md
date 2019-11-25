## Test environments
- R-hub ubuntu-gcc-release (r-release)
- R-hub ubuntu-gcc-devel (r-devel)
- R-hub windows-x86_64-devel (r-devel)
- R-hub windows-x86_64-release (r-release)
- R-hub windows-x86_64-oldrel (r-oldrel)
- R-hub macos-elcapitan-release (r-release)
- R-hub solaris-x86-patched (r-patched)
- R-hub debian-gcc-release (r-release)

## R CMD check results
> On ubuntu-gcc-release (r-release), ubuntu-gcc-devel (r-devel), windows-x86_64-devel (r-devel), windows-x86_64-release (r-release), windows-x86_64-oldrel (r-oldrel), macos-elcapitan-release (r-release), solaris-x86-patched (r-patched), debian-gcc-release (r-release)
  checking CRAN incoming feasibility ... NOTE
  Maintainer: ?Brian W. Davis <brianwdavis@gmail.com>?
  
  New submission
  
  License components with restrictions and base license permitting such:
    GPL (>= 3) + file LICENSE
  File 'LICENSE':
    https://github.com/dlbeer/quirc/blob/master/LICENSE
    Retrieved 2019-11-21
    
    quirc -- QR-code recognition library
    Copyright (C) 2010-2012 Daniel Beer <dlbeer@gmail.com>
    
    Permission to use, copy, modify, and/or distribute this software for
    any purpose with or without fee is hereby granted, provided that the
    above copyright notice and this permission notice appear in all
    copies.
    
    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
    WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
    AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
    DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
    PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
    TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
    PERFORMANCE OF THIS SOFTWARE.
    
    
    ================================================================================
    
    https://github.com/cozmo/jsQR/blob/master/LICENSE
    Retrieved 2019-11-21
    
                                     Apache License
                               Version 2.0, January 2004
                            http://www.apache.org/licenses/
    
    --- Text of standard license truncated for cran-comments.md ---

> On windows-x86_64-devel (r-devel)
  checking for non-standard things in the check directory ... NOTE
  Found the following files/directories:
    'tests_i386' 'tests_x64'

0 errors v | 0 warnings v | 2 notes x

This appears to be an artifact from R-hub, not reproducible on other Windows machines.