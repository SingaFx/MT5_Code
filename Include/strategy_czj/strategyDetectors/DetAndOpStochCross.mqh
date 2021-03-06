//+------------------------------------------------------------------+
//|                                           DetAndOpStochCross.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "DetectorBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDetAndOpStochCross:public CDetectorBase
  {
protected:
   int               win_points;
   double            buffer_main[];
   double            buffer_signal[];
public:
                     CDetAndOpStochCross(void){};
                    ~CDetAndOpStochCross(void){};
   void              SetTP(int tp_points=300);
protected:
   virtual void      SignalCheckAndOperateAt(int h_index,int s_index,int p_index);  // 对指定索引进行指标信号的相关的处理 
   virtual void      CheckPositionOpenAt(int h_index,int s_index,int p_index);  // 对指定索引进行指标信号的开仓操作
   void              InitHandles(int k,int d,int slowing);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetAndOpStochCross::SetTP(int tp_points=300)
  {
   win_points=tp_points;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetAndOpStochCross::InitHandles(int k,int d,int slowing)
  {
   ArrayResize(h_detector,num_p*num_s);
   for(int i=0;i<num_s;i++)
     {
      for(int j=0;j<num_p;j++)
        {
         int index=i*num_p+j;
         h_detector[index]=iStochastic(symbols[i],periods[j],k,d,slowing,MODE_EMA,STO_LOWHIGH);
         AddBarOpenEvent(symbols[i],periods[j]);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetAndOpStochCross::SignalCheckAndOperateAt(int h_index,int s_index,int p_index)
  {
   CopyBuffer(h_detector[h_index],0,0,2,buffer_main);
   CopyBuffer(h_detector[h_index],1,0,2,buffer_signal);
   
   if(buffer_main[i+1]<buffer_signal[i+1]&&buffer_main[i+2]>buffer_signal[i+1]&&buffer_main[i+1]>InpUpLevel)
     {
      msg=symbols[s_index]+" On "+EnumToString(periods[p_index])+" Ma拐点 to Sell,China Time:"+TimeToString(TimeLocal())+" Current Price:"+DoubleToString(latest_price.bid,Digits());
      SendMsg(msg);
     }
   else if(h_signal[0]==1)
     {
      msg=symbols[s_index]+" On "+EnumToString(periods[p_index])+" Ma拐点 to Buy,China Time:"+TimeToString(TimeLocal())+" Current Price:"+DoubleToString(latest_price.ask,Digits());
      SendMsg(msg);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetAndOpStochCross::CheckPositionOpenAt(int h_index,int s_index,int p_index)
  {

  }
//+------------------------------------------------------------------+
