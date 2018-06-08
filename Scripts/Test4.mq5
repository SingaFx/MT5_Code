//+------------------------------------------------------------------+
//|                                                        Test4.mq5 |
//|                                                                  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   CTrade trade;
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
   trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,0.01,0,0,0,"");
   
   Sleep(1);
   Print(trade.ResultPrice());
   if(!PositionSelectByTicket(trade.ResultOrder()))
      {
       Print("select failed");
      }
    
   Print(PositionGetDouble(POSITION_PRICE_OPEN));
   
  }
//+------------------------------------------------------------------+
