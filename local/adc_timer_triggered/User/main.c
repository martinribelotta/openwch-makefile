#include "debug.h"

#include <stdatomic.h>

/* Global Variable */
static s16 Calibrattion_Val = 0;
static atomic_uint_fast16_t adcVal = 0;
static atomic_int haveData = 0;

void TIM1_PWMOut_Init(u16 arr, u16 psc, u16 ccp);
void ADC_Function_Init(void);

void setup()
{
    USART_Printf_Init(115200);
    SystemCoreClockUpdate();
    TIM1_PWMOut_Init(100, 48000 - 1, 50);
    ADC_Function_Init();
}

static void uart_send_string(const char* s)
{
    while (*s) {
        while (USART_GetFlagStatus(USART1, USART_FLAG_TC) == RESET)
            ;
        USART_SendData(USART1, *s++);
    }
}

static char* int2ascii(char* buf, size_t len, int v)
{
    char* ptr = buf + len;
    *--ptr = '\0';
    while (v) {
        int c = v % 10;
        *--ptr = '0' + c;
        v /= 10;
    }
    return ptr;
}

int main(void)
{
    setup();
    while (1) {
        if (atomic_fetch_and(&haveData, 0)) {
            int val = atomic_load(&adcVal);
            static char buf[8];
            char* s = int2ascii(buf, sizeof(buf), val);
            uart_send_string(s);
            uart_send_string("\r\n");
        }
    }
}

static inline int adcTestIRQ(ADC_TypeDef* adc, uint32_t flag)
{
    return ((adc->STATR & (flag >> 8)) != 0) && (adc->CTLR1 & (uint8_t)flag);
}

static inline void adcClearIRQ(ADC_TypeDef* adc, uint32_t flag)
{
    adc->STATR = ~(uint32_t)((uint8_t)(flag >> 8));
}

static inline u16 adcReadData(ADC_TypeDef* adc)
{
    return adc->RDATAR;
    ;
}

static inline int saturate(int val, int max, int min)
{
    if (val > max)
        return max;
    if (val < min)
        return min;
    return val;
}

void ADC1_2_IRQHandler() __attribute__((interrupt("WCH-Interrupt-fast")));

void ADC1_2_IRQHandler()
{
    if (adcTestIRQ(ADC1, ADC_IT_EOC)) {
        u16 RawAdc = adcReadData(ADC1);
        atomic_store(&adcVal, saturate(RawAdc + Calibrattion_Val, 4096, 0));
        atomic_store(&haveData, 1);
    }
    adcClearIRQ(ADC1, ADC_IT_EOC);
}

void TIM1_PWMOut_Init(u16 arr, u16 psc, u16 ccp)
{
    TIM_OCInitTypeDef TIM_OCInitStructure = { 0 };
    TIM_TimeBaseInitTypeDef TIM_TimeBaseInitStructure = { 0 };

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM1, ENABLE);

    TIM_TimeBaseInitStructure.TIM_Period = arr;
    TIM_TimeBaseInitStructure.TIM_Prescaler = psc;
    TIM_TimeBaseInitStructure.TIM_ClockDivision = TIM_CKD_DIV1;
    TIM_TimeBaseInitStructure.TIM_CounterMode = TIM_CounterMode_Up;
    TIM_TimeBaseInit(TIM1, &TIM_TimeBaseInitStructure);

    TIM_OCInitStructure.TIM_OCMode = TIM_OCMode_PWM1;

    TIM_OCInitStructure.TIM_OutputState = TIM_OutputState_Enable;
    TIM_OCInitStructure.TIM_Pulse = ccp;
    TIM_OCInitStructure.TIM_OCPolarity = TIM_OCPolarity_High;
    TIM_OC1Init(TIM1, &TIM_OCInitStructure);

    TIM_CtrlPWMOutputs(TIM1, ENABLE);
    TIM_OC1PreloadConfig(TIM1, TIM_OCPreload_Disable);
    TIM_ARRPreloadConfig(TIM1, ENABLE);
    TIM_Cmd(TIM1, ENABLE);
}

void ADC_Function_Init(void)
{
    ADC_InitTypeDef ADC_InitStructure = { 0 };
    GPIO_InitTypeDef GPIO_InitStructure = { 0 };
    NVIC_InitTypeDef NVIC_InitStructure = { 0 };

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_ADC1, ENABLE);
    RCC_ADCCLKConfig(RCC_PCLK2_Div8);

    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN;
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    ADC_DeInit(ADC1);
    ADC_InitStructure.ADC_Mode = ADC_Mode_Independent;
    ADC_InitStructure.ADC_ScanConvMode = DISABLE;
    ADC_InitStructure.ADC_ContinuousConvMode = DISABLE;
    ADC_InitStructure.ADC_ExternalTrigConv = ADC_ExternalTrigConv_T1_CC1;
    ADC_InitStructure.ADC_DataAlign = ADC_DataAlign_Right;
    ADC_InitStructure.ADC_NbrOfChannel = 1;
    ADC_Init(ADC1, &ADC_InitStructure);

    ADC_Cmd(ADC1, ENABLE);

    ADC_BufferCmd(ADC1, DISABLE);
    ADC_ResetCalibration(ADC1);
    while (ADC_GetResetCalibrationStatus(ADC1))
        ;
    ADC_StartCalibration(ADC1);
    while (ADC_GetCalibrationStatus(ADC1))
        ;
    Calibrattion_Val = Get_CalibrationValue(ADC1);

    NVIC_InitStructure.NVIC_IRQChannel = ADC1_2_IRQn;
    NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 2;
    NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;
    NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
    NVIC_Init(&NVIC_InitStructure);

    ADC_ExternalTrigConvCmd(ADC1, ENABLE);
    ADC_RegularChannelConfig(ADC1, ADC_Channel_0, 1, ADC_SampleTime_239Cycles5);

    NVIC_SetPriority(DMA1_Channel1_IRQn, 0xE0);
    NVIC_EnableIRQ(DMA1_Channel1_IRQn);
    ADC_ITConfig(ADC1, ADC_IT_EOC, ENABLE);
}
