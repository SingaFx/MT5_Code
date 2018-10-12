//+------------------------------------------------------------------+
//|                                              GridSimpleHedge.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "GridBaseOperate.mqh"
#include "HedgeBaseOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridSimpleHedge:public CStrategy
  {
private:
   CGridBaseOperate  grid_operator;
   CHedgeBaseOperate hedge_operator;
   int points_win;
   int points_add;
public:
                     CGridSimpleHedge(void){};
                    ~CGridSimpleHedge(void){};
   void              Init();
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              HedgeOperate();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSimpleHedge::Init(void)
  {
   grid_operator.ExpertMagic(ExpertMagic()+0);
   grid_operator.Init();
   hedge_operator.ExpertMagic(ExpertMagic()+1);
   hedge_operator.Init();
   points_win=600;
   points_add=300;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSimpleHedge::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      grid_operator.RefreshTickPrice();
      grid_operator.RefreshPositionState();
      if(grid_operator.pos_state.num_buy==0) grid_operator.BuildLongPositionWithTP(points_win);
      if(grid_operator.pos_state.num_sell==0) grid_operator.BuildShortPositionWithTP(points_win);
      if(grid_operator.pos_state.num_buy>0 && grid_operator.pos_state.num_buy<12 && grid_operator.DistanceAtLastBuyPrice()>points_add) grid_operator.BuildLongPositionWithTP(points_win);
      if(grid_operator.pos_state.num_sell>0 && grid_operator.pos_state.num_sell<12 && grid_operator.DistanceAtLastSellPrice()>points_add) grid_operator.BuildShortPositionWithTP(points_win);
      HedgeOperate();
     }
  }
void CGridSimpleHedge::HedgeOperate(void)
   {
    hedge_operator.RefreshPositionState();
    double lots_balance=grid_operator.pos_state.lots_buy-grid_operator.pos_state.lots_sell;
    if(MathAbs(lots_balance)<0.25) return;
    hedge_operator.RefreshTickPrice();
    if(lots_balance>0.25 && hedge_operator.pos_state.num_sell==0) hedge_operator.OpenShortPositionWithTpAndSl(NormalizeDouble(lots_balance/3,2),700,700);
    if(lots_balance<-0.25 && hedge_operator.pos_state.num_buy==0) hedge_operator.OpenLongPositionWithTpAndSl(NormalizeDouble(-lots_balance/3,2),700,700);
   }
//+------------------------------------------------------------------+
