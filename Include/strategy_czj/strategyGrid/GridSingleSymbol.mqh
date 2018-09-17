//+------------------------------------------------------------------+
//|                                                     GridBase.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridSingleSymbol:public CStrategy
  {
protected:
   int               grid_points;
   int               tp_per_lots;
   int               tp_points;
   double            lots_current_buy;
   double            lots_current_sell;
   CArrayLong        long_pos_id;
   CArrayLong        short_pos_id;
   double            last_open_long_price;
   double            last_open_short_price;
   MqlTick           latest_price;
public:
   PositionInfor     pos_state;
   virtual bool      AddLongPositionCondition();
   virtual bool      AddShortPositionCondition();
   virtual bool      CloseLongPositionCondition();
   virtual bool      CloseShortPositionCondition();
   virtual void      BuildLongPosition();
   virtual void      BuildShortPosition();
   virtual void      AddLongPosition();
   virtual void      AddShortPosition();
   virtual void      CloseLongPosition();
   virtual void      CloseShortPosition();
   bool IsEmptyPosition();
   double CalLotsDefault(int num_pos);
   void  RefreshTickPrice(){SymbolInfoTick(ExpertSymbol(),latest_price);};

public:
                     CGridSingleSymbol(void);
                    ~CGridSingleSymbol(void){};
   void              RefreshPositionState();   // 刷新仓位信息
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGridSingleSymbol::CGridSingleSymbol(void)
  {
//base_lots=0.01;
   grid_points=500;
   tp_per_lots=100;
   tp_points=500;
  }
//+------------------------------------------------------------------+
//|              刷新仓位信息                                        |
//+------------------------------------------------------------------+
void CGridSingleSymbol::RefreshPositionState(void)
  {
   long_pos_id.Clear();
   short_pos_id.Clear();
   for(int i=0;i<PositionsTotal();i++)
     {
      if(PositionGetSymbol(i)!=ExpertSymbol() && PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      ulong ticket=PositionGetTicket(i);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) long_pos_id.Add(ticket);
      else short_pos_id.Add(ticket);
     }
   pos_state.Init();
   for(int i=0;i<long_pos_id.Total();i++)
     {
      PositionSelectByTicket(long_pos_id.At(i));
      pos_state.lots_buy+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_buy+=1;
      pos_state.profits_buy+=PositionGetDouble(POSITION_PROFIT);
     }
   for(int i=0;i<short_pos_id.Total();i++)
     {
      PositionSelectByTicket(short_pos_id.At(i));
      pos_state.lots_sell+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_sell+=1;
      pos_state.profits_sell+=PositionGetDouble(POSITION_PROFIT);
     }
  }
//+------------------------------------------------------------------+
//|            多头加仓条件                                          |
//+------------------------------------------------------------------+
bool CGridSingleSymbol::AddLongPositionCondition(void)
  {
   if(long_pos_id.Total()!=0&&last_open_long_price-latest_price.ask>grid_points/MathPow(10,Digits())) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                空头加仓条件                                      |
//+------------------------------------------------------------------+
bool CGridSingleSymbol::AddShortPositionCondition(void)
  {
   if(short_pos_id.Total()!=0&&latest_price.bid-last_open_short_price>grid_points/MathPow(10,Digits())) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridSingleSymbol::CloseLongPositionCondition(void)
  {
//if(pos_state.lots_buy>0&&pos_state.profits_buy/pos_state.lots_buy>tp_per_lots) return true;
//return false;
   if(pos_state.num_sell==0&&pos_state.num_buy==1&&pos_state.profits_buy/pos_state.lots_buy>tp_per_lots) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridSingleSymbol::CloseShortPositionCondition(void)
  {
//if(pos_state.lots_sell>0&&pos_state.profits_sell/pos_state.lots_sell>tp_per_lots) return true;
//return false;
   if(pos_state.num_buy==0&&pos_state.num_sell==1&&pos_state.profits_sell/pos_state.lots_sell>tp_per_lots) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSingleSymbol::BuildLongPosition(void)
  {
   lots_current_buy=CalLotsDefault(pos_state.num_buy+1);
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots_current_buy,latest_price.ask,0,0,"first-build long");
   last_open_long_price=latest_price.ask;
   long_pos_id.Add(Trade.ResultOrder());
   Trade.PositionModify(Trade.ResultOrder(),0,last_open_long_price+tp_points/MathPow(10,Digits()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSingleSymbol::BuildShortPosition(void)
  {
   lots_current_sell=CalLotsDefault(pos_state.num_sell+1);
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots_current_sell,latest_price.bid,0,0,"first-build short");
   last_open_short_price=latest_price.bid;
   short_pos_id.Add(Trade.ResultOrder());
   Trade.PositionModify(Trade.ResultOrder(),0,last_open_short_price-tp_points/MathPow(10,Digits()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSingleSymbol::AddLongPosition(void)
  {
   
   lots_current_buy=CalLotsDefault(pos_state.num_buy+1);
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots_current_buy,latest_price.ask,0,0,"Add long-"+string(long_pos_id.Total()));
   last_open_long_price=latest_price.ask;
   long_pos_id.Add(Trade.ResultOrder());
   for(int i=0;i<long_pos_id.Total();i++)
     {
      Trade.PositionModify(long_pos_id.At(i),0,last_open_long_price+tp_points/MathPow(10,Digits()));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSingleSymbol::AddShortPosition(void)
  {
   lots_current_sell=CalLotsDefault(pos_state.num_sell+1);
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots_current_sell,latest_price.ask,0,0,"Add short-"+string(short_pos_id.Total()));
   last_open_short_price=latest_price.bid;
   short_pos_id.Add(Trade.ResultOrder());
   for(int i=0;i<short_pos_id.Total();i++)
     {
      Trade.PositionModify(short_pos_id.At(i),0,last_open_short_price-tp_points/MathPow(10,Digits()));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSingleSymbol::CloseLongPosition(void)
  {
   for(int i=0;i<long_pos_id.Total();i++)
     {
      Trade.PositionClose(long_pos_id.At(i));
     }
   long_pos_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSingleSymbol::CloseShortPosition(void)
  {
   for(int i=0;i<short_pos_id.Total();i++)
     {
      Trade.PositionClose(short_pos_id.At(i));
     }
   short_pos_id.Clear();
  }
bool CGridSingleSymbol::IsEmptyPosition(void)
   {
    if(pos_state.num_buy==0&&pos_state.num_sell==0) return true;
    return false;
   }
double CGridSingleSymbol::CalLotsDefault(int num_pos)
   {
    return NormalizeDouble(0.007*exp(0.4*num_pos),2);
    //return base_lots*num_pos;
   }
//+------------------------------------------------------------------+
