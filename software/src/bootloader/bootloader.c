#include "cm7ikmcu.h"
#include "CMSDK.h"
#include "uart_stdout.h"
#include <stdio.h>
#include "dma230.h"

int main (void)
{
  // STDOUT init
  UartStdOutInit();

  printf("\nSoCLabs MilliSoC'25 ARM-CM7\n");
  printf("Preload ITCM...\n");

  printf("DMA CFG: 0x%08X\n", DMA_PL230_DMAC->DMA_CFG);


  UartEndSimulation();
  return 0;
}

