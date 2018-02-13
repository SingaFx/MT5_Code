//+------------------------------------------------------------------+
//|                                                  EA_ArbTest2.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <Arbitrage\ArbitrageStrategy.mqh>
CStrategyList Manager;
input string symbol_x="XAUUSD";
input string symbol_y="USDJPY";
input int num_ts=600;
input double lots_x=0.08;
input double lots_y=0.12;
input CointergrationCalType coin_cal_type=ENUM_COINTERGRATION_TYPE_MULTIPLY;
input IndicatorType indicator_type=ENUM_INDICATOR_ORIGIN;
input double p_down=0.15;
input double p_up=0.8;
input double take_profits=20; 
input uint ea_magic=888801;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   CArbitrageStrategy *arb =new CArbitrageStrategy();
   arb.ExpertMagic(ea_magic);
   arb.ExpertSymbol(symbol_x);
   arb.Timeframe(PERIOD_M1);
   arb.ExpertName("Arbitrage"+string(ea_magic));
   arb.SetEventDetect(symbol_x,PERIOD_M1);
   arb.SetEventDetect(symbol_y,PERIOD_M1);
   arb.SetSymbolsInfor(symbol_x,symbol_y,PERIOD_M1,num_ts,lots_x,lots_y);
   arb.SetCointergrationInfor(coin_cal_type,indicator_type);
   arb.SetOpenCloseParameter(p_down,p_up,take_profits);
   
   Manager.AddStrategy(arb);
   
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
