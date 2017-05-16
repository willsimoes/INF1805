led1 = 3
led2 = 6
sw1 = 1
sw2 = 2

local ledtimer = tmr.create()

-- definição dos leds e botões
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
gpio.mode(sw1, gpio.INPUT)
gpio.mode(sw2, gpio.INPUT)

-- leds desligados
gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);

function newled (num) 
  local pin = num
  return {
    liga = function () 
      gpio.write(pin, gpio.HIGH) 
    end,
    desliga = function () 
      gpio.write(pin, gpio.LOW) 
    end,
    piscar = function (self) 
      ledtimer:start()
      if(gpio.read(pin) == 1) then
        self.desliga()
      else
        self.liga()
      end
    end,
    parar = function () 
      ledtimer:stop()
    end
  }
end

led_um = newled(led1)
led_dois = newled(led2)


function pisca_leds () 
  led_um:piscar()
  led_dois:piscar()
end

tmr.alarm(ledtimer, 1000, tmr.ALARM_SEMI, pisca_leds)
