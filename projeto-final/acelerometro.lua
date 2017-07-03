-- Código que dá medida do acelerometro MPU-6050 nos 3 eixos
-- SDA em D3 e SCL em D4 no mini nodeMCU 
-- adaptado de https://github.com/TheOS1/ESP8266/tree/master/Drivers/Lua%20Drivers/MPU6050/Code

acelerometro = {}

dev_addr = 0x68 --104
bus = 0
sda, scl = 3, 4
-- sda fio laranja, scl fio amarelo
function acelerometro.init() 
    local self = {}
    function self.init_I2C()
      i2c.setup(bus, sda, scl, i2c.SLOW)
    end

    function self.init_MPU(reg,val)  --(107) 0x6B / 0
       self.write_reg_MPU(reg,val)
    end

    function self.write_reg_MPU(reg,val)
      i2c.start(bus)
      i2c.address(bus, dev_addr, i2c.TRANSMITTER)
      i2c.write(bus, reg)
      i2c.write(bus, val)
      i2c.stop(bus)
    end

    function self.read_reg_MPU(reg)
      i2c.start(bus)
      i2c.address(bus, dev_addr, i2c.TRANSMITTER)
      i2c.write(bus, reg)
      i2c.stop(bus)
      i2c.start(bus)
      i2c.address(bus, dev_addr, i2c.RECEIVER)
      c=i2c.read(bus, 1)
      i2c.stop(bus)
      --print(string.byte(c, 1))
      return c
    end

    function self.read_MPU_raw()
      i2c.start(bus)
      i2c.address(bus, dev_addr, i2c.TRANSMITTER)
      i2c.write(bus, 59)
      i2c.stop(bus)
      i2c.start(bus)
      i2c.address(bus, dev_addr, i2c.RECEIVER)
      c=i2c.read(bus, 14)
      i2c.stop(bus)

      Ax=bit.lshift(string.byte(c, 1), 8) + string.byte(c, 2)
      Ay=bit.lshift(string.byte(c, 3), 8) + string.byte(c, 4)
      Az=bit.lshift(string.byte(c, 5), 8) + string.byte(c, 6)

      --print("Ax:"..Ax.."     Ay:"..Ay.."      Az:"..Az)
      publicaDadosAcelerometro(Ax..":"..Ay..":"..Az)
      --return Ax, Ay, Az
    end

    function self.status_MPU(dev_addr)
         i2c.start(bus)
         c=i2c.address(bus, dev_addr ,i2c.TRANSMITTER)
         i2c.stop(bus)
         if c==true then
            print(" Device found at address : "..string.format("0x%X",dev_addr))
         else print("Device not found !!")
         end
    end

    function self.check_MPU(dev_addr)
       print("")
       self.status_MPU(0x68)
       self.read_reg_MPU(117) --Register 117 – Who Am I - 0x75
       if string.byte(c, 1) == 104 then print(" MPU6050 Device answered OK!")
       else print("  Check Device - MPU6050 NOT available!",c,string.byte(c, 1))
            return
       end
       self.read_reg_MPU(107) --Register 107 �� Power Management 1-0x6b
       if string.byte(c, 1)==64 then print(" MPU6050 in SLEEP Mode !")
       else print(" MPU6050 in ACTIVE Mode !")
       end
    end

    return self
end
