local MQTT = require("mqtt_library")
MQTT.Utility.set_debug(true)

-- topicos que gerenciador vai assinar
topics = { "localizacao", "sensor", "monitoramento" }

c = MQTT.client.create("192.168.0.13", 1833, callback)
c:connect("gerenciador-id")
c:subscribe(topics)

-- callback chamada quando mensagens dos topicos chegam
function callback(topic, message)
    print("Received from " .. topic .. ": " .. message)
    if topic == "sensor" then
        print("Processando dados do sensor. Mensagem: " .. message)
        -- "processa" dado do sensor
        local distance = tonumber(message)
        if distance < 30 then
            c:publish("acoes", "LIGALED")
        elseif distance > 30 then
            c:publish("acoes", "DESLIGALED")
        end
    elseif topic == "localizacao" then
        print("Processando localizacao. Mensagem: " .. message)
        lastLocation, origem = message:match("(.+) (.+)")
        local sinal = {}
    
        if (lastLocation ~= nil) then
          for k, v in string.gmatch(lastLocation, "([^=]+)=([^=]+)&") do
            sinal[k] = v
            print (k, sinal[k])
          end
        end

        local info = "Usuário última vez localizado n latitude "  .. sinal["lat"].." e longitude: "..sinal["lon"];
        if origem == "botaoajuda" then
            info = "[ATENÇÃO] Usuário solicitou sua ajuda \n"..info
        end

        c:publish("monitoramento", info)
    elseif topic == "monitoramento" then
        if message == "pedido" then
          c:publish("acoes", "LOCALIZACAO")
        else
          print(message)
        end
    elseif message == "quit" then 
    	running = false
    	c:unsubscribe(topics)
    end
end

running = true
while (running) do
	c:handler()
	socket.sleep(1.0)  -- seconds
end


