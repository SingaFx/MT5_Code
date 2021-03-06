//+------------------------------------------------------------------+
//|                                                         Tab2.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Program.mqh"


bool CProgram::CreateCalendarTab2(const int x_gap,const int y_gap)
   {
      int row1_y_gap=y_gap;
      int row2_y_gap=y_gap+30;
      int row3_y_gap=y_gap+60;
      int col1_x_gap=x_gap;
      int col2_x_gap=x_gap+110;
      int col3_x_gap=x_gap+220;
      int col4_x_gap=x_gap+330;
      int col5_x_gap=x_gap+440;
      int col_adjust=100;
      
      m_button_reset.MainPointer(m_tabs1);
      m_tabs1.AddToElementsArray(1,m_button_reset);
      m_button_reset.XSize(70);
      
      if(!m_button_reset.CreateButton("ReSet",col1_x_gap,row1_y_gap))
         return(false);
   //--- Add the object to the common array of object groups
      CWndContainer::AddToElementsArray(0,m_button_reset);
      
      label_long.MainPointer(m_tabs1);
      m_tabs1.AddToElementsArray(1,label_long);
      if(!label_long.CreateTextLabel("Long",col2_x_gap,row1_y_gap))
         return false;
      CWndContainer::AddToElementsArray(0,label_long);
      
      label_medium.MainPointer(m_tabs1);
      m_tabs1.AddToElementsArray(1,label_medium);
      if(!label_medium.CreateTextLabel("Medium",col3_x_gap,row1_y_gap))
         return false;
      CWndContainer::AddToElementsArray(0,label_medium);
      
      label_short.MainPointer(m_tabs1);
      m_tabs1.AddToElementsArray(1,label_short);
      if(!label_short.CreateTextLabel("Short",col4_x_gap,row1_y_gap))
         return false;
      CWndContainer::AddToElementsArray(0,label_short);
      
      label_user.MainPointer(m_tabs1);
      m_tabs1.AddToElementsArray(1,label_user);
      if(!label_user.CreateTextLabel("User",col5_x_gap,row1_y_gap))
         return false;
      CWndContainer::AddToElementsArray(0,label_user);
      
      label_from.MainPointer(m_tabs1);
      m_tabs1.AddToElementsArray(1,label_from);
      if(!label_from.CreateTextLabel("from",col1_x_gap,row2_y_gap))
         return false;
      CWndContainer::AddToElementsArray(0,label_from);
      
      label_to.MainPointer(m_tabs1);
      m_tabs1.AddToElementsArray(1,label_to);
      if(!label_to.CreateTextLabel("to",col1_x_gap,row3_y_gap))
         return false;
      CWndContainer::AddToElementsArray(0,label_to);
      
      m_drop_calendar_long_from.MainPointer(m_tabs1);
      m_drop_calendar_long_to.MainPointer(m_tabs1);
      m_drop_calendar_short_from.MainPointer(m_tabs1);
      m_drop_calendar_short_to.MainPointer(m_tabs1);
      m_drop_calendar_middle_from.MainPointer(m_tabs1);
      m_drop_calendar_middle_to.MainPointer(m_tabs1);
      m_drop_calendar_user_from.MainPointer(m_tabs1);
      m_drop_calendar_user_to.MainPointer(m_tabs1);

      m_tabs1.AddToElementsArray(1,m_drop_calendar_long_from);
      m_tabs1.AddToElementsArray(1,m_drop_calendar_long_to);
      m_tabs1.AddToElementsArray(1,m_drop_calendar_short_from);
      m_tabs1.AddToElementsArray(1,m_drop_calendar_short_to);
      m_tabs1.AddToElementsArray(1,m_drop_calendar_middle_from);
      m_tabs1.AddToElementsArray(1,m_drop_calendar_middle_to);
      m_tabs1.AddToElementsArray(1,m_drop_calendar_user_from);
      m_tabs1.AddToElementsArray(1,m_drop_calendar_user_to);
      
      if(!m_drop_calendar_long_from.CreateDropCalendar("",col2_x_gap+col_adjust,row2_y_gap))
         return false;
      CWndContainer::AddToElementsArray(0,m_drop_calendar_long_from);
      if(!m_drop_calendar_long_to.CreateDropCalendar("",col2_x_gap+col_adjust,row3_y_gap))
         return false;
      CWndContainer::AddToElementsArray(0,m_drop_calendar_long_to);
      if(!m_drop_calendar_short_from.CreateDropCalendar("",col3_x_gap+col_adjust,row2_y_gap))
         return false;
       CWndContainer::AddToElementsArray(0,m_drop_calendar_middle_from);
      if(!m_drop_calendar_short_to.CreateDropCalendar("",col3_x_gap+col_adjust,row3_y_gap))
         return false;
       CWndContainer::AddToElementsArray(0,m_drop_calendar_middle_to);
      if(!m_drop_calendar_middle_from.CreateDropCalendar("",col4_x_gap+col_adjust,row2_y_gap))
         return false;
       CWndContainer::AddToElementsArray(0,m_drop_calendar_short_from);
      if(!m_drop_calendar_middle_to.CreateDropCalendar("",col4_x_gap+col_adjust,row3_y_gap))
         return false;
      CWndContainer::AddToElementsArray(0,m_drop_calendar_short_to);
      
      if(!m_drop_calendar_user_from.CreateDropCalendar("",col5_x_gap+col_adjust,row2_y_gap))
         return false;
      CWndContainer::AddToElementsArray(0,m_drop_calendar_user_from);
      if(!m_drop_calendar_user_to.CreateDropCalendar("",col5_x_gap+col_adjust,row3_y_gap))
         return false;     
      //m_drop_calendar_from.SelectedDate(D'2017.01.01');  
      CWndContainer::AddToElementsArray(0,m_drop_calendar_user_to);
      return true;
   }

bool CProgram::CreateTableResult(const int x_gap,const int y_gap)
   {
      m_table_result.MainPointer(m_tabs1);
      m_tabs1.AddToElementsArray(1,m_table_result);
      //m_table_result.AutoXResizeMode(true);
      //m_table_result.AutoYResizeMode(true);
      //m_table_result.AutoXResizeRightOffset(10);
      //m_table_result.AutoYResizeBottomOffset(10);
      m_table_result.TableSize(8,5);
      m_table_result.CellYSize(50);
      m_table_result.SetValue(0,0,"Result");
      m_table_result.SetValue(1,1,"GBP");

  
      if(!m_table_result.CreateTable(x_gap,y_gap))
         return false;
      CWndContainer::AddToElementsArray(0,m_table_result);  
       return true; 
   }