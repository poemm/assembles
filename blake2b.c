

#include <stdio.h>
#include <inttypes.h>
#include <string.h>



//#define COUNT_CYCLES_X86_64 0
#if COUNT_CYCLES_X86_64
#include <x86intrin.h> // for __rdtsc();
#endif



void blake2b_compress(uint64_t* h, uint8_t* chunk, uint64_t numBytesCompressed[2], uint64_t isLastBlock, uint64_t* IV);




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










// this calls blake2b, ignoring any key
int blake2b_nokey(uint8_t out[64], uint8_t* msg, uint64_t msglen, uint32_t hashLen){

  uint64_t IV[8];
  IV[0] = 0x6a09e667f3bcc908;   //Frac(sqrt(2))
  IV[1] = 0xbb67ae8584caa73b;   //Frac(sqrt(3))
  IV[2] = 0x3c6ef372fe94f82b;   //Frac(sqrt(5))
  IV[3] = 0xa54ff53a5f1d36f1;   //Frac(sqrt(7))
  IV[4] = 0x510e527fade682d1;   //Frac(sqrt(11))
  IV[5] = 0x9b05688c2b3e6c1f;   //Frac(sqrt(13))
  IV[6] = 0x1f83d9abfb41bd6b;   //Frac(sqrt(17))
  IV[7] = 0x5be0cd19137e2179;   //Frac(sqrt(19))

  uint64_t* h = (uint64_t*)out;

  for (int i=0;i<8;i++)
    ((uint64_t*)h)[i]=IV[i];

  h[0]=h[0]^(0x01010000+hashLen);

  // init
  uint64_t messageLen[2];
  messageLen[0] = msglen;
  messageLen[1] = 0;
  uint64_t bytesCompressed[2];
  bytesCompressed[0]=0;
  bytesCompressed[1]=0;
  uint64_t bytesRemaining[2];
  bytesRemaining[0] = messageLen[0];
  bytesRemaining[1] = messageLen[1];

  uint8_t* chunk = msg-128;
  while(*bytesRemaining>128){
    chunk+=128;
    bytesCompressed[0]+=128;
    bytesRemaining[0]-=128;
    blake2b_compress( h, chunk, bytesCompressed, (uint64_t)0, IV ); /* Compress */
  }

  chunk+=128;
  bytesCompressed[0]+=bytesRemaining[0];
  uint8_t padded_last_chunk[128];
  memset(padded_last_chunk,0,128);
  for(int i=0;i<bytesRemaining[0];i++)
    padded_last_chunk[i]=chunk[i];

  blake2b_compress( h, padded_last_chunk, bytesCompressed, (uint64_t)1, IV ); /* Compress */

  return 0;
  
}



int main(int argc, char** argv) {

  uint8_t in[64], out[64], out_expected[64];

  if (argc!=3){
    printf("./a.out 0x<input> 0x<expected output>\n");
  }
  else{
    hexstr_to_bytearray(argv[1]+2,(uint8_t*)in);
    hexstr_to_bytearray(argv[2]+2,(uint8_t*)out_expected);
  }

  size_t length = sizeof(in);

  int ret = blake2b_nokey(out, in, length, 64);

  int error = 0;
  for (int i=0; i<32; i++){
    if (out[i]!=out_expected[i])
      error=1;
  }
  if (error){
    printf("in: ");
    for (int i=0; i<sizeof(in); i++)
      printf("%02x", in[i]);
    printf("\n");
    printf("out: ");
    for (int i=0; i<64; i++)
      printf("%02x", out[i]);
    printf("\n");
    printf("expected: ");
    for (int i=0; i<sizeof(out_expected); i++)
      printf("%02x",out_expected[i]);
    printf("\n");
    printf("\n");
  }
  else
    printf("correct\n");

  return 0;
}
