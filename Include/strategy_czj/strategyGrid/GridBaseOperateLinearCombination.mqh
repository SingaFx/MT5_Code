//+------------------------------------------------------------------+
//|                             GridBaseOperateLinearCombination.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridBaseOperateLinearCombination:public CStrategy
  {
private:
   int               num_symbols;   // 线性组合品种对数目
   string            symbols[]; // 线性组合的品种对
   double            alpha[];   // 线性组合的系数
   MqlTick           latest_price[];   // 最新的tick报价
   int               num_pos_max;   // 最大仓位数
   double            symbol_points[];  // 品种的最小点位
   double            base_lots;   // 基础手数
   
   CArrayObj         long_pos_id;  // 多头仓位组合
   CArrayObj         short_pos_id; // 空头仓位组合
   double            last_open_long_price;  // 上一次做多的价格
   double            last_open_short_price; // 上一次做空的价格
   double            current_compare_long_price;   // 用于比较是否加多仓的当前价格
   double            current_compare_short_price;   // 用于比较是否加空仓的当前价格
   double            current_add_long_price;   // 开多仓的当前价格
   double            current_add_short_price;   // 开空仓的当前价格


public:
   PositionInfor     pos_state;   // 仓位信息
public:
                     CGridBaseOperateLinearCombination(void){};
                    ~CGridBaseOperateLinearCombination(void){};
   void              Init(const string &sym[], const double &al[]);     
   void              SetPosMax(int p_max){num_pos_max=p_max;};  
   void              SetBaseLots(double l){base_lots=l;};             
   void              RefreshTickPrice();   // 刷新最新报价,计算线性组合的报价
   void              RefreshPositionState();  // 刷新仓位信息
   void              BuildLongPosition();  // 多头建仓
   void              BuildShortPosition();  // 空头建仓
   void              CloseLongPosition(); // 平多头操作
   void              CloseShortPosition();   // 平空头操作
   double            DistanceAtLastSellPrice(){return(current_compare_short_price-last_open_short_price);}; // 和上次卖价比，又上升的点数
   double            DistanceAtLastBuyPrice(){return(last_open_long_price-current_compare_long_price);}; // 和上次买价比，又下跌的点数
   double            CalLotsDefault(int num_pos); // 计算第num_pos个仓位对应的手数
  };
