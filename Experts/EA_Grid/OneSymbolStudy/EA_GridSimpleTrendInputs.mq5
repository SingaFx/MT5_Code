//+------------------------------------------------------------------+
//|                                     EA_GridSimpleTrendInputs.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridSimple.mqh>

input int Inp_points_add=300; // 网格加仓点数
input int Inp_points_total=4500; // 网格设置总趋势点
input double Inp_base_lots=0.01; // 基础手数

input uint Inp_magic=20181010;   // Magic ID
input ENUM_ORDER_TYPE_FILLING Inp_order_type=ORDER_FILLING_FOK;//FOK 指定额度执行， IOC使用市场最大量执行(微型账户使用)


CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//   根据趋势长度和网格大小确定仓位数，以及计算手数的指数函数对应的系数
   int pos_num=int(Inp_points_total/Inp_points_add);
   double alpha,beta;
   beta=MathLog(100)/(pos_num-1);
   alpha=1/MathExp(beta);
//   计算止盈出场点，满足在给定的趋势范围内，一定止盈出场；
   double sum_product=0;
   double sum_lots=0;
   for(int i=1;i<pos_num+1;i++)
     {
      sum_lots+=NormalizeDouble(0.01*alpha*exp(beta*i),2);
      sum_product+=NormalizeDouble(0.01*alpha*exp(beta*i),2)*i;
     }
   int points_win=int(Inp_points_add*(pos_num-sum_product/sum_lots));
   Print("计算出的止盈点位:", points_win); 
   CGridSimple *strategy=new CGridSimple();
   strategy.ExpertName("CGridSimple");
   strategy.ExpertMagic(Inp_magic);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init(Inp_points_add,points_win,Inp_base_lots,ENUM_GRID_LOTS_EXP_NUM,ENUM_GRID_WIN_LAST,pos_num);
   strategy.SetTypeFilling(Inp_order_type);  // FOK 指定额度执行， IOC使用市场最大量执行(微型账户使用)
   strategy.ReInitPositions();
   Manager.AddStrategy(strategy);
//---
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

