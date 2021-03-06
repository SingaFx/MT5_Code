//+------------------------------------------------------------------+
//|                                       ComplicatedControlBase.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include "common_define.mqh"
#include "PositionAndRiskState.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CComplicatedControlBase:public CStrategy
  {
protected:
   MqlTick           latest_price[28]; // 28个品种对的最新报价
   CPositionAndRiskState pos_risk_state;

protected:
   void              RefreshTickPrice(){for(int i=0;i<28;i++) SymbolInfoTick(SYMBOLS_28[i],latest_price[i]);};   // 刷新tick报价                                                                                                       //void              RefreshPositionState(){for(int i=0;i<28;i++) pos_state[i].Refresh();};  // 刷新仓位信息
   void              RefreshRiskInfor(){pos_risk_state.RefreshState();};   // 刷新风险信息 
   void              PrintRiskInfor(); // 打印当前风险信息

   double            DistanceLatestPriceToLastBuyPrice(int index); // 同上次买价的下降的距离
   double            DistanceLatestPriceToLastSellPrice(int index); // 同上次卖价的上升的距离
   double            DistanceLatestPriceToFirstBuyPrice(int index); // 同首次买价的下降的距离
   double            DistanceLatestPriceToFirstSellPrice(int index); // 同首次卖价的上升的距离
   double            HoursLatestTimeToLastBuyTime(int index);  // 同上次买的时间差
   double            HoursLatestTimeToLastSellTime(int index); // 同上次卖的时间差 

   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CheckPositionClose(){};      // 平仓判断
   virtual void      CheckPositionOpen(const MarketEvent &event){}; // 开仓判断
   //---平仓操作
   void              ClosePositionOnOneSymbolAt(int index,string comment=""); // 将某个品种的所有仓位平掉

   //---不同的平仓操作
   void              CloseLongPositionAt(int i_s,string comment=" "); // 将指定索引的多头仓位进行平仓
   void              CloseShortPositionAt(int i_s,string comment=" "); // 将指定索引的空头仓位进行平仓
   void              CloseLongPositionAt(int i_s,int i_p,string comment=" ");
   void              CloseShortPositionAt(int i_s,int i_p,string comment=" ");
   void              CloseLongPositionAt(int i_s,const CArrayInt &i_p,string comment=" ");
   void              CloseShortPositionAt(int i_s,const CArrayInt &i_p,string comment=" ");

public:
                     CComplicatedControlBase(void);
                    ~CComplicatedControlBase(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CComplicatedControlBase::CComplicatedControlBase(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CComplicatedControlBase::DistanceLatestPriceToLastBuyPrice(int index)
  {
   return (pos_risk_state.GetLastOpenLongPrice(index)-latest_price[index].ask)/SymbolInfoDouble(SYMBOLS_28[index],SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CComplicatedControlBase::DistanceLatestPriceToFirstBuyPrice(int index)
  {
   return (pos_risk_state.GetFirstOpenLongPrice(index)-latest_price[index].ask)/SymbolInfoDouble(SYMBOLS_28[index],SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CComplicatedControlBase::DistanceLatestPriceToLastSellPrice(int index)
  {
   return (latest_price[index].bid-pos_risk_state.GetLastOpenShortPrice(index))/SymbolInfoDouble(SYMBOLS_28[index],SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CComplicatedControlBase::DistanceLatestPriceToFirstSellPrice(int index)
  {
   return (latest_price[index].bid-pos_risk_state.GetFirstOpenShortPrice(index))/SymbolInfoDouble(SYMBOLS_28[index],SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CComplicatedControlBase::HoursLatestTimeToLastBuyTime(int index)
  {
   return double(latest_price[index].time-pos_risk_state.GetLastOpenLongTime(index))/(60*60*24);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CComplicatedControlBase::HoursLatestTimeToLastSellTime(int index)
  {
   return double(latest_price[index].time-pos_risk_state.GetLastOpenShortTime(index))/(60*60*24);
  }
//+------------------------------------------------------------------+
void CComplicatedControlBase::OnEvent(const MarketEvent &event)
  {
// Tick 事件处理 <= tick数据更新，仓位状态更新，风险更新，平仓判断
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      RefreshTickPrice();
      RefreshRiskInfor();
      CheckPositionClose();
     }
// BAR 事件处理 <= 开仓判断
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      CheckPositionOpen(event);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControlBase::ClosePositionOnOneSymbolAt(int index,string comment="")
  {
   CloseLongPositionAt(index,comment);
   CloseShortPositionAt(index,comment);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControlBase::CloseLongPositionAt(int i_s,string comment=" ")
  {
   for(int j=0;j<pos_risk_state.LongPosTotalAt(i_s);j++) Trade.PositionClose(pos_risk_state.LongPositionIdAt(i_s,j),comment);
   pos_risk_state.DeleteLongPositionAt(i_s);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControlBase::CloseShortPositionAt(int i_s,string comment=" ")
  {
   for(int j=0;j<pos_risk_state.ShortPosTotalAt(i_s);j++) Trade.PositionClose(pos_risk_state.ShortPositionIdAt(i_s,j),comment);
   pos_risk_state.DeleteShortPositionAt(i_s);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControlBase::CloseLongPositionAt(int i_s,const CArrayInt &i_p,string comment=" ")
  {
   for(int j=0;j<i_p.Total();j++) Trade.PositionClose(pos_risk_state.LongPositionIdAt(i_s,i_p.At(j)),comment);
   pos_risk_state.DeleteLongPositionAt(i_s,i_p);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControlBase::CloseShortPositionAt(int i_s,const CArrayInt &i_p,string comment=" ")
  {
   for(int j=0;j<i_p.Total();j++) Trade.PositionClose(pos_risk_state.ShortPositionIdAt(i_s,i_p.At(j)),comment);
   pos_risk_state.DeleteShortPositionAt(i_s,i_p);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControlBase::CloseLongPositionAt(int i_s,int i_p,string comment=" ")
  {
   Trade.PositionClose(pos_risk_state.LongPositionIdAt(i_s,i_p),comment);
   pos_risk_state.DeleteLongPositionAt(i_s,i_p);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControlBase::CloseShortPositionAt(int i_s,int i_p,string comment=" ")
  {
   Trade.PositionClose(pos_risk_state.ShortPositionIdAt(i_s,i_p),comment);
   pos_risk_state.DeleteShortPositionAt(i_s,i_p);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControlBase::PrintRiskInfor(void)
  {
   for(int i=0;i<8;i++)
     {
      Print("货币-",CURRENCIES_8[i]," long lots:",DoubleToString(pos_risk_state.GetCurrencyLongRiskAt(i),2)," short lots:",DoubleToString(pos_risk_state.GetCurrencyShortRiskAt(i),2));
     }
  }
//+------------------------------------------------------------------+
