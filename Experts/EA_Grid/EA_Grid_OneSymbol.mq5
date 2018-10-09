//+------------------------------------------------------------------+
//|                                         EA_Grid_ThreeSymbols.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridOneSymbol.mqh>
input int Inp_grid=300;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridOneSymbol *strategy=new CGridOneSymbol();
   strategy.ExpertName("CGridOneSymbol");
   strategy.ExpertMagic(2018090401);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   if(Inp_grid==0)
     {
      if(_Symbol=="EURGBP"||_Symbol=="EURUSD"||_Symbol=="USDCAD"||_Symbol=="USDJPY"||_Symbol=="CADJPY")
        {
         strategy.Init(_Symbol,500);
        }
      else if(_Symbol=="EURAUD"||_Symbol=="EURNZD"||_Symbol=="EURCAD"||_Symbol=="EURJPY"||_Symbol=="AUDJPY"||_Symbol=="NZDJPY"||_Symbol=="CHFJPY")
             {
              strategy.Init(_Symbol,800);
             }
           else if(_Symbol=="GBPAUD"||_Symbol=="GBPNZD"||_Symbol=="GBPUSD"||_Symbol=="GBPCAD"||_Symbol=="GBPCHF"||_Symbol=="GBPJPY")
                  {
                   strategy.Init(_Symbol,1000);
                  }
                 else
                   {
                    strategy.Init(_Symbol,300);
                   }
     
     }
   else strategy.Init(_Symbol,Inp_grid);
   Manager.AddStrategy(strategy);
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
