//
//  buffer.metal
//  LifeOnMars
//
//  Created by Antonio Sanchez-Rivas on 19/1/2025.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 DrawCore1(float2 position, half4 color, device const float *CoreBuffer1, int CoreSize1, float GridCol, float GridRow, float GridSize)
{
    half4 PixelColour;
    int CoreValue;
 //   int ColourMatch = 0;
    //int MyGridRow = int(GridRow);
    int MyGridCol = int(GridCol);
    int MyGridSize = int(GridSize);
    
  //  if (int(position.x) % 11 == 0 || int(position.y) % 11 == 0 )
    if (int(position.x) % (MyGridSize+1) == 0 || int(position.y) % (MyGridSize+1) == 0 )
    {
        PixelColour = half4(255,255,255,1);
 //       ColourMatch = 1;
    }
    else
    {
      //  CoreValue = int(CoreBuffer1[(int(position.y)/11*10) + int(position.x)/11]);
        CoreValue = int(CoreBuffer1[(int(position.y)/(MyGridSize+1)*MyGridCol) + int(position.x)/(MyGridSize+1)]);
        switch (CoreValue)
        {
           case 0 : PixelColour = half4(0,0,0,1);break;
           case 1 : PixelColour = half4(255,0,0,1);break;
           case 2 : PixelColour = half4(0,255,0,1);
        }
 //       ColourMatch = 1;
    }
  
//    //    if (int(position.x) >= 1 && int(position.y) >= 1 && int(position.x) <= 10 && int(position.y) <= 10)
//    //        {
//    //        thingy = half4(0,255,0,1);
//    //        ColourMatch = 1;
//    //    } // Corebuffer[0]
//    
//    if (int(position.x) >= 12 && int(position.y) >= 1 && int(position.x) <= 21 && int(position.y) <= 10)
//    {
//        thingy = half4(0,255,0,1);
//        ColourMatch = 1;
//    } // Corebuffer[1]
//    
//    if (int(position.x) >= 23 && int(position.y) >= 1 && int(position.x) <= 32 && int(position.y) <= 10)
//    {
//        thingy = half4(0,255,0,1);
//        ColourMatch = 1;
//    } // Corebuffer[2]
//    
//    if (int(position.x) >= 34 && int(position.y) >= 1 && int(position.x) <= 43 && int(position.y) <= 10)
//    {
//        thingy = half4(0,255,0,1);
//        ColourMatch = 1;
//    } // Corebuffer[3]
//    
//    if (int(position.x) >= 45 && int(position.y) >= 1 && int(position.x) <= 54 && int(position.y) <= 10)
//    {
//        thingy = half4(0,255,0,1);
//        ColourMatch = 1;
//    } // Corebuffer[4]
//    
//    if (int(position.x) >= 56 && int(position.y) >= 1 && int(position.x) <= 65 && int(position.y) <= 10)
//    {
//        thingy = half4(0,255,0,1);
//        ColourMatch = 1;
//    } // Corebuffer[5]
//    
//    if (int(position.x) >= 67 && int(position.y) >= 1 && int(position.x) <= 76 && int(position.y) <= 10)
//    {
//        thingy = half4(0,0,255,1);
//        ColourMatch = 1;
//    } // Corebuffer[6]
//    
//    if (int(position.x) >= 78 && int(position.y) >= 1 && int(position.x) <= 87 && int(position.y) <= 10)
//    {
//        thingy = half4(0,0,255,1);
//        ColourMatch = 1;
//    } // Corebuffer[7]
//    
//    if (int(position.x) >= 89 && int(position.y) >= 1 && int(position.x) <= 98 && int(position.y) <= 10)
//    {
//        thingy = half4(0,0,255,1);
//        ColourMatch = 1;
//    } // Corebuffer[8]
//    
//    if (int(position.x) >= 100  && int(position.y) >= 1 && int(position.x) <= 109 && int(position.y) <= 10)
//    {
//        thingy = half4(0,0,255,1);
//        ColourMatch = 1;
//    } // Corebuffer[9]
//
//    if (int(position.x) >= 1 && int(position.y) >= 34 && int(position.x) <= 10 && int(position.y) <= 43)
//    {
//        thingy = half4(255,0,0,1);
//        ColourMatch = 1;
//    } // Corebuffer[30]
//    
//    if (int(position.x) >= 12 && int(position.y) >= 34 && int(position.x) <= 21 && int(position.y) <= 43)
//    {
//        thingy = half4(255,0,0,1);
//        ColourMatch = 1;
//    } // Corebuffer[31]
//    
//    if (int(position.x) >= 23 && int(position.y) >= 34 && int(position.x) <= 32 && int(position.y) <= 43)
//    {
//        thingy = half4(255,0,0,1);
//        ColourMatch = 1;
//    } // Corebuffer[32]
//    
//    if (int(position.x) >= 34 && int(position.y) >= 34 && int(position.x) <= 43 && int(position.y) <= 43)
//    {
//        thingy = half4(255,0,0,1);
//        ColourMatch = 1;
//    } // Corebuffer[33]
//    
//    //        if (int(position.x) >= 45 && int(position.y) >= 1 && int(position.x) <= 54 && int(position.y) <= 10)
//    //            {
//    //            thingy = half4(255,0,0,1);
//    //            ColourMatch = 1;
//    //        } // Corebuffer[34]
    
//    if (ColourMatch == 0)
//        
//    {
//        PixelColour = half4(0,0,0,1); }
    
    return PixelColour;
}

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

