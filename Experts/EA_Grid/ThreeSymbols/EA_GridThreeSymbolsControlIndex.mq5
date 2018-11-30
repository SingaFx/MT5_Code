//+------------------------------------------------------------------+
//|                              EA_GridThreeSymbolsControlIndex.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridThreeSymbolsControl.mqh>
input int Inp_index=0;
input bool  Inp_hedge_enable=true;

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   int counter=0;
   string currencies[]={"EUR","GBP","AUD","NZD","USD","CAD","CHF","JPY"};
   string c1[56];
   string c2[56];
   string c3[56];
   for(int i=0;i<6;i++)
     {
      for(int j=i+1;j<7;j++)
        {
         for(int k=j+1;k<8;k++)
           {
            c1[counter]=currencies[i];
            c2[counter]=currencies[j];
            c3[counter]=currencies[k];   
            counter++;
           }
        }
     }
//---
   CGridThreeSymbolsControl *strategy=new CGridThreeSymbolsControl();
   strategy.ExpertName("CGridThreeSymbolsControl");
   strategy.ExpertMagic(2018090401);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.SetCurrencies(c1[Inp_index],c2[Inp_index],c3[Inp_index]);
   Print(c1[Inp_index],c2[Inp_index],c3[Inp_index]);
   strategy.SetHedgeAllowed(Inp_hedge_enable);
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

