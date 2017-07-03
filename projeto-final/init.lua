------ Código executado no NodeMCU
dofile("mqtt.lua")
dofile("sensor_distancia.lua")
dofile("acelerometro.lua")

-- inicializando sensores
--sensor de distancia ultrassom

function start_devices()
	device_ultrassonic = sensor_distancia.init()
	-- acelerometro
	device_acl = acelerometro.init()
	device_acl.init_I2C()
	device_acl.check_MPU(0x68)
	device_acl.init_MPU(0x6B,0)

	--alarmes para medição de 1 em 1s
	tmr.create():alarm(1000, tmr.ALARM_AUTO, device_ultrassonic.measure)
	tmr.create():alarm(1000, tmr.ALARM_AUTO, device_acl.read_MPU_raw)
end