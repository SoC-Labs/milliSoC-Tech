#include "cm7ikmcu.h"
#include "CMSDK.h"
#include "uart_stdout.h"
#include <stdio.h>
#include "dma230.h"
#include "SL_QSPI.h"

void dma_data_struct_init(void);
int FlashInit(void);
int DmaMemcpy(void);
void dma_memory_copy (unsigned int src, unsigned int dest, unsigned int size, unsigned int num);

void start_main_code(void);

int FlashInit(void){
  if(SPI_STARTUP(SL_QSPI)==0){
    printf("Flash started...\n");
    CACHE_STARTUP(CG092);
  } else {
    printf("ERROR FLASH NOT STARTED\n");
    return 1;
  }
  return 0;
}


int DmaMemcpy(void){
  unsigned int i;
  dma_pl230_init(1);
  DMA_PL230_DMAC->CHNL_ENABLE_SET = (1<<0); /* Enable channel 0 */
  for(i=0;i<0x1000;i=i+0x1000){
    dma_memory_copy(FLASH_BASE+i,ITCM_BASE+i,2,0x400);
    printf("Cpy: 0x%05X / 0x%05X\n",i+0x1000,ITCM_SIZE);
    while(dma_pl230_channel_active(1)==0){;}
    while(dma_pl230_channel_active(1)!=0){;}
  }

  return 0;
}

int main (void)
{
  // STDOUT init
  UartStdOutInit();

  printf("\nSoCLabs MilliSoC'25 ARM-CM7\n");

  FlashInit();
  printf("Preload ITCM...\n");
  DmaMemcpy();

  printf("Enable ITCM\n\n");

  //EnableITCM();
  __DSB();
  __ISB();

  start_main_code();

  UartEndSimulation();
  return 0;
}


__asm void start_main_code(void){
  MOVS  R0,#0;
  LDR   R1,[R0];     //; Get initial MSP value
  MOV   SP, R1;
  LDR   R1,[R0, #4]; //; Get initial PC value
  BX    R1;
}
/* --------------------------------------------------------------- */
/*  DMA memory copy                                                */
/* --------------------------------------------------------------- */
void dma_memory_copy (unsigned int src, unsigned int dest, unsigned int size, unsigned int num)
{
  unsigned long src_end_pointer =  src + ((1<<size)*(num-1));
  unsigned long dst_end_pointer = dest + ((1<<size)*(num-1));
  unsigned long control         = (size << 30) |  /* dst_inc */
                                  (size << 28) |  /* dst_size */
                                  (size << 26) |  /* src_inc */
                                  (size << 24) |  /* src_size */
                                  (size << 21) |  /* dst_prot_ctrl - HPROT[3:1] */
                                  (size << 18) |  /* src_prot_ctrl - HPROT[3:1] */
//                                  (0    << 14) |  /* R_power */
                                  (4    << 14) |  /* R_power set for up to 16 transfers */
                                  ((num-1)<< 4) | /* n_minus_1 */
                                  (0    <<  3) |  /* next_useburst */
                                  (2    <<  0) ;  /* cycle_ctrl - auto */

  dma_pl230_table->Primary->SrcEndPointer  =  (unsigned char*)(src_end_pointer);
  dma_pl230_table->Primary->DstEndPointer =   (unsigned char*)(dst_end_pointer);
  dma_pl230_table->Primary->Control        =  (control        );
  /* Debugging printfs: */
  /*printf ("SrcEndPointer  = %x\n", dma_data->Primary->SrcEndPointer);*/
  /*printf ("DestEndPointer = %x\n", dma_data->Primary->DestEndPointer);*/

  DMA_PL230_DMAC->CHNL_ENABLE_SET = (1<<0); /* Enable channel 0 */
  DMA_PL230_DMAC->CHNL_SW_REQUEST = (1<<0); /* request channel 0 DMA */

  return;
}
