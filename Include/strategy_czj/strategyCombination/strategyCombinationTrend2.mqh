//+------------------------------------------------------------------+
//|                                          strategyCombination.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <strategy_czj\common\strategy_combination.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStrategyCombinationTrend:public CStrategtCombination
  {
private:
   int               handle_combination_short;
   int               handle_combination_long;
   int               win_points;
   double            lots_base;
   double price_combination_short[];
   double price_ma_short[];
   double price_up_short[];
   double price_down_short[];
   
   double price_combination_long[];
   double price_ma_long[];
   double price_up_long[];
   double price_down_long[];
   
   string symbols_name[];
   double symbols_coef[];
public:
                     CStrategyCombinationTrend(void);
                    ~CStrategyCombinationTrend(void){};
   void InitStrategy(int indicator_period_short,double indicator_delta_short,int indicator_period_long,double indicator_delta_long,double &indicator_coef[],int win_points_out,int per_lots);
   virtual bool      CloseLongCondition(void);
   virtual bool      CloseShortCondition(void);
   virtual bool      OpenLongCondition(void);
   virtual bool      OpenShortCondition(void);
   virtual void      OnEvent(const MarketEvent &event);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategyCombinationTrend::CStrategyCombinationTrend(void)
  {
  }
CStrategyCombinationTrend::InitStrategy(int indicator_period_short,double indicator_delta_short,int indicator_period_long,double indicator_delta_long,double &indicator_coef[],int win_points_out,int per_lots)
   {
    handle_combination_short=iCustom(ExpertSymbol(),Timeframe(),"MyIndicators\\CZJIndicators\\SymbolCombination",
                              indicator_period_short,
                              indicator_delta_short,
                              indicator_coef[0],
                              indicator_coef[1],
                              indicator_coef[2],
                              indicator_coef[3],
                              indicator_coef[4],
                              indicator_coef[5],
                              indicator_coef[6],
                              false);
   handle_combination_long=iCustom(ExpertSymbol(),Timeframe(),"MyIndicators\\CZJIndicators\\SymbolCombination",
                              indicator_period_long,
                              indicator_delta_long,
                              indicator_coef[0],
                              indicator_coef[1],
                              indicator_coef[2],
                              indicator_coef[3],
                              indicator_coef[4],
                              indicator_coef[5],
                              indicator_coef[6],
                              false); 
   Print("coef:",indicator_coef[0]," ",indicator_coef[1]," ",indicator_coef[6]);
   win_points=win_points_out;
   lots_base=per_lots;
   string symbols_[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
   ArrayCopy(symbols_name,symbols_);
   ArrayCopy(symbols_coef,indicator_coef);
   }
void CStrategyCombinationTrend::OnEvent(const MarketEvent &event)
   {
    if(event.type==MARKET_EVENT_BAR_OPEN)
      {
       RefreshPositionState();
       
       if(CloseLongCondition()) CloseLongPosition();
       if(CloseShortCondition()) CloseShortPosition();
       
       RefreshPositionState();
       
       CopyBuffer(handle_combination_short,0,0,2,price_combination_short);
       CopyBuffer(handle_combination_short,1,0,2,price_ma_short);
       CopyBuffer(handle_combination_short,2,0,2,price_up_short);
       CopyBuffer(handle_combination_short,3,0,2,price_down_short);
       
       CopyBuffer(handle_combination_long,0,0,2,price_combination_long);
       CopyBuffer(handle_combination_long,1,0,2,price_ma_long);
       CopyBuffer(handle_combination_long,2,0,2,price_up_long);
       CopyBuffer(handle_combination_long,3,0,2,price_down_long);
      
      
       if(OpenLongCondition()) OpenLongPosition(symbols_name,symbols_coef,lots_base);
       if(OpenShortCondition()) OpenShortPosition(symbols_name,symbols_coef,lots_base);
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategyCombinationTrend::OpenLongCondition(void)
  {
   if(long_position_id.Total()>0) return false;
   if(price_ma_short[0]>price_ma_long[0]) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategyCombinationTrend::OpenShortCondition(void)
  {
   if(short_position_id.Total()>0) return false;
   if(price_ma_short[0]<price_ma_long[0]) return true;
   return false;
  }
bool CStrategyCombinationTrend::CloseLongCondition(void)
   {
    if(long_position_id.Total()==0) return false;
    if(pos_state.profits_buy/pos_state.lots_buy>win_points) return true;
    if(price_combination_short[0]<price_down_short[0]&&price_combination_long[0]<price_ma_long[0]) return true;
    return false;
   }
bool CStrategyCombinationTrend::CloseShortCondition(void)
   {
    if(short_position_id.Total()==0) return false;
    if(pos_state.profits_sell/pos_state.lots_sell>win_points) return true;
    if(price_combination_short[0]>price_up_short[0]&&price_combination_long[0]>price_ma_long[0]) return true;
    return false;
   }
//+------------------------------------------------------------------+
