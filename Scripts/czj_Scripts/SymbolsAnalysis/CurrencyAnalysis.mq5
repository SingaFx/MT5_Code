//+------------------------------------------------------------------+
//|                                             CurrencyAnalysis.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"

string currencies[]={"EUR","GBP","AUD","NZD","USD","CAD","CHF","JPY"};

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   CopyRates
   for(int i=0;i<8;i++)
     {
      for(int j=0;j<8;j++)
        {
         if(i==j) continue;
         string s;
         if(i<j)
           {
            s=currencies[i]+currencies[j];
           }
         else
           {
            s=currencies[j]+currencies[i];
           }
          
         
        }
     }
   
  }
//+------------------------------------------------------------------+
