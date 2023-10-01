# ADC triggered with time

This example trigger the ADC1 CH0 with TIM1 PWM OC1

The code do it:

 - Configure TIM1 CC1 as PWM
 - Configure ADC1 CH0 to trigger with TIM1.CC1 output
 - Start TIM1, enable ADC1
 - In ADC interrupt save the value and set flag (using C11 stdatomic)
 - In main loop test (and clear) flag and print value if flag is set

