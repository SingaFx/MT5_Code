//+------------------------------------------------------------------+
//|                                        DetectorBandRsiCandle.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "DetectorBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDetectorBandRsiCandle:public CDetectorBase
  {
protected:
   int               h_band[];
   int               h_rsi[];

   double            band_base[];
   double            band_up[];
   double            band_down[];
   double            rsi[];

   double            high_price[];
   double            low_price[];
   double            open_price[];
   double            close_price[];

   int               rsi_up;
   int               rsi_down;
   int               band_range;
   
   int               pr;
   
public:
                     CDetectorBandRsiCandle(void){};
                    ~CDetectorBandRsiCandle(void){};
   void              InitHandles(int ma_period_band=20,double deviation=2.0,int range=300,int ma_period_rsi=14);
protected:
   virtual void      SignalCheckAndOperateAt(int h_index,int s_index,int p_index);  // 对指定索引进行指标信号的相关的处理 
   void              PatternRecognition(int index_s);
   bool              IsSellCandle();
   bool              IsBuyCandle();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorBandRsiCandle::InitHandles(int ma_period_band=20,double deviation=2.0,int range=300,int ma_period_rsi=14)
  {
   ArrayResize(h_band,num_p*num_s);
   ArrayResize(h_rsi,num_p*num_s);

   for(int i=0;i<num_s;i++)
     {
      for(int j=0;j<num_p;j++)
        {
         int index=i*num_p+j;
         h_band[i]=iBands(symbols[i],periods[j],ma_period_band,0,deviation,PRICE_CLOSE);
         h_rsi[i]=iRSI(symbols[i],periods[j],ma_period_rsi,PRICE_CLOSE);
         AddBarOpenEvent(symbols[i],periods[j]);
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorBandRsiCandle::SignalCheckAndOperateAt(int h_index,int s_index,int p_index)
  {
   CopyBuffer(h_band[h_index],0,0,2,band_base);
   CopyBuffer(h_band[h_index],1,0,2,band_up);
   CopyBuffer(h_band[h_index],2,0,2,band_down);
   CopyBuffer(h_rsi[h_index],0,0,2,rsi);

   CopyHigh(symbols[s_index],periods[p_index],0,4,high_price);
   CopyLow(symbols[s_index],periods[p_index],0,4,low_price);
   CopyOpen(symbols[s_index],periods[p_index],0,4,open_price);
   CopyClose(symbols[s_index],periods[p_index],0,4,close_price);
   
   PatternRecognition(s_index);
   
   if(pr==1)
     {
      msg=symbols[s_index]+" On "+EnumToString(periods[p_index])+" BandRsiCandle to buy,China Time:"+TimeToString(TimeLocal())+" Current Price:"+DoubleToString(latest_price.bid,Digits());
      SendMsg(msg);
     }
   else if(pr==-1)
     {
      msg=symbols[s_index]+" On "+EnumToString(periods[p_index])+" BandRsiCandle to sell,China Time:"+TimeToString(TimeLocal())+" Current Price:"+DoubleToString(latest_price.ask,Digits());
      SendMsg(msg);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorBandRsiCandle::PatternRecognition(int index_s)
  {
   pr=0;
   if(band_up[0]-band_base[0]>band_range*SymbolInfoDouble(symbols[index_s],SYMBOL_POINT))
     {
      if(rsi[0]>rsi_up)
        {
         if(IsSellCandle()) 
           {
            pr=-1;
            return;
           }
        }
     }
   if(band_base[0]-band_down[0]>band_range*SymbolInfoDouble(symbols[index_s],SYMBOL_POINT))
     {
      if(rsi[0]<rsi_down)
        {
         if(IsBuyCandle())
           {
            pr=1;
            return;
           }
        }
     }
  }
bool CDetectorBandRsiCandle::IsBuyCandle(void)
  {
   if(low_price[0]<low_price[1]&&low_price[1]<low_price[2]&&low_price[2]<low_price[3]) return true;
   if(high_price[0]<high_price[1]&&high_price[1]<high_price[2]&&high_price[2]<high_price[3]) return true;
   if(high_price[3]>high_price[2]&&high_price[1]>high_price[2]&&low_price[3]>low_price[2]) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDetectorBandRsiCandle::IsSellCandle(void)
  {
   if(high_price[0]>high_price[1]&&high_price[1]>high_price[2]&&high_price[2]>high_price[3]) return true;
   if(low_price[0]>low_price[1]&&low_price[1]>low_price[2]&&low_price[2]>low_price[3]) return true;
   if(low_price[3]<low_price[2]&&low_price[1]<low_price[2]&&high_price[3]<high_price[2]) return true;
   return false;
  }  
//+------------------------------------------------------------------+
