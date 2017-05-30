require('lure//lure.lua')
JSON = (loadfile "JSON.lua")()

MQTT = require("mqtt_library")
MQTT.Utility.set_debug(true)

-- topicos que gerenciador vai assinar
topics = { "localizacao", "sensor", "monitoramento" }

c = MQTT.client.create("localhost", 1833, callback)
c:connect("gerenciador-id")
c:subscribe(topics)

-- callback chamada quando mensagens dos topicos chegam
function callback(topic, message)
    print("Received: " .. topic .. ": " .. message)
    if topic == "sensor" then
        print("Processando dados do sensor. Mensagem: " .. message)
        -- "processa" dado do sensor
        local distance = tonumber(message)
        if distance < 30 then
            c:publish("acoes", "LIGALED")
        else if distance > 30 then
            c:publish("acoes", "DESLIGALED")
        end
    else if topic == "localizacao" then
        print("Processando localizacao. Mensagem: " .. message)
        lastLocation, origem = message:match("(.+) (.+)")
        local sinal = {}
    
        if (lastLocation ~= nil) then
          for k, v in string.gmatch(lastLocation, "([^=]+)=([^=]+)&") do
            sinal[k] = v
            print (k, sinal[k])
          end
        end

        local endereco = processarLocalizacao(sinal["lon"], sinal["lat"])

        if(sinal["data"] ~= nil) then
          _, _, dt, hora = string.find(sinal["data"], "(%d+/%d+/%d+)$(.+)");
        end

        local info = "Usuário última vez localizado em: "  .. endereco .. " às " .. hora .. " do dia " .. dt;
        if origem == "botaoajuda" then
            info = "[ATENÇÃO] Usuário solicitou sua ajuda \n" .. info
        end

        c:publish("monitoramento", info)
    else if topic == "monitoramento" then
        if message == "pedido" then
          c:public("acoes", "LOCALIZACAO")
        else
          print(message)
        end
    end
end

-- funcao que faz requisicao a API do google Maps para pegar endereco a partir de longitude e latitude
function processarLocalizacao(lon, lat)
  req = XMLHttpRequest.new()
 
  local caminho = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=' + lon + ',' + lat;
  --create a new request, set method, url, and sync option
  req.open('GET', caminho, true);

  req.onReadyStateChange = function() 
    if req.readyState == 4 and req.status == 200 then
      local jsonTable= JSON:decode(req.responseText)
      local results = jsonTable["results"]
      local result = results[0]
      return result["formatted_address"]
    end
  end

  req.send();
end