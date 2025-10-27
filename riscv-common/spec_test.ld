/*======================================================================*/
/* Proxy kernel linker script                                           */
/*======================================================================*/
/* This is the linker script used when building the proxy kernel. */

/*----------------------------------------------------------------------*/
/* Setup                                                                */
/*----------------------------------------------------------------------*/

/* The OUTPUT_ARCH command specifies the machine architecture where the
   argument is one of the names used in the BFD library. More
   specifically one of the entires in bfd/cpu-mips.c */

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

/*----------------------------------------------------------------------*/
/* Sections                                                             */
/*----------------------------------------------------------------------*/

SECTIONS
{

  /* text: test code section */
  . = 0x80000000;
  .text.init : { *(.text.init) }
  
  . = ALIGN(0x1000);
  .tohost : { *(.tohost) }

  .text : { *(.text) }

  /* data segment */
  .data : { *(.data) }

  __cap_relocs : {
     . = ALIGN(8);
  }


  .captable : {
     . = ALIGN(8);
  }

  .text : { *(.text) }
  . = ALIGN(0x200);
  .user : { *(.user) }
  .kernel : { *(.kernel) }
  . = 0x80003200;
  .spec_btb_cheri_s : { *(.spec_btb_cheri_s) }
  /* . = ALIGN(0x20000); */
  . = ALIGN(0x8000000);
  .spec_btb_cheri_u : { *(.spec_btb_cheri_u) }

  .sdata : {
    __global_pointer$ = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  }

  /* bss segment */
  .sbss : {
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
  }
    .tdata :
  {
    . = ALIGN(8);
    _tls_data = .;
    *(.tdata.begin)
    *(.tdata)
    *(.tdata.end)
  }

  .sdata : {
    __global_pointer$ = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  }

  /* bss segment */
  .sbss : {
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
  }
  .bss : { *(.bss) }
  .tbss :
  {
    *(.tbss)
    *(.tbss.end)
    _end = .;
  }

  .blinded : {
    __start_blinded = .;
    *(.blinded)
    .gnu.linkonce.d.*
    __stop_blinded = .;
  }

  /* End of uninitalized data segement */
}

