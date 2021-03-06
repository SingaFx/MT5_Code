//+------------------------------------------------------------------+
//|                                           SignalGridStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridBaseStrategy.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum IndSignal
  {
   ENUM_SIGNAL_UP_1,
   ENUM_SIGNAL_UP_2,
   ENUM_SIGNAL_UP_3,
   ENUM_SIGNAL_DOWN_1,
   ENUM_SIGNAL_DOWN_2,
   ENUM_SIGNAL_DOWN_3,
   ENUM_SIGNAL_NONE
  };
//+------------------------------------------------------------------+
//|               基于信号的网格                                     |
//+------------------------------------------------------------------+
class CSignalGridStrategy:public CGridBaseStrategyOneSymbol
  {
protected:
   int               h_ind;
   double            v_ind[];
   double            tp_total;
   double            tp_per_lots;
   IndSignal         signal;
   int               grid_gap;
protected:
   virtual void      CheckPositionOpen(const MarketEvent &event); // 开仓检测
   virtual void      CheckPositionClose(const MarketEvent &event);   // 平仓检测
   void              CheckPartialLongClose();
   void              CheckPartialShortClose();
   virtual void      RefreshSignal(const MarketEvent &event);
public:
                     CSignalGridStrategy(void);
                    ~CSignalGridStrategy(void){};
   virtual void      Init();
   void              SetParameters(int gap=300,int total_tp=200,int per_tp=200);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSignalGridStrategy::CSignalGridStrategy(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalGridStrategy::Init()
  {
   h_ind=iRSI(ExpertSymbol(),Timeframe(),14,PRICE_CLOSE);
   SetParameters();
  }
void CSignalGridStrategy::SetParameters(int gap=300,int total_tp=200,int per_tp=200)
   {
    grid_gap=gap;
    tp_total=total_tp;
    tp_per_lots=per_tp;
   }
void CSignalGridStrategy::RefreshSignal(const MarketEvent &event)
   {
    if(event.symbol==ExpertSymbol()&&event.type==MARKET_EVENT_BAR_OPEN&&event.period==Timeframe())
      {
       signal=ENUM_SIGNAL_NONE;
       CopyBuffer(h_ind,0,0,1,v_ind);
       if(v_ind[0]>85) signal=ENUM_SIGNAL_DOWN_3;
       else if(v_ind[0]>80) signal=ENUM_SIGNAL_DOWN_2;
       else if(v_ind[0]>70) signal=ENUM_SIGNAL_DOWN_1;
       else if(v_ind[0]<15) signal=ENUM_SIGNAL_UP_3;
       else if(v_ind[0]<20) signal=ENUM_SIGNAL_UP_2;
       else if(v_ind[0]<30) signal=ENUM_SIGNAL_UP_1;
      }
   }
void CSignalGridStrategy::CheckPartialLongClose(void)
   {
      CArrayInt index_pid;
      double p_total,l_total;
      if(pos.TotalLong()>0)
        {
         pos.GetPartialLongPosition(index_pid,p_total,l_total);
         if(p_total>tp_total || p_total/l_total>tp_per_lots)
           {
            CloseLongPosition(index_pid);
           }
        }  
   }
void CSignalGridStrategy::CheckPartialShortClose(void)
   {
      CArrayInt index_pid;
      double p_total,l_total;
      if(pos.TotalShort()>0)
        {
         pos.GetPartialShortPosition(index_pid,p_total,l_total);
         if(p_total>tp_total || p_total/l_total>tp_per_lots)
           {
            CloseShortPosition(index_pid);
           }
        }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalGridStrategy::CheckPositionClose(const MarketEvent &event)
  {
   if(event.type==MARKET_EVENT_TICK && event.symbol==ExpertSymbol())
     {
     CheckPartialLongClose();
     CheckPartialShortClose();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalGridStrategy::CheckPositionOpen(const MarketEvent &event)
  {
   if(event.type==MARKET_EVENT_BAR_OPEN && event.symbol==ExpertSymbol())
     {
      signal=ENUM_SIGNAL_NONE;
      RefreshSignal(event);
      switch(signal)
        {
         case ENUM_SIGNAL_UP_3:
            if(pos.TotalLong()==0||DistToLastLongPrice()>grid_gap) OpenLongPosition();
            break;
         case ENUM_SIGNAL_UP_2:
            if(pos.TotalLong()==0) OpenLongPosition();
            else if(pos.TotalLong()<5&&DistToLastLongPrice()>grid_gap) OpenLongPosition();
            break; 
         case ENUM_SIGNAL_UP_1:
            if(pos.TotalLong()==0) OpenLongPosition();
            else if(pos.TotalLong()<3&&DistToLastLongPrice()>grid_gap) OpenLongPosition();
            break;                    
         case ENUM_SIGNAL_DOWN_3:
            if(pos.TotalShort()==0||DistToLastShortPrice()>grid_gap) OpenShortPosition();
            break;
         case ENUM_SIGNAL_DOWN_2:
            if(pos.TotalShort()==0) OpenShortPosition();
            else if(pos.TotalShort()<5&&DistToLastShortPrice()>grid_gap) OpenShortPosition();
            break;
         case ENUM_SIGNAL_DOWN_1:
            if(pos.TotalShort()==0) OpenShortPosition();
            else if(pos.TotalShort()<3&&DistToLastShortPrice()>grid_gap) OpenShortPosition();
            break;            
         default:
            break;
        }
     }
  }
//+------------------------------------------------------------------+
