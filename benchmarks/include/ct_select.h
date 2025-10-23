static inline int ct_select(int taken, int a, int b) {
    // int result = (taken * a) ^ (!taken * b);
    int result;
    __asm__ volatile (
        "mulw       a4, %[a], %[taken] \n\t"
        "snez       a5, %[taken] \n\t"
        "addi       a5, a5, -1\n\t"
        "and        a5, a5, %[b]\n\t"
        "xor        %[result], a5, a4\n\t"
        : [result] "=r" (result)
        : [a] "r" (a),
            [b] "r" (b),
            [taken] "r" (taken)
        : "a4", "a5"
    );

    return result;
}

static inline long long int ct_select_ll(int taken, long long int a, long long int b) {
    // int result = (taken * a) ^ (!taken * b);
    long long int result;
    __asm__ volatile (
        "mul        a4, %[a], %[taken] \n\t"
        "snez       a5, %[taken] \n\t"
        "addi       a5, a5, -1\n\t"
        "and        a5, a5, %[b]\n\t"
        "xor        %[result], a5, a4\n\t"
        : [result] "=r" (result)
        : [a] "r" (a),
            [b] "r" (b),
            [taken] "r" (taken)
        : "a4", "a5"
    );

    return result;
}