//+------------------------------------------------------------------+
//|                                             EA_BreakPointRSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRSI\SimpleRSI.mqh>
input int Inp_RSI_period=12;
input double Inp_RSI_up=70;
input double Inp_RSI_down=30;
input double Inp_lots=0.1;
input bool Inp_single_position=true;
input int Inp_EA_MAGIC=2018012201;

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CSimpleRSIStrategy *rsi_s=new CSimpleRSIStrategy(Inp_RSI_period,Inp_RSI_up,Inp_RSI_down,Inp_lots,Inp_single_position);
   rsi_s.ExpertName("RSI BreakPoints");
   rsi_s.ExpertMagic(Inp_EA_MAGIC);
   rsi_s.Timeframe(_Period);
   rsi_s.ExpertSymbol(_Symbol);
   rsi_s.SetEventDetect(_Symbol,_Period);
   Manager.AddStrategy(rsi_s);
   
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
   Manager.OnTick();
  }
//+------------------------------------------------------------------+
