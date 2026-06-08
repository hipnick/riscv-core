/* =============================================================================
   Project:         riscv-core
   File:            main.c
   Description:     Freestanding Fibonacci algorithmic routine targeting
                    structural functional path verification.
   ============================================================================= */

int main(void) {
    volatile int *status_port = (volatile int *)0x00000F00; // Custom termination tracker address
    int n = 8;
    int t1 = 0, t2 = 1;
    int next_term = 0;

    for (int i = 1; i <= n; ++i) {
        if(i == 1) {
            next_term = t1;
            continue;
        }
        if(i == 2) {
            next_term = t2;
            continue;
        }
        next_term = t1 + t2;
        t1 = t2;
        t2 = next_term;
    }

    // Write final output result payload calculation to the custom termination zone
    *status_port = next_term; 

    return 0;
}