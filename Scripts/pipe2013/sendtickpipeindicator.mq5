//+------------------------------------------------------------------
//|                                        SendTickPipeIndicator.mq5 |
//|                                      Copyright 2010, Investeo.pl |
//|                                                http:/Investeo.pl |
//+------------------------------------------------------------------
#property copyright "Copyright 2010, Investeo.pl"
#property link      "http:/Investeo.pl"
#property version   "1.00"
#property indicator_chart_window

#include <CNamedPipes.mqh>

CNamedPipe pipe;
int ctx;

//+------------------------------------------------------------------
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------
int OnInit()
  {
 
   while (!pipe.Open(AccountInfoInteger(ACCOUNT_LOGIN)))
   {
      Print("管道未创建, 5 秒内重试...");
      if (GlobalVariableCheck("gvar1")==true) break;
   }
   
   ctx = 0;
   return(0);
  }
//+------------------------------------------------------------------
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   ctx++;
   MqlTick outgoing;
   SymbolInfoTick(Symbol(), outgoing);
   pipe.WriteTick(outgoing);
   Print(IntegerToString(ctx)+" 即时价通过 SendTickPipeClick 发送至服务器.");
   return(rates_total);
  }
//+------------------------------------------------------------------