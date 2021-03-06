//+------------------------------------------------------------------+
//|                                                GridOneSymbol.mqh |
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
class CGridOneSymbol:public CStrategy
  {
private:
   string            symbol;
   CGridBaseOperate  child_strategy;
   int               grid_add_points;
   CTrendHedgeOperate hedge_strategy;

protected:
   void              RefreshTickPrice();
   void              RefreshPositionState();
   void              CheckPositionClose();
   void              CheckPositionOpen();
   void              PositionOpenDefault();
   void              PositionOpenWithTP();
   void              PositionOpenByRiskControlAndIndicatorControl();
   void              PositionOpenByHedgeStrategy();
public:
                     CGridOneSymbol(void){};
                    ~CGridOneSymbol(void){};
   void              Init(string symbol_,int grid_);
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbol::Init(string symbol_,int grid_)
  {
   symbol=symbol_;
   grid_add_points=grid_;
   child_strategy.ExpertMagic(ExpertMagic()+0);
   child_strategy.ExpertSymbol(symbol);
   child_strategy.Init();
   hedge_strategy.ExpertMagic(ExpertMagic()+1);
   hedge_strategy.ExpertSymbol(symbol);
   hedge_strategy.Init();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbol::RefreshTickPrice(void)
  {
   CGridBaseOperate *s_grid=&child_strategy;
   CTrendHedgeOperate *s_trend=&hedge_strategy;
   s_grid.RefreshTickPrice();
   s_trend.RefreshTickPrice();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbol::RefreshPositionState(void)
  {
   CGridBaseOperate *s_grid=&child_strategy;
   CTrendHedgeOperate *s_trend=&hedge_strategy;
   s_grid.RefreshPositionState();
   s_trend.RefreshPositionState();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbol::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      RefreshTickPrice();
      RefreshPositionState();
      //CheckPositionClose();
      RefreshPositionState();
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbol::CheckPositionClose(void)
  {
   CGridBaseOperate *s=&child_strategy;
   CTrendHedgeOperate *s_trend=&hedge_strategy;

   if(s.pos_state.num_buy>0 && s.pos_state.profits_buy/s.pos_state.lots_buy>100)
     {
      Print(s.ExpertSymbol(),"进行多头网格策略平仓1");
      s.CloseLongPosition();
      Print(s_trend.ExpertSymbol(),"进行空头趋势对冲策略平仓1");
      s_trend.CloseShortPosition();
     }
   if(s.pos_state.num_sell>0 && s.pos_state.profits_sell/s.pos_state.lots_sell>100)
     {
      Print(s.ExpertSymbol(),"进行空头网格策略平仓1");
      s.CloseShortPosition();
      Print(s_trend.ExpertSymbol(),"进行多头趋势对冲策略平仓1");
      s_trend.CloseLongPosition();
     }
    if(s.pos_state.num_buy>5 && s.pos_state.profits_buy>0)
     {
      Print(s.ExpertSymbol(),"进行多头网格策略平仓2");
      s.CloseLongPosition();
      Print(s_trend.ExpertSymbol(),"进行空头趋势对冲策略平仓2");
      s_trend.CloseShortPosition();
     }
    if(s.pos_state.num_sell>5 && s.pos_state.profits_sell>0)
     {
      Print(s.ExpertSymbol(),"进行空头网格策略平仓2");
      s.CloseShortPosition();
      Print(s_trend.ExpertSymbol(),"进行多头趋势对冲策略平仓2");
      s_trend.CloseLongPosition();
     }
   RefreshPositionState();
   if(s.pos_state.num_sell==0 || (s_trend.IsDown() && s_trend.pos_state.num_buy>0)) s_trend.CloseLongPosition();
   if(s.pos_state.num_buy==0 || (s_trend.IsUp() && s_trend.pos_state.num_sell>0)) s_trend.CloseShortPosition();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbol::CheckPositionOpen(void)
  {
   //PositionOpenDefault();
   PositionOpenWithTP();
   RefreshPositionState();
   
   //PositionOpenByHedgeStrategy();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbol::PositionOpenDefault(void)
  {
   CGridBaseOperate *s=&child_strategy;
   if(s.pos_state.num_buy==0) s.BuildLongPositionDefault();
   if(s.pos_state.num_sell==0) s.BuildShortPositionDefault();
   if(s.pos_state.num_buy>0 && s.DistanceAtLastBuyPrice()>grid_add_points) s.BuildLongPositionDefault();
   if(s.pos_state.num_sell>0 && s.DistanceAtLastSellPrice()>grid_add_points) s.BuildShortPositionDefault();
  }
void CGridOneSymbol::PositionOpenWithTP(void)
   {
   CGridBaseOperate *s=&child_strategy;
   if(s.pos_state.num_buy==0) s.BuildLongPositionWithTP(600);
   if(s.pos_state.num_sell==0) s.BuildShortPositionWithTP(600);
   if(s.pos_state.num_buy>0 && s.DistanceAtLastBuyPrice()>300) s.BuildLongPositionWithTP(600);
   if(s.pos_state.num_sell>0 && s.DistanceAtLastSellPrice()>300) s.BuildShortPositionWithTP(600);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbol::PositionOpenByRiskControlAndIndicatorControl(void)
  {
   CGridBaseOperate *s=&child_strategy;
   if(s.pos_state.num_buy>0 && s.DistanceAtLastBuyPrice()>grid_add_points && s.PositionAddLongCondition()) s.BuildLongPositionDefault();
   if(s.pos_state.num_sell>0 && s.DistanceAtLastSellPrice()>grid_add_points && s.PositionAddShortCondition()) s.BuildShortPositionDefault();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridOneSymbol::PositionOpenByHedgeStrategy(void)
  {
   CGridBaseOperate *s_grid_child=&child_strategy;
   CTrendHedgeOperate *s_hedge=&hedge_strategy;
   if(s_grid_child.pos_state.num_buy-s_grid_child.pos_state.num_sell>2 && s_hedge.IsDown() && s_hedge.pos_state.num_sell==0)
     {
      s_hedge.OpenShortPosition(NormalizeDouble((s_grid_child.pos_state.lots_buy-s_grid_child.pos_state.lots_sell)/2,2));
     }
   if(s_grid_child.pos_state.num_sell-s_grid_child.pos_state.num_buy>2 && s_hedge.IsUp() && s_hedge.pos_state.num_buy==0)
     {
      s_hedge.OpenLongPosition(NormalizeDouble((s_grid_child.pos_state.lots_sell-s_grid_child.pos_state.lots_buy)/2,2));
     }
  }
//+------------------------------------------------------------------+