void CGridBaseOperateLinearCombination::Init(const string &sym[],const double &al[])
   {
    num_symbols=ArraySize(sym);
    ArrayCopy(symbols,sym);
    ArrayCopy(alpha,al);
    ArrayResize(latest_price,num_symbols);
    ArrayResize(symbol_points,num_symbols);
    for(int i=0;i<num_symbols;i++)
      {
       if(symbols[i]=="XAUUSD")
         {
          symbol_points[i]=0.01;
         }
       else
         symbol_points[i]=SymbolInfoDouble(symbols[i],SYMBOL_POINT);
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseOperateLinearCombination::RefreshTickPrice(void)
  {
   current_add_long_price=0;
   current_add_short_price=0;
   current_compare_long_price=0;
   current_compare_short_price=0;
   for(int i=0;i<num_symbols;i++)
     {
      SymbolInfoTick(symbols[i],latest_price[i]);
      if(alpha[i]>0)
        {
         current_add_long_price+=latest_price[i].ask/symbol_points[i]*alpha[i];
         current_add_short_price+=latest_price[i].bid/symbol_points[i]*alpha[i];
         current_compare_long_price+=latest_price[i].bid/symbol_points[i]*alpha[i];
         current_compare_short_price+=latest_price[i].ask/symbol_points[i]*alpha[i];
        }
      else
        {
         current_add_long_price+=latest_price[i].bid/symbol_points[i]*alpha[i];
         current_add_short_price+=latest_price[i].ask/symbol_points[i]*alpha[i];
         current_compare_long_price+=latest_price[i].ask/symbol_points[i]*alpha[i];
         current_compare_short_price+=latest_price[i].bid/symbol_points[i]*alpha[i];
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseOperateLinearCombination::RefreshPositionState(void)
  {
   pos_state.Init();
   for(int i=0;i<long_pos_id.Total();i++)
     {
      CArrayLong *p_id=long_pos_id.At(i);
      for(int j=0;j<p_id.Total();j++)
        {
         PositionSelectByTicket(p_id.At(j));
         pos_state.profits_buy+=PositionGetDouble(POSITION_PROFIT);
        }
     }
   for(int i=0;i<short_pos_id.Total();i++)
     {
      CArrayLong *p_id=short_pos_id.At(i);
      for(int j=0;j<p_id.Total();j++)
        {
         PositionSelectByTicket(p_id.At(j));
         pos_state.profits_sell+=PositionGetDouble(POSITION_PROFIT);
        }
     }
   pos_state.num_buy=long_pos_id.Total();
   pos_state.num_sell=short_pos_id.Total();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseOperateLinearCombination::BuildLongPosition(void)
  {
   double l=CalLotsDefault(pos_state.num_buy+1)*base_lots;
   double l_sym;
   bool trade_res;
   CArrayLong *new_long_id=new CArrayLong();
   for(int i=0;i<num_symbols;i++)
     {
      if(alpha[i]>0)
        {
         l_sym=NormalizeDouble(l*alpha[i],2);
         trade_res=Trade.PositionOpen(symbols[i],ORDER_TYPE_BUY,l_sym,latest_price[i].ask,0,0,"Long-"+string(pos_state.num_buy+1));
        }
      else
        {
         l_sym=NormalizeDouble(-l*alpha[i],2);
         trade_res=Trade.PositionOpen(symbols[i],ORDER_TYPE_SELL,l_sym,latest_price[i].bid,0,0,"Long-"+string(pos_state.num_buy+1));
        }
      if(trade_res)
        {
         Print("多头第"+string(pos_state.num_buy)+"次开仓成功:"+symbols[i]);
         new_long_id.Add(Trade.ResultOrder());
        }
      else Print("多头第"+string(pos_state.num_buy)+"次开仓失败:"+symbols[i],"reason:",Trade.ResultRetcode());
     }
   long_pos_id.Add(new_long_id);
   last_open_long_price=current_add_long_price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseOperateLinearCombination::BuildShortPosition(void)
  {
   double l=CalLotsDefault(pos_state.num_sell+1)*base_lots;
   double l_sym;
   bool trade_res;
   CArrayLong *new_short_id=new CArrayLong();
   for(int i=0;i<num_symbols;i++)
     {
      if(alpha[i]>0)
        {
         l_sym=NormalizeDouble(l*alpha[i],2);
         trade_res=Trade.PositionOpen(symbols[i],ORDER_TYPE_SELL,l_sym,latest_price[i].bid,0,0,"Short-"+string(pos_state.num_sell+1));
        }
      else
        {
         l_sym=NormalizeDouble(-l*alpha[i],2);
         trade_res=Trade.PositionOpen(symbols[i],ORDER_TYPE_BUY,l_sym,latest_price[i].ask,0,0,"Short-"+string(pos_state.num_sell+1));
        }
      if(trade_res)
        {
         Print("空头第"+string(pos_state.num_sell)+"次开仓成功:"+symbols[i]);
         new_short_id.Add(Trade.ResultOrder());
        }
      else Print("空头第"+string(pos_state.num_sell)+"次开仓失败:"+symbols[i],"reason:",Trade.ResultRetcode());
     }
   short_pos_id.Add(new_short_id);
   last_open_short_price=current_add_short_price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseOperateLinearCombination::CloseLongPosition(void)
  {
   for(int i=0;i<long_pos_id.Total();i++)
     {
      CArrayLong *p_id=long_pos_id.At(i);
      for(int j=0;j<p_id.Total();j++)
        {
         Trade.PositionClose(p_id.At(j));
        }
      p_id.Clear();
     }
   long_pos_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseOperateLinearCombination::CloseShortPosition(void)
  {
   for(int i=0;i<short_pos_id.Total();i++)
     {
      CArrayLong *p_id=short_pos_id.At(i);
      for(int j=0;j<p_id.Total();j++)
        {
         Trade.PositionClose(p_id.At(j));
        }
      p_id.Clear();
     }
   short_pos_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridBaseOperateLinearCombination::CalLotsDefault(int num_pos)
  {
   double beta_exp=MathLog(100)/(num_pos_max-1);
   double alpha_exp=1/MathExp(beta_exp);
   return NormalizeDouble(alpha_exp*exp(beta_exp*num_pos),2);
   //return 0.1;
  }
//+------------------------------------------------------------------+
