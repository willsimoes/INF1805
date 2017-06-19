local MQTT = require("mqtt_library")
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
        print("oiee, sensor")
    else if topic == "localizacao" then
        print("oiee, localizacao")
    else if topic == "monitoramento" then
         print("oiee, monitora")
    end
end