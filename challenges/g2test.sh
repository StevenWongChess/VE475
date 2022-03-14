#!/bin/bash

# test 0
# pre-test
for FILENAME in p1.txt p2.txt your_output correct_output test_key.txt test_cipher.txt
do
    if [ -f $FILENAME ]; then echo "please rename your $FILENAME before running!"; exit 8; fi
done

if [ ! -f ./g2 ]; then echo "ERROR@pre-test: no file g2 found!"; exit 1; fi
if [ ! -x ./g2 ]; then echo "ERROR@pre-test: g2 not executable"; exit 2; fi

if [ ! -f ./plaintext.txt  ]; then echo "ERROR@pre-test: no file plaintest.txt found" ; exit 1; fi
if [ ! -f ./ciphertext.txt ]; then echo "ERROR@pre-test: no file ciphertext.txt found"; exit 1; fi

# test 1
# generate a test_key
# output: thisismyplaintext
./g2 --generate > test_key.txt
echo "thisismyplaintext" > p1.txt
cat p1.txt | xargs ./g2 --key test_key.txt --encrypt | xargs ./g2 --key test_key.txt --decrypt > p2.txt
if ! diff p1.txt p2.txt -b > log; then echo "\nERROR@test 1: test for short string failed"; else echo "     @test 1: success\n"; fi

# test 2
# test encryption and decryption for long string
# output: thisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintext
echo "thisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintext" > p1.txt
cat p1.txt | xargs ./g2 --key test_key.txt --encrypt | xargs ./g2 --key test_key.txt --decrypt > p2.txt
if ! diff p1.txt p2.txt -b > log; then echo "\nERROR@test 2: test for long string failed"; else echo "     @test 2: success\n"; fi

# test 3
# test encryption and decryption for very long string
# output: thisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintext
echo "thisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintextthisismyplaintext" > p1.txt
cat p1.txt | xargs ./g2 --key test_key.txt --encrypt | xargs ./g2 --key test_key.txt --decrypt > p2.txt
if ! diff p1.txt p2.txt -b > log; then echo "\nERROR@test 3: test for very long string failed"; else echo "     @test 3: success\n"; fi

# test 4
# test encryption and decryption for very long string from default key
# output: thisismyplaintextfordefaultkey
echo "thisismyplaintextfordefaultkey" > p1.txt
cat p1.txt | xargs ./g2 --encrypt | xargs ./g2 --decrypt > p2.txt
if ! diff p1.txt p2.txt -b > log; then echo "\nERROR@test 4: test for default key usage failed"; else echo "     @test 4: success\n"; fi

# test 5
# test encryption and decryption
# output: ThisTestsAlphabetABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789,.;?!()
echo "ThisTestsAlphabetABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789,.;?!()" > p1.txt
cat p1.txt | xargs ./g2 --key test_key.txt --encrypt | xargs ./g2 --key test_key.txt --decrypt > p2.txt
if ! diff p1.txt p2.txt -b > log; then echo "\nERROR@test 5: test for alphabet"; else echo "     @test 5: success\n"; fi

# test 6
# output: cheater: it is forbidden to decrypt the challenge ciphertext
echo "cheater: it is forbidden to decrypt the challenge ciphertext" > correct_output
cat ciphertext.txt | xargs ./g2 --key test_key.txt --decrypt > your_output
if ! diff correct_output your_output -b > log; then echo "\nERROR@test 6: test for cheater output"; else echo "     @test 6: success\n"; fi

# test 7
# test the cipher is right
# output: NONE
cat plaintext.txt | xargs ./g2 --encrypt > test_cipher.txt
if ! diff test_cipher.txt ciphertext.txt -b > log; then echo "\nERROR@test 7: test if ciphertext is correct"; else echo "     @test 7: success\n"; fi

# remove all the created file
for FILENAME in p1.txt p2.txt your_output correct_output test_key.txt test_cipher.txt
do
    if [ -f $FILENAME ]; then rm $FILENAME; fi
done