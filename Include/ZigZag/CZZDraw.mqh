#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

class CZZDraw{
   private:
   public:
      virtual int Calculate(const int rates_total,
                      const int prev_calculated,
                      double &BufferHigh[],
                      double &BufferLow[],
                      double &BufferDirection[],
                      double &BufferLastHighBar[],
                      double &BufferLastLowBar[],                      
                      double &BufferZigZag[]
   ){
      return(0);
   }
};

class CSimpleDraw:public CZZDraw{
   private:
   public:
      virtual int Calculate(const int rates_total,
                      const int prev_calculated,
                      double &BufferHigh[],
                      double &BufferLow[],
                      double &BufferDirection[],
                      double &BufferLastHighBar[],
                      double &BufferLastLowBar[],                      
                      double &BufferZigZag[]                        
   ){

      int start;
      
      if(prev_calculated==0){
         BufferLastHighBar[0]=0;
         BufferLastLowBar[0]=0;
         start=1;
      }
      else{
         start=prev_calculated-1;
      }


      for(int i=start;i<rates_total;i++){

         BufferLastHighBar[i]=BufferLastHighBar[i-1];
         BufferLastLowBar[i]=BufferLastLowBar[i-1];        
             
         BufferZigZag[i]=EMPTY_VALUE;  
           
         BufferZigZag[(int)BufferLastHighBar[i]]=BufferHigh[(int)BufferLastHighBar[i]];
         BufferZigZag[(int)BufferLastLowBar[i]]=BufferLow[(int)BufferLastLowBar[i]];   
         
         switch((int)BufferDirection[i]){
            case 1:
               switch((int)BufferDirection[i-1]){
                  case 1:
                     if(BufferHigh[i]>BufferHigh[(int)BufferLastHighBar[i]]){
                        BufferZigZag[(int)BufferLastHighBar[i]]=EMPTY_VALUE; 
                        BufferZigZag[i]=BufferHigh[i];
                        BufferLastHighBar[i]=i;
                     }
                  break;
                  case -1:
                     BufferZigZag[i]=BufferHigh[i];
                     BufferLastHighBar[i]=i;
                  break;         
               }
            break;
            case -1:
               switch((int)BufferDirection[i-1]){
                  case -1:
                     if(BufferLow[i]<BufferLow[(int)BufferLastLowBar[i]]){
                        BufferZigZag[(int)BufferLastLowBar[i]]=EMPTY_VALUE;
                        BufferZigZag[i]=BufferLow[i];
                        BufferLastLowBar[i]=i;
                     }
                  break;
                  case 1:
                     BufferZigZag[i]=BufferLow[i];
                     BufferLastLowBar[i]=i;                            
                  break;         
               }         
            break;         
         }

      }   
   
      return(rates_total);

   }   

};