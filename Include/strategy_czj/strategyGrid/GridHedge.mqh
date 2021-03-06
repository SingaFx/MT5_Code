//+------------------------------------------------------------------+
//|                                                    GridHedge.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridBaseOperate.mqh"
#include "TrendHedgeOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridHedge:public CStrategy
  {
private:
   CGridBaseOperate  strategy_grid[28];
   CTrendHedgeOperate strategy_hedge[28];
protected:
   void              RefreshTickPrice();
   void              RefreshPositionState();
   void              CheckPositionClose();
   void              CheckPositionOpen();
   void              PositionOpenDefault();
   void              PositionOpenByHedgeStrategy();
public:
                     CGridHedge(void){};
                    ~CGridHedge(void){};
   void              Init();
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridHedge::Init(void)
  {
   for(int i=0;i<28;i++)
     {
      CGridBaseOperate *s_grid=&strategy_grid[i];
      CTrendHedgeOperate *s_hedge=&strategy_hedge[i];
      s_grid.ExpertMagic(ExpertMagic()+i);
      s_hedge.ExpertMagic(ExpertMagic()+i+50);
      s_grid.ExpertSymbol(SYMBOLS_28[i]);
      s_hedge.ExpertSymbol(SYMBOLS_28[i]);
      s_grid.Init();
      s_hedge.Init();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridHedge::RefreshTickPrice(void)
  {
   for(int i=0;i<28;i++)
     {
      CGridBaseOperate *s_grid=&strategy_grid[i];
      s_grid.RefreshTickPrice();
      CTrendHedgeOperate *s_hedge=&strategy_hedge[i];
      s_hedge.RefreshTickPrice();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridHedge::RefreshPositionState(void)
  {
   for(int i=0;i<28;i++)
     {
      CGridBaseOperate *s_grid=&strategy_grid[i];
      s_grid.RefreshPositionState();
      CTrendHedgeOperate *s_hedge=&strategy_hedge[i];
      s_hedge.RefreshPositionState();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridHedge::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      RefreshTickPrice();
      RefreshPositionState();
      CheckPositionClose();
      RefreshPositionState();
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridHedge::CheckPositionClose(void)
  {
   for(int i=0;i<28;i++)
     {
      CGridBaseOperate *s_grid=&strategy_grid[i];
      CTrendHedgeOperate *s_hedge=&strategy_hedge[i];

      if(s_grid.pos_state.num_buy>0 && s_grid.pos_state.profits_buy/s_grid.pos_state.lots_buy>100)
        {
         Print(s_grid.ExpertSymbol(),"进行多头网格策略平仓");
         s_grid.CloseLongPosition();
         Print(s_hedge.ExpertSymbol(),"进行空头趋势对冲策略平仓");
         s_hedge.CloseShortPosition();
        }
      if(s_grid.pos_state.num_sell>0 && s_grid.pos_state.profits_sell/s_grid.pos_state.lots_sell>100)
        {
         Print(s_grid.ExpertSymbol(),"进行空头网格策略平仓");
         s_grid.CloseShortPosition();
         Print(s_hedge.ExpertSymbol(),"进行多头趋势对冲策略平仓");
         s_hedge.CloseLongPosition();
        }
      RefreshPositionState();
      if(s_hedge.IsDown()&&s_hedge.pos_state.num_buy>0) s_hedge.CloseLongPosition();
      if(s_hedge.IsUp()&&s_hedge.pos_state.num_sell>0) s_hedge.CloseShortPosition();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridHedge::CheckPositionOpen(void)
  {
   PositionOpenDefault();
   RefreshPositionState();
   PositionOpenByHedgeStrategy();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridHedge::PositionOpenDefault(void)
  {
   for(int i=0;i<28;i++)
     {
      CGridBaseOperate *s_grid=&strategy_grid[i];
      if(s_grid.pos_state.num_buy==0) s_grid.BuildLongPositionDefault();
      if(s_grid.pos_state.num_sell==0) s_grid.BuildShortPositionDefault();
      if(s_grid.pos_state.num_buy>0 && s_grid.DistanceAtLastBuyPrice()>300) s_grid.BuildLongPositionDefault();
      if(s_grid.pos_state.num_sell>0 && s_grid.DistanceAtLastSellPrice()>300) s_grid.BuildShortPositionDefault();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridHedge::PositionOpenByHedgeStrategy(void)
  {
   for(int i=0;i<28;i++)
     {
      CGridBaseOperate *s_grid=&strategy_grid[i];
      CTrendHedgeOperate *s_hedge=&strategy_hedge[i];
      if(s_grid.pos_state.num_buy-s_grid.pos_state.num_sell>2 && s_hedge.IsDown() && s_hedge.pos_state.num_sell==0)
        {
         s_hedge.OpenShortPosition(NormalizeDouble((s_grid.pos_state.lots_buy-s_grid.pos_state.lots_sell)/2,2));
        }
      if(s_grid.pos_state.num_sell-s_grid.pos_state.num_buy>2 && s_hedge.IsUp() && s_hedge.pos_state.num_buy==0)
        {
         s_hedge.OpenLongPosition(NormalizeDouble((s_grid.pos_state.lots_sell-s_grid.pos_state.lots_buy)/2,2));
        }
     }
  }
//+------------------------------------------------------------------+
