//+------------------------------------------------------------------+
//|                                         PositionAndRiskState.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayInt.mqh>
#include <Arrays\ArrayDouble.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum RiskSymbolToCurrency
  {
   ENUM_RISKSTC_DOUBLE_RISK,  // 品种对双重风险
   ENUM_RISKSTC_ONE_RISK,  // 风险大的货币存在风险
   ENUM_RISKSTC_ONE_HEDGE, // 风险大的货币对冲，另一货币风险
   ENUM_RISKSTC_DOUBLE_HEDGE,   // 品种对双重对冲
  };
enum SymbolCloseType
  {
   ENUM_CLOSE_TYPE_0,   // 平仓方式0
   ENUM_CLOSE_TYPE_1   // 平仓方式1
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPositionAndRiskState
  {
private:
   CArrayLong        long_pos_id[28];  // 品种多头仓位ID
   CArrayLong        short_pos_id[28]; // 品种空头仓位ID
   CArrayInt         long_pos_level[28];  // 品种多头仓位等级
   CArrayInt         short_pos_level[28]; // 品种空头仓位等级
   SymbolCloseType   close_type[28];
   CArrayDouble      profits_long[28];
   CArrayDouble      profits_short[28];
   CArrayDouble      lots_long[28];
   CArrayDouble      lots_short[28];

   int               index_s2c_left[28];  // 品种索引对应的左货币索引
   int               index_s2c_right[28]; // 品种索引对应的右货币索引
   //--- 手数
   double            c_risk_long[8];  // 币种 多头手数
   double            c_risk_short[8];  // 币种 空头手数
   double            s_risk_long[28]; // 品种 多头手数
   double            s_risk_short[28]; // 品种 空头手数
   //--- 仓位获利   
   double            s_profits_long[28]; // 品种多头盈利
   double            s_profits_short[28];  // 品种空头盈利
   double            profits_total; // 总盈利
   double            lots_total; // 总手数
   //--- 不同风险货币索引
   int               c_index_long_max; // 多头手数最大的币种索引
   int               c_index_short_max; // 空头手数最大的币种索引
   int               c_index_lts_max;  // 多-空最大的货币索引
   int               c_index_lts_min;  // 空-多最大的货币索引

   double            c_lts_sort[8];  // 货币多头-空头的排序
   double            s_lts_sort[28];  // 品种多头-空头的排序
   int               c_lts_sort_index[8]; // 货币多头-空头的排序对应的索引
   int               s_lts_sort_index[28]; // 品种多头-空头的排序对应的索引

   int               num_sym_open;  // 已经开仓的品种数目
   bool              sym_is_open_long[28]; // 品种多头是否已经开仓
   bool              sym_is_open_short[28];  // 品种空头是否已经开仓
public:
                     CPositionAndRiskState(void);
                    ~CPositionAndRiskState(void){};
   void              RefreshState();
   void              RiskSort(); // 风险排序

   //---获取不同品种多空仓位的最早或最后的开仓价
   double            GetLastOpenLongPrice(int i_s);
   double            GetLastOpenShortPrice(int i_s);
   double            GetFirstOpenLongPrice(int i_s);
   double            GetFirstOpenShortPrice(int i_s);

   //---获取不同品种最早或最晚的开仓时间
   datetime          GetLastOpenLongTime(int i_s);
   datetime          GetLastOpenShortTime(int i_s);
   datetime          GetFirstOpenLongTime(int i_s);
   datetime          GetFirstOpenShortTime(int i_s);

   //---获取仓位号和级别
   long              LongPositionIdAt(int i_s,int i_p) {return long_pos_id[i_s].At(i_p);};
   long              ShortPositionIdAt(int i_s,int i_p) {return short_pos_id[i_s].At(i_p);};
   long              LongPositionLevelAt(int i_s,int i_p) {return long_pos_level[i_s].At(i_p);};
   long              ShortPositionLevelAt(int i_s,int i_p) {return short_pos_level[i_s].At(i_p);};
   int               LongPosTotalAt(int i_s) {return long_pos_id[i_s].Total();};
   int               ShortPosTotalAt(int i_s) {return short_pos_id[i_s].Total();};
   int               LastLongLevelAt(int i_s) {return long_pos_level[i_s].Total()==0?0:long_pos_level[i_s].At(long_pos_level[i_s].Total()-1);};
   int               LastShortLevelAt(int i_s) {return short_pos_level[i_s].Total()==0?0:short_pos_level[i_s].At(short_pos_level[i_s].Total()-1);};

   //--- 仓位添加或删除操作
   void              AddLongPositionIdAt(int i_s, long pos_id)   {long_pos_id[i_s].Add(pos_id);};
   void              AddShortPositionIdAt(int i_s, long pos_id)  {short_pos_id[i_s].Add(pos_id);};
   void              AddLongPositionLevelAt(int i_s,int level) {long_pos_level[i_s].Add(level);};
   void              AddShortPositionLevelAt(int i_s,int level) {short_pos_level[i_s].Add(level);};

   void              DeleteLongPositionAt(int i_s);
   void              DeleteShortPositionAt(int i_s);
   void              DeleteLongPositionAt(int i_s,int i_pos);
   void              DeleteShortPositionAt(int i_s,int i_pos);
   void              DeleteLongPositionAt(int i_s,const CArrayInt &i_pos_arr);
   void              DeleteShortPositionAt(int i_s,const CArrayInt &i_pos_arr);

   //--- 获取分级仓位的相关信息
   void              GetPartialLongPosition(int i_s,CArrayInt &i_pos_arr,double &p_total,double &l_total);
   void              GetPartialShortPosition(int i_s,CArrayInt &i_pos_arr,double &p_total,double &l_total);

   //--- 获得币种/品种 多头/空头风险                    
   double               GetCurrencyLongRiskAt(int index) {return c_risk_long[index];};
   double               GetCurrencyShortRiskAt(int index){return c_risk_short[index];};
   double               GetCurrencyDeltaRiskAt(int index){return c_risk_long[index]-c_risk_short[index];};
   double               GetSymbolLongRiskAt(int index){return s_risk_long[index];};
   double               GetSymbolShortRiskAt(int index){return s_risk_short[index];};
   double               GetSymbolDeltaRiskAt(int index){return s_risk_long[index]-s_risk_short[index];};
   double               GetSymbolLeftCurrencyRisk(int index){return GetCurrencyDeltaRiskAt(index_s2c_left[index]);};
   double               GetSymbolRightCurrencyRisk(int index){return GetCurrencyDeltaRiskAt(index_s2c_right[index]);};
   
   double               GetMaxLongCurrencyRisk(){return c_risk_long[c_index_long_max];};
   double               GetMaxShortCurrencyRisk(){return c_risk_short[c_index_short_max];};
   double               GetCurrencyDeltaRiskMax(){return  MathMax(MathAbs(c_lts_sort[0]),MathAbs(c_lts_sort[7]));};
   double               GetMaxRiskChangeAfterCloseSymbolAt(int index);

   int                  GetSymbolOpenNum(){return num_sym_open;};
   //--- 获取获利信息
   double               GetTotalProfits(){return profits_total;};
   double               GetTotalProfitsPerLots(){return lots_total==0?0:profits_total/lots_total;};
   double               GetSymbolProfitsAt(int index){return s_profits_long[index]+s_profits_short[index];};
   double               GetSymbolProfitsPerLotsAt(int index){return s_risk_long[index]+s_risk_short[index]==0?0:(s_profits_long[index]+s_profits_short[index])/(s_risk_long[index]+s_risk_short[index]);};
   double               GetSymbolLongProfitsAt(int index){return s_profits_long[index];};
   double               GetSymbolShortProfitsAt(int index){return s_profits_short[index];};
   double               GetSymbolLongProfitsAt(int i_s, int i_pos){return profits_long[i_s].At(i_pos);};
   double               GetSymbolShortProfitsAt(int i_s,int i_pos){return profits_short[i_s].At(i_pos);};
   //---获取品种手数
   double            GetSymbolLongLotsAt(int i_s, int i_pos){return lots_long[i_s].At(i_pos);};
   double            GetSymbolShortLotsAt(int i_s,int i_pos){return lots_short[i_s].At(i_pos);};
   double            GetSymbolAllLongFirstShortProfitsAt(int index);
   double            GetSymbolAllShortFirstLongProfitsAt(int index);
   double            GetSymbolAllLongFirstShortProfitsPerLotsAt(int index);
   double            GetSymbolAllShortFirstLongProfitsPerLotsAt(int index);
   //---
   int                  GetIndexCurrencyLongMax(){return c_index_long_max;};
   int                  GetIndexCurrencyShortMax(){return c_index_short_max;};
   int                  GetIndexCurrencyDeltaMax(){return c_index_lts_max;};
   int                  GetIndexCurrencyDeltaMin(){return c_index_lts_min;};
   int                  GetIndexCurrencyRiskSortAt(int index){return c_lts_sort_index[index];};
   //---
   bool                 IsSymbolOpenLong(int index){return sym_is_open_long[index];};
   bool                 IsSymbolOpenShort(int index){return sym_is_open_short[index];};
   bool                 IsSymbolWorstCase(int index);
   bool                 IsSymbolLongRiskCalByCurrency(int index); // 通过币种的多空值来判断品种是否有多头风险
   bool                 IsSymbolShortRiskCalByCurrency(int index); // 通过币种的多空值来判断品种是否有空头风险
   RiskSymbolToCurrency GetRiskTypeSTC(int index); //品种对的仓位对两个币种来说是否都是不利的
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPositionAndRiskState::CPositionAndRiskState(void)
  {
//    初始化币种序号和品种序号的对应关系
   int index;
   for(int i=0;i<7;i++)
     {
      for(int j=i+1;j<8;j++)
        {
         index=i*(15-i)/2+j-i-1;
         index_s2c_left[index]=i;
         index_s2c_right[index]=j;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionAndRiskState::RefreshState()
  {
//   计算每个品种的多空手数，计算每个币种的多空手数，计算每个品种的盈利，计算所有品种的盈利
   ArrayInitialize(c_risk_long,0);
   ArrayInitialize(c_risk_short,0);
   ArrayInitialize(s_risk_long,0);
   ArrayInitialize(s_risk_short,0);
   ArrayInitialize(s_profits_long,0);
   ArrayInitialize(s_profits_short,0);
   profits_total=0;
   lots_total=0;
   num_sym_open=0;
   ArrayInitialize(sym_is_open_long,false);
   ArrayInitialize(sym_is_open_short,false);
   for(int index_sym=0;index_sym<28;index_sym++)
     {
      profits_long[index_sym].Clear();
      profits_short[index_sym].Clear();
      lots_long[index_sym].Clear();
      lots_short[index_sym].Clear();
      // 遍历品种的多头仓位信息，统计信息
      for(int index_pid=0;index_pid<long_pos_id[index_sym].Total();index_pid++)
        {
         PositionSelectByTicket(long_pos_id[index_sym].At(index_pid));
         s_risk_long[index_sym]+=PositionGetDouble(POSITION_VOLUME);   // 品种多头手数累加
         c_risk_long[index_s2c_left[index_sym]]+=PositionGetDouble(POSITION_VOLUME);  // 品种对应的前面币种多头手数累加
         c_risk_short[index_s2c_right[index_sym]]+=PositionGetDouble(POSITION_VOLUME);  // 品种对应的后面币种空头手数累加
         lots_long[index_sym].Add(PositionGetDouble(POSITION_VOLUME));
         lots_total+=PositionGetDouble(POSITION_VOLUME);
         profits_total+=PositionGetDouble(POSITION_PROFIT);
         profits_long[index_sym].Add(PositionGetDouble(POSITION_PROFIT));
         s_profits_long[index_sym]+=PositionGetDouble(POSITION_PROFIT);
        }
      // 遍历品种空头仓位信息，统计信息
      for(int index_pid=0;index_pid<short_pos_id[index_sym].Total();index_pid++)
        {
         PositionSelectByTicket(short_pos_id[index_sym].At(index_pid));
         s_risk_short[index_sym]+=PositionGetDouble(POSITION_VOLUME);   // 品种空头手数累加
         c_risk_short[index_s2c_left[index_sym]]+=PositionGetDouble(POSITION_VOLUME);  // 对应左边的货币空头累加
         c_risk_long[index_s2c_right[index_sym]]+=PositionGetDouble(POSITION_VOLUME);  // 对应右边的货币多头累加
         lots_total+=PositionGetDouble(POSITION_VOLUME);
         lots_short[index_sym].Add(PositionGetDouble(POSITION_VOLUME));
         profits_total+=PositionGetDouble(POSITION_PROFIT);
         profits_short[index_sym].Add(PositionGetDouble(POSITION_PROFIT));
         s_profits_short[index_sym]+=PositionGetDouble(POSITION_PROFIT);
        }

      if(long_pos_id[index_sym].Total()>0) sym_is_open_long[index_sym]=true;
      if(short_pos_id[index_sym].Total()>0) sym_is_open_short[index_sym]=true;
      if(long_pos_id[index_sym].Total()!=0 || short_pos_id[index_sym].Total()!=0) num_sym_open++;
     }
   RiskSort();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionAndRiskState::RiskSort(void)
  {
   c_index_long_max=0;
   c_index_short_max=0;
   c_index_lts_max=0;
   c_index_lts_min=0;
   for(int ic=1;ic<8;ic++)
     {
      if(c_risk_long[ic]>c_risk_long[c_index_long_max]) c_index_long_max=ic;
      if(c_risk_short[ic]>c_risk_short[c_index_short_max]) c_index_short_max=ic;;
      if(c_risk_long[ic]-c_risk_short[ic]>c_risk_long[c_index_lts_max]-c_risk_short[c_index_lts_max]) c_index_lts_max=ic;
      if(c_risk_long[ic]-c_risk_short[ic]<c_risk_long[c_index_lts_min]-c_risk_short[c_index_lts_min]) c_index_lts_min=ic;
     }
//--- 对货币的风险进行排序由小到大short->long      
   for(int i=0;i<8;i++)
     {
      c_lts_sort[i]=c_risk_long[i]-c_risk_short[i];
      c_lts_sort_index[i]=i;
     }
   int tmp_index;
   double tmp_lts;
   for(int i=0;i<7;i++)
     {
      for(int j=7;j>i;j--)
        {
         if(c_lts_sort[j-1]>c_lts_sort[j])
           {
            tmp_lts=c_lts_sort[j-1];
            c_lts_sort[j-1]=c_lts_sort[j];
            c_lts_sort[j]=tmp_lts;
            tmp_index=c_lts_sort_index[j-1];
            c_lts_sort_index[j-1]=c_lts_sort_index[j];
            c_lts_sort_index[j]=tmp_index;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPositionAndRiskState::GetMaxRiskChangeAfterCloseSymbolAt(int index)
  {
   double c_left_risk=GetCurrencyDeltaRiskAt(index_s2c_left[index]);
   double c_right_risk=GetCurrencyDeltaRiskAt(index_s2c_right[index]);
   double s_delta=GetSymbolDeltaRiskAt(index);
   double before_risk=MathMax(MathAbs(c_left_risk),MathAbs(c_right_risk));
   double after_risk=MathMax(MathAbs(c_left_risk-s_delta),MathAbs(c_right_risk+s_delta));
   return after_risk-before_risk;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RiskSymbolToCurrency CPositionAndRiskState::GetRiskTypeSTC(int index)
  {
   double delta_risk_s=GetSymbolDeltaRiskAt(index);
   double delta_risk_c_left=GetCurrencyDeltaRiskAt(index_s2c_left[index]);
   double delta_risk_c_right=GetCurrencyDeltaRiskAt(index_s2c_right[index]);

   if(delta_risk_s>0&&delta_risk_c_left>0&&delta_risk_c_right<0) return ENUM_RISKSTC_DOUBLE_RISK;
   if(delta_risk_s<0&&delta_risk_c_left<0&&delta_risk_c_right>0) return ENUM_RISKSTC_DOUBLE_RISK;
   if(delta_risk_s>0&&delta_risk_c_left<0&&delta_risk_c_right>0) return ENUM_RISKSTC_DOUBLE_HEDGE;
   if(delta_risk_s<0&&delta_risk_c_left>0&&delta_risk_c_right<0) return ENUM_RISKSTC_DOUBLE_HEDGE;
   
   if(MathAbs(delta_risk_c_left)>MathAbs(delta_risk_c_right))
     {
      if(delta_risk_s>0&&delta_risk_c_left>0) return ENUM_RISKSTC_ONE_RISK;
      if(delta_risk_s<0&&delta_risk_c_left<0) return ENUM_RISKSTC_ONE_RISK;
     }
   else
     {
      if(delta_risk_s>0&&delta_risk_c_right<0) return ENUM_RISKSTC_ONE_RISK;
      if(delta_risk_s<0&&delta_risk_c_right>0) return ENUM_RISKSTC_ONE_RISK;
     }
   return ENUM_RISKSTC_ONE_HEDGE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPositionAndRiskState::GetSymbolAllLongFirstShortProfitsAt(int index)
  {
   if(profits_short[index].Total()==0) return GetSymbolLongProfitsAt(index);
   else return GetSymbolLongProfitsAt(index)+profits_short[index].At(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPositionAndRiskState::GetSymbolAllShortFirstLongProfitsAt(int index)
  {
   if(profits_long[index].Total()==0) return GetSymbolShortProfitsAt(index);
   else return GetSymbolShortProfitsAt(index)+profits_long[index].At(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPositionAndRiskState::GetSymbolAllLongFirstShortProfitsPerLotsAt(int index)
  {
   double sum_l=0;
   double sum_p=0;
   if(IsSymbolOpenLong(index))
     {
      sum_l+=s_risk_long[index];
      sum_p+=s_profits_long[index];
     }
   if(IsSymbolOpenShort(index))
     {
      sum_l+=lots_short[index].At(0);
      sum_p+=profits_short[index].At(0);
     }
   return sum_l==0?0:sum_p/sum_l;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPositionAndRiskState::GetSymbolAllShortFirstLongProfitsPerLotsAt(int index)
  {
   double sum_l=0;
   double sum_p=0;
   if(IsSymbolOpenShort(index))
     {
      sum_l+=s_risk_short[index];
      sum_p+=s_profits_short[index];
     }
   if(IsSymbolOpenLong(index))
     {
      sum_l+=lots_long[index].At(0);
      sum_p+=profits_long[index].At(0);
     }
   return sum_l==0?0:sum_p/sum_l;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPositionAndRiskState::GetLastOpenLongPrice(int i_s)
  {
   if(IsSymbolOpenLong(i_s))
     {
      PositionSelectByTicket(long_pos_id[i_s].At(long_pos_id[i_s].Total()-1));
      return PositionGetDouble(POSITION_PRICE_OPEN);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPositionAndRiskState::GetLastOpenShortPrice(int i_s)
  {
   if(IsSymbolOpenShort(i_s))
     {
      PositionSelectByTicket(short_pos_id[i_s].At(short_pos_id[i_s].Total()-1));
      return PositionGetDouble(POSITION_PRICE_OPEN);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPositionAndRiskState::GetFirstOpenLongPrice(int i_s)
  {
   if(IsSymbolOpenLong(i_s))
     {
      PositionSelectByTicket(long_pos_id[i_s].At(0));
      return PositionGetDouble(POSITION_PRICE_OPEN);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPositionAndRiskState::GetFirstOpenShortPrice(int i_s)
  {
   if(IsSymbolOpenShort(i_s))
     {
      PositionSelectByTicket(short_pos_id[i_s].At(0));
      return PositionGetDouble(POSITION_PRICE_OPEN);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CPositionAndRiskState::GetLastOpenLongTime(int i_s)
  {
   if(IsSymbolOpenLong(i_s))
     {
      PositionSelectByTicket(long_pos_id[i_s].At(long_pos_id[i_s].Total()-1));
      return datetime(PositionGetInteger(POSITION_TIME));
     }
   return datetime(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CPositionAndRiskState::GetLastOpenShortTime(int i_s)
  {
   if(IsSymbolOpenShort(i_s))
     {
      PositionSelectByTicket(short_pos_id[i_s].At(short_pos_id[i_s].Total()-1));
      return datetime(PositionGetInteger(POSITION_TIME));
     }
   return datetime(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CPositionAndRiskState::GetFirstOpenLongTime(int i_s)
  {
   if(IsSymbolOpenLong(i_s))
     {
      PositionSelectByTicket(long_pos_id[i_s].At(0));
      return datetime(PositionGetInteger(POSITION_TIME));
     }
   return datetime(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CPositionAndRiskState::GetFirstOpenShortTime(int i_s)
  {
   if(IsSymbolOpenShort(i_s))
     {
      PositionSelectByTicket(short_pos_id[i_s].At(0));
      return datetime(PositionGetInteger(POSITION_TIME));
     }
   return datetime(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionAndRiskState::DeleteLongPositionAt(int i_s)
  {
   long_pos_id[i_s].Clear();
   long_pos_level[i_s].Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionAndRiskState::DeleteShortPositionAt(int i_s)
  {
   short_pos_id[i_s].Clear();
   short_pos_level[i_s].Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionAndRiskState::DeleteLongPositionAt(int i_s,int i_pos)
  {
   long_pos_id[i_s].Delete(i_pos);
   long_pos_level[i_s].Delete(i_pos);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionAndRiskState::DeleteShortPositionAt(int i_s,int i_pos)
  {
   short_pos_id[i_s].Delete(i_pos);
   short_pos_level[i_s].Delete(i_pos);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionAndRiskState::DeleteLongPositionAt(int i_s,const CArrayInt &i_pos_arr)
  {
   for(int i=i_pos_arr.Total()-1;i>=0;i--)
     {
      long_pos_id[i_s].Delete(i_pos_arr.At(i));
      long_pos_level[i_s].Delete(i_pos_arr.At(i));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionAndRiskState::DeleteShortPositionAt(int i_s,const CArrayInt &i_pos_arr)
  {
   for(int i=i_pos_arr.Total()-1;i>=0;i--)
     {
      short_pos_id[i_s].Delete(i_pos_arr.At(i));
      short_pos_level[i_s].Delete(i_pos_arr.At(i));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionAndRiskState::GetPartialLongPosition(int i_s,CArrayInt &i_pos_arr,double &p_total,double &l_total)
  {
   double temp_p=0;
   p_total=0;l_total=0;
   i_pos_arr.Clear();
   for(int i=0;i<long_pos_id[i_s].Total();i++)
     {
      PositionSelectByTicket(long_pos_id[i_s].At(i));
      temp_p=PositionGetDouble(POSITION_PROFIT);
      if(i==0 || temp_p>0)
        {
         l_total+=PositionGetDouble(POSITION_VOLUME);
         p_total+=temp_p;
         i_pos_arr.Add(i);
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPositionAndRiskState::GetPartialShortPosition(int i_s,CArrayInt &i_pos_arr,double &p_total,double &l_total)
  {
   double temp_p=0;
   p_total=0;l_total=0;
   i_pos_arr.Clear();
   for(int i=0;i<short_pos_id[i_s].Total();i++)
     {
      PositionSelectByTicket(short_pos_id[i_s].At(i));
      temp_p=PositionGetDouble(POSITION_PROFIT);
      if(i==0 || temp_p>0)
        {
         l_total+=PositionGetDouble(POSITION_VOLUME);
         p_total+=temp_p;
         i_pos_arr.Add(i);
        }
     }
  }
bool CPositionAndRiskState::IsSymbolWorstCase(int index)
   {
    if(s_risk_long[index]>s_risk_short[index])
      {
       if(index_s2c_left[index]==GetIndexCurrencyDeltaMax()&&index_s2c_right[index]==GetIndexCurrencyDeltaMin())
         return true;
      }
    else
      {
       if(index_s2c_right[index]==GetIndexCurrencyDeltaMax()&&index_s2c_left[index]==GetIndexCurrencyDeltaMin())
         return true;
      }
    return false;
   }
bool CPositionAndRiskState::IsSymbolLongRiskCalByCurrency(int index)
   {
    if(GetCurrencyDeltaRiskAt(index_s2c_left[index])>0&&GetCurrencyDeltaRiskAt(index_s2c_right[index])<0) return true;
    return false;
   }
bool CPositionAndRiskState::IsSymbolShortRiskCalByCurrency(int index)
   {
    if(GetCurrencyDeltaRiskAt(index_s2c_left[index])<0&&GetCurrencyDeltaRiskAt(index_s2c_right[index])>0) return true;
    return false;
   }
//+------------------------------------------------------------------+
