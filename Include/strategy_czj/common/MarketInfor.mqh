//+------------------------------------------------------------------+
//|                                                  MarketInfor.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "strategy_common.mqh"
#include <Math\Alglib\matrix.mqh>

string c_str[]={"EUR","GBP","AUD","NZD","USD","CAD","CHF","JPY"};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct MarketRates
  {
   MqlRates          rates[];
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMarketInfor
  {
private:
   int               symbol_num;
   double            symbol_points[];
   MqlTick           latest_price[];
   MarketRates       m_rates[];
   CMatrixInt        up_and_down;

public:
                     CMarketInfor(void);
                    ~CMarketInfor(void);
   void              CopyRatesData(ENUM_TIMEFRAMES tf=PERIOD_H4,int num=1);
   void              SortCurrencies();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMarketInfor::CMarketInfor(void)
  {
   symbol_num=28;
   ArrayResize(symbol_points,symbol_num);
   ArrayResize(latest_price,symbol_num);
   ArrayResize(m_rates,symbol_num);
   up_and_down.Resize(8,8);
   for(int i=0;i<symbol_num;i++) symbol_points[i]=SymbolInfoDouble(SYMBOLS_28[i],SYMBOL_POINT);
  }
CMarketInfor::~CMarketInfor(void)
   {
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMarketInfor::CopyRatesData(ENUM_TIMEFRAMES tf,int num)
  {
   for(int i=0;i<symbol_num;i++) CopyRates(SYMBOLS_28[i],tf,0,num,m_rates[i].rates);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMarketInfor::SortCurrencies(void)
  {
   for(int i=0;i<8;i++)
     {
      int sum_points=0;
      for(int j=0;j<8;j++)
        {
         if(i==j) continue;
         int index;
         if(i<j)
           {
            index=i*(15-i)/2+j-i-1;
            int end=ArraySize(m_rates[index].rates)-1;
            up_and_down[i].Set(j,(int)((m_rates[index].rates[end].close-m_rates[index].rates[0].open)/symbol_points[index]));
           }
          else
            {
             up_and_down[i].Set(j,-up_and_down[j][i]);
            }
          sum_points+=up_and_down[i][j];   
        }
       up_and_down[i].Set(i,sum_points);
       Print(c_str[i],":",up_and_down[i][i]);
     }
  }

//+------------------------------------------------------------------+
