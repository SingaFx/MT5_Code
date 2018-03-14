//+------------------------------------------------------------------+
//|                                             EA_BreakPointRSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRSI\GridAddRSI.mqh>

input int Inp_rsi_period=14; //RSI计算周期
input double Inp_rsi_up_open=70;//RSI开空阈值
input double Inp_rsi_down_open=30;//RSI开多阈值
input double Inp_lots_init=0.1;//初始手数
input int Inp_num_position=5;//最大持仓数
input int Inp_points_win1=100;//止盈点数1--达到RSI平仓阈值后的要求每手盈利点
input int Inp_points_win2=300;//止盈点数2--无论RSI平仓阈值是否达到每手的盈利点
input double Inp_rsi_up_close=50;//RSI平空阈值
input double Inp_rsi_down_close=50;//RSI平多阈值
input RSI_type Inp_rsi_type=ENUM_RSI_TYPE_5;//RSI计算类型
input int Inp_points_add=500;//加仓必须满足的回撤点数
input int EA_MAGIC=9000;//EA标识符

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridAddRSIStrategy *rsi_s=new CGridAddRSIStrategy();
   rsi_s.ExpertName("RSI网格加仓策略");
   rsi_s.ExpertMagic(EA_MAGIC);
   rsi_s.Timeframe(_Period);
   rsi_s.ExpertSymbol(_Symbol);
   rsi_s.SetEventDetect(_Symbol,_Period);
   rsi_s.InitStrategy(Inp_rsi_period,
                      Inp_rsi_up_open,
                      Inp_rsi_down_open,
                      Inp_lots_init,
                      Inp_num_position,
                      Inp_points_win1,
                      Inp_points_win2,
                      Inp_rsi_up_close,
                      Inp_rsi_down_close,
                      Inp_rsi_type,
                      Inp_points_add);
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
