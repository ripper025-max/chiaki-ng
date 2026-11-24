// SPDX-License-Identifier: LicenseRef-AGPL-3.0-only-OpenSSL
#include "nativeupscalegovernor.h"
#include <cassert>
int main() {
    NativeUpscaleGovernor g;
    assert(g.select(3,false,1000)==3);
    assert(g.select(3,true,2000)==3);
    assert(g.select(3,true,121999)==3);
    assert(g.select(3,true,122000)==2);
    assert(g.select(3,true,242000)==1);
    assert(g.select(3,true,400000)==1);
    assert(g.select(3,false,500000)==1);
    assert(g.select(3,false,3499999)==1);
    assert(g.select(3,false,3500000)==2);
    assert(g.select(3,false,6500000)==3);
    assert(g.select(0,true,6500001)==0);
    assert(g.select(2,false,6500002)==2);
    assert(g.select(2,true,6500003)==2);
    assert(g.select(2,false,6550000)==2);
    assert(g.select(1,true,7000000)==1);
    assert(g.select(8,false,8000000)==3);
    assert(g.select(-1,false,9000000)==0);
}
