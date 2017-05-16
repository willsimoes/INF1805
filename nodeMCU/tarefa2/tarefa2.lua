led1 = 3
led2 = 6
sw1 = 1
sw2 = 2

local ledtimer = tmr.create()
local tmp = 1000
local timer_1 = nil
local timer_2 = nil

function acelera(level, time) 
  local diff_timer
  -- pressionei botao 1
  tmp = tmp - 50
  if(tmp < 2) then
    tmp = 2
  end

  if timer_2 then
    diff_timer = time - timer_2
    --microsegundos em milisegundo
    diff_timer = diff_timer/1000
    print("tempo entre os dois botoes", diff_timer)
    if diff_timer < 500 then
      apaga_leds()
    end
  else 
    timer_1 = time
  end

  timer_2 = nil

  ledtimer:interval(tmp)
end


function desacelera(level, time) 
  local diff_timer
  -- pressionei botao 2
  tmp = tmp + 50

  if timer_1 then
    diff_timer = time - timer_1
    --microsegundos em milisegundo
    diff_timer = diff_timer/1000
    print("tempo entre os dois botoes", diff_timer)
    if diff_timer < 500 then
      apaga_leds()
    end
  else 
    timer_2 = time
  end

  timer_1 = nil
  
  ledtimer:interval(tmp)
end

-- definição dos leds e botões
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
gpio.mode(sw1, gpio.INT, gpio.PULLUP)
gpio.mode(sw2, gpio.INT, gpio.PULLUP)

-- leds desligados
gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);

gpio.trig(sw1, "down", acelera)
gpio.trig(sw2, "down", desacelera)

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
    parar = function (self) 
      ledtimer:stop()
      self.desliga()
    end
  }
end

led_um = newled(led1)
led_dois = newled(led2)

function pisca_leds () 
  led_um:piscar()
  led_dois:piscar()
end

function apaga_leds () 
  led_um:parar()
  led_dois:parar()
end

tmr.alarm(ledtimer, tmp, tmr.ALARM_SEMI, pisca_leds)
