//+------------------------------------------------------------------+
//|                                                 PairStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include "HedgePosition.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum SymbolRelation
  {
   RELATION_POSITIVE,// 正相关
   RELATION_NEGATIVE // 负相关
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPairStrategy:public CStrategy
  {
protected:
   string            sym_x;
   string            sym_y;
   MqlTick           tick_x;
   MqlTick           tick_y;
   SymbolRelation    sr;
   CHedgePositionList plist;
   int               tp_per_lots;
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CheckPositionClose();
   virtual void      CheckPositionOpen(){};

public:
                     CPairStrategy(void){};
                    ~CPairStrategy(void){};
   void              SetBasicParameters(string s_x,string s_y,SymbolRelation r);
   void              SetTP(int tp_pl=100){tp_per_lots=tp_pl;};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPairStrategy::SetBasicParameters(string s_x,string s_y,SymbolRelation r)
  {
   sym_x=s_x;
   sym_y=s_y;
   sr=r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPairStrategy::OnEvent(const MarketEvent &event)
  {
   if(event.type==MARKET_EVENT_TICK && event.symbol==ExpertSymbol())
     {
      SymbolInfoTick(sym_x,tick_x);
      SymbolInfoTick(sym_y,tick_y);
      CheckPositionClose();
     }
   if(event.type==MARKET_EVENT_BAR_OPEN && event.symbol==ExpertSymbol())
     {
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPairStrategy::CheckPositionClose(void)
  {
   for(int i=plist.PosTotal()-1;i>=0;i--)
     {
      Print(plist.GetPairProfits(i));
      Print(plist.GetPairLots(i));
      if(plist.GetPairProfits(i)/plist.GetPairLots(i)>tp_per_lots||plist.GetPairProfits(i)/plist.GetPairLots(i)<-tp_per_lots)
        {
         Trade.PositionClose(plist.GetPairPosXId(i));
         Trade.PositionClose(plist.GetPairPosYId(i));
         plist.DeletePairPos(i);
        }
     }
  }
//+------------------------------------------------------------------+
