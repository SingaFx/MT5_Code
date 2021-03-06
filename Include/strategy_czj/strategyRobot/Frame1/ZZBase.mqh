//+------------------------------------------------------------------+
//|                                                       ZZBase.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <Arrays\ArrayDouble.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CZZBase:public CStrategy
  {
protected:
   int               h_zz;
   int               num_zz;
   CArrayDouble      value_zz;
   MqlTick           latest_price;
   datetime          last_buy_time;
   datetime          last_sell_time;
   double            tp_price;
   double            sl_price;
   int               points_tp;
   int               points_sl;
public:
                     CZZBase(void){};
                    ~CZZBase(void){};
   void              InitZZ(int n_zz=100);
protected:
   void              GetZZ();    //  获取zigzag的值     
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CheckPositionOpen(){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CZZBase::InitZZ(int n_zz=100)
  {
   num_zz=n_zz;
   h_zz=iCustom(ExpertSymbol(),Timeframe(),"Examples\\ZigZag");
   Print(h_zz);
   points_tp=300;
   points_sl=300;
   GetZZ();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CZZBase::GetZZ(void)
  {
   double zigzag[];
   CopyBuffer(h_zz,0,0,num_zz,zigzag);
   value_zz.Clear();
   for(int i=0;i<num_zz;i++) if(zigzag[i]!=0) value_zz.Add(zigzag[i]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CZZBase::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CheckPositionOpen();
     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      GetZZ();
     }
  }
//+------------------------------------------------------------------+
