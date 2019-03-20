//+------------------------------------------------------------------+
//|                                                 PairHedgeRSI.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "PairStrategy.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPairHedgeRSI:public CPairStrategy
  {
private:
   int               h_rsi_x;
   int               h_rsi_y;
   double            value_x[];
   double            value_y[];
   double            rsi_up;
   double            rsi_down;
protected:
   virtual void      CheckPositionOpen();
public:
                     CPairHedgeRSI(void){};
                    ~CPairHedgeRSI(void){};
   void              SetRSI(int tf=14,double up=70,double down=30);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPairHedgeRSI::SetRSI(int tf=14,double up=70,double down=30)
  {
   h_rsi_x=iRSI(sym_x,Timeframe(),tf,PRICE_CLOSE);
   h_rsi_y=iRSI(sym_y,Timeframe(),tf,PRICE_CLOSE);
   rsi_up=up;
   rsi_down=down;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPairHedgeRSI::CheckPositionOpen(void)
  {
   if(plist.PosTotal()>0) return;
   CopyBuffer(h_rsi_x,0,0,2,value_x);
   CopyBuffer(h_rsi_y,0,0,2,value_y);
   switch(sr)
     {
      case RELATION_NEGATIVE :
         if(value_x[0]>rsi_up && value_y[0]>rsi_up)
           {
            Trade.PositionOpen(sym_x,ORDER_TYPE_SELL,0.01,tick_x.bid,0,0,DoubleToString(value_x[0],0));
            ulong idx=Trade.ResultOrder();
            Trade.PositionOpen(sym_y,ORDER_TYPE_SELL,0.01,tick_y.bid,0,0,DoubleToString(value_y[0],0));
            ulong idy=Trade.ResultOrder();
            plist.AddPairPos(idx,idy);
           }
         else if(value_x[0]<rsi_down && value_y[0]<rsi_down)
           {
            Trade.PositionOpen(sym_x,ORDER_TYPE_BUY,0.01,tick_x.ask,0,0,DoubleToString(value_x[0],0));
            ulong idx=Trade.ResultOrder();
            Trade.PositionOpen(sym_y,ORDER_TYPE_BUY,0.01,tick_y.ask,0,0,DoubleToString(value_y[0],0));
            ulong idy=Trade.ResultOrder();
            plist.AddPairPos(idx,idy);
           }
         break;
      case RELATION_POSITIVE:
         if(value_x[0]>rsi_up && value_y[0]<rsi_down)
           {
            Trade.PositionOpen(sym_x,ORDER_TYPE_SELL,0.01,tick_x.bid,0,0);
            ulong idx=Trade.ResultOrder();
            Trade.PositionOpen(sym_y,ORDER_TYPE_BUY,0.01,tick_y.ask,0,0);
            ulong idy=Trade.ResultOrder();
            plist.AddPairPos(idx,idy);
           }
         else if(value_x[0]<rsi_down && value_y[0]>rsi_up)
           {
            Trade.PositionOpen(sym_x,ORDER_TYPE_BUY,0.01,tick_x.ask,0,0);
            ulong idx=Trade.ResultOrder();
            Trade.PositionOpen(sym_y,ORDER_TYPE_SELL,0.01,tick_y.bid,0,0);
            ulong idy=Trade.ResultOrder();
            plist.AddPairPos(idx,idy);
           }
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
