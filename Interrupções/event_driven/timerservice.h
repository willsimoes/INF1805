#ifndef TIMER_SERVICE_H
#define TIMER_SERVICE_H

#include <Arduino.h>

#ifndef __AVR_ATmega328P__
#error TimeService Library works only for ATmega328P (Uno And ProMini)
#endif

#define MAX_TIMERS 10  // Timer vector size

typedef void (*cbTimer)(void);

class TimerService {
  public:
  
    /*
     * Instantiate TimerService
     */
    TimerService();
    ~TimerService();

    /* 
     * Initialize internal timer - must be called in setup()
     */
    void init();

    /*
     * Set the timer delay - starts immediately
     * id: Timer id -   0 .. (MAX_TIMERS-1)
     * dl: Time to count in seconds (float point) - precision is about milliseconds
     * cb: Callback function to be called when the timer fired
     */
    boolean set(uint8_t id, float dl, cbTimer cb);

    /*
     * Return true if the time is running, otherwise returns false
     * id: Timer id -   0 .. (MAX_TIMERS-1)
     */
    boolean isRunning(uint8_t id);

    /*
     * Clear the timer counting and the cb function registration.
     * id: Timer id -   0 .. (MAX_TIMERS-1)
     */
    void stop(uint8_t id);
};

#endif // TIMER_SERVICE_H

