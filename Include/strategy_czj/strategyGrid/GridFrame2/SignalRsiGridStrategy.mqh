//+------------------------------------------------------------------+
//|                                        SignalRsiGridStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "SignalGridStrategy.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum RsiGridType
  {
   ENUM_RG_MODE_1,// 简单RSI信号+网格
   ENUM_RG_MODE_2,// 简单RSI信号+动态网格(仓位越大，网格越大)
   ENUM_RG_MODE_3, // 重仓需要信号，轻仓只需GAP
   ENUM_RG_MODE_4 // 最后两个加仓间隔的和<20
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSignalRsiGridStrategy:public CSignalGridStrategy
  {
private:
   RsiGridType       rg_type;
protected:
   virtual void      CheckPositionOpen(const MarketEvent &event); // 开仓检测
   virtual void      RefreshSignal(const MarketEvent &event);
   void              PositionOpenByMode1();
   void              PositionOpenByMode2();
   void              PositionOpenByMode3();
   void              PositionOpenByMode4();
public:
                     CSignalRsiGridStrategy(void){};
                    ~CSignalRsiGridStrategy(void){};
   virtual void      Init();
   void              SetRGType(RsiGridType type_rg=ENUM_RG_MODE_1){rg_type=type_rg;};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiGridStrategy::Init(void)
  {
   h_ind=iRSI(ExpertSymbol(),Timeframe(),14,PRICE_CLOSE);
   SetParameters();
   SetRGType();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiGridStrategy::RefreshSignal(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN && event.period==Timeframe())
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiGridStrategy::CheckPositionOpen(const MarketEvent &event)
  {
   if(event.type==MARKET_EVENT_BAR_OPEN && event.symbol==ExpertSymbol())
     {
      signal=ENUM_SIGNAL_NONE;
      RefreshSignal(event);
      switch(rg_type)
        {
         case ENUM_RG_MODE_1 :
            PositionOpenByMode1();
            break;
         case ENUM_RG_MODE_2:
            PositionOpenByMode2();
            break;
         case ENUM_RG_MODE_3:
            PositionOpenByMode3();
            break;
         case ENUM_RG_MODE_4:
            PositionOpenByMode4();
            break;            
         default:
            PositionOpenByMode1();
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiGridStrategy::PositionOpenByMode1(void)
  {
   switch(signal)
     {
      case ENUM_SIGNAL_UP_3:
      case ENUM_SIGNAL_UP_2:
      case ENUM_SIGNAL_UP_1:
         if(pos.TotalLong()==0 || DistToLastLongPrice()>grid_gap) OpenLongPosition();
         break;
      case ENUM_SIGNAL_DOWN_3:
      case ENUM_SIGNAL_DOWN_2:
      case ENUM_SIGNAL_DOWN_1:
         if(pos.TotalShort()==0 || DistToLastShortPrice()>grid_gap) OpenShortPosition();
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiGridStrategy::PositionOpenByMode2(void)
  {
  }
void CSignalRsiGridStrategy::PositionOpenByMode3(void)
   {
    if(pos.TotalLong()==0&&pos.TotalShort()==0)
      {
       PositionOpenByMode1();
       return;
      }
    if(pos.TotalLongLots()>pos.TotalShortLots()+0.5)
      {
       switch(signal)
        {
         case ENUM_SIGNAL_UP_3:
         case ENUM_SIGNAL_UP_2:
         case ENUM_SIGNAL_UP_1:
            if(pos.TotalLong()==0 || DistToLastLongPrice()>grid_gap) OpenLongPosition();
            break;
         default:
            break;
        }
       if(pos.TotalShort()==0 || DistToLastShortPrice()>grid_gap) OpenShortPosition();
      }
    else if(pos.TotalShortLots()>pos.TotalLongLots()+0.5)
      {
       switch(signal)
        {
         case ENUM_SIGNAL_DOWN_3:
         case ENUM_SIGNAL_DOWN_2:
         case ENUM_SIGNAL_DOWN_1:
            if(pos.TotalShort()==0 || DistToLastShortPrice()>grid_gap) OpenShortPosition();
            break;
         default:
            break;
         }
        if(pos.TotalLong()==0 || DistToLastLongPrice()>grid_gap) OpenLongPosition();
      }
    else
      {
       PositionOpenByMode1();
      }
   }
void CSignalRsiGridStrategy::PositionOpenByMode4(void)
   {
    if(pos.TotalLong()==0&&pos.TotalShort()==0)
      {
       PositionOpenByMode1();
       return;
      }
    if(pos.TotalLongLots()>pos.TotalShortLots())
      {
       switch(signal)
        {
         case ENUM_SIGNAL_UP_3:
         case ENUM_SIGNAL_UP_2:
         case ENUM_SIGNAL_UP_1:
            if(pos.TotalLong()==0) OpenLongPosition();
            //else if(pos.TotalLong()<4 || DistToLastLongPrice()>grid_gap) OpenLongPosition();
            else if(pos.DeltaHoursLong()+DeltaHoursToLastLong()>240 && DistToLastLongPrice()>grid_gap) OpenLongPosition(DoubleToString(pos.DeltaHoursLong()+DeltaHoursToLastLong(),0));
            break;
         default:
            break;
        }
       if(pos.TotalShort()==0 || DistToLastShortPrice()>grid_gap) OpenShortPosition();
      }
    else
      {
       switch(signal)
        {
         case ENUM_SIGNAL_DOWN_3:
         case ENUM_SIGNAL_DOWN_2:
         case ENUM_SIGNAL_DOWN_1:
            if(pos.TotalShort()==0) OpenShortPosition();
            //else if(pos.TotalShort()<4 || DistToLastShortPrice()>grid_gap) OpenShortPosition();
            else if(pos.DeltaHoursShort()+DeltaHoursToLastShort()>240&& DistToLastShortPrice()>grid_gap) OpenShortPosition(DoubleToString(pos.DeltaHoursShort()+DeltaHoursToLastShort(),0));
            break;
         default:
            break;
         }
        if(pos.TotalLong()==0 || DistToLastLongPrice()>grid_gap) OpenLongPosition();
      }
   }
//+------------------------------------------------------------------+
