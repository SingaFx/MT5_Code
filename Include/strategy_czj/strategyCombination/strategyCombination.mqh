//+------------------------------------------------------------------+
//|                                          strategyCombination.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <strategy_czj\common\strategy_combination.mqh>
//double coef_f1[]={-0.399507059528915,-0.370922865570124,-0.427589364667445,-0.181076685848670,0.503477240176153,0.104966594162066,0.471891501283697};
//double coef_f2[]={0.156120119973915,0.715731392291141,-0.126736008372040,0.117875179050492,0.0299506048976982,-0.178609072735887,0.632929908423311};
//double coef_f3[]={0.327979989020678,-0.516986378765809,0.201814258438518,0.527692590134551,0.0381730990152814,-0.452048047705465,0.316482422036138};
//double coef_f4[]={0.307570633268989,0.146945928345138,-0.249584580981536,-0.171309807453575,0.589245072698589,-0.508662449132625,-0.431532668105931};
//double coef_f5[]={0.743086948081259,-0.204609032796194,-0.395675619296499,-0.273858340231410,-0.188255687857085,0.350251237192899,0.127605689151442};
//double coef_f6[]={0.0337389911317090,0.130386150934774,-0.311275182193609,0.743528195407073,0.254599822340319,0.458321993809418,-0.239279326649219};
//double coef_f7[]={0.246035603007154,0.0491057587483893,0.666807638436350,-0.132957092001832,0.544688365174624,0.401573043778991,0.129610056992029};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStrategyCombinationTest:public CStrategtCombination
  {
private:
   int               handle_combination;
   int               win_points;
   double            lots_base;
   double price_combination[];
   double price_ma[];
   double price_up[];
   double price_down[];
   
   string symbols_name[];
   double symbols_coef[];
public:
                     CStrategyCombinationTest(void);
                    ~CStrategyCombinationTest(void){};
   void InitStrategy(int indicator_period, double indicator_delta, double &indicator_coef[], int win_points_out, int per_lots);
   virtual bool      CloseLongCondition(void);
   virtual bool      CloseShortCondition(void);
   virtual bool      OpenLongCondition(void);
   virtual bool      OpenShortCondition(void);
   virtual void      OnEvent(const MarketEvent &event);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategyCombinationTest::CStrategyCombinationTest(void)
  {
   //double coef_given[]={-0.399507059528915,-0.370922865570124,-0.427589364667445,-0.181076685848670,0.503477240176153,0.104966594162066,0.471891501283697};
   //handle_combination=iCustom(ExpertSymbol(),Timeframe(),"MyIndicators\\CZJIndicators\\SymbolCombination",
   //                           200,
   //                           2.5,
   //                           -0.399507059528915,
   //                           -0.370922865570124,
   //                           -0.427589364667445,
   //                           -0.181076685848670,
   //                           0.503477240176153,
   //                           0.104966594162066,
   //                           0.471891501283697);
   //win_points=100;
   //lots_base=1.0;
   //string symbols_[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
   //ArrayCopy(symbols_name,symbols_);
   //ArrayCopy(symbols_coef,coef_given);
  }
CStrategyCombinationTest::InitStrategy(int indicator_period,double indicator_delta,double &indicator_coef[],int win_points_out,int per_lots)
   {
    handle_combination=iCustom(ExpertSymbol(),Timeframe(),"MyIndicators\\CZJIndicators\\SymbolCombination",
                              indicator_period,
                              indicator_delta,
                              indicator_coef[0],
                              indicator_coef[1],
                              indicator_coef[2],
                              indicator_coef[3],
                              indicator_coef[4],
                              indicator_coef[5],
                              indicator_coef[6]);
   win_points=win_points_out;
   lots_base=per_lots;
   string symbols_[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
   ArrayCopy(symbols_name,symbols_);
   ArrayCopy(symbols_coef,indicator_coef);
   }
void CStrategyCombinationTest::OnEvent(const MarketEvent &event)
   {
    if(event.type==MARKET_EVENT_TICK)
      {
       RefreshPositionState();
       
       if(CloseLongCondition()) CloseLongPosition();
       if(CloseShortCondition()) CloseShortPosition();
       
       RefreshPositionState();
       
       CopyBuffer(handle_combination,0,0,2,price_combination);
       CopyBuffer(handle_combination,1,0,2,price_ma);
       CopyBuffer(handle_combination,2,0,2,price_up);
       CopyBuffer(handle_combination,3,0,2,price_down);
      
       if(OpenLongCondition()) OpenLongPosition(symbols_name,symbols_coef,lots_base);
       if(OpenShortCondition()) OpenShortPosition(symbols_name,symbols_coef,lots_base);
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategyCombinationTest::OpenLongCondition(void)
  {
   if(long_position_id.Total()>0) return false;
   if(price_combination[0]<price_down[0]) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategyCombinationTest::OpenShortCondition(void)
  {
   if(short_position_id.Total()>0) return false;
   if(price_combination[0]>price_up[0]) return true;
   return false;
  }
bool CStrategyCombinationTest::CloseLongCondition(void)
   {
    if(long_position_id.Total()==0) return false;
    if(pos_state.profits_buy/pos_state.lots_buy>win_points) return true;
    if(price_combination[0]>price_up[0]) return true;
    return false;
   }
bool CStrategyCombinationTest::CloseShortCondition(void)
   {
    if(short_position_id.Total()==0) return false;
    if(pos_state.profits_sell/pos_state.lots_sell>win_points) return true;
    if(price_combination[0]<price_down[0]) return true;
    return false;
   }
//+------------------------------------------------------------------+
