/*
function mulmodmont384(out,a,b,m,inv) multiplies bigint values; out = a*b*R (mod m) 
	where inv is the 


gcc -std=c99 mulmodmont384.c mulmodmont384.x86_64.S -fno-pie -no-pie -DBENCHMARK=0
./a.out 0xcc9b6b1cb968880075bb2a454c033118f6724fe84abea910d23ff21374a83f686c48c8507a52ace2b7333fa44a38327 0xec2ec530e9d03ceeec73efef28ce7039cdc4fc50f32aa193e1b10edfa1dbbddf4e6dd63cf109d3977a034a2a9ccf6ef 0x12c49c6f13347fa54bbfd54c2ac9e674edbf4b0efc260427d6d70458a3a908f07afffcd1f7c6548e9869fb42de25f9ed 0xc0874f51a0d231f919f8033bae5b5ae02a16a2c2f06085f95426d7f67f537385e89ab0e8e170427c818c822bbed4b41b 0xbd8e9b8345fa8c628ebf0f4cedc0cd207ad0a84edd2e3ef780eea7ed5e19d193abd802b411e2a2c8e63a2f4dcab45b2

*/

#include <stdio.h>
#include <inttypes.h>
#include <string.h>


//#define COUNT_CYCLES_X86_64 0
#ifdef COUNT_CYCLES_X86_64
#include <x86intrin.h> // for __rdtsc();
#endif


void mulmodmont384(uint64_t* out, uint64_t* a, uint64_t* b, uint64_t* mod, uint64_t inv);

void bench(uint64_t* out, uint64_t* a, uint64_t* b, uint64_t* mod, uint64_t inv){
  for (int i=0; i<23159000;i++){
  //for (int i=0; i<1000000000;i++){
    mulmodmont384(out, a, b, mod, inv);
    //a[0]=out[0];
  }
}

// hex string to int array conversion
// input is string of hex characters, without 0x prefix
// also converts to little endian (ie least significant nibble first)
void hexstr_to_bytearray(char* in, uint8_t* out){
  //printf("hexstr_to_intarray(%s)\n",in);
  size_t len = strlen(in);
  uint8_t byte = 0;
  uint8_t nibble = 0;
  int i;
  for (i=len-1; i>=0 ;i--){
    nibble = in[i];
    if (nibble >= '0' && nibble <= '9') nibble = nibble - '0';
    else if (nibble >= 'a' && nibble <='f') nibble = nibble - 'a' + 10;
    else if (nibble >= 'A' && nibble <='F') nibble = nibble - 'A' + 10;
    else printf("ERROR: %s is not hex string.\n",in);
    if (!((i+len%2)%2)) {
      byte = (nibble<<4) + byte;
      *(out+(len-i)/2-1) = byte;
      byte=0;
    }
    else byte = nibble;
  }
  if (byte)
    *(out+(len-i)/2-1) = byte;
}


int main(int argc, char** argv) {

  uint64_t a[6], b[6], mod[6], inv[6], out[6], out_expected[6];

  for (int i=0; i<6;i++){
    out[i]=0;
    a[i]=0;
    b[i]=0;
    mod[i]=0;
    inv[i]=0;
    out_expected[i]=0;
  }

  if (argc==1){
    hexstr_to_bytearray("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",(uint8_t*)a);
    hexstr_to_bytearray("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",(uint8_t*)b);
    hexstr_to_bytearray("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",(uint8_t*)mod);
    hexstr_to_bytearray("000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001",(uint8_t*)inv);
    hexstr_to_bytearray("000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",(uint8_t*)out_expected);
  }
  else{
    hexstr_to_bytearray(argv[1]+2,(uint8_t*)a);
    hexstr_to_bytearray(argv[2]+2,(uint8_t*)b);
    hexstr_to_bytearray(argv[3]+2,(uint8_t*)mod);
    hexstr_to_bytearray(argv[4]+2,(uint8_t*)inv);
    hexstr_to_bytearray(argv[5]+2,(uint8_t*)out_expected);
  }

#if BENCHMARK
  bench(out,a,b,mod,*inv);
#else // no bench, just evaluate
#ifdef COUNT_CYCLES_X86_64
  uint64_t cycles1 = __rdtsc();
#endif
  mulmodmont384(out,a,b,mod,*inv);
#ifdef COUNT_CYCLES_X86_64
  uint64_t cycles2 = __rdtsc();
  printf("num cycles %u\n", (uint32_t)(cycles2-cycles1));
#endif
#endif

  int error = 0;
  for (int i=0; i<6; i++){
    if (out[i]!=out_expected[i]){
      error=1;
    }
  }
  if (error){
    for (int i=0; i<6; i++)
      printf(" %lx", out[i]);
    printf("\n");
    for (int i=0; i<6; i++)
      printf(" %lx", out_expected[i]);
    printf("\n");
    printf("\n");
  }
  else
    printf(".");
  printf("\n");

  return 0;
}
