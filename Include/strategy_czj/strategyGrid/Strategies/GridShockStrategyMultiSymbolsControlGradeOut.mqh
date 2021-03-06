//+------------------------------------------------------------------+
//|                 GridShockStrategyMultiSymbolsControlGradeOut.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "震荡网格--分级出场(多品种风险控制)"
#property description "分级出场:每次检测最后和最早的仓位组合是否满足止盈出场条件"
#property description "多品种风险控制:根据风险情况，改变网格距离，改变TP"

#include <strategy_czj\strategyGrid\Strategies\GridShockStrategyGradeOut.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridShockStrategyMultiSymbolsControlGradeOut:public CStrategy
  {
protected:
   int               sym_total;  // 品种数
   string            syms[]; // 品种
   int               grid_base_gap; // 标准网格大小
   double            grid_tp_per_lots; // 标准每手止盈
   double            grid_tp_total; // 标准总止盈
   CGridShockStrategyGradeOut grid_operator[]; // 分级出场网格策略数组

   double            currencies_risk[8];
   double            sym_risk[];
   int               c_index[][2];
private:
   int               SwitchCIndex(string str_c);
   bool              HasLongRiskAtSymbol(int index);
   bool              HasShortRiskAtSymbol(int index);
protected:
   void              RefreshTickPriceAndPositionState();  // 刷新tick报价和仓位信息
   void              RefreshStrategyState(); // 刷新策略信息
   void              CheckPositionClose();   // 检测平仓
   void              CheckPositionOpen(); // 检测开仓
   void              RiskControl(); // 风险控制操作 
   virtual void      OnEvent(const MarketEvent &event);
public:
                     CGridShockStrategyMultiSymbolsControlGradeOut(void);
                    ~CGridShockStrategyMultiSymbolsControlGradeOut(void){};
   void              SetSymbols(const string &syms_[]);
   void              SetLotsParameter(double lots_,GridLotsCalType lots_type_,int pos_max);
   void              SetGridParameter(int gap_grid,double per_lots_tp,double total_tp);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGridShockStrategyMultiSymbolsControlGradeOut::CGridShockStrategyMultiSymbolsControlGradeOut(void)
  {
   //SetSymbols(SYMBOLS_28);
   //SetLotsParameter(0.01,ENUM_GRID_LOTS_LINEAR,15);
   //SetGridParameter(150,600,6);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyMultiSymbolsControlGradeOut::SetSymbols(const string &syms_[])
  {
   sym_total=ArrayCopy(syms,syms_);
   ArrayResize(grid_operator,sym_total);
   ArrayResize(c_index,sym_total);
   ArrayResize(sym_risk,sym_total);
   for(int i=0;i<sym_total;i++)
     {
      grid_operator[i].ExpertName(ExpertName()+"-"+syms[i]);
      grid_operator[i].ExpertSymbol(syms[i]);
      grid_operator[i].ExpertMagic(ExpertMagic()+i);

      string x=StringSubstr(syms[i],0,3);
      string y=StringSubstr(syms[i],3,3);
      c_index[i][0]=SwitchCIndex(x);
      c_index[i][1]=SwitchCIndex(y);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyMultiSymbolsControlGradeOut::SetLotsParameter(double lots_,GridLotsCalType lots_type_,int pos_max)
  {
   for(int i=0;i<sym_total;i++) grid_operator[i].SetLotsParameter(lots_,lots_type_,pos_max);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyMultiSymbolsControlGradeOut::SetGridParameter(int gap_grid,double per_lots_tp,double total_tp)
  {
   grid_base_gap=gap_grid;
   grid_tp_per_lots=per_lots_tp;
   grid_tp_total=total_tp;
   for(int i=0;i<sym_total;i++) grid_operator[i].SetGridParameter(gap_grid,per_lots_tp,total_tp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGridShockStrategyMultiSymbolsControlGradeOut::SwitchCIndex(string str_c)
  {
   if(str_c=="EUR") return 0;
   if(str_c=="GBP") return 1;
   if(str_c=="AUD") return 2;
   if(str_c=="NZD") return 3;
   if(str_c=="USD") return 4;
   if(str_c=="CAD") return 5;
   if(str_c=="CHF") return 6;
   return 7;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyMultiSymbolsControlGradeOut::RefreshTickPriceAndPositionState(void)
  {
   for(int i=0;i<sym_total;i++)
     {
      grid_operator[i].RefreshTickPrice();
      grid_operator[i].RefreshPositionState();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyMultiSymbolsControlGradeOut::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      RefreshTickPriceAndPositionState();
      CheckPositionClose();
      RefreshStrategyState();
      RiskControl();
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyMultiSymbolsControlGradeOut::CheckPositionClose(void)
  {
   for(int i=0;i<sym_total;i++) 
      {
       grid_operator[i].ShortPositionCloseCheck();
       grid_operator[i].LongPositionCloseCheck();
      }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyMultiSymbolsControlGradeOut::CheckPositionOpen(void)
  {
//for(int i=0;i<sym_total;i++) grid_operator[i].CheckPositionOpen();
   RefreshStrategyState();
   RiskControl();
   for(int i=0;i<sym_total;i++)
     {
      if(!HasLongRiskAtSymbol(i))
        {
         grid_operator[i].CheckLongPositionOpen();
         RefreshStrategyState();
         RiskControl();
        }
      if(!HasShortRiskAtSymbol(i))
        {
         grid_operator[i].CheckShortPositionOpen();
         RefreshStrategyState();
         RiskControl();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyMultiSymbolsControlGradeOut::RefreshStrategyState(void)
  {
   ArrayInitialize(currencies_risk,0.0);
   for(int i=0;i<sym_total;i++)
     {
      currencies_risk[c_index[i][0]]+=grid_operator[i].pos_state.GetLotsBuyToSell();
      currencies_risk[c_index[i][1]]-=grid_operator[i].pos_state.GetLotsBuyToSell();
     }
   for(int i=0;i<sym_total;i++)
     {
      double risk_left=currencies_risk[c_index[i][0]]==0?0:grid_operator[i].pos_state.GetLotsBuyToSell()/currencies_risk[c_index[i][0]];
      double risk_right=currencies_risk[c_index[i][1]]==0?0:-grid_operator[i].pos_state.GetLotsBuyToSell()/currencies_risk[c_index[i][1]];
      sym_risk[i]=(risk_left+risk_right)/2;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyMultiSymbolsControlGradeOut::RiskControl(void)
  {
   for(int i=0;i<sym_total;i++)
     {
      if(HasLongRiskAtSymbol(i))
        {
         //grid_operator[i].SetGridGapBuy(grid_base_gap*2);
         grid_operator[i].SetGridGapSell(grid_base_gap/2);
         //grid_operator[i].SetBuyTP(grid_tp_total/2,grid_tp_per_lots/2);
         //grid_operator[i].SetSellTP(grid_tp_total*2,grid_tp_per_lots*2);
         //grid_operator[i].SetBaseSellLots(MathMin(0.1,grid_operator[i].pos_state.lots_buy/2));
         //Print("风险管控:多头风险",syms[i],"/",sym_risk[i],", x risk:",currencies_risk[c_index[i][0]],", y risk:",currencies_risk[c_index[i][1]]);
        }
      else if(HasShortRiskAtSymbol(i))
        {
         grid_operator[i].SetGridGapBuy(grid_base_gap/2);
         //grid_operator[i].SetGridGapSell(grid_base_gap*2);
         //grid_operator[i].SetBuyTP(grid_tp_total*2,grid_tp_per_lots*2);
         //grid_operator[i].SetSellTP(grid_tp_total/2,grid_tp_per_lots/2);
         //grid_operator[i].SetBaseBuyLots(MathMin(0.1,grid_operator[i].pos_state.lots_sell/2));
         //Print("风险管控:空头风险",syms[i],"/",sym_risk[i],", x risk:",currencies_risk[c_index[i][0]],", y risk:",currencies_risk[c_index[i][1]]);
        }
      else
        {
         grid_operator[i].SetGridGapBuy(grid_base_gap);
         grid_operator[i].SetGridGapSell(grid_base_gap);
         grid_operator[i].SetBuyTP(grid_tp_total,grid_tp_per_lots);
         grid_operator[i].SetSellTP(grid_tp_total,grid_tp_per_lots);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridShockStrategyMultiSymbolsControlGradeOut::HasLongRiskAtSymbol(int index)
  {
   if(currencies_risk[c_index[index][0]]>0.5||currencies_risk[c_index[index][1]]<-0.5) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridShockStrategyMultiSymbolsControlGradeOut::HasShortRiskAtSymbol(int index)
  {
   if(currencies_risk[c_index[index][0]]<-0.5||currencies_risk[c_index[index][1]]>0.5) return true;
   return false;
  }
//+------------------------------------------------------------------+
