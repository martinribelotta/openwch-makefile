/********************************** (C) COPYRIGHT *******************************
* File Name          : system_ch32v30x.h
* Author             : Martin Ribelotta
* Version            : V1.0.0
* Date               : 2023/10/01
* Description        : CH32V30x Device Peripheral Access Layer System Header File.
*********************************************************************************
* Copyright (c) 2023 Martin Ribelotta.
* SPDX-License-Identifier: Apache-2.0
*******************************************************************************/
#ifndef __SYSTEM_CH32V30x_H 
#define __SYSTEM_CH32V30x_H

#include <stdint.h>

#ifdef __cplusplus
 extern "C" {
#endif 

extern uint32_t SystemCoreClock;          /* System Clock Frequency (Core Clock) */

/* System_Exported_Functions */  
extern void SystemInit(void);
extern void SystemCoreClockUpdate(void);

#ifdef __cplusplus
}
#endif

#endif /*__CH32V30x_SYSTEM_H */



