//
//  buffer.metal
//  LifeOnMars
//
//  Created by Antonio Sanchez-Rivas on 19/1/2025.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 DrawCore(float2 position, half4 color, device const float *CoreBuffer1, int CoreSize1)
{
    half4 thingy;
    int CoreValue;
        
    CoreValue = int(CoreBuffer1[int(position.y) * 100 + int(position.x)]);

    switch (CoreValue) {
      case 0: // empty
        thingy = half4(0,0,0,1);
        break;
      case 1: // red
            thingy = half4(255, 0, 0,1);
        break;
      case 2: //green
              thingy = half4(0,255,0,1);
          break;
    }
    
    return thingy;
}


