led1 = 3
led2 = 6
sw1 = 1
sw2 = 2

-- definição dos leds e botões
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
gpio.mode(sw1, gpio.INPUT)
gpio.mode(sw2, gpio.INPUT)

led_um = newled(led1)
led_dois = newled(led2)

-- leds desligados
gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);

local led_state={}
led_state[0]="OFF"
led_state[1]="ON_"

local sw={}
sw[1]="OFF"
sw[0]="ON_"

local lasttemp = 0

local actions = {
  LERTEMP = readtemp,
  PISCA1 = led_um.pisca()
  PARA1 = led_um.para()
  PISCAR = led_dois.pisca()
  PARA2 = led_dois.para()
}

local function readtemp()
  lasttemp = adc.read(0)*(3.3/10.24)
end

srv = net.createServer(net.TCP)

function receiver(sck, request)

  -- analisa pedido para encontrar valores enviados
  local _, _, method, path, vars = string.find(request, "([A-Z]+) ([^?]+)%?([^ ]+) HTTP");
  -- se não conseguiu casar, tenta sem variáveis
  if(method == nil)then
    _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
  end
  
  local _GET = {}
  
  if (vars ~= nil)then
    for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
      _GET[k] = v
    end
  end


  local action = actions[_GET.pin]
  if action then action() end

  local vals = {
    --TEMP = string.format("%2.1f",adc.read(0)*(3.3/10.24)),
    TEMP =  string.format("%2.1f", lasttemp),
    CHV1 = gpio.LOW,
    CHV2 = gpio.LOW,
    LED1 = led_state[gpio.read(led1)],
    LED2 = led_state[gpio.read(led2)],
  }

  local buf = [[
<h1><u>PUC Rio - Sistemas Reativos</u></h1>
<h2><i>ESP8266 Web Server</i></h2>
        <p>Temperatura: $TEMP oC <a href="?pin=LERTEMP"><button><b>REFRESH</b></button></a>
        <p>LED 1: $LED1  :  <a href="?pin=PISCA1"><button><b>PISCAR</b></button></a>
                            <a href="?pin=PARA1"><button><b>PARAR</b></button></a></p>
        <p>LED 2: $LED2  :  <a href="?pin=PISCA2"><button><b>PISCAR</b></button></a>
                            <a href="?pin=PARA2"><button><b>PARAR</b></button></a></p>
]]

  buf = string.gsub(buf, "$(%w+)", vals)
  sck:send(buf, function() print("respondeu") sck:close() end)
end

if srv then
  srv:listen(80,"192.168.0.20", function(conn)
      print("estabeleceu conexão")
      conn:on("receive", receiver)
    end)
end

addr, port = srv:getaddr()
print(addr, port)
print("servidor inicializado.")

function newled (num) 
  local ledtimer = tmr.create()
  ledtimer:register(1000, tmr.ALARM_SEMI, self.piscar())
  pin = num,
  return {
    liga = function () 
       gpio.write(pin, gpio.HIGH) 
    end,
    desliga = function () 
      gpio.write(pin, gpio.LOW) 
    end,
    piscar = function (self) 
      ledtimer:start()
      if(gpio.read(pin)) then
        desliga()
      else
        liga()
      end
    end,
    parar = function () 
      ledtimer:stop()
    end
  }
end