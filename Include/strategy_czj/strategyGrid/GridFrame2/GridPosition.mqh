//+------------------------------------------------------------------+
//|                                                 GridPosition.mqh |
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
class CGridPositionOneSymbol
  {
private:
   CArrayLong        pid_long;
   CArrayLong        pid_short;
   CArrayInt         plevel_long;
   CArrayInt         plevel_short;

public:
                     CGridPositionOneSymbol(void){};
                    ~CGridPositionOneSymbol(void){};
   //---
   void              Refresh();
   //---
   int               TotalLong(){return pid_long.Total();};
   int               TotalShort(){return pid_short.Total();};
   int               LastLongLevel(){return plevel_long.At(plevel_long.Total()-1);};
   int               LastShortLevel(){return plevel_short.At(plevel_short.Total()-1);};
   int               FirstLongLevel(){return plevel_long.At(0);};
   int               FirstShortLevel(){return plevel_short.At(0);};

   double            TotalLongLots();
   double            TotalShortLots();
   double            TotalLongProfits();
   double            TotalShortProfits();
   
   double            LongProfitsAt(int index);
   double            ShortProfitsAt(int index);
   double            LongLotsAt(int index);
   double            ShortLotsAt(int index);
   
   double            LastLongPrice();
   double            LastShortPrice();
   long              LastLongTime();
   long              LastShortTime();
   long              LongPosIdAt(int index){return pid_long.At(index);};
   long              ShortPosIdAt(int index){return pid_short.At(index);};

   double            DeltaHoursLong(int i_begin,int i_end);
   double            DeltaHoursShort(int i_begin,int i_end);
   double            DeltaHoursLong();
   double            DeltaHoursShort();
   

   //--- 获取分级仓位的相关信息
   void              GetPartialLongPosition(CArrayInt &i_pos_arr,double &p_total,double &l_total);
   void              GetPartialShortPosition(CArrayInt &i_pos_arr,double &p_total,double &l_total);
   //---
   void              AddLongPosId(long pid,int level);
   void              AddShortPosId(long pid,int level);
   void              DelLongPosId(int index);
   void              DelShortPosId(int index);
   void              DelLongPosId(CArrayInt &i_pos_arr);
   void              DelShortPosId(CArrayInt &i_pos_arr);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPositionOneSymbol::Refresh(void)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridPositionOneSymbol::LastLongPrice(void)
  {
   PositionSelectByTicket(pid_long.At(TotalLong()-1));
   return PositionGetDouble(POSITION_PRICE_OPEN);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridPositionOneSymbol::LastShortPrice(void)
  {
   PositionSelectByTicket(pid_short.At(TotalShort()-1));
   return PositionGetDouble(POSITION_PRICE_OPEN);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridPositionOneSymbol::TotalLongLots(void)
  {
   double l=0;
   for(int i=0;i<pid_long.Total();i++)
     {
      PositionSelectByTicket(pid_long.At(i));
      l+=PositionGetDouble(POSITION_VOLUME);
     }
   return l;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridPositionOneSymbol::TotalShortLots(void)
  {
   double l=0;
   for(int i=0;i<pid_short.Total();i++)
     {
      PositionSelectByTicket(pid_short.At(i));
      l+=PositionGetDouble(POSITION_VOLUME);
     }
   return l;
  }
double CGridPositionOneSymbol::LongLotsAt(int index)
   {
    PositionSelectByTicket(pid_long.At(index));
    return PositionGetDouble(POSITION_VOLUME);   
   }
double CGridPositionOneSymbol::ShortLotsAt(int index)
   {
    PositionSelectByTicket(pid_short.At(index));
    return PositionGetDouble(POSITION_VOLUME);  
   }
double CGridPositionOneSymbol::LongProfitsAt(int index)
   {
    PositionSelectByTicket(pid_long.At(index));
    return PositionGetDouble(POSITION_PROFIT);
   }
double CGridPositionOneSymbol::ShortProfitsAt(int index)
   {
    PositionSelectByTicket(pid_short.At(index));
    return PositionGetDouble(POSITION_PROFIT);
   }
double CGridPositionOneSymbol::TotalLongProfits(void)
   {
    double sum_p=0;
    for(int i=0;i<TotalLong();i++) sum_p+=LongProfitsAt(i);
    return sum_p;
   }
double CGridPositionOneSymbol::TotalShortProfits(void)
   {
    double sum_p=0;
    for(int i=0;i<TotalShort();i++) sum_p+=ShortProfitsAt(i);
    return sum_p;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPositionOneSymbol::AddLongPosId(long pid,int level)
  {
   pid_long.Add(pid);
   plevel_long.Add(level);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPositionOneSymbol::AddShortPosId(long pid,int level)
  {
   pid_short.Add(pid);
   plevel_short.Add(level);
  }
void CGridPositionOneSymbol::DelLongPosId(int index)
   {
      pid_long.Delete(index);
      plevel_long.Delete(index);
   }
void CGridPositionOneSymbol::DelShortPosId(int index)
   {
      pid_short.Delete(index);
      plevel_short.Delete(index);    
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPositionOneSymbol::DelLongPosId(CArrayInt &i_pos_arr)
  {
   for(int i=i_pos_arr.Total()-1;i>=0;i--)
     {
      pid_long.Delete(i_pos_arr.At(i));
      plevel_long.Delete(i_pos_arr.At(i));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPositionOneSymbol::DelShortPosId(CArrayInt &i_pos_arr)
  {
   for(int i=i_pos_arr.Total()-1;i>=0;i--)
     {
      pid_short.Delete(i_pos_arr.At(i));
      plevel_short.Delete(i_pos_arr.At(i));
     }
  }
long CGridPositionOneSymbol::LastLongTime(void)
   {
    PositionSelectByTicket(pid_long.At(TotalLong()-1));
    return PositionGetInteger(POSITION_TIME);
   }
long CGridPositionOneSymbol::LastShortTime(void)
   {
    PositionSelectByTicket(pid_short.At(TotalShort()-1));
    return PositionGetInteger(POSITION_TIME);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridPositionOneSymbol::DeltaHoursLong(int i_begin,int i_end)
  {
   long t_begin,t_end;
   PositionSelectByTicket(pid_long.At(i_begin));
   t_begin=PositionGetInteger(POSITION_TIME);
   PositionSelectByTicket(pid_long.At(i_end));
   t_end=PositionGetInteger(POSITION_TIME);
   return double(t_end-t_begin)/(60*60);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridPositionOneSymbol::DeltaHoursShort(int i_begin,int i_end)
  {
   long t_begin,t_end;
   PositionSelectByTicket(pid_short.At(i_begin));
   t_begin=PositionGetInteger(POSITION_TIME);
   PositionSelectByTicket(pid_short.At(i_end));
   t_end=PositionGetInteger(POSITION_TIME);
   return double(t_end-t_begin)/(60*60);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridPositionOneSymbol::DeltaHoursLong()
  {
   Print("DeltaHoursLong:",DeltaHoursLong(TotalLong()-2,TotalLong()-1));
   return DeltaHoursLong(TotalLong()-2,TotalLong()-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridPositionOneSymbol::DeltaHoursShort()
  {
   Print("DeltaHoursShort:",DeltaHoursShort(TotalShort()-2,TotalShort()-1));
   return DeltaHoursShort(TotalShort()-2,TotalShort()-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPositionOneSymbol::GetPartialLongPosition(CArrayInt &i_pos_arr,double &p_total,double &l_total)
  {
   double temp_p=0;
   p_total=0;l_total=0;
   i_pos_arr.Clear();
   for(int i=0;i<pid_long.Total();i++)
     {
      PositionSelectByTicket(pid_long.At(i));
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
void CGridPositionOneSymbol::GetPartialShortPosition(CArrayInt &i_pos_arr,double &p_total,double &l_total)
  {
   double temp_p=0;
   p_total=0;l_total=0;
   i_pos_arr.Clear();
   for(int i=0;i<pid_short.Total();i++)
     {
      PositionSelectByTicket(pid_short.At(i));
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
