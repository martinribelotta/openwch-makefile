#include "debug.h"
#include "usbd_core.h"

extern void hid_custom_init(void);

void usb_dc_low_level_init(void)
{
    RCC_USBCLK48MConfig(RCC_USBCLK48MCLKSource_USBPHY);
    RCC_USBHSPLLCLKConfig(RCC_HSBHSPLLCLKSource_HSE);
    RCC_USBHSConfig(RCC_USBPLL_Div2);
    RCC_USBHSPLLCKREFCLKConfig(RCC_USBHSPLLCKREFCLK_4M);
    RCC_USBHSPHYPLLALIVEcmd(ENABLE);

    RCC_AHBPeriphClockCmd(RCC_AHBPeriph_USBHS, ENABLE);
    NVIC_EnableIRQ(USBHS_IRQn);

    RCC_AHBPeriphClockCmd(RCC_AHBPeriph_OTG_FS, ENABLE);
    //EXTEN->EXTEN_CTR |= EXTEN_USBD_PU_EN;
    NVIC_EnableIRQ(OTG_FS_IRQn);

    Delay_Us(100);
}

void hid_in_callback(int ep, int nbytes)
{
}

void hid_out_callback(int ep, const uint8_t *buffer, int nbytes)
{
    printf("%s\n", buffer);
}

int main(void)
{
    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
    SystemCoreClockUpdate();
    Delay_Init();
    USART_Printf_Init(115200);
    printf("SystemClk:%d\r\n", SystemCoreClock);
    printf("ChipID:%08x\r\n", DBGMCU_GetCHIPID());

    hid_custom_init();

    // Wait until configured
    while (!usb_device_is_configured())
    {
    }

    printf("Configured\n");

    while (1)
    {
        Delay_Ms(100);
    }
}
