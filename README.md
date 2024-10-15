# pcf8574-spin 
--------------

This is a P8X32A/Propeller, P2X8C4M64P/Propeller 2 driver object for the PCF8574 I2C I/O expander

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.


## Salient Features

* I2C connection at ~30kHz (P1: SPIN I2C), 100kHz (P1: PASM I2C, P2)
* Methods to read a byte from and write a byte to the I/O expander parallel port
* Common terminal I/O routines (`getchar()`, `putchar()`, `puts()`, etc)


## Requirements

P1/SPIN1:
* spin-standard-library
* terminal.common.spinh (source: spin-standard-library)

P2/SPIN2:
* p2-spin-standard-library
* terminal.common.spin2h (source: p2-spin-standard-library)


## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (6.9.4)       | Bytecode     | OK                    |
| P1        | SPIN1    | FlexSpin (6.9.4)       | Native/PASM  | OK                    |
| P2        | SPIN2    | FlexSpin (6.9.4)       | NuCode       | Untested              |
| P2        | SPIN2    | FlexSpin (6.9.4)       | Native/PASM2 | OK                    |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Limitations

* TBD

