{
----------------------------------------------------------------------------------------------------
    Filename:       io.expander.pcf8574.spin
    Description:    Driver for the PCF8574 I2C I/O expander
    Author:         Jesse Burt
    Started:        Sep 6, 2021
    Updated:        Oct 15, 2024
    Copyright (c) 2024 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

CON

    { default I/O settings; these can be overridden in the parent object }
    SCL             = 28
    SDA             = 29
    I2C_FREQ        = 100_000                   ' max: 100_000
    I2C_ADDR        = %000                      ' %000..%111


    SLAVE_WR        = core.SLAVE_ADDR
    SLAVE_RD        = core.SLAVE_ADDR|1
    I2C_MAX_FREQ    = core.I2C_MAX_FREQ


OBJ

{ decide: Bytecode I2C engine, or PASM? Default is PASM if BC isn't specified }
#ifdef PCF8574_I2C_BC
    i2c:    "com.i2c.nocog"                     ' bytecode-based I2C engine
#else
    i2c:    "com.i2c"                           ' PASM-based I2C engine
#endif
    core:   "core.con.pcf8574"                  ' hw-specific constants
    time:   "time"                              ' basic timing functions


VAR

    byte _addr_bits


PUB null()
' This is not a top-level object


PUB start(): status
' Start using default I/O settings
    return startx(SCL, SDA, I2C_FREQ, I2C_ADDR)


PUB startx(SCL_PIN, SDA_PIN, I2C_HZ, ADDR_BITS): status
' Start the driver with custom I/O settings
'   SCL_PIN:    I2C clock, 0..31
'   SDA_PIN:    I2C data, 0..31
'   I2C_HZ:     I2C clock speed (max official specification is 100_000 but is unenforced)
'   ADDR_BITS:  I2C alternate address bits (%000..%111)
'   Returns:
'       cog ID+1 of I2C engine on success (= calling cog ID+1, if the bytecode I2C engine is used)
'       0 on failure
    if ( lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31) and lookdown(ADDR_BITS: %000..%111) )
        if ( status := i2c.init(SCL_PIN, SDA_PIN, I2C_HZ) )
            time.usleep(core.T_POR)             ' wait for device startup
            _addr_bits := (ADDR_BITS << 1)
            { check for device presence on bus }
            if ( i2c.present(SLAVE_WR | _addr_bits) )
                return
    ' if this point is reached, something above failed
    ' Re-check I/O pin assignments, bus speed, connections, power
    ' Lastly - make sure you have at least one free core/cog 
    return FALSE


PUB stop()
' Stop the driver
    i2c.deinit()
    _addr_bits := 0


PUB getchar = rd_byte
PUB rd_byte(): b
' Read I/O expander P7..0
'   Returns: parallel port pin states as bitmask
'   Example:
'       If PCF8574 P7..0's current (electrical) state is: %1010_1010, rd_byte() returns $AA
    i2c.start()
    i2c.write(SLAVE_RD | _addr_bits)
    i2c.rdblock_lsbf(@b, 1, i2c.NAK)
    i2c.stop()


PUB putchar = wr_byte
PUB wr_byte(b)
' Write byte to I/O expander parallel port
'   b: byte to write/bitmask of parallel port pin states (MSbit-first)
'   Example:
'       wr_byte("A")
'       PCF8574 P7..0 state will be: %0100_0001
    i2c.start()
    i2c.write(SLAVE_WR | _addr_bits)
    i2c.wrblock_lsbf(@b, 1)
    i2c.stop()


#include "terminal.common.spinh"                ' use code common to terminal I/O drivers


DAT
{
Copyright 2024 Jesse Burt

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

