//+------------------------------------------------------------------+
//|                                               EA_SignalRsiMa.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRSI\SignalRsiMaStrategy.mqh>
input double Inp_rsi_long_open=30;
input double Inp_rsi_short_open=70;
input double Inp_rsi_long_close=70;
input double Inp_rsi_short_close=30;
input double Inp_tp=200;
input double Inp_lots=0.01;

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CSignalRsiMaStrategy *rsi_s=new CSignalRsiMaStrategy();
   rsi_s.ExpertName("CSignalRsiMaStrategy");
   rsi_s.ExpertMagic(2018012201);
   rsi_s.ExpertSymbol(_Symbol);
   rsi_s.Timeframe(_Period);
   rsi_s.Init(Inp_rsi_long_open,Inp_rsi_short_open,Inp_rsi_long_close,Inp_rsi_short_close,Inp_tp,Inp_lots);
   rsi_s.InitMaParameter();
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