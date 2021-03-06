//+------------------------------------------------------------------+
//|                                          SignalRsiMaStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "SignalRsiStrategy.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSignalRsiMaStrategy:public CSignalRsiStrategy
  {
protected:
   int               h_ma_long;
   int               h_ma_short;
   double            value_ma_long[];
   double            value_ma_short[];
protected:
   virtual void      CheckPositionOpen();
public:
                     CSignalRsiMaStrategy(void){};
                    ~CSignalRsiMaStrategy(void){};
   void              InitMaParameter();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiMaStrategy::InitMaParameter(void)
  {
   h_ma_long=iMA(ExpertSymbol(),Timeframe(),200,0,MODE_EMA,PRICE_CLOSE);
   h_ma_short=iMA(ExpertSymbol(),Timeframe(),24,0,MODE_EMA,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiMaStrategy::CheckPositionOpen(void)
  {
   CopyBuffer(h_rsi,0,0,2,rsi_value);
   CopyBuffer(h_ma_long,0,0,1,value_ma_long);
   CopyBuffer(h_ma_short,0,0,1,value_ma_short);
   if(pos.pstate==POS_EMPTY)
     {
      if(value_ma_long[0]>value_ma_short[0]&&latest_price.ask<value_ma_long[0]) // 下降中
        {
         if(value_ma_long[0]-latest_price.ask<latest_price.ask-value_ma_short[0])
         //if(rsi_value[0]>rsi_open_short&&value_ma_long[0]-latest_price.ask<latest_price.ask-value_ma_short[0])
           {
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,base_lots,latest_price.bid,0,0);
            pos.BuildPos(Trade.ResultOrder(),POS_SELL);
            return;
           }
         if(value_ma_short[0]-latest_price.bid>0.8*(value_ma_long[0]-value_ma_short[0]))
         //if(rsi_value[0]<rsi_open_long&&value_ma_short[0]-latest_price.bid>0.8*(value_ma_long[0]-value_ma_short[0]))
           {
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,base_lots,latest_price.ask,0,0);
            pos.BuildPos(Trade.ResultOrder(),POS_BUY);
            return;
           }
        }
      else if(value_ma_long[0]<value_ma_short[0]&&latest_price.bid>value_ma_long[0])
        {
         if(latest_price.bid-value_ma_short[0]>0.8*(value_ma_short[0]-value_ma_long[0]))
         //if(rsi_value[0]>rsi_open_short&&latest_price.bid-value_ma_short[0]>0.8*(value_ma_short[0]-value_ma_long[0]))
           {
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,base_lots,latest_price.bid,0,0);
            pos.BuildPos(Trade.ResultOrder(),POS_SELL);
            return;
           }
         if(latest_price.ask-value_ma_long[0]<value_ma_short[0]-latest_price.ask)
         //if(rsi_value[0]<rsi_open_long&&latest_price.ask-value_ma_long[0]<value_ma_short[0]-latest_price.ask)
           {
            Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,base_lots,latest_price.ask,0,0);
            pos.BuildPos(Trade.ResultOrder(),POS_BUY);
            return;
           }
        }

     }
  }
//+------------------------------------------------------------------+
