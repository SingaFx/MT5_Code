//+------------------------------------------------------------------+
//|                                               EA_FindSymbols.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
input ENUM_TIMEFRAMES Inp_period=PERIOD_M5;
input int Inp_num=5;
input int Inp_dev_points=100;
input int Inp_tp=200;
input int Inp_sl=50;
string symbols_="AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY";
//string symbols_="EURGBP,AUDCAD,EURCHF,AUDNZD";
string symbols[];
string points[];
CTrade ExtTrade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   StringSplit(symbols_,StringGetCharacter(",",0),symbols);
   for(int i=0;i<ArraySize(symbols);i++)
     {
      Print(symbols[i]);
     }
   ArrayResize(points,ArraySize(symbols));
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
   //my_on_tick_test1();
   my_on_tick_test2();
  }
//+------------------------------------------------------------------+

int RefreshSymbolsMoments(string symbol,ENUM_TIMEFRAMES period,int num_candle)
   {
    double high_price[],low_price[],current_price[];
    CopyHigh(symbol,period,1,num_candle,high_price);
    CopyLow(symbol,period,1,num_candle,low_price);
    CopyClose(symbol,period,0,1,current_price);
    int i_max = ArrayMaximum(high_price);
    int i_min = ArrayMinimum(low_price);
    int moment_points;
    if(current_price[0]<low_price[i_min])
       moment_points=(int)((current_price[0]-low_price[i_min])/SymbolInfoDouble(symbol,SYMBOL_POINT));
    else if(current_price[0]>high_price[i_max])
       moment_points=(int)((current_price[0]-high_price[i_max])/SymbolInfoDouble(symbol,SYMBOL_POINT));
    else moment_points=0;
    return moment_points;
   }
bool ExistPosition(string check_symbol, ENUM_ORDER_TYPE order_type)
   {
    for(int i=0;i<PositionsTotal();i++)
      {
       ulong ticket=PositionGetTicket(i);
      PositionSelectByTicket(ticket);
      if(PositionGetInteger(POSITION_TYPE)==order_type&&PositionGetString(POSITION_SYMBOL)==check_symbol) return true;
      }
     return false;
   }
bool ExistAnyPosition()
   {
    if(PositionsTotal()>0) return true;
    return false;
   }
void my_on_tick_test1()
   {
    for(int i=0;i<ArraySize(symbols);i++)
     {
      int p = RefreshSymbolsMoments(symbols[i],Inp_period,Inp_num);
      MqlTick latest_price;
      SymbolInfoTick(symbols[i],latest_price);
      if(p>Inp_dev_points && !ExistPosition(symbols[i],ORDER_TYPE_BUY))
        {
         ExtTrade.Buy(0.1,symbols[i],latest_price.ask,latest_price.ask-Inp_sl*SymbolInfoDouble(symbols[i],SYMBOL_POINT),latest_price.ask+Inp_tp*SymbolInfoDouble(symbols[i],SYMBOL_POINT),string(p));
        }
      else if(p<-Inp_dev_points && !ExistPosition(symbols[i],ORDER_TYPE_SELL))
             {
              ExtTrade.Sell(0.1,symbols[i],latest_price.bid,latest_price.bid+Inp_sl*SymbolInfoDouble(symbols[i],SYMBOL_POINT),latest_price.bid-Inp_tp*SymbolInfoDouble(symbols[i],SYMBOL_POINT),string(p));
             }
     }
   }
void my_on_tick_test2()
   {
    int max_points=0,min_points=0;
    int i_max=0,i_min=0;
    for(int i=0;i<ArraySize(symbols);i++)
      {
       points[i] = RefreshSymbolsMoments(symbols[i],Inp_period,Inp_num); 
       if(max_points<points[i]) 
         {
          max_points=points[i];
          i_max=i;
         }
        if(min_points>points[i])
         {
          min_points=points[i];
          i_min=i;
         }
      }

     MqlTick latest_price;

      if(max_points>Inp_dev_points && !ExistAnyPosition())
        {
         SymbolInfoTick(symbols[i_max],latest_price);
         ExtTrade.Buy(0.1,symbols[i_max],latest_price.ask,latest_price.ask-Inp_sl*SymbolInfoDouble(symbols[i_max],SYMBOL_POINT),latest_price.ask+Inp_tp*SymbolInfoDouble(symbols[i_max],SYMBOL_POINT),string(points[i_max]));
        }
      else if(i_min>0&&points[i_min]<-Inp_dev_points && !ExistAnyPosition())
             {
              SymbolInfoTick(symbols[i_min],latest_price);
              ExtTrade.Sell(0.1,symbols[i_min],latest_price.bid,latest_price.bid+Inp_sl*SymbolInfoDouble(symbols[i_min],SYMBOL_POINT),latest_price.bid-Inp_tp*SymbolInfoDouble(symbols[i_min],SYMBOL_POINT),string(points[i_min]));
             }
   }