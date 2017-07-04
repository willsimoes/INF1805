-- Código que mede distância em centimetro utilizando sensor de distância ultrassônico HC-SR04
-- Trigger (output) em D2 e Echo (input e interrupção) em D1 no mini nodeMCU 
-- adaptado de https://github.com/sza2/node_hcsr04

sensor_distancia = {}

pin_trigger = 2 -- manda sinal, fio azul
pin_echo = 6 -- recebe sinal, fio branco

function sensor_distancia.init()
	local self = {}
	self.time_start = 0
	self.time_end = 0
	gpio.mode(pin_trigger, gpio.OUTPUT) -- pino trigger como saida
	gpio.mode(pin_echo, gpio.INT, gpio.PULLUP) -- pino echo como interrupção

	function self.echo_callback(level, when)
		-- se pino echo foi pra HIGH, começa a medir o tempo
		if level == gpio.HIGH then
			--print("ECHO High: Iniciando contagem")
			self.time_start = when
		-- se pino echo foi pra LOW, termina de medir o tempo (microsegundos) e calcula distancia (cm)
		elseif level == gpio.LOW then
			--print("ECHO Low: Finalizando contagem")
			self.time_end = when

			if (self.time_end - self.time_start) < 0 then
				print("!! ERRO. Diferenca de tempo < 0")
				print("!! Tempo de inicio:   "..self.time_start.."  Tempo de fim:   "..self.time_end)
			else
				--delta_tempo é o tempo que a onda levou até encontrar o obstáculo
				local delta_tempo = (self.time_end - self.time_start) / 2
				if delta_tempo ~= 0  then
					publicaDadosUltrassonico(delta_tempo)
				end
			end
		else
			return;
		end
	end

	function self.measure()
		-- define interrupção para pino echo pra ambas voltagens (HIGH e LOW)
		gpio.trig(pin_echo, "both", self.echo_callback)
		gpio.write(pin_trigger, gpio.HIGH)
		tmr.delay(10) --10us
		gpio.write(pin_trigger, gpio.LOW)
		tmr.delay(2) --2us
	end

	return self
end



