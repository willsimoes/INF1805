#include "timerservice.h"


// the prescaler is set so that timer0 ticks every 64 clock cycles, and the
// the overflow handler is called every 256 ticks.
#define MICROSECONDS_PER_TIMER0_OVERFLOW_ (clockCyclesToMicroseconds(64 * 256))

// the whole number of milliseconds per timer0 overflow
#define MILLIS_INC_ (MICROSECONDS_PER_TIMER0_OVERFLOW_ / 1000)

// the fractional number of milliseconds per timer0 overflow. we shift right
// by three to fit these numbers into a byte. (for the clock speeds we care
// about - 8 and 16 MHz - this doesn't lose precision.)
#define FRACT_INC_ ((MICROSECONDS_PER_TIMER0_OVERFLOW_ % 1000) >> 3)
#define FRACT_MAX_ (1000 >> 3)

typedef struct timer {
  uint32_t remaining;
  cbTimer cb;
} timer_t;

volatile timer_t timers[MAX_TIMERS];
void dummy(){}

void TimerService::init(){

  // Change Timer0 to CTC1 mode and compare with 0xFF.
  cli();
  TCCR0B |= (1 << WGM12);   // CTC mode
  OCR0A = 0xFF;
  TIMSK0 = (1 << OCIE0A);
  sei();             // enable all interrupts
}


TimerService::TimerService(){
  for (int i=0; i< MAX_TIMERS; i++) {
    timers[i].remaining = 0;
    timers[i].cb = dummy;
  }
}

TimerService::~TimerService(){}

void updateTimers()
{
  for (int i=0; i< MAX_TIMERS; i++){
     if  (timers[i].remaining > 0) {
       timers[i].remaining = timers[i].remaining - MILLIS_INC_;
       if (timers[i].remaining <= 0) {
         timers[i].remaining = 0;
         timers[i].cb();
       }
     }
  }  

}

boolean TimerService::set(uint8_t id, float dl, cbTimer cb){ 
    if (id >= MAX_TIMERS){
      return false;
    } else {
      timers[id].cb = cb;
      timers[id].remaining = (int32_t)(dl*1000.0/1.023);
      return true;
    }
  }

boolean TimerService::isRunning(uint8_t id){ 
    if (id >= MAX_TIMERS){
      return false;
    } else {
      return timers[id].remaining > 0;
    }
}
void TimerService::stop(uint8_t id){
    if (id < MAX_TIMERS){
      timers[id].cb = dummy;
      timers[id].remaining = 0;
    }
}





extern volatile unsigned long timer0_overflow_count;
extern volatile unsigned long timer0_millis;
static unsigned char timer0_fract;

ISR(TIMER0_COMPA_vect)
{
	// copy these to local variables so they can be stored in registers
	// (volatile variables must be read from memory on every access)
	unsigned long m = timer0_millis;
	unsigned char f = timer0_fract;

	m += MILLIS_INC_;
	f += FRACT_INC_;
	if (f >= FRACT_MAX_) {
		f -= FRACT_MAX_;
		m += 1;
	}

	timer0_fract = f;
	timer0_millis = m;
	timer0_overflow_count++;

        updateTimers();
}



