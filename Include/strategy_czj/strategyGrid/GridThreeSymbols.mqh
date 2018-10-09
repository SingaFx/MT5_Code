//+------------------------------------------------------------------+
//|                                             GridThreeSymbols.mqh |
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
class CGridThreeSymbols:public CStrategy
  {
private:
   string            symbols[3];
   CGridBaseOperate  child_strategy[3];
   int               grid_add_points[3];
   CTrendHedgeOperate hedge_strategy[3];
   //int h_rsi[3];
   //int h_sma[3];
   //double value_rsi[3][1];
   //double value_sma[3][1];

protected:
   void              RefreshTickPrice();
   void              RefreshPositionState();
   void              CheckPositionClose();
   void              CheckPositionOpen();
   void              PositionOpenDefault();
   void              PositionOpenByRiskControl();
   void              PositionOpenByRiskControlAndIndicatorControl();
   void              PositionOpenByHedgeStrategy();
   void              PositionOperate();
public:
                     CGridThreeSymbols(void){};
                    ~CGridThreeSymbols(void){};
   void              Init(string symbol_cross,string symbol_x,string symbol_y,int grid_cross,int grid_x,int grid_y);
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::Init(string symbol_cross="EURGBP",string symbol_x="EURUSD",string symbol_y="GBPUSD",int grid_cross=300,int grid_x=300,int grid_y=300)
  {
   symbols[0]=symbol_cross;
   symbols[1]=symbol_x;
   symbols[2]=symbol_y;
   grid_add_points[0]=grid_cross;
   grid_add_points[1]=grid_x;
   grid_add_points[2]=grid_y;
   for(int i=0;i<3;i++)
     {
      child_strategy[i].ExpertMagic(i+ExpertMagic());
      child_strategy[i].ExpertSymbol(symbols[i]);
      child_strategy[i].Init();

      hedge_strategy[i].ExpertMagic(i+10+ExpertMagic());
      hedge_strategy[i].ExpertSymbol(symbols[i]);
      hedge_strategy[i].Init();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::RefreshTickPrice(void)
  {
   for(int i=0;i<3;i++)
     {
      CGridBaseOperate *s=&child_strategy[i];
      s.RefreshTickPrice();
      CTrendHedgeOperate *s_trend=&hedge_strategy[i];
      s_trend.RefreshTickPrice();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::RefreshPositionState(void)
  {
   for(int i=0;i<3;i++)
     {
      CGridBaseOperate *s=&child_strategy[i];
      s.RefreshPositionState();
      CTrendHedgeOperate *s_trend=&hedge_strategy[i];
      s_trend.RefreshPositionState();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      RefreshTickPrice();
      RefreshPositionState();
      CheckPositionClose();
      //RefreshPositionState();
      //CheckPositionOpen();
      PositionOperate();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::CheckPositionClose(void)
  {
   for(int i=0;i<3;i++)
     {
      CGridBaseOperate *s=&child_strategy[i];
      CTrendHedgeOperate *s_trend=&hedge_strategy[i];

      if(s.pos_state.num_buy>0 && s.pos_state.profits_buy/s.pos_state.lots_buy>100)
        {
         Print(s.ExpertSymbol(),"进行多头网格策略平仓");
         s.CloseLongPosition();
         Print(s_trend.ExpertSymbol(),"进行空头趋势对冲策略平仓");
         s_trend.CloseShortPosition();
        }
      if(s.pos_state.num_sell>0 && s.pos_state.profits_sell/s.pos_state.lots_sell>100)
        {
         Print(s.ExpertSymbol(),"进行空头网格策略平仓");
         s.CloseShortPosition();
         Print(s_trend.ExpertSymbol(),"进行多头趋势对冲策略平仓");
         s_trend.CloseLongPosition();
        }
      RefreshPositionState();
      if(s.pos_state.num_sell==0 || (s_trend.IsDown() && s_trend.pos_state.num_buy>0)) s_trend.CloseLongPosition();
      if(s.pos_state.num_buy==0 || (s_trend.IsUp() && s_trend.pos_state.num_sell>0)) s_trend.CloseShortPosition();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::CheckPositionOpen(void)
  {
   PositionOpenDefault();
//PositionOpenByRiskControl();
//PositionOpenByRiskControlAndIndicatorControl();
   RefreshPositionState();
//PositionOpenByHedgeStrategy();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::PositionOperate(void)
  {
   int num_eur_long,num_eur_short;
   int num_gbp_long,num_gbp_short;
   num_eur_long=child_strategy[0].pos_state.num_buy+child_strategy[1].pos_state.num_buy;
   num_eur_short=child_strategy[0].pos_state.num_sell+child_strategy[1].pos_state.num_sell;
   num_gbp_long=child_strategy[0].pos_state.num_sell+child_strategy[2].pos_state.num_buy;
   num_gbp_short=child_strategy[0].pos_state.num_buy+child_strategy[2].pos_state.num_sell;
   
   CGridBaseOperate *s=&child_strategy[0];
   if(s.pos_state.num_buy==0) s.BuildLongPositionWithTP(500);
   if(s.pos_state.num_sell==0) s.BuildShortPositionWithTP(500);
   if(s.pos_state.num_buy>0 && s.DistanceAtLastBuyPrice()>300) s.BuildLongPositionWithTP(500);
   if(s.pos_state.num_sell>0 && s.DistanceAtLastSellPrice()>300) s.BuildShortPositionWithTP(500);
   
   RefreshPositionState();
   
   s=&child_strategy[1];
   if(s.pos_state.num_buy==0&&num_eur_short>num_eur_long+2) s.BuildLongPositionWithTP(500);
   if(s.pos_state.num_sell==0&&num_eur_long>num_eur_short+2) s.BuildShortPositionWithTP(500);
   if(s.pos_state.num_buy>0 && ((s.DistanceAtLastBuyPrice()>300&&num_eur_short>num_eur_long+2)||(s.DistanceAtLastBuyPrice()>800))) s.BuildLongPositionWithTP(500);
   if(s.pos_state.num_sell>0 && ((s.DistanceAtLastSellPrice()>300&&num_eur_long>num_eur_short+2)||(s.DistanceAtLastSellPrice()>800))) s.BuildShortPositionWithTP(500); 
    
   RefreshPositionState();
   s=&child_strategy[2];
   if(s.pos_state.num_buy==0&&num_gbp_short>num_gbp_long+2) s.BuildLongPositionDefault();
   if(s.pos_state.num_sell==0&&num_gbp_long>num_gbp_short+2) s.BuildShortPositionDefault();
   if(s.pos_state.num_buy>0 && ((s.DistanceAtLastBuyPrice()>300&&num_gbp_short>num_gbp_long+2)||(s.DistanceAtLastBuyPrice()>800))) s.BuildLongPositionWithTP(500);
   if(s.pos_state.num_sell>0 && ((s.DistanceAtLastSellPrice()>300&&num_gbp_long>num_gbp_short+2)||(s.DistanceAtLastSellPrice()>800))) s.BuildShortPositionWithTP(500);  
   

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::PositionOpenDefault(void)
  {
   for(int i=0;i<3;i++)
     {
      CGridBaseOperate *s=&child_strategy[i];
      if(s.pos_state.num_buy==0) s.BuildLongPositionDefault();
      if(s.pos_state.num_sell==0) s.BuildShortPositionDefault();
      if(s.pos_state.num_buy>0 && s.DistanceAtLastBuyPrice()>300) s.BuildLongPositionDefault();
      if(s.pos_state.num_sell>0 && s.DistanceAtLastSellPrice()>300) s.BuildShortPositionDefault();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::PositionOpenByRiskControl(void)
  {
   for(int i=0;i<3;i++)
     {
      CGridBaseOperate *s=&child_strategy[i];
      //if(s.pos_state.num_buy>0 && s.DistanceAtLastBuyPrice()>300) s.BuildLongPositionDefault();
      //if(s.pos_state.num_sell>0 && s.DistanceAtLastSellPrice()>300) s.BuildShortPositionDefault();
      if(s.pos_state.num_buy>0 && s.DistanceAtLastBuyPrice()>grid_add_points[i]) s.BuildLongPositionDefault();
      if(s.pos_state.num_sell>0 && s.DistanceAtLastSellPrice()>grid_add_points[i]) s.BuildShortPositionDefault();
     }

   CGridBaseOperate *s_cross=&child_strategy[0];
   CGridBaseOperate *s_x=&child_strategy[1];
   CGridBaseOperate *s_y=&child_strategy[2];

   if(s_cross.pos_state.num_buy==0) s_cross.BuildLongPositionDefault();
   if(s_cross.pos_state.num_sell==0) s_cross.BuildShortPositionDefault();

   RefreshPositionState();
   if(s_cross.pos_state.num_buy>s_cross.pos_state.num_sell+1)
     {
      if(s_y.pos_state.num_buy==0) s_y.BuildLongPositionDefault();
      if(s_x.pos_state.num_sell==0) s_x.BuildShortPositionDefault();
     }
   else if(s_cross.pos_state.num_buy<s_cross.pos_state.num_sell-1)
     {
      if(s_x.pos_state.num_buy==0) s_x.BuildLongPositionDefault();
      if(s_y.pos_state.num_sell==0) s_y.BuildShortPositionDefault();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::PositionOpenByRiskControlAndIndicatorControl(void)
  {
   for(int i=0;i<3;i++)
     {
      CGridBaseOperate *s=&child_strategy[i];
      if(s.pos_state.num_buy>0 && s.DistanceAtLastBuyPrice()>300 && s.PositionAddLongCondition()) s.BuildLongPositionDefault();
      if(s.pos_state.num_sell>0 && s.DistanceAtLastSellPrice()>300 && s.PositionAddShortCondition()) s.BuildShortPositionDefault();
     }

   CGridBaseOperate *s_cross=&child_strategy[0];
   CGridBaseOperate *s_x=&child_strategy[1];
   CGridBaseOperate *s_y=&child_strategy[2];

   if(s_cross.pos_state.num_buy==0) s_cross.BuildLongPositionDefault();
   if(s_cross.pos_state.num_sell==0) s_cross.BuildShortPositionDefault();

   RefreshPositionState();
   if(s_cross.pos_state.num_buy>s_cross.pos_state.num_sell+1)
     {
      if(s_y.pos_state.num_buy==0) s_y.BuildLongPositionDefault();
      if(s_x.pos_state.num_sell==0) s_x.BuildShortPositionDefault();
     }
   else if(s_cross.pos_state.num_buy<s_cross.pos_state.num_sell-1)
     {
      if(s_x.pos_state.num_buy==0) s_x.BuildLongPositionDefault();
      if(s_y.pos_state.num_sell==0) s_y.BuildShortPositionDefault();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::PositionOpenByHedgeStrategy(void)
  {
   for(int i=0;i<3;i++)
     {
      CGridBaseOperate *s_grid_child=&child_strategy[i];
      CTrendHedgeOperate *s_hedge=&hedge_strategy[i];
      if(s_grid_child.pos_state.num_buy-s_grid_child.pos_state.num_sell>2 && s_hedge.IsDown() && s_hedge.pos_state.num_sell==0)
        {
         s_hedge.OpenShortPosition(NormalizeDouble((s_grid_child.pos_state.lots_buy-s_grid_child.pos_state.lots_sell)/2,2));
        }
      if(s_grid_child.pos_state.num_sell-s_grid_child.pos_state.num_buy>2 && s_hedge.IsUp() && s_hedge.pos_state.num_buy==0)
        {
         s_hedge.OpenLongPosition(NormalizeDouble((s_grid_child.pos_state.lots_sell-s_grid_child.pos_state.lots_buy)/2,2));
        }
     }
  }
//+------------------------------------------------------------------+
