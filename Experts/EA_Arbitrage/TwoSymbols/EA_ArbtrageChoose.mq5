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


input int index_pairs=0; // XAUJPY-0,EURCHF-1,AUDCAD-2,XAUXAG-3
input int num_ts=600;//协整周期
input double lots_x=0.01;//品种一手数
input double lots_y=0.01;//品种二手数
input IndicatorType indicator_type=ENUM_INDICATOR_ORIGIN;//计算协整采用的指标
input double p_down=0.05;//套利下界
input double p_up=0.95;//套利上界
input double take_profits=2;//获利止盈 
input uint ea_magic=888800;//ea标识符

CStrategyList Manager;
string symbol_xs[]={"XAUUSD","EURUSD","AUDUSD","XAUUSD"};
string symbol_ys[]={"USDJPY","USDCHF","USDCAD","XAGUSD"};
CointergrationCalType coin[]={ENUM_COINTERGRATION_TYPE_MULTIPLY,ENUM_COINTERGRATION_TYPE_MULTIPLY,ENUM_COINTERGRATION_TYPE_MULTIPLY,ENUM_COINTERGARTION_TYPE_DIVIDE};
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
      CArbitrageStrategy *arb =new CArbitrageStrategy();
      arb.ExpertMagic(ea_magic);
      arb.ExpertSymbol(symbol_xs[index_pairs]);
      arb.Timeframe(_Period);
      arb.ExpertName("Arbitrage"+string(ea_magic));
      arb.SetEventDetect(symbol_xs[index_pairs],_Period);
      arb.SetEventDetect(symbol_ys[index_pairs],_Period);
      arb.SetSymbolsInfor(symbol_xs[index_pairs],symbol_ys[index_pairs],_Period,num_ts,lots_x,lots_y);
      arb.SetCointergrationInfor(coin[index_pairs],indicator_type);
      arb.SetOpenCloseParameter(p_down,p_up,take_profits);
      arb.ReInitPositions();
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
