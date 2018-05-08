//+------------------------------------------------------------------+
//|                                                        Test3.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   //test_bars();
   test_symbol_infor();
  }
//+------------------------------------------------------------------+
void test_symbol_infor()
   {
    string symbols[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY","XAUUSD"};
    for(int i=0;i<ArraySize(symbols);i++)
      {
       double s_point=SymbolInfoDouble(symbols[i],SYMBOL_POINT);
       double t_value=SymbolInfoDouble(symbols[i],SYMBOL_TRADE_TICK_VALUE);
       double t_size=SymbolInfoDouble(symbols[i],SYMBOL_TRADE_TICK_SIZE);
       Print("symbol:",symbols[i]," Point",s_point," tick_value",t_value," tick_size",t_size);
      }
   }
void test_bars()
   {
    string symbols[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
    for(int i=0;i<ArraySize(symbols);i++)
      {
       Print(symbols[i]," ",Bars(symbols[i],_Period));
       Print("Total number of bars for the symbol-period at this moment = ", 
            SeriesInfoInteger(symbols[i],0,SERIES_BARS_COUNT)); 
     
      Print("The first date for the symbol-period at this moment = ", 
            (datetime)SeriesInfoInteger(symbols[i],0,SERIES_FIRSTDATE)); 
     
      Print("The first date in the history for the symbol-period on the server = ", 
            (datetime)SeriesInfoInteger(symbols[i],0,SERIES_SERVER_FIRSTDATE)); 
     
      Print("Symbol data are synchronized = ", 
            (bool)SeriesInfoInteger(symbols[i],0,SERIES_SYNCHRONIZED)); 

      }
   }