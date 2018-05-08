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
class CStrategyCombinationRSI:public CStrategtCombination
  {
private:
   int               handle_combination;
   double            rsi_up;
   double            rsi_down;
   int               win_points;
   double            lots_base;
   
   double indicator_value[];

   string symbols_name[];
   double symbols_coef[];
public:
                     CStrategyCombinationRSI(void){};
                    ~CStrategyCombinationRSI(void){};
   void InitStrategy(int indicator_period, double indicator_up,double indicator_down, double &indicator_coef[], int win_points_out, int per_lots);
   virtual bool      CloseLongCondition(void);
   virtual bool      CloseShortCondition(void);
   virtual bool      OpenLongCondition(void);
   virtual bool      OpenShortCondition(void);
   virtual void      OnEvent(const MarketEvent &event);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategyCombinationRSI::InitStrategy(int indicator_period, double indicator_up,double indicator_down, double &indicator_coef[], int win_points_out, int per_lots)
   {
    handle_combination=iCustom(ExpertSymbol(),Timeframe(),"MyIndicators\\CZJIndicators\\SymbolCombinationRSI",
                              indicator_period,
                              indicator_coef[0],
                              indicator_coef[1],
                              indicator_coef[2],
                              indicator_coef[3],
                              indicator_coef[4],
                              indicator_coef[5],
                              indicator_coef[6]);
   win_points=win_points_out;
   lots_base=per_lots;
   rsi_up=indicator_up;
   rsi_down=indicator_down;
   
   string symbols_[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
   ArrayCopy(symbols_name,symbols_);
   ArrayCopy(symbols_coef,indicator_coef);
   }
void CStrategyCombinationRSI::OnEvent(const MarketEvent &event)
   {
    if(event.type==MARKET_EVENT_TICK)
      {
       RefreshPositionState();
       
       if(CloseLongCondition()) CloseLongPosition();
       if(CloseShortCondition()) CloseShortPosition();
       
       RefreshPositionState();
       
       CopyBuffer(handle_combination,0,0,2,indicator_value);
      
       if(OpenLongCondition()) OpenLongPosition(symbols_name,symbols_coef,lots_base);
       if(OpenShortCondition()) OpenShortPosition(symbols_name,symbols_coef,lots_base);
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategyCombinationRSI::OpenLongCondition(void)
  {
   if(long_position_id.Total()>0) return false;
   if(indicator_value[0]<rsi_down) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategyCombinationRSI::OpenShortCondition(void)
  {
   if(short_position_id.Total()>0) return false;
   if(indicator_value[0]>rsi_up) return true;
   return false;
  }
bool CStrategyCombinationRSI::CloseLongCondition(void)
   {
    if(long_position_id.Total()==0) return false;
    if(pos_state.profits_buy/pos_state.lots_buy>win_points) return true;
    if(indicator_value[0]>rsi_up) return true;
    return false;
   }
bool CStrategyCombinationRSI::CloseShortCondition(void)
   {
    if(short_position_id.Total()==0) return false;
    if(pos_state.profits_sell/pos_state.lots_sell>win_points) return true;
    if(indicator_value[0]<rsi_down) return true;
    return false;
   }
//+------------------------------------------------------------------+
