//+------------------------------------------------------------------+
//|                                                  EA_ArbTest2.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyTriangularArbitrage\CTriangularArbCurrency.mqh>
CStrategyList Manager;
input double Inp_lots=0.1;
input int Inp_dev_points=50;
input double Inp_win_per_lots=50;
input int ea_magic=1800;
string currencies[]={"EUR","GBP","AUD","NZD","CAD","CHF","JPY"};
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   for(int i=0;i<ArraySize(currencies)-1;i++)
     {
      for(int j=i+1;j<ArraySize(currencies);j++)
        {
         CTriangularArbCurrency *arb = new CTriangularArbCurrency();
         arb.ExpertMagic(ea_magic+10*i+j);
         arb.Timeframe(PERIOD_M1);
         arb.ExpertName("TriangularArbCurrency"+string(ea_magic+10*i+j));
         arb.SetSymbolsInfor(currencies[i],currencies[j],Inp_lots,Inp_dev_points,Inp_win_per_lots);
         Manager.AddStrategy(arb);
        }
     }
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
