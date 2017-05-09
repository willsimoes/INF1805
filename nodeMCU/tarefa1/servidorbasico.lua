led1 = 3
led2 = 6
sw1 = 1
sw2 = 2

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
gpio.mode(sw1, gpio.INPUT)
gpio.mode(sw2, gpio.INPUT)

gpio.write(led1, gpio.LOW);
gpio.write(led2, gpio.LOW);

local led={}
led[0]="OFF"
led[1]="ON_"

local sw={}
sw[1]="OFF"
sw[0]="ON_"

local lasttemp = 0

local function willwrite (led, s)
  return function () 
           gpio.write(led, s) 
         end
end

local function readtemp()
  lasttemp = adc.read(0)*(3.3/10.24)
end

local actions = {
  LERTEMP = readtemp,
  LIGA1 = willwrite(led1, gpio.HIGH),
  DESLIGA1 = willwrite(led1, gpio.LOW),
  LIGA2 = willwrite(led2, gpio.HIGH),
  DESLIGA2 = willwrite(led2, gpio.LOW),
}

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
    LED1 = led[gpio.read(led1)],
    LED2 = led[gpio.read(led2)],
  }

  local buf = [[
<h1><u>PUC Rio - Sistemas Reativos</u></h1>
<h2><i>ESP8266 Web Server</i></h2>
        <p>Temperatura: $TEMP oC <a href="?pin=LERTEMP"><button><b>REFRESH</b></button></a>
        <p>LED 1: $LED1  :  <a href="?pin=LIGA1"><button><b>ON</b></button></a>
                            <a href="?pin=DESLIGA1"><button><b>OFF</b></button></a></p>
        <p>LED 2: $LED2  :  <a href="?pin=LIGA2"><button><b>ON</b></button></a>
                            <a href="?pin=DESLIGA2"><button><b>OFF</b></button></a></p>
]]

  buf = string.gsub(buf, "$(%w+)", vals)
  sck:send(buf, function() print("respondeu") end)
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
