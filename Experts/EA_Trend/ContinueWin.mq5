//+------------------------------------------------------------------+
//|                                                  ContinueWin.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
input int Inp_ma_long_period=200;
input int Inp_ma_short_period=24;
input int Inp_win_points=200;
int handle_ma_long;
int handle_ma_short;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct POS_STATE
  {
   int               buy_num;
   int               sell_num;
   void              Init();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
POS_STATE::Init(void)
  {
   buy_num=0;
   sell_num=0;
  }
POS_STATE pos_state;
CTrade trade;
double ma_long[];
double ma_short[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   handle_ma_long=iMA(_Symbol,_Period,Inp_ma_long_period,0,MODE_EMA,PRICE_CLOSE);
   handle_ma_short=iMA(_Symbol,_Period,Inp_ma_short_period,0,MODE_EMA,PRICE_CLOSE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MqlTick latest_price;
   SymbolInfoTick(_Symbol,latest_price);
   CopyBuffer(handle_ma_long,0,0,2,ma_long);
   CopyBuffer(handle_ma_short,0,0,2,ma_short);
   refresh_position_state();
   check_position_close();
   if(open_long_condition())
      trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,0.1,latest_price.ask,0,latest_price.ask+Inp_win_points*SymbolInfoDouble(_Symbol,SYMBOL_POINT));
   if(open_short_condition())
      trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,0.1,latest_price.bid,0,latest_price.bid-Inp_win_points*SymbolInfoDouble(_Symbol,SYMBOL_POINT));

  }
//+------------------------------------------------------------------+
bool open_long_condition()
  {
   if(ma_short[0]>ma_long[0]&&pos_state.buy_num==0) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool open_short_condition()
  {
   if(ma_short[0]<ma_long[0]&&pos_state.sell_num==0) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool close_long_condition()
  {
   if(ma_short[0]<ma_long[0]) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool close_short_condition()
  {
   if(ma_short[0]>ma_long[0]) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void check_position_close()
  {
   if(close_long_condition()) close_long_position();
   if(close_short_condition()) close_short_position();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void close_long_position()
  {
   int total= PositionsTotal();
   for(int i=0;i<total;i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         trade.PositionClose(ticket);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void close_short_position()
  {
   int total=PositionsTotal();
   for(int i=0;i<total;i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         trade.PositionClose(ticket);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void refresh_position_state()
  {
   pos_state.Init();
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) pos_state.buy_num++;
      else pos_state.sell_num++;
     }
  }
//+------------------------------------------------------------------+
