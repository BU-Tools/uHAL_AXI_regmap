#ifndef __REG_OFFSET__
#define __REG_OFFSET__

#include <cstdint.h>

class RegOffset {
public:
  RegOffset(uint32_t _baseAddress){
    baseAddress= _baseAddress;
  }
protected:
  uint32_t baseAddress;
private:
  RegOffset()=0;
};
#endif
