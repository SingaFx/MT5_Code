//+------------------------------------------------------------------+
//|                                      GridThreeSymbolsControl.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridBaseOperate.mqh"
#include <Math\Alglib\matrix.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridThreeSymbolsControl:public CStrategy
  {
private:
   string            currencies[3];
   string            symbols[3];
   CMatrixDouble     symbol_lots; // 上三角存储多单手数，下三角存储空单手数
   double            currency_risk[3];   // 存储每个币种的风险(多单手数-空单手数)
   CGridBaseOperate  grid_operator[3];   // 子策略
   int               grid_index;
   int               grid_add;
   int               long_risk_index;
   int               short_risk_index;
   bool              hedge_enable;
protected:
   void              RefreshState();  // 刷新状态信息 
   void              CheckPositionOpen();
   double            CalLotsFun(int num,int num_total,double base_lots); // 计算pos num_total为1手时，num对应的手数；
   void              GridOperate();
   void              HedgeOperate();
   bool              HedgeSymbolOperate(int hedge_long_index,int hedge_short_index,int &r_counter);  // 根据给定的货币需要对冲的多空进行操作
public:
                     CGridThreeSymbolsControl(void){};
                    ~CGridThreeSymbolsControl(void){};
   void              SetCurrencies(string c1,string c2,string c3);
   void              SetHedgeAllowed(bool is_hedge){hedge_enable=is_hedge;};
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbolsControl::SetCurrencies(string c1,string c2,string c3)
  {
   currencies[0]=c1;
   currencies[1]=c2;
   currencies[2]=c3;
   symbols[0]=c1+c2;
   symbols[1]=c1+c3;
   symbols[2]=c2+c3;
   symbol_lots.Resize(3,3);
   for(int i=0;i<3;i++)
     {
      grid_operator[i].ExpertSymbol(symbols[i]);
      grid_operator[i].ExpertMagic(ExpertMagic()+i);
      grid_operator[i].Init();
     }
   grid_index=0;
   grid_add=250;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbolsControl::RefreshState(void)
  {
   for(int i=0;i<3;i++)
     {
      grid_operator[i].RefreshTickPrice();
      grid_operator[i].RefreshPositionState();
     }
   symbol_lots[0].Set(1,grid_operator[0].pos_state.lots_buy);
   symbol_lots[0].Set(2,grid_operator[1].pos_state.lots_buy);
   symbol_lots[1].Set(2,grid_operator[2].pos_state.lots_buy);
   symbol_lots[1].Set(0,grid_operator[0].pos_state.lots_sell);
   symbol_lots[2].Set(0,grid_operator[1].pos_state.lots_sell);
   symbol_lots[2].Set(1,grid_operator[2].pos_state.lots_sell);
   currency_risk[0]=symbol_lots[0][1]+symbol_lots[0][2]-symbol_lots[1][0]-symbol_lots[2][0];
   currency_risk[1]=symbol_lots[1][0]+symbol_lots[1][2]-symbol_lots[0][1]-symbol_lots[2][1];
   currency_risk[2]=symbol_lots[2][0]+symbol_lots[2][1]-symbol_lots[0][2]-symbol_lots[1][2];
   long_risk_index=ArrayMaximum(currency_risk);
   short_risk_index=ArrayMinimum(currency_risk);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridThreeSymbolsControl::CalLotsFun(int num,int num_total,double base_lots)
  {
   double beta=MathLog(100)/(num_total-1);
   double alpha=1/MathExp(beta);
   return NormalizeDouble(base_lots*alpha*exp(beta*num),2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbolsControl::GridOperate(void)
  {
   if(grid_operator[grid_index].pos_state.num_buy==0)
     {
      grid_operator[grid_index].BuildLongPositionWithCostTP(200,0.01);
     }
   else if(grid_operator[grid_index].DistanceAtLastBuyPrice()>grid_add)
     {
      double open_lots=CalLotsFun(grid_operator[grid_index].pos_state.num_buy+1,12,0.01);
      grid_operator[grid_index].BuildLongPositionWithCostTP(200,open_lots);
     }
   if(grid_operator[grid_index].pos_state.num_sell==0)
     {
      grid_operator[grid_index].BuildShortPositionWithCostTP(200,0.01);
     }
   else if(grid_operator[grid_index].DistanceAtLastSellPrice()>grid_add)
     {
      double open_lots=CalLotsFun(grid_operator[grid_index].pos_state.num_sell+1,12,0.01);
      grid_operator[grid_index].BuildShortPositionWithCostTP(200,open_lots);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CGridThreeSymbolsControl::HedgeOperate(void)
  {
   for(int i=0;i<3;i++)
     {
      if(currency_risk[i]<-0.1) // 空头风险
        {
         Print("空头Risk货币:",currencies[i],"->",currency_risk[i]);
         for(int j=0;j<3;j++)
           {
            if(i==j) continue;
            if(currency_risk[j]<-0.1) continue;
            int real_counter=0;
            Print("空头Risk货币:",currencies[i],"->",currency_risk[i],",对冲货币:",currencies[j],"->",currency_risk[j]);
            HedgeSymbolOperate(j,i,real_counter);
            RefreshState();
           }
        }
      else if(currency_risk[i]>0.1)
        {
         Print("多头Risk货币:",currencies[i],"->",currency_risk[i]);
         for(int j=0;j<3;j++)
           {
            if(i==j) continue;
            if(currency_risk[j]>0.1) continue;
            int real_counter=0;
            Print("多头Risk货币:",currencies[i],"->",currency_risk[i],",对冲货币:",currencies[j],"->",currency_risk[j]);
            HedgeSymbolOperate(i,j,real_counter);
            RefreshState();
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridThreeSymbolsControl::HedgeSymbolOperate(int hedge_long_index,int hedge_short_index,int &r_counter)
  {
   if(hedge_long_index==hedge_short_index) return false;
   int sym_index;
   r_counter=0;
   if(hedge_long_index<hedge_short_index) // currency[hedge_long_index]~currency[hedge_short_index] 做空对冲
     {
      Print("做空货币对:",currencies[hedge_long_index],currencies[hedge_short_index]);

      sym_index=(5-hedge_long_index)*hedge_long_index/2+hedge_short_index-hedge_long_index-1;

      if(sym_index==grid_index) return false;
      if(grid_operator[sym_index].pos_state.num_sell==0) // 对冲品种对未有空头仓位
        {
         if(grid_operator[sym_index].BuildShortPositionWithCostTP(200,0.01))
           {
            r_counter=1;
            return true;
           }
        }
      else if(grid_operator[sym_index].DistanceAtLastSellPrice()>200)
        {
         double c_lots=CalLotsFun(grid_operator[sym_index].pos_state.num_sell+1,12,0.01);
         if(grid_operator[sym_index].BuildShortPositionWithCostTP(200,c_lots))
           {
            r_counter=int(c_lots/0.01);
            return true;
           }
        }
     }
   else // currency[hedge_short_index]~currency[hedge_long_index] 做多对冲
     {
      sym_index=(5-hedge_short_index)*hedge_short_index/2+hedge_long_index-hedge_short_index-1;
      Print("做多货币对:",currencies[hedge_short_index],currencies[hedge_long_index]);
      if(sym_index==grid_index) return false;
      if(grid_operator[sym_index].pos_state.num_buy==0) // 对冲品种对未有多头仓位
        {
         if(grid_operator[sym_index].BuildLongPositionWithCostTP(200,0.01))
           {
            r_counter=1;
            return true;
           }
        }
      else if(grid_operator[sym_index].DistanceAtLastBuyPrice()>200)
        {
         double c_lots=CalLotsFun(grid_operator[sym_index].pos_state.num_buy+1,12,0.01);
         if(grid_operator[sym_index].BuildLongPositionWithCostTP(200,c_lots))
           {
            r_counter=int(c_lots/0.01);
            return true;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbolsControl::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      RefreshState();
      GridOperate();
      if(hedge_enable)
        {
         RefreshState();
         HedgeOperate();
        }
     }
  }
//+------------------------------------------------------------------+
