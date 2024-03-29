{
    --------------------------------------------
    Filename: io.expander.pcf8574.spin
    Author: Jesse Burt
    Description: Driver for the PCF8574 I2C I/O expander
    Copyright (c) 2022
    Started Sep 06, 2021
    Updated Nov 27, 2022
    See end of file for terms of use.
    --------------------------------------------
}

CON

    SLAVE_WR        = core#SLAVE_ADDR
    SLAVE_RD        = core#SLAVE_ADDR|1

    DEF_SCL         = 28
    DEF_SDA         = 29
    DEF_HZ          = 100_000
    DEF_ADDR        = %000
    I2C_MAX_FREQ    = core#I2C_MAX_FREQ

OBJ

{ decide: Bytecode I2C engine, or PASM? Default is PASM if BC isn't specified }
#ifdef PCF8574_SPIN
    i2c : "com.i2c.nocog"                       ' SPIN I2C engine
#else
    i2c : "com.i2c"                             ' PASM I2C engine
#endif
    core: "core.con.pcf8574"                    ' hw-specific low-level const's
    time: "time"                                ' basic timing functions

VAR

    byte _addr_bits

PUB null{}
' This is not a top-level object

PUB start{}: status
' Start using "standard" Propeller I2C pins and 100kHz
    return startx(DEF_SCL, DEF_SDA, DEF_HZ, DEF_ADDR)

PUB startx(SCL_PIN, SDA_PIN, I2C_HZ, ADDR_BITS): status
' Start using custom IO pins and I2C bus frequency
    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31) and {
}   I2C_HZ =< core#I2C_MAX_FREQ and lookdown(ADDR_BITS: %000..%111)
        if (status := i2c.init(SCL_PIN, SDA_PIN, I2C_HZ))
            time.usleep(core#T_POR)             ' wait for device startup
            _addr_bits := (ADDR_BITS << 1)
            { check for device presence on bus }
            if (i2c.present(SLAVE_WR | _addr_bits))
                return
    ' if this point is reached, something above failed
    ' Re-check I/O pin assignments, bus speed, connections, power
    ' Lastly - make sure you have at least one free core/cog 
    return FALSE

PUB stop{}
' Stop the driver
    i2c.deinit{}
    _addr_bits := 0

PUB rd_byte{}: rd_b
' Read I/O expander P7..0
'   Returns: parallel port pin states as bitmask
'   Example:
'       If PCF8574 P7..0's current (electrical) state is: %1010_1010, rd_byte() returns $AA
    i2c.start{}
    i2c.write(SLAVE_RD | _addr_bits)
    rd_b := i2c.rd_byte(i2c#NAK)
    i2c.stop{}

PUB wr_byte(wr_b)
' Write byte to I/O expander parallel port
'   wr_b: bitmask of parallel port pin states (MSbit-first)
'   Example:
'       wr_byte("A")
'       PCF8574 P7..0 state will be: %0010_0001
    i2c.start{}
    i2c.write(SLAVE_WR | _addr_bits)
    i2c.wr_byte(wr_b)
    i2c.stop{}

DAT
{
Copyright 2022 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

