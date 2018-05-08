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
class CStrategyCombinationRSIAdd:public CStrategtCombination
  {
private:
   int               handle_combination;
   double            rsi_up;
   double            rsi_down;
   int               win_points;
   double            lots_base;
   
   double         add_ratio;
   double         add_points;
   int long_num;
   int short_num;
   
   double indicator_value[];
   double price_value[];
   double last_price_long;
   double last_price_short;
   double last_long_lots;
   double last_short_lots;

   string symbols_name[];
   double symbols_coef[];
public:
                     CStrategyCombinationRSIAdd(void){};
                    ~CStrategyCombinationRSIAdd(void){};
   void InitStrategy(int indicator_period, double indicator_up,double indicator_down, double &indicator_coef[], int win_points_out, double per_lots,double ratio_add=1.5,double points_add=3000);
   virtual bool      CloseLongCondition(void);
   virtual bool      CloseShortCondition(void);
   virtual bool      OpenLongCondition(void);
   virtual bool      OpenShortCondition(void);
   virtual bool      AddLongCondition(void);
   virtual bool      AddShortCondition(void);
   virtual void      OnEvent(const MarketEvent &event);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategyCombinationRSIAdd::InitStrategy(int indicator_period, 
                                         double indicator_up,
                                         double indicator_down, 
                                         double &indicator_coef[], 
                                         int win_points_out, 
                                         double per_lots,
                                         double ratio_add=1.5,
                                         double points_add=3000)
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
   add_ratio=ratio_add;
   add_points=points_add;
   
   string symbols_[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
   ArrayCopy(symbols_name,symbols_);
   ArrayCopy(symbols_coef,indicator_coef);
   }
void CStrategyCombinationRSIAdd::OnEvent(const MarketEvent &event)
   {
    if(event.type==MARKET_EVENT_TICK)
      {
       RefreshPositionState();
       
       if(CloseLongCondition()) 
         {
          CloseLongPosition();
          long_num=0;
          last_long_lots=lots_base;
         }
         
       if(CloseShortCondition())
         {
          CloseShortPosition();
          short_num=0;
          last_short_lots=lots_base;
         }
       
       RefreshPositionState();
       
       CopyBuffer(handle_combination,0,0,2,indicator_value);
       CopyBuffer(handle_combination,3,0,2,price_value);
      
       if(OpenLongCondition()) 
         {
          last_long_lots=lots_base;
          if(last_short_lots>lots_base)
            {
             last_long_lots=last_short_lots*0.8;
            }
          OpenLongPosition(symbols_name,symbols_coef,last_long_lots);
          long_num++;
          last_price_long=price_value[0];
          last_long_lots=lots_base;
         }
       if(OpenShortCondition())
         {
          last_short_lots=lots_base;
          if(last_long_lots>lots_base)
            {
             last_short_lots=last_long_lots*0.8;
            }
          OpenShortPosition(symbols_name,symbols_coef,last_short_lots);
          short_num++;
          last_price_short=price_value[0];
          last_short_lots=lots_base;
         }
        
       if(AddLongCondition()) 
         {
          last_long_lots*=add_ratio;
          OpenLongPosition(symbols_name,symbols_coef,last_long_lots);
          long_num++;
          last_price_long=price_value[0];
         }
       if(AddShortCondition())
         {
          last_short_lots*=lots_base*add_ratio;
          OpenShortPosition(symbols_name,symbols_coef,last_short_lots);
          short_num++;
          last_price_short=price_value[0];
         }
         
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategyCombinationRSIAdd::OpenLongCondition(void)
  {
   if(long_position_id.Total()>0) return false;
   if(indicator_value[0]<rsi_down) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategyCombinationRSIAdd::OpenShortCondition(void)
  {
   if(short_position_id.Total()>0) return false;
   if(indicator_value[0]>rsi_up) return true;
   return false;
  }
bool CStrategyCombinationRSIAdd::CloseLongCondition(void)
   {
    if(long_position_id.Total()==0) return false;
    if(pos_state.profits_buy/pos_state.lots_buy>win_points) return true;
    return false;
   }
bool CStrategyCombinationRSIAdd::CloseShortCondition(void)
   {
    if(short_position_id.Total()==0) return false;
    if(pos_state.profits_sell/pos_state.lots_sell>win_points) return true;
    return false;
   }
bool CStrategyCombinationRSIAdd::AddLongCondition(void)
   {
    if(pos_state.num_buy>0&&indicator_value[0]<rsi_down-1*long_num && (last_price_long-price_value[0])>add_points)
       return true;
    return false;
   }
bool CStrategyCombinationRSIAdd::AddShortCondition(void)
   {
    if(pos_state.num_sell>0&&indicator_value[0]>rsi_up+1*short_num &&(price_value[0]-last_price_short>add_points))
      return true;
    return false;
   }
//+------------------------------------------------------------------+
