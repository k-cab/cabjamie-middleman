#include <ruby.h>
#include <rubysig.h>

/*top*/
int main() { return 0; }
int t() { const volatile void *volatile p; p = &(&rb_trap_immediate)[0]; return 0; }
