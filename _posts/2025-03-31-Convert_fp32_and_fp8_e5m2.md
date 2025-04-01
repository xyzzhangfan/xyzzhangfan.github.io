---
layout:     post
title:      Convert data between FP32 and FP8(E5M2)
date:       2025-03-30
author:     xyzzhangfan
header-img: img/post-bg-kuaidi.jpg
catalog: true
toc:
  sidebar: left

tags: FP8

---

## Goal
Continue from the [last post](https://www.xyzzhangfan.tech/blog/2025/Convert_fp32_and_fp8_e4m3/) where we discussed data conversion between FP32 and E4M3. This post discusses how to convert FP32 to E5M2 and FP8(E5M2) back to FP32.

## FP8(E5M2) brief intro
Similar to the IEEE 754, OFP8 representation consists of sign, exponent, and mantissa fields. For E5M2, it 1 bit for sign, 5 bits for exponent, and 2 bit for mantissa.

OFP8 has 2 range: normal and sub-normal

For normal number:
$v = (-1)^S \times 2^{E - \text{bias}} \times (1 + 2^{-m} \times M)$

For sub-normal number(where Exponent fileds are 0):
$v = (-1)^S \times 2^{1 - \text{bias}} \times (0 + 2^{-m} \times M)$

i.e. for normal value: 0_00001_00 --> $(-1)^0 \times 2^{(1-15)} \times (1 + 2^{-2} \times 0)$, the bias for E5M2 is 15. 

The subnormal helps to extend the representive range for E4M3. Without subnormal, the minimum value E4M3 can represent is $2^{-15} \times (1 + 2^{-2})$. But in subnormal, the minimun value is $2^{-16}$.

Here are some specific encoding for E5M2:

| Category                 | E5M2                        |
|--------------------------|-----------------------------|
| **Infinities**           | S.11111.00₂                 |
| **NaN**                 | S.11111.{01, 10, 11}₂       |
| **Zeros**               | S.00000.00₂                 |
| **Max normal number**    | S.11110.11₂ = ±57,344       |
| **Min normal number**    | S.00001.00₂ = ±2⁻¹⁴         |
| **Max subnormal number** | S.00000.11₂ = ±0.75 × 2⁻¹⁴ |
| **Min subnormal number** | S.00000.01₂ = ±2⁻¹⁶         |
| **Dynamic range**        | 32 binades                  |



## E5M2 to FP32
```cpp
#include <cmath>
#include <iostream>
#include <cstdlib>
#include <iomanip>
#include <cstdint>

float E5M2ToFloat(uint8_t value) {
    uint8_t bits = *reinterpret_cast<uint8_t*>(&value);
    if ((bits & 0x7f) == 0x7f) return std::nanf(""); // Return NaN Value

    uint32_t sign = (bits >> 7) & 0x1; // 1-bit sign
    uint32_t e5m2_exponent = (bits >> 2) & 0x1f; // 5 bits exp
    uint32_t e5m2_mantissa = bits & 0x3; // 2 bits mantissa
    int32_t exponent = e5m2_exponent - 15;
    uint32_t float_exponent = exponent + 127;
    uint32_t result;
    float floatValue;

    if (e5m2_exponent > 0) {
        // normal number
        result = sign << 31 | float_exponent << 23 | e5m2_mantissa << (23-2);
    } else {
        // sub-normal number
        if (e5m2_mantissa >= 0x2) {
            // 2^-15
            result = sign << 31 | (float_exponent) << 23 | (e5m2_mantissa & 0x1) << (23 - 1);
        } else if (e5m2_mantissa == 0x1) {
            result = sign << 31 | (float_exponent - 1) << 23;
        } else {
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
        std::cout << "Enter a E5M2 value in Hex: ";
        std::cin >> std::hex >> temp;  // Read input from the user
        uint8_t value = static_cast<uint8_t>(temp);

        // Call the function to convert
        float result = E5M2ToFloat(value);

        // Print the result
        std::cout << "float representation of E5M2 number 0x" << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(value) << " is " << result << std::endl;

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
clang++ -o e5m2tofp32 E5M2TOFP32.cc
./e5m2tofp32
Enter a E5M2 value in Hex: 01
float representation of E5M2 number 0x01 is 1.52588e-05
Do you want to enter another value? (y/n): y
Enter a E5M2 value in Hex: 02
float representation of E5M2 number 0x02 is 3.05176e-05
Do you want to enter another value? (y/n): y
Enter a E5M2 value in Hex: 03
float representation of E5M2 number 0x03 is 4.57764e-05
Do you want to enter another value? (y/n): n
```



## FP32 to E5M2
```cpp
#include <cmath>
#include <iostream>
#include <cstdlib>

uint8_t FloatToE5M2(float value) {
    if (std::isnan(value)) return 0xFF; // NaN is 0xFF, 0xFE, 0xFD
    if (std::isinf(value)) return (value > 0) ? 0x7C : 0xFC; // inf is 0xFC and 0x7C
    // Handle zero case
    if (value == 0) return 0x00;
    // Extract the sign, exponent, and mantissa of the FP32
    uint32_t bits = *reinterpret_cast<uint32_t*>(&value);

    // Extract the sign (1 bit)
    uint8_t sign = (bits >> 31) & 0x1;

    // Extract the exponent (8 bits for FP32)
    uint32_t exponent = ((bits >> 23) & 0xFF) - 127; // Bias for FP32 is 127

    // Extract the mantissa (23 bits for FP32)
    uint32_t mantissa = bits & 0x7FFFFF; // Get the frational part

    if (exponent != -127) {
        mantissa |= 0x800000; // Add the leading 1 bit for normalized values
    }

    // Apply the bias for e5m2 (bias of 15)
    int32_t e5m2_exponent = exponent + 15; // Bias for e5m2 is 15

    // Handle exponent out of range(e5m2 has 5 exponent bis, max is 31)
    if (e5m2_exponent > 31) {
        return sign << 7 | 0x7C; // Saturate to inf
    } else if ((e5m2_exponent >= -1) && (e5m2_exponent <= 0)) {
        uint8_t shift_bits = (2 + e5m2_exponent);
        uint8_t e5m2_mantissa = (mantissa >> (24 - shift_bits)) & (0x3 >> (0 - e5m2_exponent));
        return sign << 7 | 0x00 | e5m2_mantissa;
    } else if (e5m2_exponent < -1) {
        return sign << 7 | 0x00;
    }

    uint8_t e5m2_mantissa = (mantissa >> (23 - 2)) & 0x03;

    uint8_t result = (sign << 7) | (e5m2_exponent << 2) | e5m2_mantissa;
    return result;
}

int main() {
    float value;
    char cont = 'y';

    // Loop to repeately accept input
    while (cont == 'y' || cont == 'Y') {
        // Prompt the user to enter a float value
        std::cout << "Enter a float value: ";
        std::cin >> value;  // Read input from the user

        // Call the function to convert the float value to e4m3
        uint8_t e5m2 = FloatToE5M2(value);

        // Print the result
        std::cout << "e5m2 representation of " << value << " is 0x" << std::hex << (int)e5m2 << std::endl;

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
clang++ -o e5m2 FP32TOE5M2.cc
./e5m2
Enter a float value: 0.000045776367
e5m2 representation of 4.57764e-05 is 0x3
Do you want to enter another value? (y/n): y
Enter a float value: 0.000030517578
e5m2 representation of 3.05176e-05 is 0x2
Do you want to enter another value? (y/n): y
Enter a float value: 0.000015258789
e5m2 representation of 1.52588e-05 is 0x1
Do you want to enter another value? (y/n): y
Enter a float value: 57344
e5m2 representation of 57344 is 0x7b
Do you want to enter another value? (y/n): n
```