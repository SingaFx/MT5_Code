//+------------------------------------------------------------------+
//|                                         CombinePositionState.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCombinePositionState:public CObject
  {
private:
   CArrayLong        pos_ids;
   ENUM_POSITION_TYPE pos_type;
   double            pos_profits;
   double            pos_hold_time;//小时为单位
   double            pos_lots;

public:
                     CCombinePositionState(void);
                     CCombinePositionState(ENUM_POSITION_TYPE type_position){pos_type=type_position;};
                    ~CCombinePositionState(void){};
   void              AddPosID(long pos_id);
   void              RefreshPositionStates(void);
   double            Profits(){return pos_profits;};
   double            Holdtime(){return pos_hold_time;};
   double            Lots(){return pos_lots;};
   ENUM_POSITION_TYPE Type(){return pos_type;}
   CArrayLong       *PosTickets(){return &pos_ids;};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCombinePositionState::AddPosID(long pos_id)
   {
    pos_ids.Add(pos_id);
    PositionSelectByTicket(pos_id);
    pos_lots+=PositionGetDouble(POSITION_VOLUME);
   }
void CCombinePositionState::RefreshPositionStates(void)
  {
   pos_profits=0;
   pos_hold_time=0;
   for(int i=0;i<pos_ids.Total();i++)
     {
      PositionSelectByTicket(pos_ids.At(i));
      pos_profits+=PositionGetDouble(POSITION_PROFIT);
      pos_hold_time=MathMax((TimeCurrent()-PositionGetInteger(POSITION_TIME))/60/60,pos_hold_time);
     }
  }
//+------------------------------------------------------------------+
