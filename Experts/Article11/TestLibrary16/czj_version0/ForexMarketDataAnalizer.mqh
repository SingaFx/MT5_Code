//+------------------------------------------------------------------+
//|                                      ForexMarketDataAnalizer.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "ForexMarketDataManager.mqh"
#include <Math\Alglib\statistics.mqh>
CBaseStat base_stat;
//+------------------------------------------------------------------+
//|         外汇两品种相关关系结构体                                 |
//+------------------------------------------------------------------+
class CForexCorr:public CObject
  {
   public:
      string            symbol1;
      string            symbol2;
      double            r;
      ENUM_TIMEFRAMES   time_frame;
  };
//+------------------------------------------------------------------+
//|              外汇数据分析器                                      |
//+------------------------------------------------------------------+
class CForexMarketDataAnalyzier
  {
private:
   CForexMarketDataManager dm;
public:
   void SetDataManager(CForexMarketDataManager &data_manager){dm=data_manager;};
   double            GetPearsonCorr2(string symbol_x,string symbol_y,ENUM_TIMEFRAMES corr_period);
   void              GetPearsonCorrN(const string &symbols[],ENUM_TIMEFRAMES corr_period,CArrayObj &corr);
   void              GetPearsonCorrN(ENUM_TIMEFRAMES corr_period,CArrayObj &corr);
   void              GetPearsonCorrN(CArrayObj &corr);
  };
//+------------------------------------------------------------------+
//|                   获取两个品种在给定周期的相关关系               |
//+------------------------------------------------------------------+
double CForexMarketDataAnalyzier::GetPearsonCorr2(string symbol_x,string symbol_y,ENUM_TIMEFRAMES corr_period)
  {
   double price_x[],price_y[];
   ArrayResize(price_x,dm.NumTime(corr_period));
   ArrayResize(price_y,dm.NumTime(corr_period));
   for(int i=0;i<dm.NumTime(corr_period);i++)
     {
      price_x[i]=dm.GetSymbolPriceAt(symbol_x,corr_period).At(i);
      price_y[i]=dm.GetSymbolPriceAt(symbol_y,corr_period).At(i);
     }
   return base_stat.PearsonCorr2(price_x,price_y,dm.NumTime(corr_period));
  }
//+------------------------------------------------------------------+
//|               获取多个品种配对在给定周期的相关关系               |
//+------------------------------------------------------------------+
void CForexMarketDataAnalyzier::GetPearsonCorrN(const string &symbols[],ENUM_TIMEFRAMES corr_period,CArrayObj &corr)
  {
   int num_symbol=ArraySize(symbols);
   int num_pairs=num_symbol*(num_symbol-1)/2;
   int counter=0;
   for(int i=0;i<num_symbol-1;i++)
     {
      for(int j=i+1;j<num_symbol;j++)
        {
         CForexCorr *f_corr=new CForexCorr();
         f_corr.symbol1=symbols[i];
         f_corr.symbol2=symbols[j];
         f_corr.time_frame=corr_period;
         f_corr.r=GetPearsonCorr2(symbols[i],symbols[j],corr_period);
         corr.Add(f_corr);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CForexMarketDataAnalyzier::GetPearsonCorrN(ENUM_TIMEFRAMES corr_period,CArrayObj &corr)
  {
   string symbol_total[];
   ArrayResize(symbol_total,dm.NumSymbol());
   for(int i=0;i<dm.NumSymbol();i++)
     {
      symbol_total[i]=dm.GetSymbolAt(i);
     }
   GetPearsonCorrN(symbol_total,corr_period,corr);
  }
//+------------------------------------------------------------------+
//|    获取数据管理器中所有外汇配对品种所有周期的相关关系结果        |
//+------------------------------------------------------------------+
void CForexMarketDataAnalyzier::GetPearsonCorrN(CArrayObj &corr)
  {
   for(int i=0;i<dm.NumTimeFrame();i++)
     {
      CArrayObj *corr_symbol_pair=new CArrayObj();
      GetPearsonCorrN(dm.GetPeriodAt(i),corr_symbol_pair);
      corr.Add(corr_symbol_pair);
     }
  }
//+------------------------------------------------------------------+
