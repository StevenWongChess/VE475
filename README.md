# VE475

I was `teaching assistant` of `VE475 Intro to Cryptography` with 1 other TA `Hanyu Wang` Summer 2021.

##### Our responsibility & job:

1. `Grader`: grade homework & exam paper

2. Hold office hour & answer questions on Piazza

##### Env Setup

Install the GNU Multi Precision Arithmetic Library (`GMP`) from https://gmplib.org/ or its fork MPIR available at http://mpir.org/. Note that MPIR has a better support for Windows, although no binaries are officially provided. GMP is available on any modern Linux distribution.

##### Programming:

1. In the AES, choose two layers to implement in C. The 128 bits should be looked at as an unsigned char pointer. Operations should be implemented using logical operators (and, or, and xor).

   A bonus will be given for each extra layer implemented, and the generation of the S-Box. A big bonus will reward a complete implementation of the AES.

2. Implement the three functions generate, encrypt and decrypt, which generate the RSA parameters, encrypt, and decrypt, respectively.

   The function generate takes as input a security level and generate p and q such that n is long enough to match the required security level. No special requirement is requested on encrypt and decrypt.

3. Implement the Pollard-rho factorization algorithm.
