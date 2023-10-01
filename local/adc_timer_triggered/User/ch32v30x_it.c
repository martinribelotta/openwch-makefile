/********************************** (C) COPYRIGHT *******************************
* File Name          : ch32v30x_it.c
* Author             : Martin Ribelotta
* Version            : V1.0.0
* Date               : 2023/10/01
* Description        : Main Interrupt Service Routines.
*********************************************************************************
* Copyright (c) 2023 Martin Ribelotta.
* SPDX-License-Identifier: Apache-2.0
*******************************************************************************/
#include "ch32v30x_it.h"

void NMI_Handler(void) __attribute__((interrupt("WCH-Interrupt-fast")));
void HardFault_Handler(void) __attribute__((interrupt("WCH-Interrupt-fast")));

/*********************************************************************
 * @fn      NMI_Handler
 *
 * @brief   This function handles NMI exception.
 *
 * @return  none
 */
void NMI_Handler(void)
{
}

/*********************************************************************
 * @fn      HardFault_Handler
 *
 * @brief   This function handles Hard Fault exception.
 *
 * @return  none
 */
void HardFault_Handler(void)
{
  while (1)
  {
  }
}


