/*top*/
int main() { return 0; }
int t() { void ((*volatile p)()); p = (void ((*)()))rb_thread_blocking_region; return 0; }
