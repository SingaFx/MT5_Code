//+------------------------------------------------------------------+
//|                                        DetectorMaBreakPoints.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "DetectorBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDetectorMaBreakPoints:public CDetectorBase
  {
public:
                     CDetectorMaBreakPoints(void){};
                    ~CDetectorMaBreakPoints(void){};
   void              InitHandles(int bar_num=24,int ma_period=24,int left_bar_n=5,int right_bar_n=1,int dist_extreme=2);
protected:
   virtual void      SignalCheckAndOperateAt(int h_index,int s_index,int p_index);  // 对指定索引进行指标信号的相关的处理                   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorMaBreakPoints::InitHandles(int bar_num=24,int ma_period=24,int left_bar_n=5,int right_bar_n=1,int dist_extreme=2)
  {
   ArrayResize(h_detector,num_p*num_s);
   for(int i=0;i<num_s;i++)
     {
      for(int j=0;j<num_p;j++)
        {
         int index=i*num_p+j;
         h_detector[index]=iCustom(symbols[i],periods[j],"CZJIndicators\\Detectors\\MABreakPoints3",
                                   bar_num,ma_period,left_bar_n,right_bar_n,dist_extreme);
         AddBarOpenEvent(symbols[i],periods[j]);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorMaBreakPoints::SignalCheckAndOperateAt(int h_index,int s_index,int p_index)
  {
   CopyBuffer(h_detector[h_index],2,0,1,h_signal);
   //Print(h_signal[0]);
   //if(periods[p_index]==PERIOD_H1) // 用于测试是否准时发送消息
   //  {
   //   msg=symbols[s_index]+"@"+EnumToString(periods[p_index])+" Time-"+TimeToString(Time[0]);
   //   SendMsg(msg);
   //  }
   if(h_signal[0]==-1)
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
