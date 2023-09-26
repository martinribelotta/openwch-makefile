#include "debug.h"

class InitHelper
{
    static inline constexpr auto DIV_E6 = 1'000'000;
    static inline constexpr auto DEFAULT_BAUD = 115200;
public:
    InitHelper()
    {
        NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
        SystemCoreClockUpdate();
        Delay_Init();
        USART_Printf_Init(DEFAULT_BAUD);
        int fMHz = SystemCoreClock / DIV_E6;
        int fFraq = SystemCoreClock % DIV_E6;
        printf(
            "Build in %s at %s\r\n"
            "SystemClk:%d.%dMHz\r\n"
            "ChipID:%08x\r\n"
            "GPIO Toggle TEST\r\n",
            __DATE__, __TIME__,
            fMHz, fFraq,
            DBGMCU_GetCHIPID());
    }
};

template <uint32_t PORT, uint16_t PIN>
class DigitalOut
{
    static constexpr auto apbEnableForPort()
    {
        switch (PORT) {
        case GPIOA_BASE: return RCC_APB2Periph_GPIOA;
        case GPIOB_BASE: return RCC_APB2Periph_GPIOB;
        case GPIOC_BASE: return RCC_APB2Periph_GPIOC;
        case GPIOD_BASE: return RCC_APB2Periph_GPIOD;
        case GPIOE_BASE: return RCC_APB2Periph_GPIOE;
        }
    }

    static constexpr auto port() { return reinterpret_cast<GPIO_TypeDef *>(PORT); }

public:
    DigitalOut(bool initialValue = false)
    {
        GPIO_InitTypeDef GPIO_InitStructure = {0};

        RCC_APB2PeriphClockCmd(apbEnableForPort(), ENABLE);
        GPIO_InitStructure.GPIO_Pin = PIN;
        GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
        GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
        GPIO_Init(port(), &GPIO_InitStructure);
        *this = initialValue;
    }

    operator bool() const
    {
        return GPIO_ReadOutputDataBit(port(), PIN) == Bit_SET;
    }

    DigitalOut &operator=(bool status)
    {
        GPIO_WriteBit(port(), PIN, status ? Bit_SET : Bit_RESET);
        return *this;
    }
};

InitHelper initHelper;

using LedOut = DigitalOut<GPIOA_BASE, GPIO_Pin_0>;

int main(void)
{
    LedOut led;
    while (1) {
        Delay_Ms(100);
        led = !led;
    }
}
