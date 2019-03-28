//+------------------------------------------------------------------+
//|                                                Test_Calendar.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
//   MqlCalendarCountry c;
//   MqlCalendarEvent e[];
//   for(int i=0;i<1000;i++)
//     {
//      if(!CalendarCountryById(i,c)) continue;
//      string infor="id:"+string(c.id)+",name:"+c.name+",code:"+c.code+",currency:"+c.currency+",currency_symbol:"+c.currency_symbol+",url_name:"+c.url_name;
//      Print(infor);
//      
//      CalendarEventByCountry(c.code,e);
//      Print("event:",ArraySize(e));
//     }
    GetEvents(); 
  }
void GetEvents()
   {
     //MqlCalendarEvent e_arr[],e;
     //CalendarEventByCurrency("USD",e_arr);
     //Print(ArraySize(e_arr));
     //for(int i=0;i<ArraySize(e_arr);i++)
     //  {
     //   e=e_arr[i];
     //   if(e.type==CALENDAR_TYPE_HOLIDAY) continue;
     //   if(!e.importance==CALENDAR_IMPORTANCE_HIGH) continue;
     //   string msg="id:"+e.id+",type:"+e.type+",sector:"+e.sector+",frequecy:"+e.frequency+",time_mode:"+e.time_mode+",c_id:"+e.country_id+",unit:"+e.unit+",import:"+e.importance+",multiplier:"+e.multiplier+",digits:"+e.digits+",url:"+e.source_url+",e_code:"+e.event_code+",e_name:"+e.name;
     //   Print(msg);
     //  }
      ulong c_id;
      MqlCalendarValue v[];
     CalendarValueLast(c_id,v);
     Print(c_id,",",ArraySize(v));
     for(int i=0;i<ArraySize(v);i++)
       {
        Print(v[i].event_id, ",",v[i].time,",",v[i].impact_type);
       }
   }
//+------------------------------------------------------------------+
