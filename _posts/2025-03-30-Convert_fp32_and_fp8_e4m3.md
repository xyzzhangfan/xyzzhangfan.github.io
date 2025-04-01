---
layout:     post
title:      Convert data between FP32 and FP8(E4M3)
date:       2025-03-30
author:     xyzzhangfan
header-img: img/post-bg-kuaidi.jpg
catalog: true
toc:
  sidebar: left

tags: FP8

---

## Goal
Open Computing Project (OCP) announced [OCP 8-bit Floating Point Specification (OFP8)](https://www.opencompute.org/documents/ocp-8-bit-floating-point-specification-ofp8-revision-1-0-2023-12-01-pdf-1). This post discusses how to convert FP32 to FP8(E4M3) and FP8(E4M3) back to FP32.

## FP8(E4M3) brief intro
Similar to the IEEE 754, OFP8 representation consists of sign, exponent, and mantissa fields. For E4M3, it 1 bit for sign, 4 bits for exponent, and 3 bit for mantissa.

OFP8 has 2 range: normal and sub-normal

For normal number:
$v = (-1)^S \times 2^{E - \text{bias}} \times (1 + 2^{-m} \times M)$

For sub-normal number(where Exponent fileds are 0):
$v = (-1)^S \times 2^{1 - \text{bias}} \times (0 + 2^{-m} \times M)$

i.e. for normal value: 0_0001_000 --> $(-1)^0 \times 2^{(1-7)} \times (1 + 2^{-3} \times 0)$, the bias for E4M3 is 7. 

The subnormal helps to extend the representive range for E4M3. Without subnormal, the minimum value E4M3 can represent is $2^{-7} \times (1 + 2^{-3})$. But in subnormal, the minimun value is $2^{-9}$.

Here are some specific encoding for E4M3:

| Category                 | E4M3                  |
|--------------------------|----------------------|
| **Infinities**           | N/A                  |
| **NaN**                 | S.1111.111₂          |
| **Zeros**               | S.0000.000₂          |
| **Max normal number**    | S.1111.110₂ = ±448   |
| **Min normal number**    | S.0001.000₂ = ±2⁻⁶   |
| **Max subnormal number** | S.0000.111₂ = ±0.875 × 2⁻⁶ |
| **Min subnormal number** | S.0000.001₂ = ±2⁻⁹   |
| **Dynamic range**        | 18 binades           |



## E4M3 to FP32
```cpp
 #include <cmath>
 #include <iomanip>
 #include <cstdint>
 #include <iostream>
 #include <cstdlib>

 float E4M3ToFloat(uint8_t value) {
     uint8_t bits = *reinterpret_cast<uint8_t*>(&value);
     if ((bits & 0x7f) == 0x7f) return std::nanf(""); // Return Nan value

     uint32_t sign =  (bits >> 7) & 0x1; // 1-bit sign
     uint32_t e4m3_exponent = (bits >> 3) & 0xf; // 4 bit exp
     uint32_t e4m3_mantissa = bits & 0x7; // 3 bit mantissa
     int32_t exponent = e4m3_exponent - 7;
     uint32_t float_exponent = exponent + 127;
     uint32_t result;
     float floatValue;

     if (e4m3_exponent > 0) {
         // normal number
         result =  sign << 31 | float_exponent << 23 | e4m3_mantissa << (23 - 3);
     } else {
         // sub-normal number
         if (e4m3_mantissa >= 0x4) {
             // 2^-7
           result = sign << 31 | (float_exponent) << 23 | (e4m3_mantissa & 0x3) << (23 -2);

         } else if (e4m3_mantissa > 0x1) {
             // 2^-8
           result = sign << 31 | (float_exponent - 1) << 23 | (e4m3_mantissa & 0x1) << (23 -1);

         } else if (e4m3_mantissa == 0x1) {
             // 2^-9
           result = sign << 31 | (float_exponent - 2) << 23;
         } else {
             // return out of range
           return std::nanf("");
         }

     }
     floatValue = *reinterpret_cast<float*>(&result);
     return floatValue;

 }

 int main() {
     uint32_t temp;
     char cont = 'y';

     // Loop to repeatedly accept input
     while (cont == 'y' || cont == 'Y') {
         // Prompt the user to enter a float value
         std::cout << "Enter a E4M3 value in Hex: ";
         std::cin >> std::hex >> temp;  // Read input from the user
         uint8_t value = static_cast<uint8_t>(temp);

         // Call the function to convert
         float result = E4M3ToFloat(value);

         // Print the result
         std::cout << "float representation of E4M3 number 0x" << std::hex << std::setw(2) << std::
 setfill('0') << static_cast<int>(value) << " is " << result << std::endl;

         // Ask if the user wants to continue
         std::cout << "Do you want to enter another value? (y/n): ";
         std::cin >> cont;  // Read 'y' or 'n' for continuing or exiting
     }

     std::cout << "Exiting program." << std::endl;
     return 0;  // Exit successfully
 }
 ```
Run it:

```bash
clang++ -o e4m3 FP32TOFP8.cc
./e4me
Enter a float value: 0.0136719
e4m3 representation of 0.0136719 is 0x7
Do you want to enter another value? (y/n): y
Enter a float value: 448
e4m3 representation of 448 is 0x7e
Do you want to enter another value? (y/n): y
Enter a float value: 0.001954
e4m3 representation of 0.001954 is 0x1
Do you want to enter another value? (y/n): n
```


## FP32 to E4M3
```cpp
 #include <cmath>
 #include <iostream>
 #include <cstdlib>

 uint8_t FloatToE4M3(float value) {
     // Handle special cases (NaN and Infinity)
     if (std::isnan(value)) return 0xFF;  // NaN is 0xFF in e4m3
     if (std::isinf(value)) return (value > 0) ? 0x7F : 0xFF;  // Infinity, 0x7F for +Inf, 0xFF for -Inf

     // Handle zero case
     if (value == 0) return 0x00;  // Zero is 0x00 in e4m3
     // Extract the sign, exponent, and mantissa of the FP32
     uint32_t bits = *reinterpret_cast<uint32_t*>(&value);

     // Extract the sign (1 bit)
     uint8_t sign = (bits >> 31) & 0x1;

     // Extract the exponent (8 bits for FP32)
     int32_t exponent = ((bits >> 23) & 0xFF) - 127;  // Bias for FP32 is 127

     // Extract the mantissa (23 bits for FP32)
     uint32_t mantissa = bits & 0x7FFFFF;  // Get the fractional part

     // For normal numbers, add the implicit leading 1 in the mantissa
     if (exponent != -127) {
         mantissa |= 0x800000;  // Add the leading 1 bit for normalized values
     }

     // Apply the bias for e4m3 (bias of 7)
     int32_t e4m3_exponent = exponent + 7;  // Bias for e4m3 is 7

     // Handle exponent out of range (e4m3 has 4 exponent bits, max is 15)
     if (e4m3_exponent > 15) {
         return sign << 7 | 0x7F;  // Saturate to the NaN
         //return sign << 7 | 0x7E;  // Saturate to the max value (S.1111.110 = S.448)
     } else if ((e4m3_exponent > -3) && (e4m3_exponent <= 0)) {
         // Subnormal numbers (exponent is 0)
         // For subnormal numbers, the mantissa is shifted and stored directly
         uint8_t shift_bits = (3 + e4m3_exponent);
         // Add 1 bit in front of mantissa then shift it
         uint8_t e4m3_mantissa = (mantissa >> (24 - shift_bits)) & (0x7 >> (0-e4m3_exponent));  //Shift to get the top N bits (3 to 1)
         return sign << 7 | 0x00 | e4m3_mantissa;  // Exponent is 0 for subnormal numbers
     } else if (e4m3_exponent <= -3) {
         // Saturate to 0
         return sign << 7 | 0x00;
     }

     // For normal numbers, normalize mantissa to fit into 3 bits (e4m3 has 3 bits for mantissa)
     uint8_t e4m3_mantissa = (mantissa >> (23 - 3)) & 0x07;  // Shift to get the top 3 bits

     // Pack the sign, exponent, and mantissa into an 8-bit value
     uint8_t result = (sign << 7) | (e4m3_exponent << 3) | e4m3_mantissa;

     return result;
 }

 int main() {
     float value;
     char cont = 'y';

     // Loop to repeatedly accept input
     while (cont == 'y' || cont == 'Y') {
         // Prompt the user to enter a float value
         std::cout << "Enter a float value: ";
         std::cin >> value;  // Read input from the user

         // Call the function to convert the float value to e4m3
         uint8_t e4m3 = FloatToE4M3(value);

         // Print the result
         std::cout << "e4m3 representation of " << value << " is 0x" << std::hex << (int)e4m3 <<
 std::endl;

         // Ask if the user wants to continue
         std::cout << "Do you want to enter another value? (y/n): ";
         std::cin >> cont;  // Read 'y' or 'n' for continuing or exiting
     }

     std::cout << "Exiting program." << std::endl;
     return 0;  // Exit successfully
 }
```

Run it:

```bash
clang++ -o fp32 FP32TOFP8.cc
./fp32
Enter a E4M3 value in Hex: 7e
float representation of E4M3 number 0x7e is 448
Do you want to enter another value? (y/n): y
Enter a E4M3 value in Hex: 07
float representation of E4M3 number 0x07 is 0.0136719
Do you want to enter another value? (y/n): y
Enter a E4M3 value in Hex: 08
float representation of E4M3 number 0x08 is 0.015625
Do you want to enter another value? (y/n): n
```
